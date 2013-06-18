require_relative 'gem'
require_relative 'declaration'

module Pessimize
  class GemCollection
    attr_reader :gems, :declarations

    def initialize
      @gems = Hash.new do |hash, missing|
        hash[missing] = []
      end
      @declarations = []
    end

    def add_gem(*args)
      add_grouped_gem(:global, *args)
    end

    def add_grouped_gem(group, *args)
      self.gems[group] << Gem.new(*args)
    end

    def add_declaration(name, *args)
      self.declarations << Declaration.new(name, *args)
    end

    def all
      gems.values.flatten
    end

  protected
    attr_writer :gems, :declarations
  end
end
