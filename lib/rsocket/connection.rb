require 'rubygems'
require 'eventmachine'
require 'rsocket/error_type'
require 'rsocket/frame'

module RSocket

  class DuplexConnection < EventMachine::Connection

    def unbind
      puts "-- someone left!"
    end

    def post_init
      puts "-- someone wants to connect server!"
    end

    def receive_data(data)
      frame_bytes = data.unpack('C*')
      if frame_bytes.length >= 12
        receive_frame(frame_bytes)
      end
    end

    def send_frame(frame)
      send_data(frame.serialize.pack('C*'))
    end

    def receive_frame(frame_bytes)
      frame = Frame.parse(frame_bytes)
      unless frame.nil?
        case frame.frame_type
        when :REQUEST_RESPONSE
          mono = request_response(Payload.new(frame.data, frame.metadata))
          mono.subscribe(
              lambda { |payload|
                payload_frame = PayloadFrame.new(frame.stream_id, 0x40)
                payload_frame.data = payload.data
                payload_frame.metadata = payload.metadata
                send_frame(payload_frame)
              },
              lambda { |error|
                error_frame = ErrorFrame.new(frame.stream_id)
                error_frame.error_code = RSocket::ErrorType::APPLICATION_ERROR
                error_frame.error_data = error.to_s.unpack("C*")
                send_frame(error_frame)
              },
              lambda {

              })
        when :REQUEST_FNF
          EventMachine.defer(proc {
            fire_and_forget(Payload.new(frame.data, frame.metadata))
          })
        when :REQUEST_STREAM
          flux = request_stream(Payload.new(frame.data, frame.metadata))
          flux.subscribe(
              lambda { |payload|
                payload_frame = PayloadFrame.new(frame.stream_id, 0x20)
                payload_frame.data = payload.data
                payload_frame.metadata = payload.metadata
                send_frame(payload_frame)
              },
              lambda { |error|
                error_frame = ErrorFrame.new(frame.stream_id)
                error_frame.error_code = RSocket::ErrorType::APPLICATION_ERROR
                error_frame.error_data = error.to_s.unpack("C*")
                send_frame(error_frame)
              },
              lambda {
                payload_frame = PayloadFrame.new(frame.stream_id, 0x40)
                send_frame(payload_frame)
              })
        when :REQUEST_CHANNEL
          raise "request channel not implemented"
        when :KEEPALIVE
          # Respond with KEEPALIVE
          if flags[7] == 1
            frame_bytes[8] = 0
            send_data(frame_bytes.pack('C*'))
          end

        else
          ## error
        end
      end
    end

  end

end
