
TARGET ?= armv7-rpi2

nxkernel.elf: platforms/$(TARGET)/build/nxkernel.elf
nxkernel.img: platforms/$(TARGET)/build/nxkernel.img
run: platforms/$(TARGET)/run
debug: platforms/$(TARGET)/debug
clean:
	@rm -rvf platforms/*/build
	@rm -vf platforms/*/Cargo.lock

platforms/%/build/nxkernel.elf:
	@mkdir -pv $(@D)
	$(MAKE) -C $(@D)/.. build/$(@F)
platforms/%/build/nxkernel.img:
	@mkdir -pv $(@D)
	$(MAKE) -C $(@D)/.. build/$(@F)

platforms/%/run:
	$(MAKE) -C $(@D) run
platforms/%/debug:
	$(MAKE) -C $(@D) debug
