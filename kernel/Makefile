
FILES = format.c log.c

OBJ := $(FILES:%.c=$(build)/libkernel/%.o)
DEP := $(OBJ:.o=.d)

$(build)/libkernel.a: $(OBJ)
	$(AR) rsD $@ $^

$(build)/libkernel/%.o: %.c
	@mkdir -pv $(@D)
	$(CC) -c -o $@ -MMD $(CFLAGS) $<

-include $(DEP)
