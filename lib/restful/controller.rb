class Object
  def instance_exec(*args, &block)
    mname = "__instance_exec_#{Thread.current.object_id.abs}"
    class << self; self end.class_eval{define_method(mname, &block)}
    begin
      ret = send(mname, *args)
    ensure
      class << self; self end.class_eval{undef_method(mname)} rescue nil
    end
    
    ret
  end
end

module RR
  module Controller
    module InstanceMethods
      def restful_resource
        self.class.restful_resource
      end

      def callback(type, name, format, *args, &block)
        format_proxy = Restful::FormatProxy.new(format)

        self.restful_resource.callbacks.select{|c| c[:type] == type && c[:callback] == name}.each do |callback|
          instance_exec(format_proxy, *args, &callback[:proc])
        end

        unless format_proxy.called?
          yield
        end
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