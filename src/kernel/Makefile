.PHONY: clean dump

CC := riscv32-unknown-elf-gcc
OD := riscv32-unknown-elf-objdump
CP := riscv32-unknown-elf-objcopy
LD := riscv32-unknown-elf-ld
CFLAGS := -nostdinc -fno-stack-protector -fno-builtin -static -Ttext=0x00000 -march=rv32im -mabi=ilp32 -nostdlib

CFILES := boot.S main.c
CFILES += $(shell find ! -name "main.c" -name "*.c")
OBJS := $(CFILES:.c=.o)
PRO := kernel

kernel: $(OBJS)
	$(CC) $(CFLAGS) -o $(PRO) $(OBJS)

dump: kernel
	$(OD) -D kernel > kernel.dump \
	&& $(CP) -S --set-section-flags .bss=alloc,contents -O binary kernel kernel.bin \
	&& python3 bin2mif.py \
	&& cp cache.mif ../rtl/memory/

$(OBJS): typedef.h

clean:
	-rm -f $(PRO) $(OBJS)
