require 'spec_helper'

describe RackJax::InputWrapper do

  def byte_buffer(text)
    Java::JavaNio::ByteBuffer.wrap(text.join("\n").to_java_bytes)
  end

  let(:input) {described_class.new(byte_buffer(lines))}

  let(:first_line) {'stuff and text'}
  let(:lines) {[first_line]}

  describe '#get' do
    it 'can get by lines' do
      expect(input.get).to eq(first_line)
    end

    it 'returns nil once all input is read' do
      input.get
      expect(input.get).to be_nil
    end
  end

  describe '#each' do
    it 'reads lines with each' do
      expect{ |b| input.each(&b)}.to yield_with_args(first_line)
    end
  end

  describe '#read' do
    it 'reads a specific number of bytes' do
      expect(input.read(5)).to eq('stuff')
    end

    it 'reads only that number of bytes' do
      input.read(6)
      expect(input.read(3)).to eq('and')
    end
  end

  context 'with multiple lines' do
    let(:second_line) {'more stuff, but no things'}
    let(:lines) {[first_line, second_line]}

    describe '#get' do
      it 'can get the second line' do
        expect(input.get).to eq(first_line)
        expect(input.get).to eq(second_line)
      end
    end

    describe '#each' do
      it 'reads all lines with each' do
        expect{ |b| input.each(&b)}.to yield_successive_args(first_line,
                                                             second_line)
      end
    end
  end
end
