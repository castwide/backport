# Backport

A pure Ruby library for event-driven IO.

This library is designed with portability as the highest priority, which is why it's written in pure Ruby. Consider [EventMachine](https://github.com/eventmachine/eventmachine) if you need a solution that's faster, more mature, and scalable.

## Installation

Install the gem:

```
gem install backport
```

Or add it to your application's Gemfile:

```ruby
gem 'backport'
```

## Usage

This example demonstrates a simple echo server.

```ruby
require 'backport'

module MyAdapter
  def opening
    write "Opening the connection"
  end

  def closing
    write "Closing the connection"
  end

  def sending data
    write "Client sent: #{data}"
  end
end

Backport.run do
  Backport.start_tcp_server(adapter: MyAdapter)
  Backport.start_interval 1 do
    puts "tick"
  end
end
```
