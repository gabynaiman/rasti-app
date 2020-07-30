module Rasti
  class App
    class Settings
      class << self

        def load(environment, options={})
          load_file File.join(Dir.pwd, "#{environment}.yml"), options
        end

        def load_file(filename, options={})
          Hash::Accessible.new(evaluate(File.read(filename), options)).deep_freeze
        end

        private

        def evaluate(yml, options={})
          YAML.load ERB.new(yml).result_with_hash(options)
        end

      end
    end
  end
end