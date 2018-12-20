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
end
