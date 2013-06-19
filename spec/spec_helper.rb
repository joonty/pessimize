require 'rspec'
require 'pessimize'

def data_file(name)
  File.new(File.dirname(__FILE__) + '/data/' + name)
end


module IntegrationHelper
  def setup
    Dir.mkdir('tmp')
  end

  def tear_down
    system "rm -r tmp"
  end

  def root_path
    File.realpath(File.dirname(__FILE__) + "/..")
  end

  def bin_path
    root_path + "/bin/pessimize"
  end

  def tmp_path
    root_path + "/tmp/"
  end

  def run(argument_string = '')
    system "cd tmp && #{bin_path} #{argument_string}"
  end

  def write_gemfile(data)
    File.open(tmp_path + 'Gemfile', 'w') do |f|
      f.write data
    end
  end

  def write_gemfile_lock(data)
    File.open(tmp_path + 'Gemfile.lock', 'w') do |f|
      f.write data
    end
  end

  def gemfile_backup_contents
    File.read(tmp_path + 'Gemfile.backup')
  end

  def gemfile_contents
    File.read(tmp_path + 'Gemfile')
  end
end
