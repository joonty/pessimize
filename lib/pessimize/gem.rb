module Pessimize
  class Gem
    attr_reader :name, :version, :options
    attr_writer :version

    def initialize(*args)
      @name = args.shift
      while arg = args.shift
        if arg.is_a? Hash
          @options = arg
        else
          @version = arg
        end
      end
    end

    def to_code
      s = ""
      s << %Q{gem "#{name}"}
      s << %Q{, "#{version}"} if version
      s << %Q{, #{options.inspect}} if options
      s
    end
  end
end
