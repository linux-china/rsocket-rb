require 'rubygems'
require 'eventmachine'
require 'rsocket/base'
require 'rsocket/frame'
require 'rsocket/connection'


module RSocket

  module RSocketResponderHandler
    extended RSocket::AbstractRSocket

    def set(name, value)
      $rsocket_server.set(name, value)
    end

    def accept(setup_payload, sending_rsocket)
      sending_rsocket
    end

  end

  class RSocketResponder < RSocket::DuplexConnection
    include RSocketResponderHandler

    attr_accessor :server, :sending_rsocket

    def initialize(server)
      @onclose = Rx::Subject.new
      @next_stream_id = 0
      @mode = :SERVER
      @server = server
    end

    def unbind
      puts "-- someone left!"
      @server.connections.delete(self)
    end

    def post_init
      puts "-- someone connected on server!"
      @server.connections << self
      @sending_rsocket = SendingRSocket.new(self)
    end

    #@param setup_frame [RSocket::SetupFrame]
    def receive_setup(setup_frame)
      setup_payload = ConnectionSetupPayload.new(setup_frame.metadata_encoding, setup_frame.data_encoding, setup_frame.metadata, setup_frame.data)
      @sending_rsocket = accept(setup_payload, @sending_rsocket)
      if @sending_rsocket.nil?
        dispose
      end
    end

    def dispose
      close_connection(true)
      @onclose.on_completed
    end

    def next_stream_id
      @next_stream_id = @next_stream_id + 2
    end


    class SendingRSocket
      include RSocket::AbstractRSocket

      def initialize(parent)
        @parent = parent
      end

      def fire_and_forget(payload)

      end

      #@param payload [RSocket::Payload]
      #@return [Rx::Observable]
      def request_response(payload)
        raise 'request_response not implemented'
      end

      def request_stream(payload)
        raise 'request_stream not implemented'
      end

      def request_channel(payloads)
        raise 'request_channel not implemented'
      end

      def metadata_push(payloads)
        raise 'request_channel not implemented'
      end

      def dispose
        @parent.dispose
      end

    end

  end

  class RSocketServer
    attr_accessor :connections, :option

    def initialize
      @connections = []
      @option = Hash[:port => 42252, :schema => "tcp", :host => '0.0.0.0']
    end

    def set(name, value)
      @option[name] = value
    end

    def start
      @signature = EventMachine.start_server(@option[:host], @option[:port], RSocket::RSocketResponder,self)
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


end

$rsocket_server = RSocket::RSocketServer.new

include RSocket::RSocketResponderHandler

at_exit do
  EventMachine::run {
    $rsocket_server.start
    puts "New server listening #{$rsocket_server.option[:port]}"
  }
end