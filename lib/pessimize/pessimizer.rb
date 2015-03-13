require 'pessimize/gemfile'
require 'pessimize/gemfile_lock_version_parser'
require 'pessimize/version_mapper'

module Pessimize
  class Pessimizer
    def initialize(file_manager, options)
      self.file_manager = file_manager
      self.options = options
      self.lock_parser = GemfileLockVersionParser.new
    end

    def run
      collect_gems_and_versions
      update_gem_versions
      write_new_gemfile
      puts "~> written #{gemfile.gems.length} gems to Gemfile, constrained to #{options[:version_constraint]} version updates\n\n"
    end

  protected
    attr_accessor :gemfile, :lock_parser, :file_manager, :options

    def sep(num = 1)
      "\n" * num
    end

    def collect_gems_and_versions
      self.gemfile = Gemfile.new(file_manager.gemfile_contents)
      lock_parser.call File.open(file_manager.gemfile_lock)
    end

    def update_gem_versions
      VersionMapper.new.call(gemfile.gems, lock_parser.versions, options[:version_constraint])
    end

    def write_new_gemfile
      File.delete(file_manager.gemfile)
      File.open(file_manager.gemfile, 'w') do |f|
        f.write gemfile.to_s
      end
    end
  end
end
