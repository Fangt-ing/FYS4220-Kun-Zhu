#include <stdio.h>
#include "system.h"                 //access Nios II system info
#include "io.h"                     //access to IORD and IORW
#include "unistd.h"                 //access to usleep
#include "altera_avalon_pio_regs.h" //access to PIO macros
#include <sys/alt_irq.h>            // access to the IRQ routines
#include "includes.h"
#include <string.h>
// spi moduel
#include "alt_types.h"
#include "altera_avalon_spi.h"

#define TASK_STACKSIZE 2024 // Number of 32 bit words (e.g. 8192 bytes)
OS_STK uart_task_stk[TASK_STACKSIZE];
OS_STK acc_task_stk[TASK_STACKSIZE];

#define uart_task_priority 4
#define acc_task_priority 5

// semaphore to protect the shared UART resource
OS_EVENT *tx_complete_sem;
// synchronization semaphore
OS_EVENT *adxl345_sem;
// semaphore/ message for mailbox
OS_EVENT *msg_box;

// global variable to hold the value of the edge capture register.
volatile int edge_capture;
volatile int uart_status;

/* This is the ISR which will be called when the system signals an interrupt. */
static void handle_interrupts(void *context)
{
    // Cast context to edge_capture's type
    // Volatile to avoid compiler optimization
    // this will point to the edge_capture variable.
    volatile int *edge_capture_ptr = (volatile int *)context;

    // Read the edge capture register on the PIO and store the value
    // The value will be stored in the edge_capture variable and accessible
    // from other parts of the code.
    *edge_capture_ptr = IORD_ALTERA_AVALON_PIO_EDGE_CAP(PIO_IRQ_BASE);

    // Write to edge capture register to reset it
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_IRQ_BASE, 0);

    // printf("edge capture! %x", (unsigned int) edge_capture);
    if ((edge_capture >> 2) & 0x1)
    { //KR: check for INT2 interrupt and post semaphore
        OSSemPost(adxl345_sem);
    }
    
}

static void handle_interrupt_uart(void *context)
{
    // Cast context to edge_capture's type
    // Volatile to avoid compiler optimization
    // this will point to the edge_capture variable.
    volatile int *uart_status_ptr = (volatile int *)context;

    // Read the edge capture register on the PIO and store the value
    // The value will be stored in the edge_capture variable and accessible
    // from other parts of the code.
    *uart_status_ptr = IORD(UART_BASIC_BASE, 2);
    // Write to edge capture register to reset it
    IOWR(UART_BASIC_BASE, 2, 0);

    if ((uart_status >> 4) & 0x1)
    { //KR: Check for tx complete IRQ and post semaphore.
        OSSemPost(tx_complete_sem);
    }
}

/* This function is used to initializes and registers the interrupt handler. */
static void init_interrupt_pio()
{
    // Recast the edge_capture point to match the
    // alt_irq_register() function prototypo
    void *edge_capture_ptr = (void *)&edge_capture;

    // Enable a single interrupt input by writing a one to the corresponding interruptmask bit locations
    // IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_IRQ_BASE, 0x1);
    // KR: You have now also connected two additional interrupts (INT1 and INT2) to the PIO modules. 
    // You therefore need to also enable two addition bits in the MASK register.
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_IRQ_BASE, 0x7);

    // Reset the edge capture register
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_IRQ_BASE, 0);

    // Register the interrupt handler in the system
    // The ID and PIO_IRQ number is available from the system.h file.
    alt_ic_isr_register(PIO_IRQ_IRQ_INTERRUPT_CONTROLLER_ID,
                        PIO_IRQ_IRQ, handle_interrupts, edge_capture_ptr, 0x0);

    /* In order to keep the impact of interrupts on the execution of the main program to a minimum,
    it is important to keep interrupt routines short. If additional processing is necessary for a
    particular interrupt, it is better to do this outside of the ISR. E.g., checking the value
    of the edge_capture variable.*/

    void *uart_status_ptr = (void *)&uart_status;
    alt_ic_isr_register(UART_BASIC_IRQ_INTERRUPT_CONTROLLER_ID,
                        UART_BASIC_IRQ, handle_interrupt_uart, uart_status_ptr, 0x0);
}

