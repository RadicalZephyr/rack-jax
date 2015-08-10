module Rack
  module Handler

    class RackJax
      def self.run(app, options={})
        puts 'Extracting options...'
        host = options.delete(:Host) || default_host
        port = options.delete(:Port) || 7070

        puts 'Wrapping app...'
        wrapp = ::RackJax::AppWrapper.new(app, host, port)

        puts 'Creating server...'
        server = create_server(wrapp, port.to_i)

        puts 'Starting server...'
        server.listen
        server.serve
      end

      def self.valid_options
        {
          "Host=HOST" => "Hostname to listen on (default: #{default_host})",
          "Port=PORT" => "Port to listen on (default: 7070)",
        }
      end

      private

      def self.create_server(app, port)
        Java::NetZefiraizingHttp_server::HttpServer::create_server(port, app)
      end

      def self.default_host
        environment  = ENV['RACK_ENV'] || 'development'
        environment == 'development' ? 'localhost' : '0.0.0.0'
      end
    end
  end
end
