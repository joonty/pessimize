require 'spec_helper'
require 'pessimize/version_mapper'
require 'pessimize/gem'

module Pessimize
  describe VersionMapper do
    context "with a gem and version hash" do
      let(:gems)     { [ Gem.new('example') ] }
      let(:versions) { { 'example' => '2.2.3' } }
      let(:mapper)   { VersionMapper.new }

      before do
        mapper.call gems, versions
      end

      subject { gems.first }

      its(:version) { should == '~> 2.2.3' }
    end

    context "with multiple gems and version hash" do
      let(:gems)     { [ Gem.new('example'), Gem.new('fish', '1.3.2') ] }
      let(:versions) { { 'example' => '1.4.9', 'fish' => '2.3.0' } }
      let(:mapper)   { VersionMapper.new }

      before do
        mapper.call gems, versions
      end

      context "the first gem" do
        subject { gems.first }

        its(:version) { should == '~> 1.4.9' }
      end

      context "the second gem" do
        subject { gems[1] }

        its(:version) { should == '~> 2.3.0' }
      end
    end
  end
end
