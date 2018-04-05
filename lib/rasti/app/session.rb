module Rasti
  class App
    class Session

      attr_reader :user
      attr_accessor :job_id

      def initialize(options)
        @options = options
      end

      def user
        options.fetch(:user)
      end

      private

      attr_reader :options

    end
  end
end