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

    def initialize(environment, session)
      @environment = environment
      @session = session
    end

    private

    attr_reader :environment, :session

    def policy
      @policy ||= environment.policy_for session
    end

    def call(name, permission, params={})
      form = self.class.facade.build_form name, params
      authorize! permission, form
      result = self.class.facade.call name, environment, session, form
      after_call name, form.attributes

      result
    end

    def enqueue(name, permission, params={})
      options = {
        queue: params.delete(:queue),
        job_id: params.delete(:job_id)
      }
      
      form = self.class.facade.build_form name, params
      authorize! permission, form
      result = self.class.facade.enqueue name, session, form, options
      after_call name, form.attributes

      result
    end

    def authorize!(permission, form)
      policy.authorize! permission, form
    end

    def after_call(name, params)
    end

  end
end