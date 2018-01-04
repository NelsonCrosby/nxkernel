
TARGET ?= armv7-rpi2

nxkernel.elf: platforms/$(TARGET)/build/nxkernel.elf
nxkernel.img: platforms/$(TARGET)/build/nxkernel.img
run: platforms/$(TARGET)/run
debug: platforms/$(TARGET)/debug
clean:
	@rm -rvf platforms/*/build

platforms/%/build/nxkernel.elf:
	@mkdir -p $(@D)
	@echo 'MAKE $(@F)'
	@$(MAKE) -C $(@D)/.. build/$(@F)
platforms/%/build/nxkernel.img:
	@mkdir -p $(@D)
	@echo 'MAKE $(@F)'
	$(MAKE) -C $(@D)/.. build/$(@F)

platforms/%/run:
	@echo 'MAKE run'
	@$(MAKE) -C $(@D) run
platforms/%/debug:
	@echo 'MAKE debug'
	@$(MAKE) -C $(@D) debug
