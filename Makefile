
TARGET = armv7-rpi2

nxkernel.elf: nxkernel-$(TARGET).elf
nxkernel.img: nxkernel-$(TARGET).img
run: run-$(TARGET)
debug: debug-$(TARGET)
clean:
	@rm -rvf build


root := $(shell pwd)
tools := $(root)/tools

include $(tools)/call-vars.make


.PHONY: nxkernel-%.elf nxkernel-%.img
nxkernel-%.elf:
	@echo 'MAKE $@'
	@$(MAKE) -C platforms/$* \
		$(root)/build/$*/nxkernel.elf \
		$(_MAKE_VARS_NOBUILD) \
		build=$(root)/build/$*
nxkernel-%.img:
	@echo 'MAKE $@'
	@$(MAKE) -C platforms/$* \
		$(root)/build/$*/nxkernel.img \
		$(_MAKE_VARS_NOBUILD) \
		build=$(root)/build/$*

.PHONY: run-% debug-%
run-%:
	@echo 'MAKE $@'
	@$(MAKE) -C platforms/$* \
		run \
		$(_MAKE_VARS_NOBUILD) \
		build=$(root)/build/$*
debug-%:
	@echo 'MAKE $@'
	@$(MAKE) -C platforms/$* \
		debug \
		$(_MAKE_VARS_NOBUILD) \
		build=$(root)/build/$*
