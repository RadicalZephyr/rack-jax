require 'spec_helper'

describe RackJax::AppWrapper do
  class MockHandler
    attr_reader :env

    def call(env)
      @env = env
    end
  end

  let(:app) {MockHandler.new}
  let(:wrapper) {described_class.new(app)}

  context 'the wrapped app' do

    context 'sees an ENV with' do
      let(:request) {{}}

      it 'the request method' do
        response = wrapper.handle(request)

        expect(response).not_to be_nil
      end
    end
  end
end
