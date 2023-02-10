SWIFTWASM_VERSION := swift-wasm-DEVELOPMENT-SNAPSHOT-2023-02-08-a
UPSTREAM_VERSION := swift-DEVELOPMENT-SNAPSHOT-2023-02-06-a

swift-wasm-DEVELOPMENT-SNAPSHOT.tar.gz:
	curl -o $@ https://github.com/swiftwasm/swift/releases/download/$(SWIFTWASM_VERSION)/$(SWIFTWASM_VERSION)-ubuntu20.04_x86_64.tar.gz

swift-DEVELOPMENT-SNAPSHOT.tar.gz:
	curl -o $@ https://download.swift.org/development/ubuntu2004/$(UPSTREAM_VERSION)/$(UPSTREAM_VERSION)-ubuntu20.04.tar.gz

swift-%: swift-%.tar.gz
	mkdir -p $@
	tar -C $@ -xzf $@.tar.gz --strip-components=1

.PHONY: all
all: swift-DEVELOPMENT-SNAPSHOT swift-wasm-DEVELOPMENT-SNAPSHOT
