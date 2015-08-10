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

      app.call(env)
      {}
    end

    private
    attr_reader :app, :name, :port

    def rackify_headers(headers)
      headers.map do |k,v|
        ["HTTP_#{k}", v.join('')]
      end.to_h
    end

    def error_io
      java.lang.System::err.to_io
    end
  end
end
