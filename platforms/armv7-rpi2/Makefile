
FILES = boot.S interrupt.S main.c misc.S
# Select UART driver
FILES += uart-pl.S


CFLAGS_ALL += -ggdb
CFLAGS += -I../.. $(CFLAGS_ALL)


CC = arm-none-eabi-gcc
AR = arm-none-eabi-ar
QEMU = qemu-system-arm
GDB = arm-none-eabi-gdb


run: build/nxkernel.elf
	$(QEMU) \
		-M raspi2 \
		-serial stdio \
		-kernel $<

debug: build/nxkernel.elf
	$(GDB) $< -ex 'target remote | exec \
		$(QEMU) \
		-M raspi2 \
		-gdb stdio \
		-kernel $<'


build/nxkernel.elf: build/platform.a build/libkernel.a
	@echo 'LD $@ <- $^'
	@$(CC) -static -ffreestanding -nostdlib \
		-T linker.ld \
		-o $@ $(LDFLAGS) $^ -lgcc


build/libkernel.a:
	@mkdir -p $(@D)
	@echo 'MAKE $(@F)'
	@$(MAKE) -C ../../kernel $(shell pwd)/$@ \
		build=$(shell pwd)/$(@D) \
		CC=$(CC) AR=$(AR) CFLAGS='$(CFLAGS_ALL)'


SRC := $(FILES:%=src/%)
OBJ := $(FILES:%.c=build/c/%.o)
OBJ := $(OBJ:%.S=build/asm/%.o)
DEP := $(OBJ:.o=.d)

build/platform.a: $(OBJ)
	@echo 'AR $(@F)'
	@$(AR) rsD $@ $^

build/asm/%.o: src/%.S
	@mkdir -p $(@D)
	@echo 'AS platform/$<'
	@$(CC) -c -o $@ -MMD $(ASMFLAGS) $<

build/c/%.o: src/%.c
	@mkdir -p $(@D)
	@echo 'CC platform/$<'
	@$(CC) -c -o $@ -MMD $(CFLAGS) $<

-include $(DEP)
