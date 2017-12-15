
SRC = boot
OBJ = $(SRC:%=$(OBJDIR)/%.o)

$(OUTDIR)/mcode.a: $(OBJ)
	$(AR) rsD $@ $^

$(OBJDIR)/%.o: %.s
	$(CC) -c -o $@ $(CFLAGS) $<
