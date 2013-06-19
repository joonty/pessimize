require 'spec_helper'
require 'pessimize/gemfile_lock_version_parser'

module Pessimize

  describe GemfileLockVersionParser do
    context "with an example lock file" do
      let(:lock_file) { data_file('Gemfile.lock.example') }
      let(:parser) { GemfileLockVersionParser.new }
      let(:gems) { { 'diff-lcs'           => '1.2.4',
                     'rake'               => '10.0.4',
                     'rspec'              => '2.13.0',
                     'rspec-core'         => '2.13.1',
                     'rspec-expectations' => '2.13.0',
                     'rspec-mocks'        => '2.13.1' } }

      before do
        parser.call lock_file
      end

      subject { parser.versions }

      its(:length) { should == 6 }
      it { should == gems }

    end
  end
end
