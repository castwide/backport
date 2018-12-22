module Backport
  module Server
    # A mixin for Backport servers that communicate with clients.
    #
    # Connectable servers check clients for incoming data on each tick.
    #
    module Connectable
      def tick
        clients.each do |client|
          input = client.read
          client.sending input unless input.nil?
        end
      end

      def starting
        clients.map(&:run)
      end

      def stopping
        clients.map(&:stop)
      end

      # @retrun [Array<Client>]
      def clients
        @clients ||= []
      end
    end
  end
end
