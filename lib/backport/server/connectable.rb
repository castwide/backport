module Backport
  module Server
    module Connectable
      def tick
        clients.each do |client|
          input = client.read
          client.sending input unless input.nil?
        end
      end

      def start
        clients.map(&:run)
      end

      def stopping
        clients.map(&:stop)
      end

      protected

      def clients
        @clients ||= []
      end
    end
  end
end
