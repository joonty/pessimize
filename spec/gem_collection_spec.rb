require 'spec_helper'
require 'pessimize/gem_collection'

module Pessimize
  describe GemCollection do
    let(:collection) { GemCollection.new }

    describe "#add_gem" do
      context "adding a gem with a version" do
        before { collection.add_gem('ponies', '>= 0.3.0') }
        let(:gem) { collection.all.first }
        subject { gem }

        it { should be_a Gem }
        its(:name)    { should == 'ponies' }
        its(:version) { should == '>= 0.3.0' }

        it "should be the same as the first gem in the global group" do
          subject.should === collection.gems[:global].first
        end

        context "after setting the version" do
          before { gem.version = '~> 0.3.1' }

          its(:version) { should == '~> 0.3.1' }
        end
      end

      context "adding a gem with options" do
        before { collection.add_gem('ponies', :git => 'git@github.com:rails/rails.git') }
        subject { collection.all.first }

        it { should be_a Gem }
        its(:name)    { should == 'ponies' }
        its(:options) { should == {:git=>'git@github.com:rails/rails.git'} }

        it "should be the same as the first gem in the global group" do
          subject.should === collection.gems[:global].first
        end
      end
    end

    describe "#add_grouped_gem" do
      context "adding a gem in the development group" do
        before { collection.add_grouped_gem(:development, 'ponies', '~> 0.2.3') }
        subject { collection.all.first }

        it { should be_a Gem }
        its(:name)    { should == 'ponies' }
        its(:version) { should == '~> 0.2.3' }

        it "should be the same as the first gem in the development group" do
          subject.should === collection.gems[:development].first
        end
      end

      context "adding a gem in the production group" do
        before { collection.add_grouped_gem(:production, 'badger', '~> 1.4.1') }
        subject { collection.all.first }

        it { should be_a Gem }
        its(:name)    { should == 'badger' }
        its(:version) { should == '~> 1.4.1' }

        it "should be the same as the first gem in the production group" do
          subject.should === collection.gems[:production].first
        end
      end
    end

    describe "#add_declaration" do
      context "adding a source declaration" do
        before { collection.add_declaration('source', 'https://rubygems.org') }
        subject { collection.declarations.first }

        it { should be_a Declaration }
        its(:name) { should == 'source' }
        its(:to_code) { should == 'source "https://rubygems.org"' }
      end

      context "adding a git declaration" do
        before { collection.add_declaration('git', 'git://github.com/wycats/thor.git', :tag => 'v0.13.4') }
        subject { collection.declarations.first }

        it { should be_a Declaration }
        its(:name) { should == 'git' }
        its(:to_code) { should == 'git "git://github.com/wycats/thor.git", {:tag=>"v0.13.4"}' }
      end
    end
  end
end
