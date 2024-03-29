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

      [200, {}, []]
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

  def add_headers(b, headers)
    headers.each_pair do |k, v|
      b.header(k, v)
    end
  end

  let(:app) {MockHandler.new}
  let(:name) {'localhost'}
  let(:port) {80}
  let(:wrapper) {described_class.new(app, name, port)}

  context 'the wrapped app' do

    let(:method) {request_method('GET')}
    let(:path) {'/'}
    let(:query)   {nil}
    let(:headers) {nil}
    let(:body)    {nil}

    let(:request) do
      b = http_request_builder
      b.method(method).path(path)
      b.query(query) unless query.nil?
      add_headers(b, headers) unless headers.nil?
      b.body(body)   unless body.nil?
      b.build
    end

    before do
      wrapper.handle(request)
    end

    it 'calls the app' do
      expect(app.called).to be_truthy
    end

    context 'with headers' do
      let(:headers) do
        {
          'RandomHeader' => 'Things',
          'With-Hyphen'  => 'RatherUnderscores',
          'Content-Length' => '10',
          'Content-Type'   => 'text/xml'
        }
      end

      it 'upcases and prefixes headers' do
        expect(app.env).to include('HTTP_RANDOMHEADER' => 'Things')
      end

      it 'replaces - with _' do
        expect(app.env).to include('HTTP_WITH_HYPHEN'  => 'RatherUnderscores')
      end

      it 'doesnt prefix content headers' do
        expect(app.env).to include('CONTENT_LENGTH' => '10')
        expect(app.env).to include('CONTENT_TYPE'   => 'text/xml')
      end
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
          expect(input).to respond_to(:gets).with(0).arguments
          expect(input).to respond_to(:each)
          expect(input).to respond_to(:read)
          expect(input).to respond_to(:rewind).with(0).arguments
          expect(input.gets).to be_nil
        end

        it 'error' do
          expect(app.env).to include('rack.errors' => anything())
          error = app.env['rack.errors']
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

          it 'server name' do
            expect(app.env).to include('SERVER_NAME' => 'localhost')
          end

          it 'server port' do
            expect(app.env).to include('SERVER_PORT' => 80)
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
            expect(input).to respond_to(:gets).with(0).arguments
            expect(input).to respond_to(:each)
            expect(input).to respond_to(:read)
            expect(input).to respond_to(:rewind).with(0).arguments
            expect(input.gets).to eq('this silly text')
          end
        end
      end
    end
  end
end
