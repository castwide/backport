RSpec.describe Backport::Machine do
  it "yields blocks before running" do
    var = 0
    machine = Backport::Machine.new
    machine.run do
      var += 1
      machine.stop
    end
    expect(var).to eq(1)
  end

  it "prepares servers" do
    machine = Backport::Machine.new
    server = Backport::Server::Base.new
    machine.run do
      machine.prepare server
      expect(server).to be_started
      machine.stop
    end
  end

  it "runs the server thread" do
    machine = Backport::Machine.new
    done = false
    server = Backport::Server::Interval.new(0.1) do
      done = true
      machine.stop
    end
    machine.run do
      machine.prepare server
    end
    expect(done).to eq(true)
  end

  it "deletes stopped servers" do
    machine = Backport::Machine.new
    machine.prepare Backport::Server::Base.new
    expect(machine.servers.length).to eq(1)
    machine.update machine.servers.first
    expect(machine.servers.length).to eq(0)
  end
end
