require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'rspec'
require 'rspec/its'
require 'pessimize'
require 'open3'
require 'ripper'

def data_file(name)
  File.new(File.dirname(__FILE__) + '/data/' + name)
end

RSpec.configure do |c|
  c.filter_run_excluding :exclude_platform => lambda { |platform|
    RUBY_PLATFORM.to_s == platform.to_s
  }
end

module IntegrationHelper
  def setup
    Dir.mkdir('tmp')
    Dir.chdir('tmp')
  end

  def tear_down
    Dir.chdir(root_path)
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
    command = "ruby -I#{root_path}/lib #{bin_path} #{argument_string}"
    Open3.popen3 command do |_, io_stdout, io_stderr, thr|
      @stdout = io_stdout.read
      @stderr = io_stderr.read
      @status = thr.value if thr
    end
  end

  def stdout
    @stdout
  end

  def stderr
    @stderr
  end

  def status
    @status
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
