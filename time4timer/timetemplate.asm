  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro

	.data
	.align 2
mytime:	.word 0x5957  # Starttiden
timstr:	.ascii "text more text lots of text\0"
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0,1000 # Set to 1000 accodring to instructions
	jal	delay
	nop
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

  # you can write your code for subroutine "hexasc" below this line
  #
hexasc:
	 # Ska & 0xf med a0 för att endast få 4 lsb
	add $t4, $a0, $0 	# takes in a3 as argument, copies it to temp (move better?)
	andi $t4, 0x0f   	# masking all but the first 4 bits of $t0 ($a3)
	addi $t1, $t4, 0x30 	# adding 0x30 to $t0 and storing the sum in $t1.
	bge $t4, 10, chars	# Branch Greater than or Equal to, if $t0, (before addition) is greater than 10 it is a char.
	add $v0, $t1, $0	# Copies $t1 into the return register $v0.
	jr $ra			# Return to where we came from.
	nop
	chars:			# If $t0/$a3 (first 4 bits) greater than or equal to 10 we branch here.
	addi $t2, $t1, 7	# 
	add $v0, $t2, $0
	jr $ra
	nop
	
delay: # $a2 input till func, t1 = i. 
	PUSH $ra
	# addi $a2, $0, 1000
	addi $t0, $a0, 0
while:
	ble $t0, $0, exit
	addi $t0, $t0, -1 # MCB fattar ej subi
	li $t1, 0
	j forLoop
	nop
forLoop: 
	bge $t1, 350, while
	addi $t1, $t1, 1
	j forLoop
	nop
	
 exit:
  	POP $ra
  	jr $ra
  	nop
  
time2string:
	PUSH $ra
	PUSH $a0
	
	andi $t1, $a1, 0xf000 # First digit 0000..... 1111 0000 0000 0000
	srl $a0, $t1, 12 
	jal hexasc
	nop
	move $t4, $v0
	POP $a0
	PUSH $t4
	
	
	PUSH $a0
	andi $t2, $a1, 0xf00 # First digit 0000..... 0000 1111 0000 0000
	srl $a0, $t2, 8
	jal hexasc
	nop
	move $t5, $v0
	POP $a0
	PUSH $t5
	#sll $t5, $v0, 12      # Ends up at 0000.... 0000 1111 0000 0000 0000 
	
	PUSH $a0
	andi $t3, $a1, 0xf0 # First digit 0000..... 0000 0000 1111 0000
	srl $a0, $t3, 4
	jal hexasc
	nop
	move $t6, $v0
	POP $a0
	PUSH $t6
	#sll $t6, $v0, 4      # Ends up at 0000.... 0000 0000 0000 1111 0000
	PUSH $a0
	andi $a0, $a1, 0xf # First digit 0000..... 0000 0000 0000 1111
	jal hexasc
	nop
	move $t7, $v0    # Ends up at 0000.... 0000 0000 0000 0000 1111
	POP $a0
	POP $t6
	POP $t5
	POP $t4
	
	andi $t9, $a1, 0xff
	beq $t9, $0, addX

	addi $t8, $0, 0x3a    # :

	
	sb $0, 5($a0)  # Setting nullbyte.
	sb $t4, 0($a0) # x0:00 
	sb $t5, 1($a0) # 0x:00
	sb $t8, 2($a0) # :
	sb $t6, 3($a0) # 00:x0
	sb $t7, 4($a0) # 00:0x

	
	POP $ra
	
	jr $ra
	nop

	addX:
	
	sb $0, 6($a0)  # Setting nullbyte.
	
	li $t9, 0x58
	sb $t9, 5($a0) # X
	
	sb $t4, 0($a0) # x0:00 
	sb $t5, 1($a0) # 0x:00
	sb $t8, 2($a0) # :
	sb $t6, 3($a0) # 00:x0
	sb $t7, 4($a0) # 00:0x

	
	POP $ra

	jr $ra
	nop
