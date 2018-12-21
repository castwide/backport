module Backport
  module Server
    class Base
      def started?
        @started ||= false
        @started
      end

      # Stop the server.
      #
      def stop
        stopping
        @started = false
      end

      # A callback triggered when a Machine starts running or the server is
      # added to a running machine. Subclasses should override this method to
      # provide their own functionality.
      #
      # @return [void]
      def starting; end

      # A callback triggered when the server is stopping. Subclasses should
      # override this method to provide their own functionality.
      #
      # @return [void]
      def stopping; end

      # A callback triggered from the main loop of a running Machine.
      # Subclasses should override this method to provide their own
      # functionality.
      #
      # @return [void]
      def tick; end

      def start
        starting
        @started = true
      end
    end
  end
end
