config ?= debug

ifdef config
  ifeq (,$(filter $(config),debug release))
    $(error Unknown configuration "$(config)")
  endif
endif

ifeq ($(config),debug)
    PONYC-FLAGS += --debug
endif

NAME = mqtt-codec
BUILDDIR = /dev/shm/$(NAME)
TARGET = $(BUILDDIR)/$(config)/test
BUILDSCRIPTS = corral.json lock.json
SRCDIR = $(NAME)
SRCS = $(wildcard $(SRCDIR)/*.pony)

PONYC ?= ponyc
COMPILE-WITH := corral run -- $(PONYC)
PONYC-FLAGS += -V1

all: $(TARGET)

$(TARGET): $(SRCS)
	$(COMPILE-WITH) $(PONYC-FLAGS) -o $(BUILDDIR)/$(config) --bin-name=test $(NAME)

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)/$(config)
endif

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean prebuild
