.section .text

.globl _start
_start:
	lui sp, 0x1
	lui s2, 0x7
	addi s2, s2, 0x30
	#addi s3, zero, 0
	#addi a3, zero, 0
	# li a1, 0x00
	# sb a1, 0x0(sp)
	# li a1, 0x01
	# sb a1, 0x1(sp)
	# li a1, 0x02
	# sb a1, 0x2(sp)
	# li a1, 0x03
	# sb a1, 0x3(sp)
	# lw a1, 0x0(sp)
	#li a1, 0x04030201
	#sw a1, 0x0(sp)
	#li a1, 0x08070605
	#sw a1, 0x4(sp)
	li a1, 0x10
	li a2, 0x1
	div a0, a2,a1
	jal print
	rem a0,a2,a1
	jal print
	j main

.globl main
main:
	# addi a4, zero, 16
	# mul a4, a3, a4
	# sra a0, a1, a4
	# andi a0, a0, 0xff
#	add a1, sp, a3
#	lbu a0, 0x0(a1)
#	addi a3, a3, 1
#	jal print
#	addi a2, zero, 0x8
#tag:
#	beq a3, a2, tag
	j main

.globl print
print:
	lui t0, 0x80
	addi t0, t0, 0x004
	add t0, t0, s3
	lui t1, 0x7
	addi t1, t1, 0x030
	add t1, t1, a0
	sh t1, 0x0(t0)
	addi s3, s3, 2
	ret




.section .rodata
msg:
	.string "fuck"
