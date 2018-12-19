.PHONY: clean

CC := riscv32-unknown-elf-gcc
OD := riscv32-unknown-elf-objdump
CFLAGS := -nostdinc -fno-stack-protector -fno-builtin -static -Ttext=0x00000 -march=rv32i -mabi=ilp32 -nostdlib

CFILES := $(shell find -name "*.c")
OBJS := $(CFILES:.c=.o)
PRO := kernel

kernel: $(OBJS)
	$(CC) -o $(PRO) $(OBJS)

$(OBJS): typedef.h

clean:
	-rm -f $(PRO) $(OBJS)
