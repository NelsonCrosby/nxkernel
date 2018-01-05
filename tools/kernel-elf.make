
include $(tools)/call-vars.make


$(build)/nxkernel.elf: $(build)/platform.a $(build)/util.a $(build)/kernel.a
	@echo 'LD $@ <- $^'
	@$(CC) -static -ffreestanding -nostdlib \
		-T linker.ld \
		-o $@ $(LDFLAGS) $^ $(LDLIBS)


$(build)/%.a: FORCE
	@mkdir -p $(@D)
	@echo 'MAKE $(@F)'
	@$(MAKE) -C $(root)/$(*F) $@ $(_MAKE_VARS)

$(build)/platform.a: FORCE
	@mkdir -p $(@D)
	@echo 'MAKE $(@F)'
	@$(MAKE) -C src $@ $(_MAKE_VARS)

FORCE:
