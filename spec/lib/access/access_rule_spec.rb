require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
include Restful::Access


describe Restful::Access::AccessRule do
  describe "matches" do
    before(:each) do
      @controller = ActionController::Base.new
    end

    describe "options only" do
      before(:each) do
        @rule = AccessRule.new(:allow, :only => [:index])
      end

      it 'should match if the action is in the only' do
        @rule.matches(@controller, 'index').should == true
      end

      it 'should not match if the rule isnt in the only' do
        @rule.matches(@controller, 'show').should == false
      end
    end

    describe "options except" do
      before(:each) do
        @rule = AccessRule.new(:allow, :except => [:show])
      end

      it 'should match if the action is not in the except' do
        @rule.matches(@controller, 'index').should == true
      end

      it 'should not match if the action is in the except' do
        @rule.matches(@controller, 'show').should == false
      end
    end

    describe 'initiated with a block' do
      before(:each) do
        @rule = AccessRule.new(:allow) do |c,a|
          if a == 'index'
            true
          elsif a == 'show'
            nil
          else
            false
          end
        end
      end

      it 'should always return a boolean' do
        @rule.matches(@controller, 'index').should == true
        @rule.matches(@controller, 'show').should == false
        @rule.matches(@controller, 'edit').should == false
      end
    end
  end
end