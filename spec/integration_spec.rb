require 'spec_helper'

describe "running pessimize" do
  include IntegrationHelper

  shared_examples "a working pessimizer" do |gemfile, lockfile, result, cli_args = ""|
    before do
      write_gemfile(gemfile)
      write_gemfile_lock(lockfile)
      run(cli_args)
    end

    context "after execution" do

      context "the stderr", exclude_platform: :java do
        subject { stderr }
        it { should == "" }
      end

      # exclude from jruby
      context "the return code", exclude_platform: :java do
        subject { $?.exitstatus }
        it { should == 0 }
      end

      context "the Gemfile.backup" do
        it "should be created" do
          File.exist?(tmp_path + 'Gemfile.backup').should be_true
        end

        it "should be the same as the original Gemfile" do
          gemfile_backup_contents.should == gemfile
        end
      end

      context "the Gemfile" do
        subject { gemfile_contents }

        it { should == result }
      end
    end
  end

  shared_examples "a working pessimizer without backups" do |gemfile, lockfile, result, cli_args = ""|
    before do
      write_gemfile(gemfile)
      write_gemfile_lock(lockfile)
      run(cli_args)
    end

    context "after execution" do

      context "the stderr" do
        subject { stderr }
        it { should == "" }
      end

      # exclude from jruby
      context "the return code", exclude_platform: :java do
        subject { $?.exitstatus }
        it { should == 0 }
      end

      context "the Gemfile.backup" do
        it "should not exist" do
          File.exist?(tmp_path + 'Gemfile.backup').should be_false
        end
      end

      context "the Gemfile.lock.backup" do
        it "should not exist" do
          File.exist?(tmp_path + 'Gemfile.lock.backup').should be_false
        end
      end

      context "the Gemfile" do
        subject { gemfile_contents }

        it { should == result }
      end
    end
  end

  before do
    setup
  end

  after do
    tear_down
  end

  context "with the help option" do
    before do
      run('--help')
    end

    context "the exit status", :platform => :java do
      subject { status.exitstatus }

      it { should == 0 }
    end

    context "the output" do
      subject { stdout }

      it { should include("Usage:") }
    end
  end

  context "with the version option" do
    before do
      run('--version')
    end

    context "the exit status", :platform => :java do
      subject { status.exitstatus }

      it { should == 0 }
    end

    context "the output" do
      subject { stdout }

      it { should include(Pessimize::VERSION) }
    end
  end

  context "with the version option" do
    before do
      run('-c rubbish')
    end

    context "the exit status", :platform => :java do
      subject { status.exitstatus }

      it { should == 255 }
    end

    context "the error output" do
      subject { stderr }

      it { should include("--version-constraint must be one of minor|patch") }
    end
  end

  context "with no Gemfile" do
    before do
      run
    end

    context "the exit status", :platform => :java do
      subject { status.exitstatus }

      it { should == 1 }
    end

    context "the error output" do
      subject { stderr }

      it { should include("no Gemfile exists") }
    end
  end

  context "with no Gemfile.lock" do
    before do
      write_gemfile "cheese"
      run
    end

    context "the exit status", :platform => :java do
      subject { status.exitstatus }

      it { should == 2 }
    end

    context "the error output" do
      subject { stderr }

      it { should include("no Gemfile.lock exists") }
      it { should include("Please run `bundle install`") }
    end
  end

  context "with an unreadable Gemfile" do
    before do
      write_gemfile "cheese"
      write_gemfile_lock "cheese"
      system "chmod 222 Gemfile"
      run
    end

    context "the exit status", :platform => :java do
      subject { status.exitstatus }

      it { should == 3 }
    end

    context "the error output" do
      subject { stderr }

      it { should include("failed to backup existing Gemfile, exiting") }
    end
  end

  context "with an unreadable Gemfile.lock" do
    before do
      write_gemfile "cheese"
      write_gemfile_lock "cheese"
      system "chmod 222 Gemfile.lock"
      run
    end

    context "the exit status", :platform => :java do
      subject { status.exitstatus }

      it { should == 4 }
    end

    context "the error output" do
      subject { stderr }

      it { should include("failed to backup existing Gemfile.lock, exiting") }
    end
  end

  context "with a simple Gemfile and Gemfile.lock" do
    gemfile = <<-EOD
source "https://rubygems.org"
gem 'json'
gem 'rake'
    EOD

    lockfile = <<-EOD
