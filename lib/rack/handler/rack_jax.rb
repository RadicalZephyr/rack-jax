module Rack
  module Handler

    class RackJax
      def self.run(app, option={})
        host = options.delete(:Host) || default_host
        port = options.delete(:Port) || 7070
      end

      def self.valid_options
        {
          "Host=HOST" => "Hostname to listen on (default: #{default_host})",
          "Port=PORT" => "Port to listen on (default: 7070)",
        }
      end

      private

      def self.default_host
        environment  = ENV['RACK_ENV'] || 'development'
        environment == 'development' ? 'localhost' : '0.0.0.0'
      end
    end
  end
end
