require 'ripper'
require 'pessimize/gem'

module Pessimize
  class Gemfile
    attr_reader :gems

    def initialize(contents)
      self.tokens        = Ripper.lex(contents)
      self.gems          = []
      self.gem_token_map = []

      parse_gems_from_tokens!
    end

    def to_s
      TokenCompiler.new(tokens).compile_to_string(gems, gem_token_map)
    end

  protected
    attr_writer :gems
    attr_accessor :gem_token_map, :tokens

    def parse_gems_from_tokens!
      enum = tokens.each_with_index

      loop do
        (tok, i) = enum.next

        if tok[1] == :on_ident && tok[2] == "gem"
          gem_toks = []
          until [:on_nl].include?(enum.peek[0][1])
            (tok, j) = enum.next
            gem_toks << tok
          end

          self.gems << Pessimize::Gem.new(gem_toks)
          self.gem_token_map << [i + 1, j]
        end
      end
    rescue StopIteration
    end

    class TokenCompiler
      def initialize(tokens)
        self.tokens = tokens.dup
        self.offset = 0
      end

      def compile_to_string(gems, gem_token_map)
        gem_token_map.zip(gems).each do |(token_start, token_end), gem|
          insert_gem_into_tokens! gem, token_start, token_end
        end

        tokens.reduce("") { |a, e|
          a + e[2]
        }
      end

    protected
      attr_accessor :tokens, :offset

      def insert_gem_into_tokens!(gem, token_start, token_end)
        self.tokens[(offset + token_start)..(offset + token_end)] = gem.tokens
        self.offset += gem.tokens.length - (token_end - token_start + 1)
      end
    end
  end
end
