module RackJax
  class AppWrapper

    def initialize(app, name, port)
      @app = app
      @name = name
      @port = port
    end

    def base_request
      {
        'rack.version'      => [1,1],
        'rack.url_scheme'   => 'http',
        'rack.multithread'  => true,
        'rack.multiprocess' => false,
        'rack.run_once'     => false,
        'rack.hijack?'      => false,
        'rack.error'        => error_io,
        'SCRIPT_NAME'       => '',
        'SERVER_NAME'       => name,
        'SERVER_PORT'       => port
      }
    end

    def handle(request)
      env = base_request.merge({
                                 'rack.input' => InputWrapper.new(request.body),
                                 'REQUEST_METHOD' => request.method.to_s,
                                 'PATH_INFO'      => request.path.to_s,
                                 'QUERY_STRING'   => request.query.to_s,
                               })
      env.merge!(rackify_headers(request.headers))

      status, headers, body = app.call(env)
      response = http_response(status)
      headers.each do |k,v|
        response.add_header(k,v) unless k.start_with?('rack.')
      end
      response.set_content(as_content_provider(body))
      return response
    end

    private
    attr_reader :app, :name, :port

    def http_response(status)
      Java::NetZefiraizingHttp_server::HttpResponse.new(status)
    end

    def as_content_provider(body)
      acc = ""
      body.each do |s|
        acc += s
      end
      string_cp(acc)
    end

    def string_cp(text)
      Java::NetZefiraizingHttp_serverContent::StringContentProvider.new(text)
    end

    def rackify_headers(headers)
      headers.map do |k,v|
        [rackify_key(k), v]
      end.to_h
    end

    def rackify_key(key)
      prefix = prefix_header?(key) ? 'HTTP_' : ''
      key = key.upcase.gsub(/-/, '_')
      return prefix+key
    end

    def prefix_header?(key)
      key != 'Content-Length' && key != 'Content-Type'
    end

    def error_io
      java.lang.System::err.to_io
    end
  end
end
