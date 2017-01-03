require 'yaml'
require 'erb'
require 'inflecto'
require 'asynchronic'
require 'hash_ext'
require 'consty'
require 'multi_require'


module Rasti
  class App

    extend MultiRequire

    require_relative 'app/interaction'
    require_relative_pattern 'app/*'

    class << self

      def permissions
        @permissions ||= []
      end

      def valid_permission?(permission)
        permission = Permission.new permission
        permissions.any? { |p| permission.include? p }
      end

      def classes_in(namespace, superclass=nil)
        [].tap do |classes|
          namespace.constants.each do |name|
            constant = namespace.const_get name
            if constant.class == Module
              classes_in(constant, superclass).each { |c| classes << c }
            elsif constant.class == Class && (superclass.nil? || constant.ancestors.include?(superclass))
              classes << constant
            end
          end
        end
      end

      private

      def facade(namespace)
        classes_in(namespace, Interaction).each do |interaction|
          permission = interaction_permission interaction, namespace
          permissions << permission

          if !interaction.ancestors.include?(AsynchronicInteraction)
            define_method permission.last_section do |params={}|
              call interaction, permission, params
            end
          end
          
          define_method "enqueue_#{permission.last_section}" do |params={}|
            enqueue interaction, permission, params
          end
        end
      end

      def interaction_permission(interaction, namespace)
        Permission.new interaction.name.sub("#{namespace.name}::", '').split('::').map { |s| Inflecto.underscore s }
      end

    end

    def initialize(container, context={})
      @container = container
      @context = context
    end

    private

    attr_reader :container, :context

    def user
      context.fetch(:user)
    end

    def policy
      @policy ||= (container[:policy_class] || Policy).new container, user
    end

    def call(interaction, permission, params)
      authorize! permission, params
      interaction.new(container, context).call(params)
    end

    def enqueue(interaction, permission, params)
      authorize! permission, params

      Job.enqueue queue:       params.delete(:queue) || Asynchronic.default_queue,
                  alias:       interaction,
                  interaction: interaction,
                  context:     context,
                  params:      interaction.build_form(params).attributes
    end

    def authorize!(permission, params)
      policy.authorize! permission, params
    end

  end
end