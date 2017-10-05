module Rasti
  class App
    module Delegable

      def methods(*args)
        delegated_methods | super
      end

      def public_methods(*args)
        delegated_methods | super
      end

      private

      def delegated_method?(method_name)
        delegated_methods.include? method_name.to_sym
      end

      def method_missing(method_name, *args, &block)
        if delegated_method? method_name
          call_delegated_method method_name, *args, &block
        else
          super
        end
      end

      def respond_to_missing?(method_name, *args)
        delegated_method?(method_name) || super
      end

    end
  end
end