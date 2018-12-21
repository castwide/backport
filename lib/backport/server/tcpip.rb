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
            if client.adapter.closed?
              client.stop
              next
            end
            input = client.read
            client.sending input unless input.nil?
          end
          clients.delete_if(&:stopped?)
        end
      end

      def starting
        start_accept_thread
      end

      def stopping
        super
        socket.close unless socket.closed?
      end

      def stopped?
        @stopped
      end

      private

      # @return [TCPSocket]
      attr_reader :socket

      def mutex
        @mutex ||= Mutex.new
      end

      def start_accept_thread
        Thread.new do
          until stopped?
            begin
              conn = socket.accept
              mutex.synchronize do
                clients.push Client.new(conn, conn, @adapter)
                clients.last.run
              end
              sleep 0.001
            rescue Exception => e
              STDERR.puts "Server stopped with exception [#{e.class}] #{e.message}"
              stop
              break
            end
          end
        end
      end
    end
  end
end
