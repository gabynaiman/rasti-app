module Rasti
  class App
    class Interaction

      def self.build_form(params)
        constants.include?(:Form) ? const_get(:Form).new(params) : Form.new
      end

      def initialize(container, context)
        @container = container
        @context = context
      end

      def call(params)
        execute self.class.build_form(params)
      end

      private

      attr_reader :container, :context

    end
  end
end