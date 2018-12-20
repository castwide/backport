require_relative '../fixtures/input_adapter'
require 'socket'

RSpec.describe Backport::Server::Tcpip do
  it "reads input on ticks" do
    input = double(IO, sysread: 'sent', flush: nil)
    server = Backport::Server::Tcpip.new(host: '127.0.0.1', port: 99999, adapter: InputAdapter)
    server.start
    client = TCPSocket.new('127.0.0.1', 99999)
    client.send "sent", 0
    sleep 0.1
    server.tick
    client.close
    server.stop
    sleep 0.1
    expect(InputAdapter.received).to include('sent')
  end
end
