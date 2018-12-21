module Backport
  class Adapter
    # A hash of information about the client connection. The data can vary
    # based on the transport, e.g., :hostname and :address for TCP connections
    # or :filename for file streams.
    #
    # @return [Hash{Symbol => String, Integer}]
    attr_reader :remote

    # @param output [IO]
    # @param remote [Hash{Symbol => String, Integer}]
    def initialize output, remote = {}
      @out = output
      @remote = remote
    end

    # A callback triggered when a client connection is opening. Subclasses
    # and/or modules should override this method to provide their own
    # functionality.
    #
    # @return [void]
    def opening; end

    # A callback triggered when a client connection is closing. Subclasses
    # and/or modules should override this method to provide their own
    # functionality.
    #
    # @return [void]
    def closing; end

    # A callback triggered when the client is sending data to the server.
    # Subclasses and/or modules should override this method to provide their
    # own functionality.
    #
    # @param data [String]
    # @return [void]
    def sending(data); end

    # Send data to the client.
    #
    # @param data [String]
    # @return [void]
    def write data
      @out.write data
      @out.flush
    end

    # Send a line of data to the client.
    #
    # @param data [String]
    # @return [void]
    def write_line data
      @out.puts data
      @out.flush
    end
  end
end
