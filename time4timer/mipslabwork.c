/* mipslabwork.c

   This file written 2015 by F Lundevall
   Updated 2017-04-21 by F Lundevall

   This file should be changed by YOU! So you must
   add comment(s) here with your name(s) and date(s):

   Updated 2023-01-30 by O Gertling
   Updated 2023-01-30 by W Redgård

   This file modified 2017-04-31 by Ture Teknolog

   For copyright and licensing, see file COPYING */

#include <stdint.h>  /* Declarations of uint_32 and the like */
#include <pic32mx.h> /* Declarations of system-specific addresses etc */
#include "mipslab.h" /* Declatations for these labs */

volatile int *trisegen = (volatile int *)0xbf886100;
volatile int *portegen = (volatile int *)0xbf886110;

int mytime = 0x5957;

char textstring[] = "text, more text, and even more text!";

/* Interrupt Service Routine */

void user_isr(void)
{
  return;
}

/* Lab-specific initialization goes here */
void labinit(void)
{
  timer();
  *trisegen = *trisegen & 0xffffff00; // Egen TRISE, sätter till output

  TRISD = TRISD | 0x00000fe0; // Sätter bit 11-5 som 1, dvs input.

  // void delay(int);
  // void time2string( char *, int );
  return;
}

void timer(void)
{
  T2CON = 0x70; // Pre-scale
  /*T2CON |= 0xC000;
  T2CON |= 0x4;*/
  TMR2 = 0;

  IEC(0) = (1 << 8);
  IPC(2) = 4;
  // enable_interrupt();

  PR2 = 31250;     // Sätter delayen korrekt (31250 * 256 = 8 000 000) Räknar med pre-scale
  T2CON |= 0x8000; // Starts the timer
}
int num = 0x000000;

/* This function is called repetitively from the main program */
int timeoutcount = 0;
void labwork(void)
{
  
  // delay( 1000 );
  int i = 0;

  if (IFS(0) & 0x100)
  {
    
    IFS(0) = 0; // Reset timeout flag.
    TMR2 = 0;  // Reset cause of timeout. DOES THE RASING OF THE FLAG RESET TMR2 ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?
    if(timeoutcount == 10)
    {
      timeoutcount = 0;
    time2string(textstring, mytime);
    display_string(3, textstring);
    display_update();
    tick(&mytime);
    
    if (num < 256)
    {
      *portegen += 1;
    }
    else
    {
      //*portegen = *portegen & 0xffffff00;
      num = 0;
    }
    }
    timeoutcount++;
  }

  if (getbtns())
  {
    if (getbtns() & 0x1)
    {
      mytime = (mytime & 0xff0f) | getsw() << 4;
    }
    if (getbtns() & 0x2)
    {
      mytime = (mytime & 0xf0ff) | getsw() << 8;
    }
    if (getbtns() & 0x4)
    {
      mytime = (mytime & 0x0fff) | getsw() << 12;
    }
  }

  /*
   if(BTN2 | BTN3 | BTN4)
    {
      mytime = (SW1<<3) | (SW2<<2) | (SW3<<1) | SW4;
    }
  */
  display_image(96, icon);
}
