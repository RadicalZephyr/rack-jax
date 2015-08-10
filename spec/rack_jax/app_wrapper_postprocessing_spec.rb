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

  let(:response) {wrapper.handle(request)}

  context 'response has' do
    it 'status code' do
      expect(response.status).to eq(200)
    end
  end
end
