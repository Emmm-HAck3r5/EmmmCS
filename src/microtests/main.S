.section .text

.globl _start
_start:
	lui a1, 0x80
	addi a1, a1, 0x004
	lui a3, 0x7
	addi a3, a3, 0x0
	addi a2, a0, 0
	addi a4, a0, 0
	j main

.globl main
main:
	add a4, a1, a2
	sw a3, 0x0(a4)
	addi a3, a3, 1
	addi a2, a2, 2
	j main

.section .rodata
msg:
	.string "fuck"