void uart_task(void *pdata)
{
    alt_u8 sample_counter; //KR: initalize to 0 and should be of type alt_u8 since this is the type that is stored in the data array.
    INT8U error_code = OS_NO_ERR;
    alt_u8 *data_ptr; // *msg_received; //KR: you are receiving a pointer to an alt_u8 and not an int.
    alt_u8 data[8] = {0xe2, 0, 0, 0, 0, 0, 0, 0};
    while (1)
    {
        //Get pointer to data from ADXL345
        data_ptr = (alt_u8*)OSMboxPend(msg_box, 0, &error_code); //KR: you are receiving a pointer to an alt_u8 and not an int.
        // Increase sample counter and add to second byte of array.
        sample_counter++;
        data[1] = sample_counter;
        // Looping through the 6 bytes and sending over the UART
        // will take some time. Copy data to local array to avoid overwriting from the accelerometer task.
        for (int i = 0; i < 6; i++)
        {
            data[i + 2] = *data_ptr;
            data_ptr++;
        }
        // Send bytes over UART and wait for TX complete semaphore for each byte transaction.
        for (int i = 0; i < 8; i++)
        {
            IOWR(UART_BASIC_BASE, 0, data[i]);
            //printf("This is uart:%d", data[i]);
            OSSemPend(tx_complete_sem, 0, &error_code);
        }
    }
}

void acc_task(void *pdata)
{
    INT8U error_code = OS_NO_ERR;
    // tx and rx data buffers
    alt_u8 spi_rx_data[8];
    alt_u8 spi_tx_data[8];

    // Configure SPI bit in DATA_FORMAT register ---------- 
    // from section 26: https://pages.github.uio.no/FYS4220/fys4220/project/project_nios2.html#spi-test
    spi_tx_data[0] = 0x00 | 0x31; // Single byte write (cmd bti + 1 data bit) + register address
    spi_tx_data[1] = 0x28;        // register data to write
    alt_avalon_spi_command(SPI_BASE, 0, 2, spi_tx_data, 0, spi_rx_data, 0);

    spi_tx_data[0] = 0x80; // address bit for spi protocol
    // reading the device ID
    alt_avalon_spi_command(SPI_BASE, 0, 1, spi_tx_data, 1, spi_rx_data, 0);
    // printf("Device ID read: %x\n", spi_rx_data[0]);

    spi_tx_data[0] = 0x2F; // address bits for INT_MAP
    spi_tx_data[1] = 0x80; // the data bits of INT_MAP
    alt_avalon_spi_command(SPI_BASE, 0, 2, spi_tx_data, 0, spi_rx_data, 0);

    spi_tx_data[0] = 0x2E; // address bits for INT_ENABLE
    spi_tx_data[1] = 0x80; // the data bits of INT_ENABLE
    alt_avalon_spi_command(SPI_BASE, 0, 2, spi_tx_data, 0, spi_rx_data, 0);

    spi_tx_data[0] = 0x2D; // address bits for power_ctrl
    spi_tx_data[1] = 0x08; // the data bits of power_ctrl
    alt_avalon_spi_command(SPI_BASE, 0, 2, spi_tx_data, 0, spi_rx_data, 0);

    spi_tx_data[0] = 0x80 | 0x30; // address bits for INT_SOURCE // KR: changed to correct address for INT SOURCE register
    spi_rx_data[0] = 0x08; // the data bits of INT_SOURCE
    alt_avalon_spi_command(SPI_BASE, 0, 1, spi_tx_data, 1, spi_rx_data, 0);
    // printf("INT SOURCE register read: %x\n\n", spi_rx_data[0]);

    // alt_avalon_spi_command(SPI_BASE,
    // 0, {always 0 as we are using have only 1 spi, and 0 slaves
    // 1, spi_tx_data, {the value to be write to the
    // 1, spi_rx_data, {the values to read}
    // 0);

    while (1)
    {
        spi_tx_data[0] = 0xc0 | 0x32; // address bits for DATAX0 KR: Here you have to set the mulitiple byte bit to read 6 consecutive data bytes
        OSSemPend(adxl345_sem, 0, &error_code);

        alt_avalon_spi_command(SPI_BASE, 0, 1, spi_tx_data, 6, spi_rx_data, 0);
        // printf("acc data: %x\n", (unsigned int)spi_rx_data);
        // *spi_tx_data++;
        error_code = OSMboxPost(msg_box, (void *)spi_rx_data); // post to mail box
        // printf("err : %d\n",error_code);
    }
}

/* The main function creates two task and starts multi-tasking */
int main(void)
{
    tx_complete_sem = OSSemCreate(0);
    // synchronization semaphore, initialize semaphore unavailable
    adxl345_sem = OSSemCreate(0);
    // semaphore/ message for mailbox

    msg_box = OSMboxCreate((void *)NULL);
    // create empty mail box

    // initialize interrupt, to handle semaphore
    init_interrupt_pio();

    OSTaskCreateExt(uart_task,
                    NULL,
                    (void *)&uart_task_stk[TASK_STACKSIZE - 1],
                    uart_task_priority,
                    uart_task_priority,
                    uart_task_stk,
                    TASK_STACKSIZE,
                    NULL,
                    0);

    OSTaskCreateExt(acc_task,
                    NULL,
                    (void *)&acc_task_stk[TASK_STACKSIZE - 1],
                    acc_task_priority,
                    acc_task_priority,
                    acc_task_stk,
                    TASK_STACKSIZE,
                    NULL,
                    0);

    OSStart();
    return 0;
}
