require 'rubygems'
require 'eventmachine'
require 'rsocket/abstract_rsocket'
require 'rsocket/connection'
require 'rsocket/frame'
require 'rsocket/payload'
require 'uri'

module RSocket

  class RSocketRequester < RSocket::DuplexConnection
    include RSocket::AbstractRSocket

    def initialize(metadata_encoding, data_encoding, setup_payload, responder_handler)
      @metadata_encoding = metadata_encoding
      @data_encoding = data_encoding
      @setup_payload = setup_payload
      @responder_handler = responder_handler
      @next_stream_id = -1
      @mode = :CLIENT
      @onclose = Rx::Subject.new
      @responder_handler = responder_handler
    end

    def post_init
      setup_frame = SetupFrame.new(0)
      setup_frame.metadata_encoding = @metadata_encoding
      setup_frame.data_encoding = @data_encoding
      unless @setup_payload.nil?
        setup_frame.metadata = @setup_payload.metadata
        setup_frame.data = @setup_payload.data
      end
      send_frame(setup_frame)
    end

    def unbind
      @onclose.on_completed
    end

    def dispose
      close_connection(true)
    end

    def receive_response(payload_frame)
      p payload_frame
    end

    def request_response(payload)
      request_response_frame = RequestResponseFrame.new(next_stream_id)
      request_response_frame.data = "Hello".unpack("C*")
      request_response_frame.metadata = "metadata".unpack("C*")
      # todo callback implementation
      send_frame(request_response_frame)
    end

    #@param payload [RSocket::Payload]
    def fire_and_forget(payload)
      EventMachine.defer(proc {
        fnf_frame = RequestFnfFrame.new(next_stream_id)
        fnf_frame.metadata = payload.metadata
        fnf_frame.data = payload.data
        send_frame(fnf_frame)
      })
    end

    def request_stream(payload)
      stream_frame = RequestStreamFrame.new(next_stream_id)
      stream_frame.metadata = payload.metadata
      stream_frame.data = payload.data
      send_frame(stream_frame)
    end

    def request_channel(payloads)
      raise 'request_channel not implemented'
    end

    #@param payload [RSocket::Payload]
    def metadata_push(payload)
      if !payload.metadata.nil? && payload.metadata.length > 0
        EventMachine.defer(proc {
          metadata_push_frame = MetadataPushFrame.new
          metadata_push_frame.metadata = payload.metadata
          send_frame(metadata_push_frame)
        })
      end
    end


    def next_stream_id
      @next_stream_id = @next_stream_id + 2
    end
  end

  def self.connect(rsocket_uri, mime_type_encoding = "text/plain", data_type_encoding = "text/plain", setup_payload = nil, responder_handler = nil)
    uri = URI.parse(rsocket_uri)
    EventMachine::connect uri.hostname, uri.port, RSocketRequester, mime_type_encoding, data_type_encoding, setup_payload, responder_handler
  end

end