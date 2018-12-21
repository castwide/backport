require 'socket'

module Backport
  module Server
    class Tcpip < Base
      include Connectable

      def initialize host: 'localhost', port: 1117, adapter: Adapter
        @socket = TCPServer.new(host, port)
        @adapter = adapter
        @stopped = false
      end

      def tick
        mutex.synchronize do
          clients.each do |client|
            input = client.read
            client.sending input unless input.nil?
          end
        end
      end

      def starting
        start_accept_thread
      end

      def stopping
        @super
        @stopped = true
      end

      def stopped?
        @stopped
      end

      private

      attr_reader :socket

      def mutex
        @mutex ||= Mutex.new
      end

      def start_accept_thread
        Thread.new do
          until stopped?
            conn = socket.accept
            mutex.synchronize do
              addr = conn.addr(true)
              data = {
                family: addr[0],
                port: addr[1],
                hostname: addr[2],
                address: addr[3]
              }
              clients.push Client.new(conn, conn, @adapter, data)
              clients.last.run
            end
            sleep 0.001
          end
        end
      end
    end
  end
end
