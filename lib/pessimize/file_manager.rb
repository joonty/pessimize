module Pessimize
  class FileManager
    def gemfile
      'Gemfile'
    end

    def gemfile_lock
      'Gemfile.lock'
    end

    def gemfile?
      File.exist? gemfile
    end

    def gemfile_contents
      File.read gemfile
    end

    def gemfile_lock?
      File.exist? gemfile_lock
    end

    def backup_gemfile!
      backup_file! gemfile
    end

    def backup_gemfile_lock!
      backup_file! gemfile_lock
    end

  private
    def backup_file!(file)
      cmd = "cp #{file} #{file}.backup"
      puts " + #{cmd}"
      `#{cmd}`
      $?.exitstatus == 0
    end
  end
end
