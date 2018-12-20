module Backport
  module Server
    class Stdio < Base
      include Connectable

      def initialize input: STDIN, output: STDOUT, adapter: Adapter
        @in = input
        @out = output
        @in.binmode
        @adapter = adapter
        clients.push Client.new(input, output, adapter)
      end
    end
  end
end
