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
end
