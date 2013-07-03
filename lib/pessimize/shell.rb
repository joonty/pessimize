require 'pessimize/dsl'
require 'pessimize/gem_collection'
require 'pessimize/gemfile_lock_version_parser'
require 'pessimize/file_manager'

module Pessimize
  class Shell
    def initialize
      self.file_manager = FileManager.new
      verify_files

      self.collection = GemCollection.new
      self.dsl = DSL.new collection
      self.lock_parser = GemfileLockVersionParser.new
    end

    def run
      collect_gems_and_versions
      update_gem_versions
      write_new_gemfile
    end

  protected
    attr_accessor :collection, :dsl, :lock_parser, :file_manager

    def sep(num = 1)
      "\n" * num
    end

    def verify_files
      file_manager.gemfile? or exit_with 1, <<-ERR.strip
        error: no Gemfile exists in the current directory, exiting
      ERR

      file_manager.gemfile_lock? or exit_with 2, <<-ERR.strip
        error: no Gemfile.lock exists in the current directory, exiting
          Please run `bundle install` before running pessimize
      ERR

      file_manager.backup_gemfile! or exit_with 3, <<-ERR.strip
        error: failed to backup existing Gemfile, exiting
      ERR

      file_manager.backup_gemfile_lock! or exit_with 4, <<-ERR.strip
        error: failed to backup existing Gemfile.lock, exiting
      ERR
    end

    def exit_with(status, message)
      $stderr.write message
      exit status
    end

    def collect_gems_and_versions
      dsl.parse file_manager.gemfile_contents
      lock_parser.call File.open(file_manager.gemfile_lock)
    end

    def update_gem_versions
      collection.all.each do |gem|
        if lock_parser.versions.has_key? gem.name
          gem.version = "~> #{lock_parser.versions[gem.name]}"
        end
      end
    end

    def write_new_gemfile
      File.delete(file_manager.gemfile)
      File.open(file_manager.gemfile, 'w') do |f|
        collection.declarations.each do |dec|
          f.write(dec.to_code)
        end
        f.write sep(2)
        gem_groups = collection.gems
        global_gems = gem_groups[:global]
        gem_groups.delete :global
        gem_groups.each do |group, gems|
          f.write("group :#{group} do#{sep}")
          gems.each do |gem|
            f.write("  " + gem.to_code + sep)
          end
          f.write("end" + sep(2))
        end
        if global_gems
          global_gems.each do |gem|
            f.write(gem.to_code + sep)
          end
        end
      end
    end

  end
end
