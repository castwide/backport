module Backport
  module Server
    class Interval < Base
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
