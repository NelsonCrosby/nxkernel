

override CFLAGS += -ggdb
override LDLIBS += -lgcc


override CC = arm-none-eabi-gcc
override AR = arm-none-eabi-ar
override QEMU = qemu-system-arm
override GDB = arm-none-eabi-gdb


run: $(build)/nxkernel.elf
	$(QEMU) \
		-M raspi2 \
		-serial stdio \
		-kernel $<

debug: $(build)/nxkernel.elf
	$(GDB) $< -ex 'target remote | exec \
		$(QEMU) \
		-M raspi2 \
		-gdb stdio \
		-kernel $<'

include $(tools)/kernel-elf.make
