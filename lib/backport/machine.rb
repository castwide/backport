module Backport
  class Machine
    def initialize
      @stopped = true
    end

    def run
      return unless stopped?
      @stopped = false
      yield if block_given?
      run_server_thread
    end

    def stop
      servers.map(&:stop)
      servers.clear
      @stopped = true
    end

    def stopped?
      @stopped ||= false
    end

    def start_server server
      servers.push server
    end

    private

    # @return [Array<Backport::Server>]
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
        sleep 0.001
      end
    end
  end
end
