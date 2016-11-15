module Rasti
  class App
    class Service

      def self.implements(*methods)
        methods.each do |method|
          define_method method do |*args, &block|
            adapter.public_send method, *args, &block
          end
        end
      end

      def initialize(adapter)
        @adapter = adapter
      end

      private

      attr_reader :adapter

    end
  end
end