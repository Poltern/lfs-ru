INPUT = $(wildcard */*.toml */*/*.toml */*/*/*.toml)
OUTPUT = $(patsubst %.toml, ../%-kernel.xml, $(INPUT))

ifeq ($(KERNEL_TREE),)
$(error "must set KERNEL_TREE=/path/to/kernel/source")
endif

all: $(OUTPUT) ../introduction/welcome/conventions-kernel.xml

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

%-kernel.xml.tmp: %.toml kernel-config.py kernel_version.py kernel.version
	./kernel-config.py $(KERNEL_TREE) $< > $@

../%-kernel.xml: %-kernel.xml.tmp
	mv $< $@

../introduction/welcome/conventions-kernel.xml: kernel-config.py testdata/Kconfig testdata/config.toml.example
	./kernel-config.py testdata testdata/config.toml.example > $@
