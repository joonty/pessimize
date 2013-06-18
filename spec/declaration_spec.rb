require 'spec_helper'
require 'pessimize/declaration'

module Pessimize
  describe Declaration do
    context "creating a 'source' declaration" do
      subject { Declaration.new 'source', 'https://rubygems.org' }
      its(:to_code) { should == 'source "https://rubygems.org"' }
    end

    context "creating a 'source' declaration with a symbol value" do
      subject { Declaration.new 'source', :rubygems }
      its(:to_code) { should == 'source :rubygems' }
    end

    context "creating a 'git' declaration" do
      subject { Declaration.new 'git', 'git://github.com/wycats/thor.git', :tag => "v0.13.4" }
      its(:to_code) { should == 'git "git://github.com/wycats/thor.git", {:tag=>"v0.13.4"}' }
    end
  end
end
