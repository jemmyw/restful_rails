module RR
  module Resourcer
    def resources
      @resources ||= []
    end

    def resource(*args, &block)
      self.resources << RR::Resource.new(*args, &block)
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

      deny
      yield self
    end

    def access_rules
      @access_rules ||= []
    end

    def allow
      access_rules << :allow
    end

    def deny
      access_rules << :deny
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
        puts "Defining #{class_name}"
        eval %Q{
          class ::#{class_name} < RR::RestfulController
            resources_controller_for :#{name.to_s}
          end
        }
      end
          
      @controller_class = Kernel.const_get(class_name)
      @controller_class.resource = self if @controller_class.respond_to?(:resource)

      super
    end
  end
end