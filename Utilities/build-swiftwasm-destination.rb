#!/usr/bin/env ruby

require 'fileutils'
require 'json'

# This script is used to build the SwiftWasm toolchain for the destination
#
# Usage: build-swiftwasm-destination.rb <swiftwasm-toolchain-path> -o <output-path>

def main
  require 'optparse'
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: build-swiftwasm-destination.rb <swiftwasm-toolchain-path> -o <output-path>"

    opts.on("-o", "--output-path PATH", "Output path") do |v|
      options[:output_path] = v
    end

    opts.parse!(ARGV)
  end

  if ARGV.length != 1
    puts "Missing <swiftwasm-toolchain-path>"
    exit 1
  end

  BuildSwiftWasmDestination.new(ARGV[0], options[:output_path]).run
end

class BuildSwiftWasmDestination
  class ArtifactVariant
    attr_reader :name
    def initialize(name, output_path)
      @name = name
      @artifact_path = File.join(output_path, name)
    end

    def run(builder)
      FileUtils.mkdir_p(@artifact_path)
      write_destination_json
      write_toolset_json
      FileUtils.cp_r(File.join(builder.swiftwasm_toolchain_path, "usr"), @artifact_path)
    end

    def write_destination_json
      destination_json = {
        "schemaVersion": "3.0",
        "buildTimeTriples": ["x86_64-unknown-linux-gnu"],
        "runTimeTriples": ["wasm32-unknown-wasi"],
        "swiftResourcesPaths": ["usr/lib/swift", "usr/lib/swift_static"],
        "includeSearchPaths": [],
        "librarySearchPaths": [],
      }
      File.write(File.join(@artifact_path, "destination.json"), JSON.pretty_generate(destination_json))
    end

    def write_toolset_json
      toolset_json = {
        "schemaVersion": "1.0",
        "swiftCompiler": {
          "path": "usr/bin/swiftc",
          "extraFlags": ["-target", "wasm32-unknown-wasi", "-sdk", "usr/share/wasi-sysroot"],
        },
        "cCompiler": {
          "path": "usr/bin/clang",
          "extraFlags": ["-target", "wasm32-unknown-wasi", "--sysroot", "usr/share/wasi-sysroot"],
        },
        "cxxCompiler": {
          "path": "usr/bin/clang++",
          "extraFlags": ["-target", "wasm32-unknown-wasi", "--sysroot", "usr/share/wasi-sysroot"],
        },
        "linker": {
          "path": "usr/bin/clang++",
          "extraFlags": ["-target", "wasm32-unknown-wasi", "--sysroot", "usr/share/wasi-sysroot"],
        }
      }
      File.write(File.join(@artifact_path, "toolset.json"), JSON.pretty_generate(toolset_json))
    end
  end

  attr_reader :swiftwasm_toolchain_path

  def initialize(swiftwasm_toolchain_path, output_path)
    @swiftwasm_toolchain_path = swiftwasm_toolchain_path
    @output_path = output_path
    @artifact_variants = [
      ArtifactVariant.new("WebAssembly", output_path),
    ]
  end

  def run
    if File.exist?(@output_path)
      raise "Output path already exists: #{@output_path}"
    end
    FileUtils.mkdir_p(@output_path)
    write_info_json
    @artifact_variants.each do |artifact|
      artifact.run self
    end
  end

  def write_info_json
    info_json = {
      "schemaVersion": "1.0",
      "artifacts": {
        "swiftwasm": {
          "type": "crossCompilationDestination",
          "version": "DEVELOPMENT-SNAPSHOT",
          "variants": @artifact_variants.map do |variant|
            {
              "path": variant.name,
              "supportedTriples": ["x86_64-unknown-linux-gnu"],
            }
          end
        }
      }
    }
    File.write(File.join(@output_path, "info.json"), JSON.pretty_generate(info_json))
  end
end

main
