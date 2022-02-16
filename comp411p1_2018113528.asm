# -------------------------------------------------------------------
# [KNU COMP411 Computer Architecture] Skeleton code for the 1st project (calculator)
# -------------------------------------------------------------------
.globl main

.data

prompt: .asciz "> "
.space 100
expr: .asciz ""
.space 100
equal: .asciz "="
.space 100
rest: .asciz ","
.space 100
error: .asciz "ERROR"
.space 100
.text	
# main
main:
	
	jal x1, test #functionality test, Do not modify!!
	asdf:
	li t1, 43	#plus
	li t2, 45	#sub
	li t3, 42	#mul
	li t4, 47	#div
	li t5, 0	#cnt 
	#----TODO-------------------------------------------------------------
	#1. read a string from the console
	la a0, prompt		# prompt
	li a7, 4
	ecall
	la a0, expr		# input expr
	li a1, 50
	li a7, 8
	ecall	
	
	mv s1, a0		# save the expr
	first_loop:		# find first opernad
	lb a5, (s1)		# take a first value
	addi s1, s1, 1		# move the pointer
	beq a5, t1, add_	# if add
	beq a5, t2, sub_	# if sub
	beq a5, t3, mul_	# if mul
	beq a5, t4, div_	# if div
	addi t5, t5, 1		# count
	beq zero,zero, first_loop #loop
	
	add_:	
	jal x1, trans_fir	
	li a1, 0		# a1  	
	mv s3, a2		# store the value
	mv s9, a1		# store the value
	beq zero, zero, second_
	sub_:
	jal x1, trans_fir	
	li a1, 1		#a1
	mv s3, a2		# store the value
	mv s9, a1		# store the value
	beq zero, zero, second_
	mul_:
	jal x1, trans_fir
	li a1, 2		# a1
	mv s3, a2		# store the value
	mv s9, a1		# store the value
	beq zero, zero, second_
	div_:
	jal x1, trans_fir	
	li a1, 3		# a1
	mv s3, a2		# store the value
	mv s9, a1		# store the value
	beq zero, zero, second_
	
	second_:		# find second operand
	li s2, 10 		# \n ascii code
	lb a5, (s1)		# take the value
	addi s1, s1, 1		# move the pointer
	beq a5,s2, ready	# compare if end
	addi t5, t5, 1		# count
	beq zero,zero, second_ 

	
	#2. perform arithmetic operations
	ready:			# goto calc
	jal x1, trans_sec	# transform
	mv a2, s3		# restore a2
	mv a1, s9		# restore a1
	jal x1, calc
	
	#3. print a string to the console to show the computation result
	mv s5, a0		# store the result
	la a0, expr		# take a own expr
	
	mv s1, a0		
	li s2, 10 		# \n ascii code
	expr_loop:		# output loop
	lb a0, (s1)		# take the value
	addi s1, s1, 1		# move the pointer
	beq a0, s2, next_	# if end then go to next
	li a7, 11		# output
	ecall
	beq zero,zero, expr_loop
	next_:		
	la a0, equal	# output =
	li a7, 4	
	ecall
	mv a0, s5	# restore own value
	li a7, 1	# print
	ecall
	
	li t5, 3	# if operator is div then take a remainder and print
	bne a1, t5,  real_end
	
	la a0, rest	# print ,
	li a7, 4
	ecall
	
	mv a0, a4	# print remainder
	li a7, 1
	ecall
	#----------------------------------------------------------------------
	
	# Exit (93) with code 0
	real_end:	# end
	li a5,0
	beq zero, zero, asdf
	li a0, 0
        li a7, 93
        ecall
        ebreak

trans_fir:
	add s10, t5, zero	# store count
	li s11, 1		# multiply value
	mv s4, s1		# store latest string
	addi s4, s4, -2		# goto last value
	mv s2 , x1		# store address
	
	makeval:		
	lb a5, (s4)		# take a value
	addi a5, a5, -48 	# change a char to integer
	
	li a1, 2		# make a value
	mv a2, a5		
	mv a3, s11			
	jal x1, calc		
	
	add s5, a0, s5		# add value
		
	li a1, 2		# update multiply value
	li a2, 10	
	mv a3, s11		
	jal x1, calc
	mv s11, a0		# change multiply value
	
	addi s10, s10, -1	# sub cnt value
	beq s10, zero, end	# compare cnt value, 0
	addi s4, s4, -1		# move pointer
	beq zero, zero, makeval
	
	end:
	li a0, 0		# initialization a0
	mv a2, s5		# save value to a2
	li t5, 0		# initialization cnt value
	mv x1, s2		# restore address
	li s5,0			# initialization save place
	jalr x0, 0(x1)		
	
	
