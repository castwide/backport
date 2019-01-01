RSpec.describe Backport::Server::Interval do
  it "yields it block on ticks" do
    var = 0
    server = Backport::Server::Interval.new(0.01) do
      var += 1
    end
    sleep 0.1
    server.tick
    expect(var).to eq(1)
  end

  it "stops itself" do
    server = Backport::Server::Interval.new(0.01) do |server|
      server.stop
    end
    server.start
    expect(server.started?).to be(true)
    sleep 0.1
    server.tick
    expect(server.stopped?).to be(true)
  end
end
