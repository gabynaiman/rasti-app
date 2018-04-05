module Rasti
  class App
    class Policy

      class UnauthorizedError < StandardError

        attr_reader :user, :permission

        def initialize(user, permission)
          @user = user
          @permission = permission
        end

        def message
          "Permission denied [#{user} -> #{permission}]"
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

      def initialize(environment, session)
        @environment = environment
        @session = session
      end

      def authorized?(permission, form)
        if self.class.authorizations.key? permission
          instance_exec form, &self.class.authorizations[permission]
        else
          session.user.authorized? permission
        end
      end

      def authorize!(permission, form)
        raise UnauthorizedError.new(session.user.name, permission) unless authorized? permission, form
      end

      private 

      attr_reader :environment, :session

    end
  end
end