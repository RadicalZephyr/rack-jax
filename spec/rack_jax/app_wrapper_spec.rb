require 'spec_helper'

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

  def byte_buffer(text)
    Java::JavaNio::ByteBuffer.wrap(text.join("\n").to_java_bytes)
  end

  let(:app) {MockHandler.new}
  let(:wrapper) {described_class.new(app)}

  context 'the wrapped app' do

    let(:method) {request_method('GET')}
    let(:path) {'/'}
    let(:query) {nil}
    let(:body)  {nil}

    let(:request) do
      b = http_request_builder
      b.method(method).path(path)
      b.query(query) unless query.nil?
      b.body(body)   unless body.nil?
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
        it 'version' do
          expect(app.env).to include('rack.version' => [1,1])
        end

        it 'url scheme' do
          expect(app.env).to include('rack.url_scheme' => 'http')
        end

        it 'multithread' do
          expect(app.env).to include('rack.multithread' => true)
        end

        it 'multiprocess' do
          expect(app.env).to include('rack.multiprocess' => false)
        end

        it 'run once' do
          expect(app.env).to include('rack.run_once' => false)
        end

        it 'hijack' do
          expect(app.env).to include('rack.hijack?' => false)
        end

        it 'input' do
          expect(app.env).to include('rack.input' => anything())
          input = app.env['rack.input']
          expect(input).to respond_to(:get).with(0).arguments
          expect(input).to respond_to(:each)
          expect(input).to respond_to(:read)
          expect(input).to respond_to(:rewind).with(0).arguments
          expect(input.get).to be_nil
        end

        it 'error' do
          expect(app.env).to include('rack.error' => anything())
          error = app.env['rack.error']
          expect(error).to respond_to(:puts)
          expect(error).to respond_to(:write)
          expect(error).to respond_to(:flush)
        end
      end

      context 'for GET' do
        context 'with the' do
          it 'request method' do
            expect(app.env).to include('REQUEST_METHOD' => 'GET')
          end

          it 'script name' do
            expect(app.env).to include('SCRIPT_NAME' => '')
          end

          it 'path info' do
            expect(app.env).to include('PATH_INFO' => path)
          end

          it 'query string' do
            expect(app.env).to include('QUERY_STRING' => '')
          end

          context 'alternate path' do
            let(:query) {'with-query=true'}
            let(:path)  {'/alt/path'}

            it 'info' do
              expect(app.env).to include('PATH_INFO' => path)
            end

            it 'query string' do
              expect(app.env).to include('QUERY_STRING' => query)
            end
          end
        end
      end

      context 'for POST ' do
        let(:method) {request_method('POST')}
        let(:body) {byte_buffer(['this silly text'])}

        context 'with the' do
          it 'request method' do
            expect(app.env).to include('REQUEST_METHOD' => 'POST')
          end

          it 'request body' do
            expect(app.env).to include('rack.input' => anything())
            input = app.env['rack.input']
            expect(input).to respond_to(:get).with(0).arguments
            expect(input).to respond_to(:each)
            expect(input).to respond_to(:read)
            expect(input).to respond_to(:rewind).with(0).arguments
            expect(input.get).to eq('this silly text')
          end
        end
      end
    end
  end
end
