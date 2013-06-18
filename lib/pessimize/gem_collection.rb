require_relative 'gem'

module Pessimize
  class GemCollection
    def initialize
      @gems = []
    end

    def add_gem(*args)
      @gems << Gem.new(*args)
    end

    def all
      gems
    end

  protected
    attr_accessor :gems
  end
end
