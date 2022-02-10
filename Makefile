SHELL = /bin/bash
ifeq ($(shell uname),Darwin)
EXTRA_SWIFT_FLAGS = "--disable-sandbox"
else
SWIFT_TOOLCHAIN = "$(shell swift -print-target-info | grep runtimeResourcePath | cut -f 2 -d ':' | cut -f 2 -d '"')"
EXTRA_SWIFT_FLAGS = -Xcxx -I${SWIFT_TOOLCHAIN} -Xcxx -I${SWIFT_TOOLCHAIN}/Block
endif

define build
	@swift build --configuration $(1) -Xswiftc -warnings-as-errors ${EXTRA_SWIFT_FLAGS}
endef

.PHONY: build
build:
	$(call build,release)

.PHONY: test
test:
	@swift test ${EXTRA_SWIFT_FLAGS}

.PHONY: debug
debug:
	$(call build,debug)

.PHONY: dump
dump:
	@$(MAKE) debug
	@.build/debug/usr-summary > .build/output.tsv
