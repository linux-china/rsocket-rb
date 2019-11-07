require 'rubygems'
require 'eventmachine'
require 'rsocket/requester'
require 'rsocket/payload'
require 'rx'


EventMachine.run {
  #rsocket = EventMachine.connect '127.0.0.1', 1235, AppRequester
  rsocket = RSocket.connect("tcp://127.0.0.1:42252", "x/x", "y/y", nil) do
    def request_response(payload)
      puts "request/response called"
      Rx::Observable.just(payload_of("data", "metadata"))
    end
  end
  rsocket.request_response(payload_of("request", "response"))
  # rsocket.fire_and_forget(payload_of("fire","forget"))
}