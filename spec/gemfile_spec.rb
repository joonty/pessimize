require 'spec_helper'
require 'pessimize/gemfile'

module Pessimize
  describe Gemfile do
    context "with a string containing a gem definition" do
      subject { Gemfile.new(<<-GEM
source "https://rubygems.org"

gem "monkey"
GEM
).gems }

      its(:length) { should == 1 }
      it " should" do
        raise subject.inspect
      end
    end
  end
end
