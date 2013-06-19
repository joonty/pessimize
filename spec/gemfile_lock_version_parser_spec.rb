require 'spec_helper'
require 'pessimize/gemfile_lock_version_parser'

module Pessimize

  describe GemfileLockVersionParser do
    shared_examples "a gemfile lock parser" do |lock_file, expected_versions|

      let(:parser) { GemfileLockVersionParser.new }

      before do
        parser.call lock_file
      end

      subject { parser.versions }

      its "versions should match" do
        expected_versions.each do |name, version|
          subject[name].should == version
        end
      end
    end

    context "with an example lock file" do
      it_behaves_like "a gemfile lock parser",
        data_file('Gemfile.lock.example'),
        { 'diff-lcs'           => '1.2.4',
          'rake'               => '10.0.4',
          'rspec'              => '2.13.0',
          'rspec-core'         => '2.13.1',
          'rspec-expectations' => '2.13.0',
          'rspec-mocks'        => '2.13.1' }
    end

    context "with a larger example lock file" do
      it_behaves_like "a gemfile lock parser",
        data_file('Gemfile.lock.example2'),
        { 'actionmailer'         => '3.2.13',
          'activesupport'        => '3.2.13',
          'arel'                 => '3.0.2',
          'binman'               => '3.3.1',
          'capistrano'           => '2.15.4',
          'capybara'             => '2.0.3',
          'childprocess'         => '0.3.9',
          'climate_control'      => '0.0.3',
          'ci_reporter'          => '1.6.3',
          'rails'                => '3.2.13' }
    end
  end
end
