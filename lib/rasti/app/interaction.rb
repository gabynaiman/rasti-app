module Rasti
  class App
    class Interaction

      include Rasti::Form::Validable

      def self.build_form(params)
        constants.include?(:Form) ? const_get(:Form).new(params) : Form.new
      end

      def initialize(container, context)
        @container = container
        @context = context
      end

      def call(params)
        Thread.current[thread_form_key] = self.class.build_form(params)
        validate!
        execute
      ensure
        Thread.current[thread_form_key] = nil
      end

      private

      attr_reader :container, :context

      def form
        Thread.current[thread_form_key]
      end

      def thread_form_key
        "#{self.class.name}::Form[#{self.object_id}]"
      end

    end
  end
end