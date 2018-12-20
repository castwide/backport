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

      def stopping; end

      def tick; end

      def start; end
    end
  end
end
