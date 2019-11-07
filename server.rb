require './lib/rsocket/responder'
require './lib/rsocket/payload'
require 'rx'

set :schema, 'tcp'
set :port, 42252


# RSocket request/response
# @param payload [Payload] rsocket payload
def request_response(payload)
  puts "request/response called"
  Rx::Observable.just(payload_of("data", "metadata"))
end


def request_stream(payload)
  print "request/stream called"
  Rx::Observable.from_array([payload_of("first", "metadata"), payload_of("second", "metadata")])
end


def fire_and_forget(payload)
  print "fire_and_forget"
end