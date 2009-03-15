require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Restful::Access::RuleSet do
  describe "allow" do
    before(:each) do
      @ruleset = Restful::Access::RuleSet.new
      @controller = ActionController::Base.new
      @action = "index"
    end

    it "should return false if there are no rules" do
      @ruleset.allow(@controller, @action).should == false
    end

    it "should return false if no rules match" do
      @ruleset << mock(:access_rule, :type => :allow, :matches => false)
      @ruleset.allow(@controller, @action).should == false
    end

    it "should return false if the last rule is a deny" do
      @ruleset << mock(:access_rule, :type => :allow, :matches => true)
      @ruleset << mock(:access_rule, :type => :deny, :matches => true)
      @ruleset.allow(@controller, @action).should == false
    end

    it "should return true if the last rule is an allow" do
      @ruleset << mock(:access_rule, :type => :deny, :matches => true)
      @ruleset << mock(:access_rule, :type => :allow, :matches => true)
      @ruleset.allow(@controller, @action).should == true
    end
  end
end