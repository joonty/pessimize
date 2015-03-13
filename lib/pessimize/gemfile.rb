require 'ripper'
require 'pessimize/gem'

module Pessimize
  class Gemfile
    attr_reader :tokens, :gems

    def initialize(contents)
      self.tokens = Ripper.lex(contents)
      self.gems = []
      self.gem_token_map = []
      parse_tokens!
    end

    def to_s
      compiled_tokens = tokens.dup
      gem_token_map.zip(gems).each do |(tok_start, tok_end), gem|
        compiled_tokens[tok_start..tok_end] = gem.tokens
      end
      compiled_tokens.inject("") { |a, e|
        a + e[2]
      }
    end

  protected
    attr_writer :gems, :tokens
    attr_accessor :gem_token_map

    def parse_tokens!
      enum = tokens.each_with_index

      loop do
        (tok, i) = enum.next

        if tok[1] == :on_ident && tok[2] == "gem"
          gem_toks = []
          begin
            (tok, j) = enum.next
            gem_toks << tok
          end until [:on_nl].include?(enum.peek[0][1])

          p gem_toks
          self.gems << Pessimize::Gem.new(gem_toks)
          self.gem_token_map << [i + 1, j]
        end
      end
    rescue StopIteration
    end
  end
end
