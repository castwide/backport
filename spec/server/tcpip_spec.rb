require_relative '../fixtures/input_adapter'
require 'socket'

RSpec.describe Backport::Server::Tcpip do
  it "reads input on ticks" do
    input = double(IO, sysread: 'sent', flush: nil)
    server = Backport::Server::Tcpip.new(host: 'localhost', port: 99999, adapter: InputAdapter)
    server.start
    TCPSocket.open('localhost', 99999) do |s|
      s.send "sent", 0
    end
    server.tick
    server.stop
    expect(InputAdapter.received).to include('sent')
  end
end
