
FILES = boot.S interrupt.S main.c misc.S
# Select logging UART driver
FILES += log-pluart.S
#FILES += log-muart.S    # See the note in log-muart.s before using


CFLAGS += -I../..


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
	$(CC) -static -ffreestanding -nostdlib \
		-T linker.ld \
		-o $@ $(LDFLAGS) $^ -lgcc


build/libkernel.a:
	@mkdir -pv $(@D)
	$(MAKE) -C ../../kernel $(shell pwd)/$@ \
		build=$(shell pwd)/$(@D) \
		CC=$(CC) AR=$(AR)


SRC := $(FILES:%=src/%)
OBJ := $(FILES:%.c=build/c/%.o)
OBJ := $(OBJ:%.S=build/asm/%.o)
DEP := $(OBJ:.o=.d)

build/platform.a: $(OBJ)
	$(AR) rsD $@ $^

build/asm/%.o: src/%.S
	@mkdir -pv $(@D)
	$(CC) -c -o $@ -MMD $(CFLAGS) $<

build/c/%.o: src/%.c
	@mkdir -pv $(@D)
	$(CC) -c -o $@ -MMD $(CFLAGS) $<

-include $(DEP)
