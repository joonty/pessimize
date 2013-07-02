require 'pessimize/dsl'
require 'pessimize/gem_collection'
require 'pessimize/gemfile_lock_version_parser'

module Pessimize
  class Main
    def initialize
      self.collection = GemCollection.new
      self.dsl = DSL.new collection
      self.lock_parser = GemfileLockVersionParser.new
    end

    def run
      dsl.parse File.read('Gemfile')
      lock_parser.call File.open('Gemfile.lock')
      collection.all.each do |gem|
        if lock_parser.versions.has_key? gem.name
          gem.version = "~> #{lock_parser.versions[gem.name]}"
        end
      end

      File.delete('Gemfile')
      File.open('Gemfile', 'w') do |f|
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

  protected
    attr_accessor :collection, :dsl, :lock_parser

    def sep(num = 1)
      "\n" * num
    end
  end
end
