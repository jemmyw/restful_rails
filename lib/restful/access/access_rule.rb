module Restful
  module Access
    class AccessRule
      attr_reader :type
    
      def initialize(type, options = {}, &block)
        @type = type
        @options = options
        @block = block

        create_string_array(:only)
        create_string_array(:except)
      end

      def create_string_array(sym)
        @options[sym] = [@options[sym]].flatten.map{|o| o.to_s } if @options.has_key?(sym)
      end

      # :only
      # :except

      def matches(controller, action)
        return false unless @options[:only].include?(action.to_s) if @options[:only]
        return false if @options[:except].include?(action.to_s) if @options[:except]

        if @block
          !!controller.send(:instance_eval, &@block)
        else
          true
        end
      end
    end
  end
end