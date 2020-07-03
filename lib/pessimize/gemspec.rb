require 'pessimize/gemfile'

module Pessimize
  class Gemspec < Gemfile
  protected

    def parse_gems_from_tokens!
      enum = tokens.each_with_index

      loop do
        (tok, i) = enum.next

        if tok[1] == :on_ident && (tok[2] == "add_dependency" || tok[2] == "add_development_dependency")
          gem_toks = []
          until all_gem_tokens_collected?(tok[0], enum.peek[0])
            (tok, j) = enum.next
            gem_toks << tok
          end

          self.gems << Pessimize::Gem.new(gem_toks)
          self.gem_token_map << [i + 1, j]
        end
      end
    rescue StopIteration
    end
  end
end
