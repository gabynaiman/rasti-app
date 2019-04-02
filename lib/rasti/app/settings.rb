module Rasti
  class App
    class Settings
      class << self

        def load(environment)
          load_file File.join(Dir.pwd, "#{environment}.yml")
        end

        def load_file(filename)
          Hash::Accessible.new(evaluate(File.read(filename))).deep_freeze
        end

        private

        def evaluate(yml)
          YAML.load ERB.new(yml).result
        end

      end
    end
  end
end