require File.dirname(__FILE__) + '/../spec_helper'
require 'restful/controller'

class Dummy
  def f
    :dummy_value
  end
end

describe Object do
  describe "instance_exec" do
    it 'should pass the block in the context of the object' do
      block = lambda{|a| [a,f]}
      dummy = Dummy.new
      dummy.instance_exec('test arg', &block).should == ['test arg', :dummy_value]
    end
  end
end

