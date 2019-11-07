require 'rx'
require 'rsocket/payload'

module RSocket

  module AbstractRSocket

    attr_accessor :onclose

    def fire_and_forget(payload)
      raise 'fire_and_forget not implemented'
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
      raise 'metadata_push not implemented'
    end

    def dispose

    end

  end


end