require 'rubygems'
require 'eventmachine'


module RSocket
  OPTIONS = Hash[:port => 42252, :schema => "tcp", :host => '0.0.0.0']

  module RSocketResponder

    def set(name, value)
      OPTIONS[name] = value
    end
  end

  class RSocketServer
    attr_accessor :connections

    def initialize
      @connections = []
    end

    def start
      @signature = EventMachine.start_server(RSocket::OPTIONS[:host], RSocket::OPTIONS[:port], RSocket::Connection) do |con|
        con.server = self
      end
    end

    def stop
      EventMachine.stop_server(@signature)

      unless wait_for_connections_and_stop
        # Still some connections running, schedule a check later
        EventMachine.add_periodic_timer(1) { wait_for_connections_and_stop }
      end
    end

    def wait_for_connections_and_stop
      if @connections.empty?
        EventMachine.stop
        true
      else
        puts "Waiting for #{@connections.size} connection(s) to finish ..."
        false
      end
    end
  end

  class Connection < EventMachine::Connection
    include RSocketResponder
    attr_accessor :server

    def unbind
      server.connections.delete(self)
    end

    def post_init
      puts "-- someone connected to the echo server!"
    end

    def receive_data(data)
      send_data ">>> you sent: #{data}"
      p data.unpack('C*')
    end
  end

end

extend RSocket::RSocketResponder

$rsocket_server = RSocket::RSocketServer.new
at_exit do
  EventMachine::run {
    $rsocket_server.start
    puts "New server listening #{RSocket::OPTIONS[:port]}"
  }
end