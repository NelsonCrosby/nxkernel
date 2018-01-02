
FILES = boot.s main.c
# Select logging UART driver
FILES += log-pluart.s
#FILES += log-muart.s    # See the note in log-muart.s before using


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


build/nxkernel.elf: build/platform.a
	$(CC) -static -ffreestanding -nostdlib \
		-T linker.ld \
		-o $@ $(LDFLAGS) $^


SRC := $(FILES:%=src/%)
OBJ := $(FILES:%.c=build/c/%.o)
OBJ := $(OBJ:%.s=build/asm/%.o)
DEP := $(OBJ:.o=.d)

build/platform.a: $(OBJ)
	$(AR) rsD $@ $^

build/asm/%.o: src/%.s
	@mkdir -pv $(@D)
	$(CC) -c -o $@ -MMD $(CFLAGS) $<

build/c/%.o: src/%.c
	@mkdir -pv $(@D)
	$(CC) -c -o $@ -MMD $(CFLAGS) $<

-include $(DEP)
