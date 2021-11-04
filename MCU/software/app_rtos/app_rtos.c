#include "includes.h"
#include <stdio.h> // encounter error message "incompatible implicit declaration of built-in function 'printf'"
#include <string.h> // the strlen function requires the string.h

/* Definition of Task stacks */
#define TASK_STACKSIZE 2048  // Number of 32 bit words (e.g. 8192 bytes)
OS_STK task1_stk[TASK_STACKSIZE];
OS_STK task2_stk[TASK_STACKSIZE];

#define TASK1_PRIORITY 4
#define TASK2_PRIORITY 5


void task1(void* pdata)
{
    char text[] = "###task1\n";
    int i;
    while(1)
    {
        for (i = 0; i < strlen(text); i++){
        putchar(text[i]);
        }
        // printf("Hello from task1\n");
        OSTimeDlyHMSM(0, 0, 3, 0); // (hours, minutes, seconds, milliseconds)
    }
}

void task2(void* pdata)
{
    char text[] = "!!!!@@@task2\n";
    int i;
    while(1)
    {
        for ( i = 0; i < strlen(text); i++){
            putchar(text[i]);
        }
        // printf("@@@This is task2@@@\n");
        OSTimeDlyHMSM(0, 0, 3, 0); // (hours, minutes, seconds, milliseconds)
    }
}

/* The main function creates two task and starts multi-tasking */
int main(void)
{   
    //Create the task
    OSTaskCreateExt(task1, //Pointer to task function
                NULL, // pointer to argument that is passed to task
                (void *)&task1_stk[TASK_STACKSIZE-1], // Pointer to top of task stack
                TASK1_PRIORITY, // Task priority
                TASK1_PRIORITY, // Task ID - same as priority
                task1_stk, // Pointer to bottom of task stack
                TASK_STACKSIZE, // Stacksize
                NULL, // Pointer to user supplied memory
                0); // Various task options

    //Create the task
    OSTaskCreateExt(task2, //Pointer to task function
                NULL, // pointer to argument that is passed to task
                (void *)&task2_stk[TASK_STACKSIZE-1], // Pointer to top of task stack
                TASK2_PRIORITY, // Task priority
                TASK2_PRIORITY, // Task ID - same as priority
                task2_stk, // Pointer to bottom of task stack
                TASK_STACKSIZE, // Stacksize
                NULL, // Pointer to user supplied memory
                0); // Various task options

    //Start the multi-tasking system.
    OSStart();
    return 0; 
}

