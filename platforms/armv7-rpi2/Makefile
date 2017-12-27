
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


target = arm-nx-eabihf

build/nxkernel.elf: build/asm.a build/$(target)/debug/libplatform.a
	$(CC) -static -ffreestanding -nostdlib \
		-T linker.ld \
		-o $@ $(LDFLAGS) $^

build/$(target)/debug/libplatform.a:
	CARGO_TARGET_DIR=build RUST_TARGET_PATH=$(shell pwd) \
	xargo build --target=$(target)

-include ./build/$(target)/debug/libplatform.d


ASM_SRC = $(ASM:%=asm/%.s)
ASM_OBJ = $(ASM:%=build/asm/%.o)

build/asm.a: $(ASM_OBJ)
	$(AR) rsD $@ $^

build/asm/%.o: asm/%.s
	@mkdir -pv $(@D)
	$(CC) -c -o $@ $(CFLAGS) $<
