require 'pessimize/file_manager'
require 'pessimize/pessimizer'
require 'optimist'

module Pessimize
  class Shell
    def initialize
      self.file_manager = FileManager.new
    end

    def run
      options = cli_options
      check_options! options
      verify_files!(options[:backup])
      Pessimizer.new(file_manager, options).run
    end

  protected
    attr_accessor :file_manager

    def sep(num = 1)
      "\n" * num
    end

    def cli_options
      Optimist::options do
        version "pessimize #{VERSION} (c) #{Time.now.year} Jon Cairns"
        banner <<-EOS
Usage: pessimize [options]

Add the pessimistic constraint operator to all gems in your Gemfile, restricting the maximum update version.

Run this in a directory containing a Gemfile to apply the version constraint operator to all gems, at their current version. By default, it will restrict updates to the minor version number, but this can be changed to patch level updates.

Options:
        EOS

        opt :version_constraint, "Version constraint ('minor' or 'patch')", default: 'minor', type: :string, short: 'c'
        opt :backup, "Backup existing Gemfile and Gemfile.lock", default: true, type: :boolean, short: 'b'
      end
    end

    def check_options!(options)
      constraints = %w(minor patch)
      unless constraints.include? options[:version_constraint]
        Optimist::die :version_constraint, "must be one of #{constraints.join("|")}"
      end
    end

    def verify_files!(backup)
      file_manager.gemfile? or exit_with 1, <<-ERR.strip
        error: no Gemfile exists in the current directory, exiting
      ERR

      file_manager.gemfile_lock? or exit_with 2, <<-ERR.strip
        error: no Gemfile.lock exists in the current directory, exiting
          Please run `bundle install` before running pessimize
      ERR

      if backup
        puts "Backing up Gemfile and Gemfile.lock"

        file_manager.backup_gemfile! or exit_with 3, <<-ERR.strip
          error: failed to backup existing Gemfile, exiting
        ERR

        file_manager.backup_gemfile_lock! or exit_with 4, <<-ERR.strip
          error: failed to backup existing Gemfile.lock, exiting
        ERR
        puts ""
      end
    end

    def exit_with(status, message)
      $stderr.write message
      exit status
    end
  end
end
