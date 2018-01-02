module Rasti
  class App
    class Job < Asynchronic::Job

      extend ClassConfig

      attr_config :container

      def call
        raise "Undefined #{self.class.name}.container" unless self.class.container
        
        context = params[:context].merge(job_id: @process.id)
        interaction = params[:interaction].new self.class.container, context
        interaction.call params[:interaction].build_form params[:params]
      end

    end
  end
end