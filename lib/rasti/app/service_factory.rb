module Rasti
  class App
    class ServiceFactory

      class << self

        def service(name, service_class=nil)
          services[name] = service_class || Consty.get(Inflecto.camelize(name), self)

          define_method name do
            cache[name] ||= begin
              adapter_class = Consty.get(settings[name][:adapter], self.class.services[name])
              self.class.services[name].new adapter_class.new(environment, settings[name][:options])
            end
          end
        end

        def services
          @services ||= {}
        end

      end

      def initialize(environment, settings)
        @environment = environment
        @settings = settings
        @cache = {}
      end

      private

      attr_reader :environment, :settings, :cache
      
    end
  end
end