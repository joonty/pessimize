module Pessimize
  class Declaration
    attr_reader :name, :args

    def initialize(name, *args)
      @name = name
      @args = args
    end

    def to_code
      s = ""
      s << "#{name} "
      s << args.map(&:inspect).join(", ")
      s
    end
  end
end
