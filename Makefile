
all: target/armv7-rpi2/nxkernel
run: run-armv7-rpi2
clean:
	@rm -rvf target
.PHONY: all run


CC = arm-none-eabi-gcc
AR = arm-none-eabi-ar
OBJCOPY = arm-none-eabi-objcopy


target/%/nxkernel: target/%/.dir target/%/obj/.dir target/%/nxkernel.elf
	$(OBJCOPY) $@.elf -O binary $@

target/%/nxkernel.elf: target/%/mcode.a
	$(CC) -static -nostdlib -o $@ $(LDFLAGS) $^

_MCODE_OUTDIR = $(shell realpath \
    --relative-to=$(@D:target/%=platform/%) \
    $(@D))
target/%/mcode.a: FORCE
	$(MAKE) \
	    CC=$(CC) AR=$(AR) \
	    CFLAGS=$(CFLAGS) ARFLAGS=$(ARFLAGS) \
	    OUTDIR=$(_MCODE_OUTDIR) \
	    OBJDIR=$(_MCODE_OUTDIR)/obj \
	    -C $(@D:target/%=platform/%) \
	    $(_MCODE_OUTDIR)/$(@F)


FORCE:


.PHONY: run-%
run-%: target/%/nxkernel
	qemu-system-arm \
	    -M raspi2 \
	    -nographic \
	    -kernel $<


%/.dir:
	@mkdir -pv $(@D)
	@touch $@
