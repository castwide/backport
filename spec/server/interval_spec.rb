RSpec.describe Backport::Server::Interval do
  it 'yields its block on ticks' do
    var = 0
    server = Backport::Server::Interval.new(0.01) do
      var += 1
    end
    server.start
    sleep 0.1
    server.tick
    server.stop
    expect(var).to eq(1)
  end

  it 'stops itself' do
    server = Backport::Server::Interval.new 0.01 do |srvr|
      srvr.stop
    end
    server.start
    expect(server.started?).to be(true)
    sleep 0.1
    server.tick
    expect(server.stopped?).to be(true)
  end

  it 'repeats' do
    counter = 0
    Backport.run do |machine|
      Backport.prepare_interval 0.1 do
        machine.stop if counter == 4
        counter += 1
      end
    end
    expect(counter).to eq(5)
  end

  it 'ticks when its thread runs before #start returns' do
    # Delay #start returning so the ready thread checks #stopped? first
    slow_start = Class.new(Backport::Server::Interval) do
      def starting
        super
        sleep 0.05
      end
    end
    ticked = false
    machine = Backport::Machine.new
    thread = Thread.new do
      machine.run do |mach|
        mach.prepare(slow_start.new(0.01) do
          ticked = true
          mach.stop
        end)
      end
    end
    returned = !thread.join(1).nil?
    machine.stop
    thread.join
    expect(ticked).to be(true)
    expect(returned).to be(true)
  end
end
