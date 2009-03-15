class << ActionController::Routing::Routes;self;end.class_eval do
  alias_method :draw_without_restful, :draw

  def draw(*args, &block)
    draw_without_restful(*args, &block)
    RR::Configuration.route
  end

  def draw_without_clearing(&block)
    yield ActionController::Routing::RouteSet::Mapper.new(self)
    install_helpers
  end
end

module RR
  module Configuration
    def config(*args)
      @configuration = RR::Configuration::Base.new(*args)
      @configuration.enable
    end

    def route
      ActionController::Routing::Routes.draw_without_clearing do |map|
        @configuration.route(map)
      end
    end

    module_function :config
    module_function :route

    class Base
      include Resourcer
      cattr_accessor :current

      def initialize(*args)
        eval(args.first, binding)
      end

      def enable
        self.class.current = self
        define_controllers
      end
    end
  end
end