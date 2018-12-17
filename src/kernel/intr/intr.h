#ifndef KLIB_INTR_H
#define KLIB_INTR_H

#include "../typedef.h"

#define INDR_ADDR 0x7fffc

void intr_init();
void intr();

#endif