module Rasti
  class App
    class Environment

      attr_reader :settings

      def initialize(name)
        @settings = File.exist?(name) ? Settings.load_file(name) : Settings.load(name)
      end

      def policy_for(session)
        policy_class.new self, session
      end

      private

      def policy_class
        @policy_class ||= begin
          namespace = Utils.namespace_of self.class
          namespace.nil? ? Consty.get('Policy') : Consty.get('Policy', namespace)
        rescue 
          Policy
        end
      end

    end
  end
end