module Rasti
  class App
    class User

      attr_reader :name, :permissions

      def initialize(attributes={})
        @name = attributes[:name]
        @permissions = attributes.fetch(:permissions, [])
      end

      def authorized?(permission)
        permissions.any? { |p| Permission.new(p).include? permission }
      end

    end
  end
end