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

      alias_method :to_s, :inspect

      private

      attr_reader :options

    end
  end
end