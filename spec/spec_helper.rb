require 'rspec'
require 'pessimize'

def data_file(name)
  File.new(File.dirname(__FILE__) + '/data/' + name)
end

