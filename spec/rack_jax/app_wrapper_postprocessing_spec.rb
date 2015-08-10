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

  let(:app) {Proc.new { |env| [200, {}, []]}}
  let(:name) {'localhost'}
  let(:port) {80}
  let(:wrapper) {described_class.new(app, name, port)}

  let(:method) {request_method('GET')}
  let(:path) {'/'}

  let(:request) do
    http_request_builder.method(method).path(path).build()
  end

  let(:response) {wrapper.handle(request)}

  context 'response has' do
    it 'status code' do
      expect(response.status).to eq(200)
    end
  end
end
