
DEFAULT = armv7-rpi2
CTARGET = arm-none-eabi

all: target/$(DEFAULT)/nxkernel
run: run-$(DEFAULT)
debug: debug-$(DEFAULT)
dump: dump-$(DEFAULT)
dump-elf: dump-elf-$(DEFAULT)
clean:
	@rm -rvf target
.PHONY: all run debug dump dump-elf clean


CC = $(CTARGET)-gcc
AR = $(CTARGET)-ar
OBJCOPY = $(CTARGET)-objcopy
OBJDUMP = $(CTARGET)-objdump
GDB = $(CTARGET)-gdb

CFLAGS += -ffreestanding


.PRECIOUS: target/%/nxkernel
target/%/nxkernel: target/%/.dir target/%/obj/.dir target/%/nxkernel.elf
	$(OBJCOPY) $@.elf -O binary $@

.PRECIOUS: target/%/nxkernel.elf
target/%/nxkernel.elf: target/%/mcode.a
	$(CC) -static -ffreestanding -nostdlib \
	    -T $(@D:target/%=platform/%)/link-kernel.ld \
	    -o $@ $(LDFLAGS) $^

_MCODE_OUTDIR = $(shell realpath \
    --relative-to=$(@D:target/%=platform/%) \
    $(@D))
.PRECIOUS: target/%/mcode.a
target/%/mcode.a: FORCE
	$(MAKE) \
	    CC=$(CC) AR=$(AR) \
	    CFLAGS="$(CFLAGS)" ARFLAGS="$(ARFLAGS)" \
	    OUTDIR=$(_MCODE_OUTDIR) \
	    OBJDIR=$(_MCODE_OUTDIR)/obj \
	    -C $(@D:target/%=platform/%) \
	    $(_MCODE_OUTDIR)/$(@F)


FORCE:


.PHONY: run-%
run-%: target/%/nxkernel
	qemu-system-arm \
	    -M raspi2 \
	    -serial stdio \
	    -kernel $<.elf

.PHONY: debug-%
debug-%: target/%/nxkernel
	$(GDB) $<.elf -ex 'target remote | exec \
	    qemu-system-arm  \
	    -M raspi2 \
	    -gdb stdio \
	    -kernel $<.elf'


.PHONY: dump-elf-% dump-%
dump-elf-%: target/%/nxkernel.elf
	$(OBJDUMP) $< -D >$<.s
dump-%: target/%/nxkernel
	$(OBJDUMP) $< -b binary -marm -D >$<.s


%/.dir:
	@mkdir -pv $(@D)
	@touch $@