trans_sec:
	add s10, t5, zero	# store cnt value
	li s11, 1		
	mv s4, s1
	addi s4, s4, -2
	mv s2 , x1
	makeval_:
	lb a5, (s4)		# take a first value
	addi a5, a5, -48 	# change a char to integer
	
	li a1, 2		# 
	mv a2, a5
	mv a3, s11
	jal x1, calc
	
	add s5, a0, s5	
		
	li a1, 2		
	li a2, 10	
	mv a3, s11
	jal x1, calc
	
	mv s11, a0		
	
	addi s10, s10, -1	
	beq s10, zero, end_	
	addi s4, s4, -1		
	beq zero, zero, makeval_
	end_:
	li a0, 0
	li s5, 0
	mv a3, s5		# store a3
	mv x1, s2
	jalr x0, 0(x1)
	
	
#----------------------------------
#name: calc
#func: performs arithmetic operation
#x11(a1): arithmetic operation (0: addition, 1:  subtraction, 2:  multiplication, 3: division)
#x12(a2): the first operand
#x13(a3): the second operand
#x10(a0): return value
#x14(a4): return value (remainder for division operation)
#----------------------------------
calc:
	#TODO						
				#using t6 for comparison
				#a2,a3 are operand and a0 is return value
				
	addi s7,a2,0		# save the opernad value
	addi s8,a3,0		
		
	li t6,0 		# input zero to t6
	bne a1,t6,fun_sub 	# if a1 not equal to t6 then goto subfunc
	
	add s6, s7, s8 		# else execute add
	mv a0, s6		# save the value
	beq zero,zero,exit	# go to exit
	
	fun_sub: 
	li t6 1 
	bne a1,t6,fun_mul
	
	xori s8, s8, -1		# change
	addi s8, s8, 1		# +1
	add s6, s7, s8		# sub
	
	mv a0, s6		# save the value
	beq zero,zero,exit
	
	fun_mul:
	li t6 2
	bne a1,t6,fun_div
	
	li t5,0			# space for save the value
	li s6,0			# count value
	li a6, 32		# boundary value
	test_and:
	addi s6, s6, 1		# plus cnt
	
	andi t4, s8,1		# bit check
	srli s8, s8, 1		# shift multiplier to right
	beq t4, zero, shift_mul	# compare
	add t5, t5, s7		# if value are 1 then add 
	shift_mul:
	slli s7, s7, 1		# shift multiplicand to left 
	bne s6, a6,test_and	# end condition
	addi a0, t5, 0		# restore original value
	beq zero,zero,exit
	
	fun_div:
	li t5, 0  		# count value
	li t4, 17		# bound value
	li s6, 0		# quotient value
	slli s8, s8, 16		# shift divisor 16 bit
	
	beq a3, zero, zero_div
	
	sub_test:		
	addi t5, t5, 1		# up count
	
	xori s9, s8, -1		# change
	addi s9, s9, 1		# +1
	add t6, s7, s9		# sub
	
	bltz t6, zero_shift	# branch zero 
	mv s7, t6 		# if positive change the remainder value
	slli s6, s6, 1		# shift quotient left
	addi s6, s6, 1		# set least bit 1
	beq zero, zero, condition
	zero_shift: 		# if neg
	slli s6, s6, 1		# shift quotient left
	condition:		
	srli s8, s8, 1		# shift divisor
	bne t5, t4, sub_test	# compare count
	mv a0, s6		# data transfer
	mv a4, s7		# data transfer
	beq zero, zero exit	# end
	
	zero_div:		# exception
	la a0, error
	li a7, 4
	ecall	
	li a0, 0
        li a7, 93
        ecall
        ebreak
	
	exit:
	jalr x0, 0(x1)


.include "common.asm"
