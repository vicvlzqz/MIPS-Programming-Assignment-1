#MIPS Programming Assignment Comp Org I Fall 2017
#Victoria Velazquez


.data 																#declare variables
	str1: .space 9 													#allocating space in memory
	error_msg: .ascii "Invalid hexadecimal number."
	newline: .ascii "\n"

.text  																#where code is being executed

main:
	la $a0, str1 													#making variable to store user input 
	li $a1, 9 														#limits amount of characters
	li $v0, 8											#loads syscall that reads user input for strings
	syscall 
	li $t1, 0													 #sum of character count/length set to 0

loop_for_character_count:
	lb $t0, 0($a0) 													#loads a byte from the string array 
	beq $t0, 0, exit1 												#if char is null, exit
	beq $t0, 10, exit1												#if char is newline, exit
	addi $a0, $a0, 1 								#iterating through string array/increase to next byte
	addi $t1, $t1, 1												#add to sum
	j loop_for_character_count
exit1:
	#length is in $t1
	#SHIFT METHOD
	#based off length --- (len * 4)
	# ABC
	# A: 1010 - 10
	# B: 1011 - 11
	# C: 1100 - 12  
	#1010 1011 1100 = 1010 0000 0000 + 1011  0000 + 1100
	ble $t1, 1, invalid 											#checking for empty string
	la $s0, str1
	li $t2, 4
	mult $t1, $t2 													#multiple length times 4
	mflo $s5														#shift amount
	li $s6, 0 														#sum 

loop_for_validity:
	#ASCII: *<0<9<*<A<F<*<a<f*<*
	#Decimal: *<48<57<*<65<70<*<97<102<*
	lb $t0, 0($s0) 													#loads a byte from the string array 
	beq $t0, 0, exit2 												#if char is null, exit
	beq $t0, 10, exit2 												#if char is newline, exit
	
	addi $s0, $s0, 1 								#iterating through string array/increase to next byte
	sub $s5, $s5, 4 												#keeping track of shift amount

	blt $t0, 48, invalid 											#if char is less than 0
	blt $t0, 58, is_number 											#if char is less than 9
	blt $t0, 65, invalid 											#if char is less than A
	blt $t0, 71, is_uppercase 										#if char is less than F
	blt $t0, 97, invalid 											#if char is less than a
	blt $t0, 103, is_lowercase 										#if char is less than f
	bgt $t0, 102, invalid 											#if char is greater than f
	j loop_for_validity
exit2:
	li $v0, 4														#calling function to print a string
	la $a0, newline 												#print newline
	syscall
	bge $t1, 8, convert 											#changing two's complement
	li $v0, 1 														#calling function to print a integar
	add $a0, $s6, $0 												#printing sum
	syscall
	
	li $v0, 10 														#terminate execution
	syscall

invalid:
	li $v0, 4														#calling function to print a string
	la $a0, error_msg 												#print error msg
	syscall 
	li $v0, 10 														#terminate execution
	syscall

is_number:
	addi $t0, $t0, -48  											#convert to decimal
	sllv $t0, $t0, $s5 												#shifting
	add $s6, $t0, $s6 												#adding to sum
	li $v0, 1														#calling function to print a integar
	add $a0, $t0, $0
	syscall

    li $v0, 4														#calling function to print a string
	la $a0, newline													#print newline
	syscall 

	li $v0, 1 														#calling function to print a integar
	add $a0, $s5, $0 												#printing sum
	syscall
	li $v0, 4														#calling function to print a string
	la $a0, newline													#print newline
	syscall 
	j loop_for_validity

is_uppercase:
	addi $t0, $t0, -55												#convert to decimal
	sllv $t0, $t0, $s5 												#shifting
	add $s6, $t0, $s6 												#adding to sum
	li $v0, 1 														#calling function to print a integar
	add $a0, $t0, $0
	syscall

	li $v0, 4														#calling function to print a string
	la $a0, newline													#print newline
	syscall 
	j loop_for_validity

is_lowercase:
	addi $t0, $t0, -87 												#convert to decimal
	sllv $t0, $t0, $s5 												#shifting
	add $s6, $t0, $s6 												#adding to sum
	li $v0, 1 														#calling function to print a integar
	add $a0, $t0, $0
	syscall

	li $v0, 4														#calling function to print a string
	la $a0, newline													#print newline
	syscall 
	j loop_for_validity

convert:
	li $t3, 10000 													#assigning 10000 to address
	divu $s6, $t3 											#dividing sum by 10000 to convert from two's complement 
	mflo $t4														#remainder
	mfhi $t5														#quotient

	li $v0, 1 														#calling function to print a integar
	add $a0, $t4, $0 												#printing remainder
	syscall
	li $v0, 1 														#calling function to print a integar
	add $a0, $t5, $0 												#printing quotient
	syscall
	
