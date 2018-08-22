require 'spec_helper'
require 'pessimize/version_mapper'
require 'pessimize/gem'

module Pessimize
  describe VersionMapper do
    def gem(name, version = nil)
      gem_string = %Q{gem "#{name}"}
      gem_string << %Q{, "#{version}"} if version
      Gem.new(Ripper.lex(gem_string))
    end

    context "with a gem, version hash and minor constraint" do
      let(:gems)     { [ gem('example') ] }
      let(:versions) { { 'example' => '2.2.3' } }
      let(:mapper)   { VersionMapper.new }

      before do
        mapper.call gems, versions, 'minor'
      end

      subject { gems.first }

      its(:version) { should == '~> 2.2' }
    end

    context "with a gem, version hash with prerelease version, and minor constraint" do
      let(:gems)     { [ gem('example') ] }
      let(:versions) { { 'example' => '2.2.3.rc1' } }
      let(:mapper)   { VersionMapper.new }

      before do
        mapper.call gems, versions, 'minor'
      end

      subject { gems.first }

      its(:version) { should == '~> 2.2.3.rc1' }
    end

    context "with multiple gems, version hash and minor constraint" do
      let(:gems)     { [ gem('example'), gem('fish', '1.3.2') ] }
      let(:versions) { { 'example' => '1.4.9', 'fish' => '2.3.0' } }
      let(:mapper)   { VersionMapper.new }

      before do
        mapper.call gems, versions, 'minor'
      end

      context "the first gem" do
        subject { gems.first }

        its(:version) { should == '~> 1.4' }
      end

      context "the second gem" do
        subject { gems[1] }

        its(:version) { should == '~> 2.3' }
      end
    end

    context "with a gem, version hash and patch constraint" do
      let(:gems)     { [ gem('example') ] }
      let(:versions) { { 'example' => '2.2.3' } }
      let(:mapper)   { VersionMapper.new }

      before do
        mapper.call gems, versions, 'patch'
      end

      subject { gems.first }

      its(:version) { should == '~> 2.2.3' }
    end

    context "with multiple gems, version hash and patch constraint" do
      let(:gems)     { [ gem('example'), gem('fish', '1.3.2') ] }
      let(:versions) { { 'example' => '1.4.9', 'fish' => '2.3.0' } }
      let(:mapper)   { VersionMapper.new }

      before do
        mapper.call gems, versions, 'patch'
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

    context "with a gem, version hash with prerelease version, and patch constraint" do
      let(:gems)     { [ gem('example') ] }
      let(:versions) { { 'example' => '2.2.3.rc1' } }
      let(:mapper)   { VersionMapper.new }

      before do
        mapper.call gems, versions, 'patch'
      end

      subject { gems.first }

      its(:version) { should == '~> 2.2.3.rc1' }
    end
  end
end
