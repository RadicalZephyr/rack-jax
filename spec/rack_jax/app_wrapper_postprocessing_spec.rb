require 'spec_helper'

describe RackJax::AppWrapper do

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

  let(:headers) {{}}
  let(:body) {[]}
  let(:app) {Proc.new { |env| [200, headers, body]}}
  let(:name) {'localhost'}
  let(:port) {80}
  let(:wrapper) {described_class.new(app, name, port)}

  let(:method) {request_method('GET')}
  let(:path) {'/'}

  let(:request) do
    http_request_builder.method(method).path(path).build()
  end

  let(:response) {wrapper.handle(request)}

  context 'response' do
    it 'has status code' do
      expect(response.status).to eq(200)
    end

    context 'has headers' do
      let(:headers) do
        {
          'RandomHeader' => 'Things',
          'With-Hyphen'  => 'RatherUnderscores',
          'rack.fake'    => 'for-server',
        }
      end

      it 'RandomHeader' do
        expect(response.headers['RandomHeader']).to eq('Things')
      end

      it 'With-Hyphen' do
        expect(response.headers['With-Hyphen']).to eq('RatherUnderscores')
      end

      context 'omits rack.*' do
        it 'fake' do
          expect(response.headers['rack.fake']).to be_nil
        end
      end
    end

    context 'body' do
      let(:body) do
        [
          "First Line\n",
          "Second Line"
        ]
      end

      it 'has the first line' do
        expect(response.get_data.to_io.gets).to eq("First Line\n")
      end

      it 'has the first line' do
        body_io = response.get_data.to_io
        body_io.gets
        expect(body_io.gets).to eq("Second Line")
      end
    end
  end
end
