require 'spec_helper'

describe RackJax::InputWrapper do

  def byte_buffer(text)
    Java::JavaNio::ByteBuffer.wrap(text.join("\n").to_java_bytes)
  end

  let(:input) {described_class.new(byte_buffer(lines))}

  let(:first_line) {'stuff and text'}
  let(:lines) {[first_line]}

  it 'can get by lines' do
    expect(input.get).to eq(first_line)
  end

  it 'returns nil once all input is read' do
    input.get
    expect(input.get).to be_nil
  end

  context 'with multiple lines' do
    let(:second_line) {'more stuff, but no things'}
    let(:lines) {[first_line, second_line]}

    it 'can get the second line' do
      expect(input.get).to eq(first_line)
      expect(input.get).to eq(second_line)
    end
  end
end
