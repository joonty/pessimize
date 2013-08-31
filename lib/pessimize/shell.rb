require 'pessimize/file_manager'
require 'pessimize/pessimizer'
require 'trollop'

module Pessimize
  class Shell
    def initialize
      self.file_manager = FileManager.new
    end

    def run
      options = Trollop::options do
        opt :version_constraint, "Version constraint ('minor' or 'patch')", default: 'minor', type: :string
      end
      unless %w(minor patch).include? options[:version_constraint]
        Trollop::die :version_constraint, "must be either 'minor' or 'patch'"
      end
      verify_files
      Pessimizer.new(file_manager, options).run
    end

    protected
    attr_accessor :file_manager

    def sep(num = 1)
      "\n" * num
    end

    def verify_files
      file_manager.gemfile? or exit_with 1, <<-ERR.strip
        error: no Gemfile exists in the current directory, exiting
      ERR

      file_manager.gemfile_lock? or exit_with 2, <<-ERR.strip
        error: no Gemfile.lock exists in the current directory, exiting
          Please run `bundle install` before running pessimize
      ERR

      puts "Backing up Gemfile and Gemfile.lock"

      file_manager.backup_gemfile! or exit_with 3, <<-ERR.strip
        error: failed to backup existing Gemfile, exiting
      ERR

      file_manager.backup_gemfile_lock! or exit_with 4, <<-ERR.strip
        error: failed to backup existing Gemfile.lock, exiting
      ERR
      puts ""
    end

    def exit_with(status, message)
      $stderr.write message
      exit status
    end
  end
end
