module Pessimize
  class DSL
    def initialize(collector)
      @collector = collector
      @current_group = nil
    end

    def parse(definition)
      instance_eval definition, __FILE__, __LINE__
    end

    def method_missing(name, *args)
      collector.add_declaration(name.to_s, *args)
    end

  protected
    attr_reader :collector
    attr_accessor :current_group

    def gem(*args)
      if current_group
        collector.add_grouped_gem(current_group, *args)
      else
        collector.add_gem(*args)
      end
    end

    def group(name, *args)
      if block_given?
        self.current_group = name
        yield
        self.current_group = nil
      end
    end
  end
end
