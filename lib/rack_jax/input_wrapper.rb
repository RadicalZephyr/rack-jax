module RackJax

  class InputWrapper

    def initialize(bytes)
      @byte_reader = java_io::ByteArrayInputStream.new(bytes.array)
    end

    def get
      line_reader.read_line
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
