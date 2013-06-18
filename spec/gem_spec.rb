require 'spec_helper'
require 'pessimize/gem.rb'

module Pessimize
  describe Gem do
    context "creating with the name as the only parameter" do
      let(:gem) { Gem.new 'ponies' }
      subject   { gem }

      its(:name) { should == 'ponies' }
      its(:to_code) { should == 'gem "ponies"' }

      context "setting the version" do
        before { gem.version = '~> 3.0.0' }

        its(:version) { should == '~> 3.0.0' }
      its(:to_code) { should == 'gem "ponies", "~> 3.0.0"' }
      end
    end

    context "creating with a name and version string" do
      subject { Gem.new 'trolls', '>= 3.0' }

      its(:name) { should == 'trolls' }
      its(:version) { should == '>= 3.0' }
      its(:to_code) { should == 'gem "trolls", ">= 3.0"' }
    end

    context "creating with a name and options hash" do
      subject { Gem.new 'slow_loris', :require => false, :path => '/a/b/c' }
      its(:name) { should == 'slow_loris' }
      its(:options) { should == {:require => false, :path => '/a/b/c'} }
      its(:to_code) { should == 'gem "slow_loris", {:require=>false, :path=>"/a/b/c"}' }
    end
  end
end
