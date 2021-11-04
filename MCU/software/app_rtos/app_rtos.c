#include <stdio.h>
#include "includes.h"
#include <string.h>

#include "altera_avalon_pio_regs.h" //access to PIO macros
#include <sys/alt_irq.h>            // access to the IRQ routines

#define TASK_STACKSIZE 1024 // Number of 32 bit words (e.g. 8192 bytes)
OS_STK task1_stk[TASK_STACKSIZE];
OS_STK task2_stk[TASK_STACKSIZE];

#define TASK1_PRIORITY 4
#define TASK2_PRIORITY 5

//Semaphore to protect the shared JTAG resource
OS_EVENT *shared_jtag_sem;
// synchronization semaphore
OS_EVENT *shared_key1_sem;

// global variable to hold the value of the edge capture register.
volatile int edge_capture;

static void handle_interrupts(void *context)
{
    // Cast context to edge_capture's type
    // Volatile to avoid compiler optimization
    // this will point to the edge_capture variable.
    volatile int *edge_capture_ptr = (volatile int *)context;
    //Read the edge capture register on the PIO and store the value
    //The value will be stored in the edge_capture variable and accessible
    //from other parts of the code.
    *edge_capture_ptr = IORD_ALTERA_AVALON_PIO_EDGE_CAP(PIO_IRQ_BASE);

    //Write to edge capture register to reset it
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_IRQ_BASE, 0);
    // // Read the edge capture register on the PIO and store the value
    // // The value will be stored in the edge_capture variable and accessible
    // // from other parts of the code.
    // *uart_status_ptr = IORD(UART_STATUS_BASE, 2);
    // // Write to edge capture register to reset it
    // IOWR(UART_STATUS_BASE, 2, 0);
    OSSemPost(shared_key1_sem);
}

/* This function is used to initializes and registers the interrupt handler. */
static void init_interrupt_pio()
{
    // Recast the edge_capture point to match the
    // alt_irq_register() function prototypo
    void *edge_capture_ptr = (void *)&edge_capture;

    // Enable a single interrupt input by writing a one to the corresponding interruptmask bit locations
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_IRQ_BASE, 0x1);

    // Reset the edge capture register
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_IRQ_BASE, 0);

    /* In order to keep the impact of interrupts on the execution of the main program to a minimum,
    it is important to keep interrupt routines short. If additional processing is necessary for a
    particular interrupt, it is better to do this outside of the ISR. E.g., checking the value
    of the edge_capture variable.*/

    alt_ic_isr_register(PIO_IRQ_IRQ_INTERRUPT_CONTROLLER_ID,
                        PIO_IRQ_IRQ, handle_interrupts, edge_capture_ptr, 0x0);
}

void task1(void *pdata)
{
    char text[] = "Hello from Task1\n";
    int i;
    alt_u8 error_code = OS_NO_ERR;
    while (1)
    {
        // Collect semaphore before writing to JTAG UART
        // wait for semaphore from interrupt handling routine before executing the taks
        OSSemPend(shared_key1_sem, 0, &error_code);

        // Collect semaphore before writing to JTAG UART
        OSSemPend(shared_jtag_sem, 0, &error_code);
        for (i = 0; i < strlen(text); i++)
        {
            putchar(text[i]);
        }
        // Release semaphore
        OSSemPost(shared_jtag_sem);
        OSSemPost(shared_key1_sem);
        //printf("Hello from task2\n");
        OSTimeDlyHMSM(0, 0, 1, 20);
    }
}

void task2(void *pdata)
{
    char text[] = "Thomas speaking!\n";
    int i;
    alt_u8 error_code = OS_NO_ERR;
    while (1)
    {
        // Collect semaphore before writing to JTAG UART
        OSSemPend(shared_jtag_sem, 0, &error_code);
        for (i = 0; i < strlen(text); i++)
        {
            putchar(text[i]);
        }
        // Release semaphore
        OSSemPost(shared_jtag_sem);
        //printf("Hello from task2\n");
        OSTimeDlyHMSM(0, 0, 1, 4);
    }
}

/* The main function creates two task and starts multi-tasking */
int main(void)
{

    //create JTAG semaphore and initialize to 1
    shared_jtag_sem = OSSemCreate(1);
    // create synchronization semaphore and initialize to 0
    shared_key1_sem = OSSemCreate(0);

    // initialize interrupt
    init_interrupt_pio();

    OSTaskCreateExt(task1,
                    NULL,
                    (void *)&task1_stk[TASK_STACKSIZE - 1],
                    TASK1_PRIORITY,
                    TASK1_PRIORITY,
                    task1_stk,
                    TASK_STACKSIZE,
                    NULL,
                    0);

    OSTaskCreateExt(task2,
                    NULL,
                    (void *)&task2_stk[TASK_STACKSIZE - 1],
                    TASK2_PRIORITY,
                    TASK2_PRIORITY,
                    task2_stk,
                    TASK_STACKSIZE,
                    NULL,
                    0);

    OSStart();
    return 0;
}