GEM
  remote: https://rubygems.org/
  specs:
    json (1.8.0)
    rake (10.0.4)
    EOD

    result = <<-EOD
source "https://rubygems.org"
gem 'json', "~> 1.8"
gem 'rake', "~> 10.0"
    EOD

    it_behaves_like "a working pessimizer", gemfile, lockfile, result
  end

  context "with a Gemfile containing groups" do
    gemfile = <<-EOD
source "https://rubygems.org"
gem 'json'
gem 'rake'

group :development do
  gem 'sqlite3', '>= 1.3.7'
end

group :production do
  gem 'pg', '>= 0.15.0', '<= 0.15.2'
end
    EOD

    lockfile = <<-EOD
GEM
  remote: https://rubygems.org/
  specs:
    json (1.8.0)
    rake (10.0.4)
    pg (0.15.0)
    sqlite3 (1.3.7)
    EOD

    result = <<-EOD
source "https://rubygems.org"
gem 'json', "~> 1.8"
gem 'rake', "~> 10.0"

group :development do
  gem 'sqlite3', '~> 1.3'
end

group :production do
  gem 'pg', '~> 0.15', '<= 0.15.2'
end
    EOD

    it_behaves_like "a working pessimizer", gemfile, lockfile, result
  end

  context "with a Gemfile containing a group with multiple arguments" do
    gemfile = <<-EOD
source "https://rubygems.org"
gem 'json'
gem 'rake'

group :development, :test do
  gem 'sqlite3', '>= 1.3.7'
end
    EOD

    lockfile = <<-EOD
GEM
  remote: https://rubygems.org/
  specs:
    json (1.8.0)
    rake (10.0.4)
    sqlite3 (1.3.7)
    EOD

    result = <<-EOD
source "https://rubygems.org"
gem 'json', "~> 1.8"
gem 'rake', "~> 10.0"

group :development, :test do
  gem 'sqlite3', '~> 1.3'
end
    EOD

    it_behaves_like "a working pessimizer", gemfile, lockfile, result
  end

  context "with a Gemfile containing a group with an array argument" do
    gemfile = <<-EOD
source "https://rubygems.org"
gem 'json'
gem 'rake'

group [:development, :test] do
  gem 'sqlite3', '>= 1.3.7'
end
    EOD

    lockfile = <<-EOD
GEM
  remote: https://rubygems.org/
  specs:
    json (1.8.0)
    rake (10.0.4)
    sqlite3 (1.3.7)
    EOD

    result = <<-EOD
source "https://rubygems.org"
gem 'json', "~> 1.8"
gem 'rake', "~> 10.0"

group [:development, :test] do
  gem 'sqlite3', '~> 1.3'
end
    EOD

    it_behaves_like "a working pessimizer", gemfile, lockfile, result
  end


  context "with a Gemfile containing multiple source statements" do
    gemfile = <<-EOD
source "https://rubygems.org"
source 'https://somewhereelse.com'
    EOD

    lockfile = <<-EOD
GEM
  remote: https://rubygems.org/
  specs:
    json (1.8.0)
    EOD

    result = <<-EOD
source "https://rubygems.org"
source 'https://somewhereelse.com'
    EOD

    it_behaves_like "a working pessimizer", gemfile, lockfile, result
  end

  context "with a Gemfile containing gems with options" do
    gemfile = <<-EOD
source "https://somewhere-else.org"
gem 'metric_fu', :git => 'https://github.com/joonty/metric_fu.git', :branch => 'master'

gem "kaminari", :require => false
    EOD

    lockfile = <<-EOD
GIT
  remote: https://github.com/joonty/metric_fu.git
  revision: 8c481090ac928c78ed1f794b4e76b178e1ccf713
  specs:
    bf4-metric_fu (2.1.3.1)
      activesupport (2.0.0)
      arrayfields (= 4.7.4)
      bluff
      chronic (= 0.2.3)
      churn (= 0.0.7)
      coderay
      fattr (= 2.2.1)
      flay (= 1.2.1)
      flog (= 2.3.0)
      googlecharts
      japgolly-Saikuro (1.1.1.0)
      main (= 4.7.1)
      map (= 6.2.0)
      rails_best_practices (~> 0.6)
      rcov (~> 0.8)
      reek (= 1.2.12)
      roodi (= 2.1.0)

GEM
  remote: https://rubygems.org/
  specs:
    kaminari (0.14.1)
    EOD

    result = <<-EOD
