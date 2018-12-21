.PHONY: clean dump

CC := riscv32-unknown-elf-gcc
OD := riscv32-unknown-elf-objdump
CP := riscv32-unknown-elf-objcopy
LD := riscv32-unknown-elf-ld
AS := riscv32-unknown-elf-as
CFLAGS := -nostdinc -fno-stack-protector -fno-builtin -static -Ttext=0x00000 -march=rv32im -mabi=ilp32 -nostdlib

SRC := main.S
OBJ := main


dump: $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(OBJ) \
	&& $(OD) -D $(OBJ) > main.dump \
	&& $(CP) -S --set-section-flags .bss=alloc,contents -O binary $(OBJ) main.bin \
	&& python3 bin2mif.py

move: dump
	cp cache.mif ../rtl/memory/

clean:
	-rm -f $(PRO) $(OBJS)
