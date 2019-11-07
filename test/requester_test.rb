require "test_helper"

require 'uri'

class RequesterTest < Minitest::Test

  def test_next_stream_id
    streams = {1 => "first", 2 => "second"}
    next_stream_id = -1
    begin
      next_stream_id = next_stream_id + 2
    end until streams[next_stream_id].nil?
    puts next_stream_id
    assert_equal next_stream_id, 3
  end

end