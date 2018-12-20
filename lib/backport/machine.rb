module Backport
  class Machine
    def initialize
      @stopped = true
    end

    # Run the machine. If a block is provided, it gets executed before the
    # maching starts its main loop. The main loop halts program execution
    # until the machine is stopped.
    #
    # @return [void]
    def run
      return unless stopped?
      servers.clear
      @stopped = false
      yield if block_given?
      run_server_thread
    end

    # Stop the machine.
    #
    # @return [void]
    def stop
      servers.map(&:stop)
      servers.clear
      @stopped = true
    end

    # True if the machine is stopped.
    #
    def stopped?
      @stopped ||= false
    end

    # Add a server to the machine. The server will be started when the machine
    # starts. If the machine is already running, the server will be started
    # immediately.
    #
    # @param server [Server::Base]
    # @return [void]
    def start_server server
      servers.push server
      server.start unless stopped?
    end

    private

    # @return [Array<Server::Base>]
    def servers
      @servers ||= []
    end

    def run_server_thread
      servers.map(&:start)
      until stopped?
        servers.each do |server|
          server.tick
          sleep 0.001
        end
      end
    end
  end
end
