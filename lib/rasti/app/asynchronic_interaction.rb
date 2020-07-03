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
        options, attributes = Utils.split_hash params, [:queue, :alias, :dependency, :dependencies]

        job.send :async, Job, queue:        options[:queue] || Asynchronic.default_queue,
                              alias:        options[:alias] || interaction,
                              dependency:   options[:dependency],
                              dependencies: options[:dependencies],
                              interaction:  interaction,
                              session:      session,
                              params:       attributes
      end

      def result_of(reference)
        job.send :result, reference
      end

    end
  end
end