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

class DummyController < RR::Controller::RestfulController
end

describe RR::Controller::RestfulController do
  describe 'class' do
    it 'should have a restful_resource attribute' do
      DummyController.methods.include?('restful_resource').should == true
      DummyController.methods.include?('restful_resource=').should == true
    end
  end

  describe 'instance' do
    before(:each) do
      @instance = DummyController.new
    end

    it 'should have a restful_resource attribute' do
      DummyController.should_receive(:restful_resource).and_return(:test)
      @instance.restful_resource.should == :test
    end

    describe 'callback' do
      before(:each) do
        @format_mock = mock(:format)
        @format_proxy_mock = mock(:format_proxy, :called? => false)

        Restful::FormatProxy.should_receive(:new).with(@format_mock).and_return(@format_proxy_mock)

        @resource_mock = mock(:restful_resource)
        @proc = Proc.new{}
        @callback = {:type => :after, :callback => :test, :proc => @proc}
        @other_callback = {:type => :after, :callback => :not_test}

        @resource_mock.should_receive(:callbacks).and_return([@callback, @other_callback])

        @instance.should_receive(:restful_resource).and_return(@resource_mock)
      end

      it 'should call instance_exec with each matching callback' do
        @instance.should_receive(:instance_exec).once.with(@format_proxy_mock, :test_arg)
        @instance.callback(:after, :test, @format_mock, :test_arg) do

        end
      end

      it 'should yield if format is not called' do
        @format_proxy_mock.should_receive(:called?).and_return(false)
        @block_called = false
        @instance.callback(:after, :test, @format_mock) do
          @block_called = true
        end
        @block_called.should == true
      end

      it 'should not yield if format is called' do
        @format_proxy_mock.should_receive(:called?).and_return(true)
        @block_called = false
        @instance.callback(:after, :test, @format_mock) do
          @block_called = true
        end
        @block_called.should == false
      end
    end

    describe 'check_access' do
      it 'should call head(403) if restful resource access rules deny access' do
        @instance.should_receive(:restful_resource).and_return(mock(:resource, :access_rules => mock(:access_rules, :allow => false)))
        @instance.should_receive(:head).with(403)
        @instance.check_access
      end

      it 'should not do anything if restful resource access rules allow access' do
        @instance.should_receive(:restful_resource).and_return(mock(:resource, :access_rules => mock(:access_rules, :allow => true)))
        @instance.should_not_receive(:head).with(403)
        @instance.check_access
      end
    end
  end
end