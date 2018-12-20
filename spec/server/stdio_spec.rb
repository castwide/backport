require_relative '../fixtures/input_adapter'
# require 'stringio'

RSpec.describe Backport::Server::Stdio do
  it "reads input on ticks" do
    input = double(IO, sysread: 'sent', flush: nil)
    server = Backport::Server::Stdio.new(input: input, adapter: InputAdapter)
    server.start
    sleep 0.1
    server.tick
    server.stop
    sleep 0.1
    expect(InputAdapter.received).to include('sent')
  end
end
