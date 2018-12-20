module Backport
  class Client
    def initialize input, output, adapter
      @in = input
      @out = output
      @adapter = make_adapter(adapter)
      @stopped = true
      @buffer = ''
    end

    def stopped?
      @stopped ||= false
    end

    def stop
      return if stopped?
      @adapter.closing
      @stopped = true
    end

    def run
      return unless stopped?
      @stopped = false
      @adapter.opening
      run_input_thread
    end

    def sending data
      @adapter.sending data
    end

    def read
      tmp = nil
      mutex.synchronize do
        tmp = @buffer.dup
        @buffer.clear
      end
      return tmp unless tmp.empty?
    end

    private

    def make_adapter cls_mod
      if cls_mod.is_a?(Class)
        @adapter = cls_mod.new(@out)
      elsif cls_mod.is_a?(Module)
        @adapter = Adapter.new(@out)
        @adapter.extend cls_mod
      else
        raise TypeError, "#{cls_mod} is not a valid Backport adapter"
      end
    end

    def mutex
      @mutex ||= Mutex.new
    end

    def run_input_thread
      Thread.new do
        until stopped?
          @in.flush
          char = @in.getbyte
          if char.nil?
            stop
            break
          end
          mutex.synchronize { @buffer.concat char }
        end
      end
    end
  end
end
