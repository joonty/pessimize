require 'spec_helper'
require 'pessimize/gem.rb'

module Pessimize
  describe Gem do
    context "creating a gem with just a name" do
      let(:gem) { Gem.new(Ripper.lex('gem "monkey"')) }
      subject { gem }

      its(:name) { should == "monkey" }
      its(:version) { should be_nil }
      its(:to_s) { should == 'gem "monkey"' }

      context "after setting the version" do
        before do
          gem.version = "~> 2.3.5"
        end

        its(:to_s) { should == 'gem "monkey", "~> 2.3.5"' }
      end
    end

    context "creating a gem with a name and version" do
      let(:gem) { Gem.new(Ripper.lex('gem "monkey", "~> 3.0"')) }
      subject { gem }

      its(:name) { should == "monkey" }
      its(:version) { should == "~> 3.0" }
      its(:to_s) { should == 'gem "monkey", "~> 3.0"' }

      context "after setting the version" do
        before do
          gem.version = "~> 1.0"
        end

        its(:to_s) { should == 'gem "monkey", "~> 1.0"' }
      end
    end

    context "creating a gem with a name and git url" do
      let(:gem) { Gem.new(Ripper.lex('gem "something", git: git@somewhere.org:project.git')) }
      subject { gem }

      its(:name) { should == "something" }
      its(:version) { should be_nil }

      context "after setting the version" do
        before do
          gem.version = "~> 0.0.1"
        end

        its(:to_s) { should == 'gem "something", "~> 0.0.1", git: git@somewhere.org:project.git' }
      end

    end

    context "creating a gem with a name, version and options" do
      let(:gem) { Gem.new(Ripper.lex('gem "blah", "2.0.0beta", group: :development')) }
      subject { gem }

      its(:name) { should == "blah" }
      its(:version) { should == "2.0.0beta" }

      context "after setting the version" do
        before do
          gem.version = "~> 2.1"
        end

        its(:to_s) { should == 'gem "blah", "~> 2.1", group: :development' }
      end

    end
  end
end
