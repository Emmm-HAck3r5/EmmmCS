#include "intr.h"
#include "../driver/kbd.h"
#include "../riscv_asm.h"

static u8* intr_args = (u8*)INDR_ADDR;

void intr_init(){
    *((u32*) intr_args) = 0;
    void* intr_ptr = intr;
    write_csr(uscratch, intr_ptr); // fake instr
    // asm volatile("csrw uscratch, %0": "r"(intr_ptr));
}

void intr_open(){
    int code = 1;
    write_csr(uepc, code); // fake instr
    // asm volatile("csrw uepc, %0": "r"(code));
}

void intr_close(){
    int code = 0;
    write_csr(uepc, code); // fake instr
    // asm volatile("csrw uepc, %0": "r"(code));
}

void intr(){
    switch(intr_args[0]){
        case 0: return;
        case 1: kbd_update(intr_args + 1); break;
        default: break;
    }
    intr_close();
    int code = 0;
    write_csr(ucause, code); // fake MRET instr
    // asm volatile("csrw ucause, %0": "r"(code));
    return;
}