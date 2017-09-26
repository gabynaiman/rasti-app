module Rasti
  class App
    class Policy

      class UnauthorizedError < StandardError
        def initialize(user, permission)
          super "Access denied [#{user} -> #{permission}]"
        end
      end
      
      class << self

        def authorizations
          @authorizations ||= {}
        end

        private

        def authorization(permission, &block)
          authorizations[permission] = block
        end

        def ignore(permission)
          authorization(permission) { true }
        end

      end

      def initialize(container, context)
        @container = container
        @context = context
      end

      def authorized?(permission, params)
        if self.class.authorizations.key? permission
          self.class.authorizations[permission].call params
        else
          user.authorized? permission
        end
      end

      def authorize!(permission, params)
        raise UnauthorizedError.new(user.name, permission) unless authorized? permission, params
      end

      private 

      attr_reader :container, :context

      def user
        context.fetch(:user)
      end

    end
  end
end