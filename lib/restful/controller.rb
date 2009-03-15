module RR
  begin
    class RestfulController < ApplicationController; end
  rescue Exception => e
    class RestfulController < ActionController::Base; end
  end

  class RestfulController
    cattr_accessor :resource

    before_filter :check_access

    def check_access

    end
  end
end