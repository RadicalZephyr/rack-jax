require 'spec_helper'

describe Rack::Handler::RackJax do

  context 'default host' do
    it 'in development' do
      expect(described_class.send(:default_host)).to eq('localhost')
    end

    it 'in production' do
      ENV['RACK_ENV'] = 'production'
      expect(described_class.send(:default_host)).to eq('0.0.0.0')
    end
  end

  it 'mocked smoke test' do
    fake_server = double
    expect(described_class).to receive(:create_server).
                                with(instance_of(::RackJax::AppWrapper),
                                     instance_of(Fixnum)).
                                and_return(fake_server)
    expect(fake_server).to receive(:listen).once
    expect(fake_server).to receive(:serve).once

    described_class.run(Proc.new { |e| [200, {}, []]})
  end
end
