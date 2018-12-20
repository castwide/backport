require "backport/version"
require 'socket'

module Backport
  autoload :Adapter, 'backport/adapter'
  autoload :Machine, 'backport/machine'
  autoload :Server,  'backport/server'
  autoload :Client,  'backport/client'

  class << self
    def start_stdio_server adapter: Adapter
      machine.start_server Backport::Server::Stdio.new(adapter: adapter)
    end

    def start_tcp_server host: 'localhost', port: 1117, adapter: Adapter
      machine.start_server Backport::Server::Tcpip.new(host: host, port: port, adapter: adapter)
    end

    def start_interval period, &block
      machine.start_server Backport::Server::Interval.new(period, &block)
    end

    def run &block
      machine.run &block
    end

    def stop
      machine.stop
    end

    private

    def machine
      @machine ||= Machine.new
    end
  end
end
