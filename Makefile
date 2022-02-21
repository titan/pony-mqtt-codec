include .config
NAME-LINK = $(subst _,-,$(NAME))

ESCAPED-BUILDDIR = $(shell echo '$(BUILDDIR)' | sed 's%/%\\/%g')
TARGET = $(BUILDDIR)/$(NAME-LINK)
BUILDSCRIPTS = corral.json lock.json
DSTSCRIPTS = $(BUILDSCRIPTS:%=$(BUILDDIR)/%)
SRCDIR = mqtt-codec
SRCS = $(wildcard $(SRCDIR)/*.pony)
DSTSRCS = $(subst $(SRCDIR),$(BUILDDIR),$(SRCS))

all: $(TARGET)

$(TARGET): $(DSTSCRIPTS) $(DSTSRCS)
	cd $(BUILDDIR); corral fetch; corral run -- ponyc; cd -

$(DSTSCRIPTS): $(BUILDDIR)/%: % | prebuild
	cp $< $@

$(DSTSRCS): $(BUILDDIR)/%: $(SRCDIR)/% .config | prebuild
	cp $< $@

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)
endif

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean install prebuild test
