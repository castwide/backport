require 'socket'

module Backport
  module Server
    # A Backport TCP server. It runs a thread to accept incoming connections
    # and automatically stops when the socket is closed.
    #
    class Tcpip < Base
      include Connectable

      def initialize host: 'localhost', port: 1117, adapter: Adapter, socket_class: TCPServer
        @socket = socket_class.new(host, port)
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

      # Accept an incoming connection using accept_nonblock. Return the
      # resulting Client if a connection was accepted or nil if no connections
      # are pending.
      #
      # @return [Client, nil]
      def accept
        result = nil
        mutex.synchronize do
          begin
            conn = socket.accept_nonblock
            addr = conn.addr(true)
            data = {
              family: addr[0],
              port: addr[1],
              hostname: addr[2],
              address: addr[3]
            }
            clients.push Client.new(conn, conn, @adapter, data)
            clients.last.run
            result = clients.last
          rescue IO::WaitReadable => e
            # ignore
          rescue Errno::ENOTSOCK, IOError => e
            Backport.logger.info "Server stopped with minor exception [#{e.class}] #{e.message}"
            stop
          rescue Exception => e
            Backport.logger.warn "Server stopped with major exception [#{e.class}] #{e.message}"
            stop
          end
        end
        result
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
            client = accept
            Backport.logger.info "Client connected: #{client.adapter.remote}" unless client.nil?
            sleep 0.01
          end
        end
      end
    end
  end
end
