
SRC = boot
# Select logging UART driver
SRC += log-pluart
#SRC += log-muart        # See the note in log-muart.s before using

OBJ = $(SRC:%=$(OBJDIR)/%.o)

$(OUTDIR)/mcode.a: $(OBJ)
	$(AR) rsD $@ $^

$(OBJDIR)/%.o: %.s
	$(CC) -c -o $@ $(CFLAGS) $<

# TODO: Figure out why these don't work...
log-pluart.o: log-pluart.s aux.s
log-muart.o: log-muart.s aux.s
