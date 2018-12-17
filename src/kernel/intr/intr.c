#include "intr.h"
#include "../driver/kbd.h"

static u8* intr_args = (u8*)INDR_ADDR;

void intr_init(){
    *((u32*) intr_args) = 0;
    void* intr_ptr = intr;
    asm volatile("csrw uscratch, %0": "r"(intr_ptr));
    // TODO: insert an instr to set the idtr to intr()'s address
}

void intr_open(){
    int code = 1;
    asm volatile("csrw uepc, %0": "r"(code));
}

void intr_close(){
    int code = 0;
    asm volatile("csrw uepc, %0": "r"(code));
}

void intr(){
    switch(intr_args[0]){
        case 0: return;
        case 1: kbd_update(intr_args + 1); break;
        default: break;
    }
    intr_close();
    int code = 0;
    asm volatile("csrw ucause, %0": "r"(code));
    return;
}