INPUT = $(wildcard *.toml)
OUTPUT = $(patsubst %.toml, %.xml, $(INPUT))

ifeq ($(KERNEL_TREE),)
$(error "must set KERNEL_TREE=/path/to/kernel/source")
endif

all: $(OUTPUT)

kernel.version: s-kernel-version; @true

.PHONY: s-kernel-version
s-kernel-version:
	./kernel_version.py $(KERNEL_TREE) > tmp-kernel.version
	if ! diff tmp-kernel.version kernel.version ; then           \
		mv tmp-kernel.version kernel.version;                    \
	else                                                         \
		rm tmp-kernel.version;                                   \
	fi
	touch s-kernel-version

%.xml: %.toml kernel-config.py kernel_version.py kernel.version
	./kernel-config.py $(KERNEL_TREE) $< > $@
