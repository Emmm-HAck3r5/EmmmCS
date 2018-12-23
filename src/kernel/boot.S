.section .text

.globl _start
_start:
    li sp, 0x7fff0
    li gp, 0x70000
    j main