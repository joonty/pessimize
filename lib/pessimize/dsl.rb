module Pessimize
  class DSL
    def initialize(collector)
      @collector = collector
    end

    def parse(definition)
      instance_eval definition
    end

  protected
    attr_reader :collector

    def gem(*args)
      collector.gem(*args)
    end
  end
end
