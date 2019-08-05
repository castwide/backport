require 'observer'

module Backport
  # A client connected to a connectable Backport server.
  #
  class Client
    include Observable

    # @return [Adapter]
    attr_reader :adapter

    # @param input [IO]
    # @param output [IO]
    # @param adapter [Class, Module]
    # @param remote [Hash]
    def initialize input, output, adapter, remote = {}
      @in = input
      @out = output
      @adapter = make_adapter(adapter, remote)
      @stopped = true
      @buffer = ''
    end

    # True if the client is stopped.
    #
    def stopped?
      @stopped ||= false
    end

    # Close the client connection.
    #
    # @note The client sets #stopped? to true and runs the adapter's #closing
    # callback. The server is responsible for implementation details like
    # closing the client's socket.
    #
    def stop
      return if stopped?
      @adapter.closing
      @stopped = true
      changed
      notify_observers self
    end

    # Start running the client. This method will start the thread that reads
    # client input from IO.
    #
    def start
      return unless stopped?
      @stopped = false
      @adapter.opening
      run_input_thread
    end
    # @deprecated Prefer #start to #run for non-blocking client/server methods
    alias run start

    # Handle a tick from the server. This method will check for client input
    # and update the adapter accordingly, or stop the client if the adapter is
    # closed.
    #
    # @return [void]
    def tick
      input = read
      @adapter.receiving input unless input.nil?
    end

    private

    # Read the client input. Return nil if the input buffer is empty.
    #
    # @return [String, nil]
    def read
      tmp = nil
      mutex.synchronize do
        tmp = @buffer.dup
        @buffer.clear
      end
      return tmp unless tmp.empty?
    end

    # @return [Adapter]
    def make_adapter cls_mod, remote
      if cls_mod.is_a?(Class) && cls_mod <= Backport::Adapter
        @adapter = cls_mod.new(@out, remote)
      elsif cls_mod.class == Module
        @adapter = Adapter.new(@out, remote)
        @adapter.extend cls_mod
      else
        raise TypeError, "#{cls_mod} is not a valid Backport adapter"
      end
    end

    # @return [Mutex]
    def mutex
      @mutex ||= Mutex.new
    end

    # Start the thread that checks the input IO for client data.
    #
    # @return [void]
    def run_input_thread
      Thread.new do
        read_input until stopped?
      end
    end

    # Read input from the client.
    #
    # @return [void]
    def read_input
      begin
        @in.flush
        chars = @in.sysread(255)
      rescue EOFError, IOError, Errno::ECONNRESET, Errno::ENOTSOCK
        chars = nil
      end
      if chars.nil?
        stop
      else
        mutex.synchronize { @buffer.concat chars }
        changed
        notify_observers self
      end
    end
  end
end
