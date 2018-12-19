.PHONY: clean dump

CC := riscv32-unknown-elf-gcc
OD := riscv32-unknown-elf-objdump
LD := riscv32-unknown-elf-ld
CFLAGS := -nostdinc -fno-stack-protector -fno-builtin -static -Ttext=0x00000 -march=rv32im -mabi=ilp32 -nostdlib

CFILES := main.c
CFILES += $(shell find ! -name "main.c" -name "*.c")
OBJS := $(CFILES:.c=.o)
PRO := kernel

kernel: $(OBJS)
	$(CC) $(CFLAGS) -o $(PRO) $(OBJS)

dump: kernel
	$(OD) -D kernel > kernel.dump

$(OBJS): typedef.h

clean:
	-rm -f $(PRO) $(OBJS)
