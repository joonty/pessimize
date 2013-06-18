require 'spec_helper'
require 'pessimize/dsl'

module Pessimize
  describe DSL do
    shared_examples "a collector receiving a gem" do |definition, *args|
      let(:collector)  { double "collector" }
      let(:dsl)        { DSL.new collector  }

      context "the collector" do
        it "should receive the gem message with correct arguments" do
          collector.should_receive(:gem).with(*args)
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

  end
end
