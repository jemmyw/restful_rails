module Restful
  class FormatProxy
    attr_reader :called
    
    def initialize(proxy)
      @proxy = proxy
      @methods = []
      @called = false

      @proxy.metaclass.class_eval do
        alias_method :old_custom, :custom
        
        def custom(mime_type, &block)
          old_custom(mime_type, &block)
          old_block = @responses[mime_type]

          @responses[mime_type] = Proc.new do |*args|
            @called = true
            old_block.call(*args)
          end
        end
      end
    end

    def method_missing(method, *args, &block)
      @proxy.send(method, *args, &block)
    end

    def called?
      called
    end
  end
end