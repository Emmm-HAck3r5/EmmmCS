#ifndef DRIVER_KBD_H
#define DRIVER_KBD_H
#include "../typedef.h"

#define KBD_BUF_SIZE 256

void kbd_init();
void kbd_update();
u8   kbd_getc();

#endif