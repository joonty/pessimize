require 'pessimize/dsl'
require 'pessimize/gem_collection'
require 'pessimize/gemfile_lock_version_parser'

module Pessimize
  class Pessimizer
    def initialize(file_manager)
      self.file_manager = file_manager
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

    def collect_gems_and_versions
      dsl.parse file_manager.gemfile_contents
      puts "Collected #{collection.all.length} gems from #{file_manager.gemfile}"
      lock_parser.call File.open(file_manager.gemfile_lock)
    end

    def update_gem_versions
      puts "Updating gem versions with pessimistic operator (~>)"
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
      puts "Written new Gemfile"
    end

  end
end
