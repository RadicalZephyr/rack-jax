module RackJax

  class InputWrapper

    def initialize(bytes)
      if bytes.nil?
        byte_array = Java::byte[0].new
      else
        byte_array = bytes.array
      end

      @byte_reader = java_io::ByteArrayInputStream.new(byte_array)
    end

    def get
      line_reader.read_line
    end

    def each
      loop do
        s = get
        break if s.nil?
        yield s
      end
    end

    def read(length=nil, buffer='')
      length ||= byte_reader.available
      buff = Java::byte[length].new
      byte_reader.read(buff, 0, length)

      return buffer.insert(-1, String.from_java_bytes(buff))
    end

    def rewind
      byte_reader.reset
    end

    private
    attr_reader :byte_reader

    def line_reader
      @line_reader ||=
        java_io::BufferedReader.new(
        java_io::InputStreamReader.new(byte_reader,
                                       standard_charsets::US_ASCII))

      @line_reader
    end

    def java_io
      Java::JavaIo
    end

    def standard_charsets
      Java::JavaNioCharset::StandardCharsets
    end
  end
end
