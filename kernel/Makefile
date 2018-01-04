
FILES = format.c log.c string.c

OBJ := $(FILES:%.c=$(build)/libkernel/%.o)
DEP := $(OBJ:.o=.d)

$(build)/libkernel.a: $(OBJ)
	@echo 'AR $(@F)'
	@$(AR) rsD $@ $^

$(build)/libkernel/%.o: %.c
	@mkdir -p $(@D)
	@echo 'CC kernel/$<'
	@$(CC) -c -o $@ -MMD $(CFLAGS) $<

-include $(DEP)
