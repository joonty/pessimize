require 'pessimize/file_manager'
require 'pessimize/pessimizer'

module Pessimize
  class Shell
    def initialize
      self.file_manager = FileManager.new
    end

    def run
      verify_files
      Pessimizer.new(file_manager).run
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
