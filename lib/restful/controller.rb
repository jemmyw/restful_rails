class Object
  def instance_exec(*args, &block)
    mname = "__instance_exec_#{Thread.current.object_id.abs}"
    class << self; self end.class_eval{define_method(mname, &block)}
    begin
      ret = send(mname, *args)
    rescue Exception => e
    ensure
      class << self; self end.class_eval{undef_method(mname)} rescue nil
    end
    
    ret
  end
end

module RR
  module RestfulCallbacks
    module InstanceMethods
      def callback(type, name, format, *args, &block)
        format_proxy = Restful::FormatProxy.new(format)
        
        debugger

        self.class.restful_callbacks.select{|c| c[:type] == type && c[:callback] == name}.each do |callback|
          instance_exec(format_proxy, *args, &callback[:proc])
        end

        if block_given? && !format_proxy.called?
          yield
        end
      end
    end

    module ClassMethods
      def after(callback, &block)
        restful_callbacks << {:type => :after, :callback => callback, :proc => block}
      end

      def before(callback, &block)
        restful_callbacks << {:type => :before, :callback => callback, :proc => block}
      end

      def clear_callbacks
        @callbacks = []
      end

      def restful_callbacks
        @callbacks ||= []
      end
    end

    def self.included(base)
      base.class_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end
  end
end

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
    end

    def self.included(base) #:nodoc:
      base.class_eval do
        include InstanceMethods
        include RR::RestfulCallbacks
        extend ClassMethods
      end
    end

    base_controller = defined?(ApplicationController) ? ApplicationController : ActionController::Base

    class RestfulController < base_controller
      include RR::Controller
      before_filter :check_access
    end
  end
end