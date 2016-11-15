module Rasti
  class App
    class Container
      
      def initialize
        @registry = {}
        @cache = {}
        yield self if block_given?
      end

      def register(key, &block)
        registry[key] = block
      end

      def resolve(key)
        cache[key] ||= registry.fetch(key).call
      end

      alias_method :[], :resolve

      def resolve_all
        registry.each_key { |k| resolve k }
      end

      private

      attr_reader :registry, :cache

    end
  end
end