source "https://somewhere-else.org"
gem 'metric_fu', :git => 'https://github.com/joonty/metric_fu.git', :branch => 'master'

gem "kaminari", "~> 0.14", :require => false
    EOD

    it_behaves_like "a working pessimizer", gemfile, lockfile, result
  end

  context "with a Gemfile that hasn't been installed" do
    gemfile = <<-EOD
source "https://somewhere-else.org"
gem 'metric_fu', :git => 'https://github.com/joonty/metric_fu.git', :branch => 'master'

gem "kaminari", :require => false
    EOD

    lockfile = <<-EOD
GIT
  remote: https://github.com/joonty/metric_fu.git
  revision: 8c481090ac928c78ed1f794b4e76b178e1ccf713
  specs:
    bf4-metric_fu (2.1.3.1)
      activesupport (2.0.0)
      arrayfields (= 4.7.4)
      bluff
      chronic (= 0.2.3)
      churn (= 0.0.7)
      coderay
      fattr (= 2.2.1)
      flay (= 1.2.1)
      flog (= 2.3.0)
      googlecharts
      japgolly-Saikuro (1.1.1.0)
      main (= 4.7.1)
      map (= 6.2.0)
      rails_best_practices (~> 0.6)
      rcov (~> 0.8)
      reek (= 1.2.12)
      roodi (= 2.1.0)

GEM
  remote: https://rubygems.org/
  specs:
    kaminari (0.14.1)
    EOD

    result = <<-EOD
source "https://somewhere-else.org"
gem 'metric_fu', :git => 'https://github.com/joonty/metric_fu.git', :branch => 'master'

gem "kaminari", "~> 0.14", :require => false
    EOD

    it_behaves_like "a working pessimizer", gemfile, lockfile, result
  end

  context "with the option to use patch level constraints" do
    gemfile = <<-EOD
source "https://rubygems.org"
gem 'json'
gem 'rake'

group :development, :test do
  gem 'sqlite3', '>= 1.3.7'
end
    EOD

    lockfile = <<-EOD
GEM
  remote: https://rubygems.org/
  specs:
    json (1.8.0)
    rake (10.0.4)
    sqlite3 (1.3.7)
    EOD

    result = <<-EOD
source "https://rubygems.org"
gem 'json', "~> 1.8.0"
gem 'rake', "~> 10.0.4"

group :development, :test do
  gem 'sqlite3', '~> 1.3.7'
end
    EOD

    it_behaves_like "a working pessimizer", gemfile, lockfile, result, '-c patch'
  end

  context "with the option to not have backups" do
    gemfile = <<-EOD
source "https://rubygems.org"
gem 'json'
gem 'rake'

group :development, :test do
  gem 'sqlite3', '>= 1.3.7'
end
    EOD

    lockfile = <<-EOD
GEM
  remote: https://rubygems.org/
  specs:
    json (1.8.0)
    rake (10.0.4)
    sqlite3 (1.3.7)
    EOD

    result = <<-EOD
source "https://rubygems.org"
gem 'json', "~> 1.8"
gem 'rake', "~> 10.0"

group :development, :test do
  gem 'sqlite3', '~> 1.3'
end
    EOD

    it_behaves_like "a working pessimizer without backups", gemfile, lockfile, result, '--no-backup'
  end

  context "with a Gemfile using new lines for gem definitions" do
    gemfile = <<-EOD
source "https://rubygems.org"
gem 'json',
  group: :production

gem 'pessimize',
  github: "joonty/pessimize"

group :development, :test do
  gem 'sqlite3',
    '>= 1.3.7'
end
    EOD

    lockfile = <<-EOD
GIT
  remote: git://github.com/joonty/pessimize.git
  revision: 40f6ec6c7483a453b72e09efbba0e0d7de3b37ab
  specs:
    pessimize (0.2.0)
      bundler
      optimist

GEM
  remote: https://rubygems.org/
  specs:
    json (1.8.0)
    optimist (3.0.1)
    sqlite3 (1.3.7)
    EOD

    result = <<-EOD
source "https://rubygems.org"
gem 'json', "~> 1.8",
  group: :production

gem 'pessimize',
  github: "joonty/pessimize"

group :development, :test do
  gem 'sqlite3',
    '~> 1.3'
end
    EOD

    it_behaves_like "a working pessimizer", gemfile, lockfile, result
  end
end
