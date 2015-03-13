module Pessimize
  class Gem
    attr_reader :name, :original_tokens
    attr_accessor :version

    def initialize(gem_tokens)
      self.original_tokens = gem_tokens
      parse_name
      parse_version
    end

    def tokens
      compiled_tokens = original_tokens.dup
      if version_index
        compiled_tokens[version_index][2] = version
      elsif version
        compiled_tokens[after_name_index..0] = version_tokens
      end
      compiled_tokens
    end

    def to_s
      tokens.inject("") { |a, t| a << t[2] }
    end

  protected
    attr_writer :name, :original_tokens
    attr_accessor :version_index,
      :token_before_version,
      :after_name_index

    def version_tokens
      [
        [[], :on_comma, ","],
        [[], :on_sp, " "],
        [[], :on_tstring_beg, "\""],
        [[], :on_tstring_content, version],
        [[], :on_tstring_end, "\""]
      ]
    end

    def parse_name
      name_index = original_tokens.index { |t| t[1] == :on_tstring_content }
      self.name = original_tokens[name_index][2]
      self.after_name_index = name_index + 2
    end

    def parse_version
      token_before_version = original_tokens.index { |t| t[1] == :on_comma }
      if token_before_version
        remaining_tokens = original_tokens[(token_before_version + 1)..-1]
        while [:on_sp, :on_tstring_beg].include? remaining_tokens.first[1]
          remaining_tokens.shift
          token_before_version += 1
        end
        if remaining_tokens.first[1] == :on_tstring_content
          self.version_index = token_before_version + 1
          self.version = remaining_tokens.first[2]
        end
      end
    end
  end
end
