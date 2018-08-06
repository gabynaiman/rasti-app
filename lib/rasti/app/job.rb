module Rasti
  class App
    class Job < Asynchronic::Job

      class DefaultWrapper

        def self.call(environment, session, params)
          yield
        end

      end

      extend ClassConfig

      attr_config :environment

      def call
        raise "Undefined #{self.class.name}.environment" unless self.class.environment

        wrapper = params[:wrapper] || DefaultWrapper

        session = params[:session]
        session.job_id = @process.id

        wrapper.call self.class.environment, session, params do
          interaction = params[:interaction].new self.class.environment, session
          interaction.call params[:interaction].build_form params[:params]
        end
      end

    end
  end
end