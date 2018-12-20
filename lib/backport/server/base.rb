module Backport
  module Server
    class Base
      def stopped?
        @stopped = false if @stopped.nil?
        @stopped
      end

      def stop
        stopping
        @stopped = true
      end

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

      # A callback triggered when a Machine starts running or the server is
      # added to a running machine. Subclasses should override this method to
      # provide their own functionality.
      #
      # @return [void]
      def start; end
    end
  end
end
