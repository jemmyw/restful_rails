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

    def initialize(name, &block)
      @name = name
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
      eval %Q{
        class ::#{name.to_s.classify.pluralize}Controller < RR::RestfulController
          resources_controller_for :#{name}
        end
      }

      @controller_class = Kernel.const_get("#{name.to_s.classify.pluralize}Controller")
      @controller_class.resource = self

      super
    end
  end
end