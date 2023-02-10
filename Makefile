.PHONY: Toolchains
Toolchains:
	make -C $@ all

Destinations/swiftwasm-DEVELOPMENT-SNAPSHOT.artifactbundle: Toolchains
	ruby Utilities/build-swiftwasm-destination.rb Toolchains/swift-wasm-DEVELOPMENT-SNAPSHOT -o Destinations/swiftwasm-DEVELOPMENT-SNAPSHOT.artifactbundle
