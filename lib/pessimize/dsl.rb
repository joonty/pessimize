module Pessimize
  class DSL
    def initialize(collector)
      @collector = collector
      @current_groups = nil
    end

    def parse(definition)
      instance_eval definition, __FILE__, __LINE__
    end

    def method_missing(name, *args)
      collector.add_declaration(name.to_s, *args)
    end

  protected
    attr_reader :collector
    attr_accessor :current_groups

    def gem(*args)
      if current_groups
        current_groups.each do |group|
          collector.add_grouped_gem(group, *args)
        end
      else
        collector.add_gem(*args)
      end
    end

    def group(group, *others)
      groups = [group].flatten + others
      if block_given?
        self.current_groups = groups
        yield
        self.current_groups = nil
      end
    end
  end
end
