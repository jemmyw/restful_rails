module RR
  module Resourcer
    def resources
      @resources ||= []
    end

    def resource(*args, &block)
      self.resources << RR::Resource.new(*args)
      @current_resource = self.resources.last
      @current_resource.configure(&block)
    end

    def method_missing(symbol, *args)
      if @current_resource
        @current_resource.send(symbol, *args)
      end
    end

    def route(map)
      resources.each do |resource|
        resource.route(map)
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

    def initialize(name, &block)
      @name = name
      @create_class = false

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
    end

    def define_controllers
      class_name = "#{name.to_s.classify.pluralize}Controller"

      begin
        Kernel.const_get(class_name)
      rescue NameError => e
        self.create_class = true
      end
      
      if self.create_class
        eval %Q{
          class ::#{class_name} < RR::Controller::RestfulController
            resources_controller_for :#{name.to_s}

            def callback(type, name, *args)
              self.class.callback(type, name, *args)
            end
          end
        }
      end
          
      @controller_class = Kernel.const_get(class_name)
      @controller_class.send(:include, RR::Controller)
      @controller_class.restful_resource = self

      super
    end
  end
end