module Rasti
  class App
    class Facade

      class UndefinedInteraction < StandardError
        def initialize(name)
          super "Undefined interaction #{name}"
        end
      end


      class InteractionSpecification

        attr_reader :interaction, :namespace

        def initialize(interaction, namespace)
          @interaction = interaction
          @namespace = namespace
        end

        def name
          permission.last_section.to_sym
        end

        def permission
          @permission ||= Permission.new interaction.name.sub("#{namespace.name}::", '').split('::').map { |s| Inflecto.underscore s }
        end

        def asynchronic?
          interaction.asynchronic?
        end

        def synchronic?
          !asynchronic?
        end

      end


      class SynchronicInteractionsFactory

        include Delegable

        def initialize(facade, container, context)
          @facade = facade
          @container = container
          @context = context
        end

        private

        attr_reader :facade, :container, :context

        def delegated_methods
          facade.synchronic_interactions.keys
        end

        def call_delegated_method(interaction_name, params={})
          form = facade.build_form interaction_name, params
          facade.call interaction_name, container, context, form
        end

      end


      attr_reader :interactions

      def initialize(namespace)
        @interactions = Utils.classes_in(namespace, Interaction).each_with_object({}) do |interaction, hash|
          specificaiton = InteractionSpecification.new interaction, namespace
          hash[specificaiton.name] = specificaiton
        end
      end

      def build_form(name, params={})
        interaction_class(name).build_form params
      end

      def call(name, container, context, form)
        interaction_class(name).new(container, context).call(form)
      end

      def enqueue(name, context, form, queue=nil)
        interaction = interaction_class name
        Job.enqueue queue:        queue || Asynchronic.default_queue,
                    alias:        interaction,
                    interaction:  interaction,
                    context:      context,
                    params:       form.attributes
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

      def synchronic_interactions_factory(container, context)
        SynchronicInteractionsFactory.new self, container, context
      end

      private

      def interaction_class(name)
        raise UndefinedInteraction, name unless interactions.key?(name.to_sym)
        interactions[name.to_sym].interaction
      end

    end
  end
end
