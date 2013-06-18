require_relative 'gem'

module Pessimize
  class GemCollection
    attr_reader :gems

    def initialize
      @gems = Hash.new do |hash, missing|
        hash[missing] = []
      end
    end

    def add_gem(*args)
      add_grouped_gem(:global, *args)
    end

    def add_grouped_gem(group, *args)
      @gems[group] << Gem.new(*args)
    end

    def all
      gems.values.flatten
    end

  protected
    attr_writer :gems
  end
end
