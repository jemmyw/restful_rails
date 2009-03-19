module RR
  module Controller
    module InstanceMethods
      def restful_resource
        self.class.restful_resource
      end

      def check_access
        head(403) unless restful_resource.access_rules.allow(self, action_name)
      end
    end

    module ClassMethods
      def restful_resource
        @restful_resource
      end

      def restful_resource=(value)
        @restful_resource = value
      end

      def callback(type, name, *args)
        @restful_resource.callbacks.select{|c| c.type == type && c.name == name }.each do |callback|
          callback[:proc].call(*args)
        end
      end
    end

    def self.included(base) #:nodoc:
      base.class_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end

    begin
      class RestfulController < ApplicationController; end
    rescue Exception => e
      class RestfulController < ActionController::Base; end
    end

    class RestfulController
      before_filter :check_access
    end
  end
end