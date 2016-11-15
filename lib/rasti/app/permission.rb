module Rasti
  class App
    class Permission < String

      SEPARATOR = '.'

      def initialize(*args)
        super Array(args).flatten.map(&:to_s).join(SEPARATOR)
      end

      def include?(permission)
        other = Permission.new permission
        sections.count <= other.sections.count && self == other.sections.take(sections.count).join(SEPARATOR)
      end

      def sections
        split SEPARATOR
      end

      def last_section
        sections.last
      end
      
    end
  end
end