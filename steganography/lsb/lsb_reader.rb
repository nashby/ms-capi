require 'wav-file'

class LSBReader
  def initialize(phrase_length, file)
    @phrase_length = phrase_length.to_i * 4
    @file = open(file)
  end

  def format
    @format ||= WavFile::readFormat(@file)
  end

  def data_chunk
    @data ||= WavFile::readDataChunk(@file)
  end

  def data
    data_chunk.data
  end

  def read
    tmp, phrase = '', ''

    data.unpack('s*').each_with_index do |byte, i|
      break if i >= @phrase_length - 2
      tmp += byte.to_s(2)[-2..-1]

      if tmp.length >= 7
        phrase << tmp.slice!(0, 7).to_i(2).chr
      end
    end

    phrase
  end
end

# I thought I'd never use it...
if __FILE__ == $0
  reader = LSBReader.new(ARGV[0], ARGV[1])
  p reader.read
end
