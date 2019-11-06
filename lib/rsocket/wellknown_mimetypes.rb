module RSocket

  class WellKnownType
    attr_reader :name, :identifier
    def initialize(name, identifier)
      @name = name
      @identifier = identifier
      RSocket::WellKnownTypes::MIME_TYPES_BY_ID[identifier] = self
      RSocket::WellKnownTypes::MIME_TYPES_BY_NAME[name] = self
    end
  end

  module WellKnownTypes
    MIME_TYPES_BY_ID = {}
    MIME_TYPES_BY_NAME = {}

    APPLICATION_AVRO = WellKnownType.new("application/avro", 0x00)
    APPLICATION_CBOR = WellKnownType.new("application/cbor", 0x01)
    APPLICATION_GRAPHQL = WellKnownType.new("application/graphql", 0x02)
    APPLICATION_GZIP = WellKnownType.new("application/gzip", 0x03)
    APPLICATION_JAVASCRIPT = WellKnownType.new("application/javascript", 0x04)
    APPLICATION_JSON = WellKnownType.new("application/json", 0x05)
    APPLICATION_OCTET_STREAM = WellKnownType.new("application/octet-stream", 0x06)
    APPLICATION_PDF = WellKnownType.new("application/pdf", 0x07)
    APPLICATION_THRIFT = WellKnownType.new("application/vnd.apache.thrift.binary", 0x08)
    APPLICATION_PROTOBUF = WellKnownType.new("application/vnd.google.protobuf", 0x09)
    APPLICATION_XML = WellKnownType.new("application/xml", 0x0A)
    APPLICATION_ZIP = WellKnownType.new("application/zip", 0x0B)
    AUDIO_AAC = WellKnownType.new("audio/aac", 0x0C)
    AUDIO_MP3 = WellKnownType.new("audio/mp3", 0x0D)
    AUDIO_MP4 = WellKnownType.new("audio/mp4", 0x0E)
    AUDIO_MPEG3 = WellKnownType.new("audio/mpeg3", 0x0F)
    AUDIO_MPEG = WellKnownType.new("audio/mpeg", 0x10)
    AUDIO_OGG = WellKnownType.new("audio/ogg", 0x11)
    AUDIO_OPUS = WellKnownType.new("audio/opus", 0x12)
    AUDIO_VORBIS = WellKnownType.new("audio/vorbis", 0x13)
    IMAGE_BMP = WellKnownType.new("image/bmp", 0x14)
    IMAGE_GIF = WellKnownType.new("image/gif", 0x15)
    IMAGE_HEIC_SEQUENCE = WellKnownType.new("image/heic-sequence", 0x16)
    IMAGE_HEIC = WellKnownType.new("image/heic", 0x17)
    IMAGE_HEIF_SEQUENCE = WellKnownType.new("image/heif-sequence", 0x18)
    IMAGE_HEIF = WellKnownType.new("image/heif", 0x19)
    IMAGE_JPEG = WellKnownType.new("image/jpeg", 0x1A)
    IMAGE_PNG = WellKnownType.new("image/png", 0x1B)
    IMAGE_TIFF = WellKnownType.new("image/tiff", 0x1C)
    MULTIPART_MIXED = WellKnownType.new("multipart/mixed", 0x1D)
    TEXT_CSS = WellKnownType.new("text/css", 0x1E)
    TEXT_CSV = WellKnownType.new("text/csv", 0x1F)
    TEXT_HTML = WellKnownType.new("text/html", 0x20)
    TEXT_PLAIN = WellKnownType.new("text/plain", 0x21)
    TEXT_XML = WellKnownType.new("text/xml", 0x22)
    VIDEO_H264 = WellKnownType.new("video/H264", 0x23)
    VIDEO_H265 = WellKnownType.new("video/H265", 0x24)
    VIDEO_VP8 = WellKnownType.new("video/VP8", 0x25)
    APPLICATION_HESSIAN = WellKnownType.new("application/x-hessian", 0x26)
    APPLICATION_JAVA_OBJECT = WellKnownType.new("application/x-java-object", 0x27)
    APPLICATION_CLOUDEVENTS_JSON = WellKnownType.new("application/cloudevents+json", 0x28)
    # ... reserved for future use ...
    RSOCKET_TRACING_ZIPKIN = WellKnownType.new("message/x.rsocket.tracing-zipkin.v0", 0x7D)
    RSOCKET_ROUTING = WellKnownType.new("message/x.rsocket.routing.v0", 0x7E)
    RSOCKET_COMPOSITE_METADATA = WellKnownType.new("message/x.rsocket.composite-metadata.v0", 0x7F)

    def add_wellknown(name, identifier)
      WellKnownType.new(name, identifier)
    end
  end
end