module Pessimize
  class GemCollection
    def initialize
      @gems = []
    end

    def add_gem(*args)
      @gems << args
    end

    def all
      gems
    end

  protected
    attr_accessor :gems
  end
end
