module Backport
  module Server
    # A Backport periodical interval server.
    #
    class Interval < Base
      # @param period [Float] The interval time in seconds.
      # @param &block The proc to run on each interval.
      def initialize period, &block
        @period = period
        @block = block
        @last_time = Time.now
      end

      def tick
        now = Time.now
        return unless now - @last_time > @period
        @block.call
        @last_time = now
      end
    end
  end
end
