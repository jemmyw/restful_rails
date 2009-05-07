module RR
  module Resourcer
    def resources
      @resources ||= []
    end

    def resource(*args, &block)
      if @current_resource
        @current_resource.resource(*args, &block)
      else
        self.resources << RR::Resource.new(*args)
        @current_resource = self.resources.last
        @current_resource.configure(&block)
        @current_resource = nil
      end
    end

    def send_to_resource(symbol, *args, &block)
      if @current_resource
        @current_resource.send_to_resource(symbol, *args, &block)
      else
        self.send(symbol, *args, &block)
      end
    end

    def method_missing(symbol, *args, &block)
      if @current_resource
        @current_resource.send(:send_to_resource, symbol, *args, &block)
      end
    end

    def route(map)
      resources.each do |resource|
        resource.route(map)
      end
    end

    def undefine_controllers
      resources.each do |resource|
        resource.undefine_controllers
      end
    end

    def define_controllers
      resources.each do |resource|
        resource.define_controllers
      end
    end
  end

  class Resource
    include RR::Resourcer
    
    attr_reader :name
    attr_accessor :create_class
    attr_reader :callbacks

    def initialize(name, options = {}, &block)
      @name = name
      @options = options

      @options[:enclosing] = [@options[:enclosing]].flatten.compact
      
      @callbacks = []
    end

    def configure(&block)
      yield self
    end

    def after(callback, &block)
      @callbacks << {:type => :after, :callback => callback, :proc => block}
    end

    def before(callback, &block)
      @callbacks << {:type => :before, :callback => callback, :proc => block}
    end

    def access_rules
      @access_rules ||= Restful::Access::RuleSet.new
    end

    def allow(*args, &block)
      access_rules << Restful::Access::AccessRule.new(:allow, *args, &block)
    end

    def deny(*args, &block)
      access_rules << Restful::Access::AccessRule.new(:deny, *args, &block)
    end

    def route(map)
      map.resources(self.name) do |inner_map|
        super(inner_map)
      end

      @options[:enclosing].each do |enclosing|
        map.resources(enclosing) do |outer_map|
          outer_map.resources(self.name) do |inner_map|
            super(inner_map)
          end
        end
      end
    end

    def undefine_controllers
      if @controller_class && self.create_class
        Object.send(:remove_const, @controller_class.name.to_sym)
      end
    end
    
    def class_name
      @class_name = "#{name.to_s.classify.pluralize}Controller"
    end

    def create_class
      @create_class ||= begin
        Kernel.const_get(class_name)
        false
      rescue NameError => e
        true
      end
    end

    def define_controllers
      if self.create_class
        eval %Q{
          class ::#{class_name} < RR::Controller::RestfulController; end
        }
        @controller_class = Kernel.const_get(class_name)

        @callbacks.each do |callback|
          @controller_class.send(callback[:type], callback[:callback], &callback[:proc])
        end
      else
        @controller_class = Kernel.const_get(class_name)
        @controller_class.send(:include, RR::Controller) unless @controller_class.included_modules.include? RR::Controller::InstanceMethods
      end
          
      @controller_class.send(:resources_controller_for, name.to_sym)
      @controller_class.restful_resource = self

      super
    end
  end
end