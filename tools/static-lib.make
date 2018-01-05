
OBJ := $(files:%.c=$(build)/$(name)/%.o)
OBJ := $(OBJ:%.S=$(build)/$(name)/%.o)
DEP := $(OBJ:.o=.d)

$(build)/$(name).a: $(OBJ)
	@echo 'AR $(@F)'
	@$(AR) rsD $@ $^

$(build)/$(name)/%.o: %.S
	@mkdir -p $(@D)
	@echo 'AS $(name)/$<'
	@$(CC) -c -o $@ -MMD $(ASFLAGS) $<

$(build)/$(name)/%.o: %.c
	@mkdir -p $(@D)
	@echo 'CC $(name)/$<'
	@$(CC) -c -o $@ -MMD -I$(root) $(CFLAGS) $<

-include $(DEP)
