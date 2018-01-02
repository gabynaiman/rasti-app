require 'yaml'
require 'erb'
require 'inflecto'
require 'asynchronic'
require 'hash_ext'
require 'consty'
require 'multi_require'
require 'rasti-form'

module Rasti
  class App

    extend MultiRequire

    require_relative 'app/interaction'
    require_relative_pattern 'app/*'

    class << self

      extend Forwardable

      def_delegators :facade, :interactions,
                              :synchronic_interactions,
                              :asynchronic_interactions,
                              :permissions, 
                              :valid_permission?

      attr_reader :facade

      private

      def expose(namespace)
        @facade = Facade.new namespace

        facade.interactions.each do |name, specification|
          if specification.synchronic?
            define_method name do |params={}|
              call name, specification.permission, params
            end
          end

          define_method "enqueue_#{name}" do |params={}|
            enqueue name, specification.permission, params
          end
        end
      end

    end

    def initialize(container, context={})
      @container = container
      @context = context
    end

    private

    attr_reader :container, :context

    def policy
      @policy ||= (container[:policy_class] || Policy).new container, context
    end

    def call(name, permission, params={})
      form = self.class.facade.build_form name, params
      authorize! permission, form
      self.class.facade.call name, container, context, form
    end

    def enqueue(name, permission, params={})
      async_params = {
        queue:        params.delete(:queue),
        alias:        params.delete(:alias),
        dependency:   params.delete(:dependency),
        dependencies: params.delete(:dependencies)
      }

      form = self.class.facade.build_form name, params
      authorize! permission, form
      self.class.facade.enqueue name, context, form, async_params
    end

    def authorize!(permission, form)
      policy.authorize! permission, form
    end

  end
end