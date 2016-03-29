require 'spec_helper'
require 'pessimize/gemfile'

module Pessimize
  describe Gemfile do
    context "with a single gem definition" do
      let(:gem_defn) { <<-GEM
source "https://rubygems.org"

gem "monkey"
GEM
      }

      subject(:gemfile) { Gemfile.new(gem_defn) }

      its(:to_s) { should == gem_defn }

      describe "#gems" do
        subject(:gems) { gemfile.gems }

        its(:length) { should == 1 }

        describe "the first gem" do
          subject { gems.first }

          its(:name) { should == "monkey" }
        end
      end
    end

    context "with a gem definition and group" do
      let(:gem_defn) { <<-GEM
source "https://rubygems.org"

group :development do
  gem "monkey"
end
GEM
      }

      subject(:gemfile) { Gemfile.new(gem_defn) }

      its(:to_s) { should == gem_defn }

      describe "#gems" do
        subject(:gems) { gemfile.gems }

        its(:length) { should == 1 }

        describe "the first gem" do
          subject { gems.first }

          its(:name) { should == "monkey" }
        end
      end
    end

    context "with multiple gem definitions" do

      let(:gem_defn) { <<-GEM
source "https://rubygems.org"

gem "monkey", "2.0.0"

gem "thor", ">= 1.3.0"
GEM
      }

      subject(:gemfile) { Gemfile.new(gem_defn) }

      its(:to_s) { should == gem_defn }

      describe "#gems" do
        subject(:gems) { gemfile.gems }

        its(:length) { should == 2 }

        describe "the first gem" do
          subject(:gem) { gems[0] }

          its(:name) { should == "monkey" }
          its(:version) { should == "2.0.0" }
          its(:to_s) { should == ' "monkey", "2.0.0"' }

          context "setting the version" do
            before do
              gem.version = "~> 2.0.0"
            end

            its(:to_s) { should == ' "monkey", "~> 2.0.0"' }
          end
        end

        describe "the second gem" do
          subject { gems[1] }

          its(:name) { should == "thor" }
          its(:version) { should == ">= 1.3.0" }
        end
      end

      context "after setting the gem versions" do
        before do
          gemfile.gems.each do |gem|
            gem.version = "~> 1.0.0"
          end
        end

        let(:expected_defn) { <<-GEM
source "https://rubygems.org"

gem "monkey", "~> 1.0.0"

gem "thor", "~> 1.0.0"
GEM
        }

        its(:to_s) { should == expected_defn }
      end
    end

    context "with multiple gem definitions spanning multiple lines" do

      let(:gem_defn) { <<-GEM
source "https://rubygems.org"

gem "monkey",
  "2.0.0"

gem "thor",
  ">= 1.3.0"
GEM
      }

      subject(:gemfile) { Gemfile.new(gem_defn) }

      its(:to_s) { should == gem_defn }

      describe "#gems" do
        subject(:gems) { gemfile.gems }

        its(:length) { should == 2 }

        describe "the first gem" do
          subject(:gem) { gems[0] }

          its(:name) { should == "monkey" }
          its(:version) { should == "2.0.0" }
          its(:to_s) { should == %Q( "monkey",\n  "2.0.0") }

          context "setting the version" do
            before do
              gem.version = "~> 2.0.0"
            end

            its(:to_s) { should == %Q( "monkey",\n  "~> 2.0.0") }
          end
        end

        describe "the second gem" do
          subject { gems[1] }

          its(:name) { should == "thor" }
          its(:version) { should == ">= 1.3.0" }
        end
      end

      context "after setting the gem versions" do
        before do
          gemfile.gems.each do |gem|
            gem.version = "~> 1.0.0"
          end
        end

        let(:expected_defn) { <<-GEM
source "https://rubygems.org"

gem "monkey",
  "~> 1.0.0"

gem "thor",
  "~> 1.0.0"
GEM
        }

        its(:to_s) { should == expected_defn }
      end
    end

    context "with multiple gem definitions separated with comments" do

      let(:gem_defn) { <<-GEM
source "https://rubygems.org"

gem "monkey", "2.0.0" # a comment to throw things off

gem "thor", ">= 1.3.0"
GEM
      }

      subject(:gemfile) { Gemfile.new(gem_defn) }

      its(:to_s) { should == gem_defn }

      describe "#gems" do
        subject(:gems) { gemfile.gems }

        its(:length) { should == 2 }

        describe "the first gem" do
          subject(:gem) { gems[0] }

          its(:name) { should == "monkey" }
          its(:version) { should == "2.0.0" }
          its(:to_s) { should == ' "monkey", "2.0.0" ' }

          context "setting the version" do
            before do
              gem.version = "~> 2.0.0"
            end

            its(:to_s) { should == ' "monkey", "~> 2.0.0" ' }
          end
        end

        describe "the second gem" do
          subject { gems[1] }

          its(:name) { should == "thor" }
          its(:version) { should == ">= 1.3.0" }
        end
      end

      context "after setting the gem versions" do
        before do
          gemfile.gems.each do |gem|
            gem.version = "~> 1.0.0"
          end
        end

        let(:expected_defn) { <<-GEM
source "https://rubygems.org"

gem "monkey", "~> 1.0.0" # a comment to throw things off

gem "thor", "~> 1.0.0"
GEM
        }

        its(:to_s) { should == expected_defn }
      end
    end
  end
end
