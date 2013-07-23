require 'spec_helper'
require 'pessimize/dsl'

module Pessimize
  describe DSL do
    let(:collector)  { double "collector" }
    let(:dsl)        { DSL.new collector  }

    shared_examples "a collector receiving a gem" do |definition, *args|
      context "the collector" do
        it "should receive the gem message with correct arguments" do
          collector.should_receive(:add_gem).with(*args)
          dsl.parse definition
        end
      end
    end

    context "with a string containing a gem definition" do
      it_behaves_like "a collector receiving a gem", "gem 'monkey'", 'monkey'
    end

    context "with a string containing a gem definition with multiple arguments" do
      it_behaves_like "a collector receiving a gem", 
                      "gem 'hippo', '~> 2.0.0', :require => false",
                      'hippo', '~> 2.0.0', :require => false
    end

    context "with a string containing multiple gem definitions" do
      let(:definition) { <<-EOD
gem 'ponies', '>= 3.0.0'
gem 'shark', :require => false
        EOD
      }
      context "the collector" do
        it "should receive the gem message with correct arguments" do
          collector.should_receive(:add_gem).with('ponies', '>= 3.0.0')
          collector.should_receive(:add_gem).with('shark', :require => false)
          dsl.parse definition
        end
      end
    end

    context "with a string containing a group definition" do
      let(:definition) { <<-EOD
group :test do
  gem 'ponies', '>= 3.0.0'
end
        EOD
      }
      context "the collector" do
        it "should receive the grouped gem message with correct arguments" do
          collector.should_receive(:add_grouped_gem).with(:test, 'ponies', '>= 3.0.0')
          dsl.parse definition
        end
      end
    end

    context "with a string containing a group definition and multiple gems" do
      let(:definition) { <<-EOD
group :development do
  gem 'ponies', '>= 3.0.0'
  gem 'badgers', '~> 1.3.2', :require => false
end

gem 'ostriches', '0.0.1'
        EOD
      }
      context "the collector" do
        it "should receive the grouped gem message with correct arguments" do
          collector.should_receive(:add_grouped_gem).with(:development, 'ponies', '>= 3.0.0')
          collector.should_receive(:add_grouped_gem).with(:development, 'badgers', '~> 1.3.2', :require => false)
          collector.should_receive(:add_gem).with('ostriches', '0.0.1')
          dsl.parse definition
        end
      end
    end

    context "with a string containing a group definition with multiple arguments" do
      let(:definition) { <<-EOD
group :development, :test do
  gem 'ponies', '>= 3.0.0'
end
        EOD
      }
      context "the collector" do
        it "should receive the grouped gem message with correct arguments" do
          collector.should_receive(:add_grouped_gem).with(:development, 'ponies', '>= 3.0.0')
          collector.should_receive(:add_grouped_gem).with(:test, 'ponies', '>= 3.0.0')
          dsl.parse definition
        end
      end
    end

    context "with a string containing a group definition with an array of groups" do
      let(:definition) { <<-EOD
group [:development, :test] do
  gem 'ponies', '>= 3.0.0'
end
        EOD
      }
      context "the collector" do
        it "should receive the grouped gem message with correct arguments" do
          collector.should_receive(:add_grouped_gem).with(:development, 'ponies', '>= 3.0.0')
          collector.should_receive(:add_grouped_gem).with(:test, 'ponies', '>= 3.0.0')
          dsl.parse definition
        end
      end
    end

    context "with a string containing a source declaration and a gem" do
      let(:definition) { <<-EOD
source "https://rubygems.org"
gem 'ostriches', '0.0.1'
        EOD
      }
      context "the collector" do
        it "should receive the grouped gem message with correct arguments" do
          collector.should_receive(:add_declaration).with('source', 'https://rubygems.org')
          collector.should_receive(:add_gem).with('ostriches', '0.0.1')
          dsl.parse definition
        end
      end
    end

    context "with a string containing a git declaration and something unknown" do
      let(:definition) { <<-EOD
git 'git://github.com/wycats/thor.git', :tag => 'v0.13.4'
unknown 'sausages'
        EOD
      }
      context "the collector" do
        it "should receive the grouped gem message with correct arguments" do
          collector.should_receive(:add_declaration).with('git', 'git://github.com/wycats/thor.git', :tag => 'v0.13.4')
          collector.should_receive(:add_declaration).with('unknown', 'sausages')
          dsl.parse definition
        end
      end
    end
  end
end
