module Backport
  class Adapter
    def initialize output
      @out = output
    end

    def opening
      STDERR.puts "Opening"
    end

    def closing
      STDERR.puts "Closing"
    end

    def sending data
      STDERR.puts "Client sent #{data}"
    end

    def write data
      @out.print data
    end

    def write_line data
      @out.puts data
    end
  end
end
