module Rasti
  class App
    class Job < Asynchronic::Job

      extend ClassConfig

      attr_config :environment

      def call
        raise "Undefined #{self.class.name}.environment" unless self.class.environment

        session = params[:session]
        session.job_id = @process.id
        interaction = params[:interaction].new self.class.environment, session
        interaction.call params[:interaction].build_form params[:params]
      end

    end
  end
end