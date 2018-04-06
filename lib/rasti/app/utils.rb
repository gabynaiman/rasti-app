module Rasti
  class App
    class Utils
      class << self

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

        def namespace_of(klass)
          namespace = klass.name.split('::')[0..-2].join('::')
          namespace.empty? ? nil : Object.const_get(namespace)
        end

      end
    end
  end
end