require 'spec_helper'

describe "running pessimize" do
  let(:root_path) { File.realpath(File.dirname(__FILE__) + "/..") }
  let(:bin_path)  { root_path + "/bin/pessimize" }
  let(:tmp_path)  { root_path + "/tmp/" }

  before do
    Dir.mkdir('tmp')
  end

  after do
    system "rm -r tmp"
  end

  context "with a simple Gemfile and Gemfile.lock" do
    let(:gemfile) { <<-EOD
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
      File.open(tmp_path + 'Gemfile', 'w') do |f|
        f.write gemfile
      end

      File.open(tmp_path + 'Gemfile.lock', 'w') do |f|
        f.write lockfile
      end

      system "cd #{tmp_path} && #{bin_path}"
    end

    context "the return code" do
      subject { $? }
      it { should == 0 }
    end

    context "the Gemfile.backup" do
      it "should be created" do
        File.exists?(tmp_path + 'Gemfile.backup').should be_true
      end

      it "should be the same as the original Gemfile" do
      end
    end

  end
end
