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

  def http_request(method, path)
    Java::NetZefiraizingHttp_server::HttpRequest.new(method, path)
  end

  def request_method(method)
    Java::NetZefiraizingHttp_server::HttpRequest::Method.valueOf(method)
  end

  let(:app) {MockHandler.new}
  let(:wrapper) {described_class.new(app)}

  context 'the wrapped app' do

    context 'sees an env' do
      let(:path) {"/"}
      let(:method) {request_method("GET")}
      let(:request) do
        http_request(method, path)
      end

      before do
        wrapper.handle(request)
      end

      it 'calls the app' do
        expect(app.called).to be_truthy
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

          context 'alternate path' do
            let(:path) {'/alt/path'}

            it 'info' do
              expect(app.env).to include("PATH_INFO" => path)
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
