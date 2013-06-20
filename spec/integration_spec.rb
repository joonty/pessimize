require 'spec_helper'

describe "running pessimize" do
  include IntegrationHelper

  before do
    setup
  end

  after do
    tear_down
  end

  context "with no Gemfile" do
    before do
      run
    end

    context "the exit status" do
      subject { status.exitstatus }

      it { should == 1 }
    end

    context "the error output" do
      subject { stderr }

      it { should include("no Gemfile exists") }
    end
  end

  context "with a simple Gemfile and Gemfile.lock" do
    let(:gemfile) { <<-EOD
source "https://rubygems.org"
gem 'json'
gem 'rake'
      EOD
    }

    let(:lockfile) { <<-EOD
GEM
  remote: https://rubygems.org/
  specs:
    json (1.2.4)
    rake (10.0.4)
      EOD
    }

    before do
      write_gemfile(gemfile)
      write_gemfile_lock(lockfile)
      run
    end

    context "the return code" do
      subject { $?.exitstatus }
      it { should == 0 }
    end

    context "the Gemfile.backup" do
      it "should be created" do
        File.exists?(tmp_path + 'Gemfile.backup').should be_true
      end

      it "should be the same as the original Gemfile" do
        gemfile_backup_contents.should == gemfile
      end
    end

    context "the Gemfile" do
      subject { gemfile_contents }

      it { should == <<-EOD
source "https://rubygems.org"

gem "json", "~> 1.2.4"
gem "rake", "~> 10.0.4"
        EOD
      }
    end

  end
end
