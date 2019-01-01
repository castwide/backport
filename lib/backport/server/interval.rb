module Backport
  module Server
    # A Backport periodical interval server.
    #
    class Interval < Base
      # @param period [Float] The interval time in seconds.
      # @param block [Proc] The proc to run on each interval.
      # @yieldparam [Interval]
      def initialize period, &block
        @period = period
        @block = block
        @last_time = Time.now
      end

      def starting
        @last_time = Time.now
      end

      def tick
        now = Time.now
        return unless now - @last_time >= @period
        @block.call self
        @last_time = now
      end
    end
  end
end
