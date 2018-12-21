#ifndef RISCV_ASM_H
#define RISCV_ASM_H

#define write_csr(reg, val) \
    __asm__ volatile ("csrw " #reg ", %0" :: "rK"(val));

#define read_csr(reg, var)  \
    __asm__ volatile ("csrr %0, " #reg : "=r"(var));

#endif