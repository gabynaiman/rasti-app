module Rasti
  class App
    class Facade

      class UndefinedInteraction < StandardError
        def initialize(name)
          super "Undefined interaction #{name}"
        end
      end


      class InteractionSpecification

        attr_reader :interaction, :permission

        def initialize(options)
          @interaction = options.fetch(:interaction)
          @permission = options.fetch(:permission)
        end

        def asynchronic?
          interaction.asynchronic?
        end

        def synchronic?
          !asynchronic?
        end

      end


      attr_reader :interactions

      def initialize(namespace)
        @interactions = Utils.classes_in(namespace, Interaction).each_with_object({}) do |interaction, hash|
          permission = build_permission interaction, namespace
          hash[permission.last_section.to_sym] = InteractionSpecification.new interaction: interaction,
                                                                              permission: permission
        end
      end

      def call(name, container, context, params={})
        interaction_class(name).new(container, context).call(params)
      end

      def enqueue(name, context, params={})
        interaction = interaction_class name
        
        Job.enqueue queue:       params.delete(:queue) || Asynchronic.default_queue,
                    alias:       interaction,
                    interaction: interaction,
                    context:     context,
                    params:      interaction.build_form(params).attributes
      end

      def synchronic_interactions
        interactions.select { |k,v| v.synchronic? }
      end

      def asynchronic_interactions
        interactions.select { |k,v| v.asynchronic? }
      end

      def permissions
        interactions.values.map(&:permission).sort
      end

      def valid_permission?(permission)
        permission = Permission.new permission
        permissions.any? { |p| permission.include? p }
      end

      def synchronic_interactions_factory
        if !self.class.const_defined? :SynchronicInteractionsFactory
          facade = self

          klass = Class.new do

            def initialize(container, context)
              @container = container
              @context = context
            end

            facade.synchronic_interactions.each do |name, specification|
              define_method name do |params={}|
                facade.call name, container, context, params
              end
            end

            private

            attr_reader :container, :context

          end

          self.class.const_set :SynchronicInteractionsFactory, klass
        end

        SynchronicInteractionsFactory
      end

      private

      def interaction_class(name)
        raise UndefinedInteraction, name unless interactions.key?(name.to_sym)
        interactions[name.to_sym].interaction
      end

      def build_permission(interaction, namespace)
        Permission.new interaction.name.sub("#{namespace.name}::", '').split('::').map { |s| Inflecto.underscore s }
      end

    end
  end
end
