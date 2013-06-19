module Pessimize
  class GemfileLockVersionParser
    attr_reader :versions

    def initialize
      self.versions = {}
      self.parse_enabled = false
    end

    def call(gemfile_lock_file)
      gemfile_lock_file.each_line do |line|
        if line.start_with? 'GEM'
          self.parse_enabled = true
        end
        if parse_enabled
          parse_line(line)
        end
      end
    end

  protected
    attr_writer :versions
    attr_accessor :parse_enabled

    def parse_line(line)
      if line =~ /^\s{4}[a-z0-9]/i
        line.strip!
        matches = /([^(]+)\([^0-9]*([^)]+)/.match(line)
        if matches
          self.versions[matches[1].strip] = matches[2]
        end
      end
    end
  end
end
