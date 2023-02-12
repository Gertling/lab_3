#include <stdint.h>   /* Declarations of uint_32 and the like */
#include <pic32mx.h>  /* Declarations of system-specific addresses etc */
#include "mipslab.h"  /* Declatations for these labs */

/*
int getsw(void)
{
    int ret = 0;
    ret = PORTD | ret;
    
    ret = ((PORTD & 0x00000780) >> 7);


    return ret;
}

int getbtns(void)
{
    int ret = 0;
    ret = PORTD | ret;

    ret = ((PORTD & 0x00000070) >> 4);

    return ret;
}
*/

int getsw(void)
{
    return ((PORTD & 0x00000f00) >> 8);
}

int getbtns(void)
{
    int a = ((PORTD & 0x000000e0) >> 5);
    
    return (a);
}
