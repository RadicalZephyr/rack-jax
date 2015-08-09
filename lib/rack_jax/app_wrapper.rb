require 'java'
require 'jax-server-0.1.0.jar'

module RackJax
  class AppWrapper

    def initialize(app)
      @app = app
    end

    def handle(request)
      env = {
        "REQUEST_METHOD" => request.method.to_s,
        "SCRIPT_NAME" => "",
        "PATH_INFO" => request.path.to_s
      }
      app.call(env)
      {}
    end

    private
    attr_reader :app
  end
end
