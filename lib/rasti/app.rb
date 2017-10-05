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
      authorize! permission, params
      self.class.facade.call name, container, context, params
    end

    def enqueue(name, permission, params={})
      authorize! permission, params
      self.class.facade.enqueue name, context, params
    end

    def authorize!(permission, params)
      policy.authorize! permission, params
    end

  end
end