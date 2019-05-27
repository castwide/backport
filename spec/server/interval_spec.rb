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
    Backport.run do
      Backport.prepare_interval 0.1 do
        Backport.stop if counter == 4
        counter += 1
      end
    end
    expect(counter).to eq(5)
  end
end
