module RackJax
  class AppWrapper

    def initialize(app)
      @app = app
    end

    def handle(request)
      env = {
        'rack.version' => [1,1],
        'rack.url_scheme' => 'http',
        'rack.multithread' => true,
        'rack.multiprocess' => false,
        'rack.run_once' => false,
        'rack.hijack?' => false,
        'rack.input' => InputWrapper.new(request.body),
        'rack.error' => error_io,
        'REQUEST_METHOD' => request.method.to_s,
        'SCRIPT_NAME' => '',
        'PATH_INFO' => request.path.to_s,
        'QUERY_STRING' => request.query.to_s
      }
      app.call(env)
      {}
    end

    private
    attr_reader :app

    def error_io
      java.lang.System::err.to_io
    end
  end
end
