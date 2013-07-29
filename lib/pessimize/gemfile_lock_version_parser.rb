require 'bundler/lockfile_parser'

module Pessimize
  class GemfileLockVersionParser
    attr_reader :versions

    def initialize
      self.versions = {}
      self.parse_enabled = false
    end

    def call(gemfile_lock_file)
      parser = Bundler::LockfileParser.new gemfile_lock_file.read
      self.versions = collect_names_and_versions parser.specs
      self
    end

  protected
    attr_writer   :versions
    attr_accessor :parse_enabled

    def collect_names_and_versions(specs)
      Hash[specs.collect { |s| [s.name, s.version.to_s] }]
    end
  end
end
