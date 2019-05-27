require_relative '../fixtures/input_adapter'
require_relative '../fixtures/close_adapter'
require 'socket'

RSpec.describe Backport::Server::Tcpip do
  it "reads input on ticks" do
    server = Backport::Server::Tcpip.new(host: '127.0.0.1', port: 9999, adapter: InputAdapter)
    server.start
    client = TCPSocket.new('127.0.0.1', 9999)
    client.send "sent", 0
    sleep 0.1
    server.tick
    client.close
    server.stop
    sleep 0.1
    expect(InputAdapter.received).to include('sent')
  end

  it "closes sockets" do
    server = Backport::Server::Tcpip.new(host: 'localhost', port: 9999)
    server.start
    server.stop
    expect(server.send(:socket)).to be_closed
  end

  it "closes connections" do
    server = Backport::Server::Tcpip.new(host: '127.0.0.1', port: 9999)
    server.start
    client = TCPSocket.new('127.0.0.1', 9999)
    sleep 0.1
    server.tick
    expect(server.clients.length).to eq(1)
    client.close
    sleep 0.1
    server.tick
    expect(server.clients.length).to eq(0)
    server.stop
  end

  it "closes clients with closed adapters" do
    server = Backport::Server::Tcpip.new(host: '127.0.0.1', port: 9999, adapter: CloseAdapter)
    server.start
    client = TCPSocket.new('127.0.0.1', 9999)
    sleep 0.1
    expect(server.clients.length).to be_zero
    server.stop
  end

  it "stops on major exceptions" do
    # A "major" exception is any exception that does not occur as an expected
    # result of an operation on a closed socket. Trying to accept a connection
    # on a closed socket, for example, can be expected to result in an
    # Errno::ENOTSOCK exception. Unexpected exceptions still close the socket
    # but emit a warning.
    socket = double(:socket, close: nil, shutdown: nil)
    allow(socket).to receive(:new).and_return(socket)
    allow(socket).to receive(:accept).and_raise(RuntimeError)
    server = Backport::Server::Tcpip.new(socket_class: socket)
    expect { server.accept }.not_to raise_error
  end

  it "stops when the socket is closed" do
    server = Backport::Server::Tcpip.new(host: 'localhost', port: 9999)
    server.start
    expect(server.stopped?).to be(false)
    server.send(:socket).close
    sleep 0.1
    expect(server.stopped?).to be(true)
  end
end
