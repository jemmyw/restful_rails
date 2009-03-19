# Redefine the routing draw method so that we can add our routes afterwards
class << ActionController::Routing::Routes;self;end.class_eval do
  alias_method :draw_without_restful, :draw

  def draw(*args, &block)
    draw_without_restful(*args, &block)
    RR::Configuration.route
  end

  # Draw up some routes without clearing the old ones
  def draw_without_clearing(&block)
    yield ActionController::Routing::RouteSet::Mapper.new(self)
    install_helpers
  end
end

# We have to reload the dynamic controller classes when dependencies clear
# or they stop working
module ActiveSupport::Dependencies
  alias_method :clear_without_restful, :clear

  def clear
    clear_without_restful
    RR::Configuration::Base.current.reload
  end
end

module RR
  module Configuration
    def config(*args)
      @configuration = RR::Configuration::Base.new(*args)
    end

    def route
      ActionController::Routing::Routes.draw_without_clearing do |map|
        RR::Configuration::Base.current.route(map)
      end
    end

    module_function :config
    module_function :route

    class Base
      include ActionController::UrlWriter
      include Resourcer
      
      cattr_accessor :current

      def initialize(file)
        self.class.current = self
        @file = file
        load
      end

      def load
        @resources = []
        @changed = File.mtime(@file)
        eval(File.read(@file), binding)
        define_controllers
      end

      def reload
        if File.mtime(@file) > @changed
          undefine_controllers
          load
          ActionController::Routing::Routes.reload!
        else
          define_controllers
        end
      end
    end
  end
end