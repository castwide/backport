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
        begin
          socket.shutdown
        rescue Errno::ENOTCONN, IOError => e
          Backport.logger.info "Minor exception while stopping server [#{e.class}] #{e.message}"
        end
        socket.close
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
            rescue Errno::ENOTSOCK => e
              Backport.logger.info "Server stopped with minor exception [#{e.class}] #{e.message}"
              stop
              break
            rescue Exception => e
              Backport.logger.warn "Server stopped with major exception [#{e.class}] #{e.message}"
              stop
              break
            end
          end
        end
      end
    end
  end
end
