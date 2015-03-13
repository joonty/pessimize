require 'bundler'

module Pessimize
  class GemfileLockVersionParser
    attr_reader :versions

    def initialize
      self.versions = {}
    end

    def call(gemfile_lock_file)
      parser = Bundler::LockfileParser.new(gemfile_lock_file.read)
      self.versions = collect_names_and_versions(parser.specs)
      self
    end

  protected
    attr_writer   :versions

    def collect_names_and_versions(specs)
      Hash[specs.
            reject { |s| s.source.is_a?(Bundler::Source::Git) }.
            collect { |s| [s.name, s.version.to_s] }]
    end
  end
end
