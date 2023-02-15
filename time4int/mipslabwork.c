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

int prime = 1234567;
int timeoutcount = 0;

volatile int *trisegen = (volatile int *)0xbf886100;
volatile int *portegen = (volatile int *)0xbf886110;

int mytime = 0x5957;

char textstring[] = "text, more text, and even more text!";

/* Interrupt Service Routine */

void user_isr(void)
{
  if(timeoutcount % 10 == 0)
  {
  time2string(textstring,mytime);
  display_string(3, textstring);
  display_update();
  tick(&mytime);
  }
  if (IFS(0) & 0x100) // If flag of timer 2 raised, reset flag. assignment 3e.
  {
  IFSCLR(0x100); // Code to reset flag
  }

}

/* Lab-specific initialization goes here */
void labinit(void)
{
  timer();
  *trisegen = *trisegen & 0xffffff00; // Egen TRISE, sätter till output

  TRISD = TRISD | 0x00000fe0; // Sätter bit 11-5 som 1, dvs input.

  //T2CON = 0x70;

  TMR2 = 0;

  IEC(0) = (1 << 8);
  IPC(2) = 4;
  // enable_interrupt();

  //PR2 = 31250;     // Sätter delayen korrekt (31250 * 256 = 8 000 000) 
  T2CON |= 0x8000; // Starts the timer

  // void delay(int);
  // void time2string( char *, int );
  return;
}

void timer(void)
{
  T2CON = 0x70;
  /*T2CON |= 0xC000;
  T2CON |= 0x4;*/
  TMR2 = 0;

  IEC(0) = (1 << 8);
  IPC(2) = 4;
  // enable_interrupt();

  PR2 = 31250;     // Sätter delayen korrekt (31250 * 256 = 8 000 000) 
  T2CON |= 0x8000; // Starts the timer
}
int num = 0x000000;

/* This function is called repetitively from the main program */
void labwork(void)
{
  prime = nextprime(prime);
  display_string(0, itoaconv(prime));
  display_update();

}
