
_MAKE_VARS_NOBUILD = \
    CC=$(CC) AR=$(AR) \
    CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" LDLIBS="$(LDLIBS)" \
    root=$(root) tools=$(tools)

_MAKE_VARS = $(_MAKE_VARS_NOBUILD) build=$(build)
