module Rasti
  class App
    class AsynchronicInteraction < Interaction

      def self.asynchronic?
        true
      end      

      private

      def job
        @job ||= Asynchronic[context.fetch(:job_id)].job
      end

      def enqueue(interaction, form)
        job.send :async, Job, queue:        params[:queue] || Asynchronic.default_queue,
                              alias:        params[:alias] || interaction,
                              dependency:   params[:dependency],
                              dependencies: params[:dependencies],
                              interaction:  interaction,
                              context:      context,
                              params:       form.attributes
      end

      def result_of(reference)
        job.send :result, reference
      end

    end
  end
end