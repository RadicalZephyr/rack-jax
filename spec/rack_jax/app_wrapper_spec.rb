require 'spec_helper'
require 'java'
require 'jax-server-0.1.0.jar'

describe RackJax::AppWrapper do
  class MockHandler
    attr_reader :env, :called

    def initialize
      @called = false
    end

    def call(env)
      @called = true
      @env = env
    end
  end

  def http_request_builder
    Java::NetZefiraizingHttp_server::RequestBuilder.new
  end

  def request_method(method)
    Java::NetZefiraizingHttp_server::HttpRequest::Method.valueOf(method)
  end

  let(:app) {MockHandler.new}
  let(:wrapper) {described_class.new(app)}

  context 'the wrapped app' do

    let(:method) {request_method("GET")}
    let(:path) {"/"}
    let(:query) {nil}

    let(:request) do
      b = http_request_builder
      b.method(method).path(path)
      b.query(query) unless query.nil?
      b.build
    end

    before do
      wrapper.handle(request)
    end

    it 'calls the app' do
      expect(app.called).to be_truthy
    end

    context 'sees an env' do
      context 'with the rack variables' do
        it 'rack version' do
          expect(app.env).to include("rack.version" => [1,1])
        end

        it 'url scheme' do
          expect(app.env).to include("rack.url_scheme" => "http")
        end
      end

      context 'for GET' do
        context 'with the' do
          it 'request method' do
            expect(app.env).to include("REQUEST_METHOD" => "GET")
          end

          it 'script name' do
            expect(app.env).to include("SCRIPT_NAME" => "")
          end

          it 'path info' do
            expect(app.env).to include("PATH_INFO" => path)
          end

          it 'query string' do
            expect(app.env).to include("QUERY_STRING" => "")
          end

          context 'alternate path' do
            let(:query) {'with-query=true'}
            let(:path)  {'/alt/path'}

            it 'info' do
              expect(app.env).to include("PATH_INFO" => path)
            end

            it 'query string' do
              expect(app.env).to include("QUERY_STRING" => query)
            end
          end
        end
      end

      context 'for POST ' do
        let(:method) {request_method("POST")}

        it 'with the request method' do
          expect(app.env).to include("REQUEST_METHOD" => "POST")
        end
      end
    end
  end
end
