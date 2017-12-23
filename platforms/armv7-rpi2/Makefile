
ASM = boot
# Select logging UART driver
ASM += log-pluart
#ASM += log-muart        # See the note in log-muart.s before using


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


build/nxkernel.elf: build/asm.a #build/platform.a
	$(CC) -static -ffreestanding -nostdlib \
		-T linker.ld \
		-o $@ $(LDFLAGS) $^

build/platform.a:
	CARGO_TARGET_DIR=build cargo build --target=arm-none-eabi


ASM_SRC = $(ASM:%=asm/%.s)
ASM_OBJ = $(ASM:%=build/asm/%.o)

build/asm.a: $(ASM_OBJ)
	$(AR) rsD $@ $^

build/asm/%.o: asm/%.s
	@mkdir -pv $(@D)
	$(CC) -c -o $@ $(CFLAGS) $<
