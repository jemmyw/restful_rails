require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'restful/configuration'

describe ActionController::Routing::Routes do
  describe 'draw' do
    it 'should call draw_without_restful then RR::Configuration.route' do
      ActionController::Routing::Routes.should_receive(:draw_without_restful)
      RR::Configuration.should_receive(:route)
      ActionController::Routing::Routes.draw
    end
  end

  describe 'draw_without_clearing' do
    it 'should not call clear' do
      ActionController::Routing::Routes.should_not_receive(:clear)
      ActionController::Routing::Routes.should_receive(:install_helpers)
      ActionController::Routing::Routes.draw_without_clearing do |map|
        
      end
    end
  end
end

describe RR::Configuration do
  describe "config" do
    
  end
end