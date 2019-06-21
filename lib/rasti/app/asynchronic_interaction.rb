module Rasti
  class App
    class AsynchronicInteraction < Interaction

      def self.asynchronic?
        true
      end      

      private

      def job
        @job ||= Asynchronic[session.job_id].job
      end

      def enqueue(interaction, params)
        job.send :async, Job, queue:        params.delete(:queue) || Asynchronic.default_queue,
                              alias:        params.delete(:alias) || interaction,
                              dependency:   params.delete(:dependency),
                              dependencies: params.delete(:dependencies),
                              interaction:  interaction,
                              session:      session,
                              params:       params
      end

      def result_of(reference)
        job.send :result, reference
      end

    end
  end
end