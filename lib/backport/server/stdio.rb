module Backport
  module Server
    # A Backport STDIO server.
    #
    class Stdio < Base
      include Connectable

      def initialize input: STDIN, output: STDOUT, adapter: Adapter
        @in = input
        @out = output
        @out.binmode
        @adapter = adapter
        clients.push Client.new(input, output, adapter)
        clients.last.add_observer self
      end

      def update client
        client.tick
      end
    end
  end
end
