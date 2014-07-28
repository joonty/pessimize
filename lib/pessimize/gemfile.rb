require 'ripper'

module Pessimize
  class Gemfile
    attr_reader :tokens, :gems

    def initialize(contents)
      self.tokens = Ripper.lex(contents)
      self.gems = []
      parse_tokens!
    end

  protected
    attr_writer :gems, :tokens

    def parse_tokens!
      tokens.each_with_index do |tok, idx|
        if tok[1] == :on_ident && tok[2] == "gem"
          gem_toks = []
          next_tok = tokens[idx += 1]
          until next_tok.nil? || [:on_nl].include?(next_tok[1])
            gem_toks << next_tok
            next_tok = tokens[idx += 1]
          end

          self.gems << gem_toks
        end
      end
    end
  end
end
