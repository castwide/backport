module Backport
  class Adapter
    def initialize output
      @out = output
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

    def closed?
      @closed ||= false
    end

    def close
      return if closed?
      @closed = true
      closing
    end
  end
end
