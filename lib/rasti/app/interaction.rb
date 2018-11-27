module Rasti
  class App
    class Interaction

      include Rasti::Form::Validable

      def self.build_form(params)
        constants.include?(:Form) ? const_get(:Form).new(params) : Form.new
      end

      def self.asynchronic?
        false
      end      

      def initialize(environment, session)
        @environment = environment
        @session = session
        @uuid = SecureRandom.uuid
      end

      def call(form)
        thread_cache[:form] = form
        validate!
        execute
      ensure
        thread_cache[:form] = nil
      end

      private

      attr_reader :environment, :session, :uuid

      def form
        thread_cache[:form]
      end

      def thread_cache
        Thread.current[thread_cache_key] ||= {}
      end

      def thread_cache_key
        "#{self.class.name}[#{uuid}]"
      end

    end
  end
end