  # labwork.S
  # Written 2015-2017 by F Lundevall
  # Skeleton file for IS1200/IS1500 lab 1.
  # The macros PUSH and POP are in the public domain.
  # Please add your own code at the end of the file.

  #
  # Please keep the two macros PUSH and POP unchanged
  #

.global delay # Måste det läggas till här eller i slutet av fil enligt instruktion? 
.global time2string # Måste det läggas till här eller i slutet av fil enligt instruktion? 
.global enable_interrupt

.macro	PUSH reg
	addi	$sp,$sp,-4
	sw	\reg,0($sp)
.endm

.macro	POP reg
	lw	\reg,0($sp)
	addi	$sp,$sp,4
.endm
  #
  # Please add your own code below this line
  #
enable_interrupt:
	
	ei 
	nop
	jr $ra
	nop

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
	bge $t1, 4350, while
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

	addi $t8, $0, 0x3a    # :

	sb $0, 6($a0)  # Setting nullbyte.

	sb $0, 5($a0)  # Setting nullbyte.
	sb $t4, 0($a0) # x0:00 
	sb $t5, 1($a0) # 0x:00
	sb $t8, 2($a0) # :
	sb $t6, 3($a0) # 00:x0
	sb $t7, 4($a0) # 00:0x


	
	POP $ra

	jr $ra
	nop
