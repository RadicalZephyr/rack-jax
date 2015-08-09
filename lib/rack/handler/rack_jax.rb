module Rack
  module Handler

    class RackJax
      def self.run(app, option={})
        port = options.delete(:Port) || 7070
      end

      def self.valid_options
        environment  = ENV['RACK_ENV'] || 'development'

        {
          "Port=PORT" => "Port to listen on (default: 7070)",
        }
      end
    end
  end
end
