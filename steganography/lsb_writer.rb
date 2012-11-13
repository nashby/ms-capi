require 'wav-file'

class LSBWriter
  def initialize(phrase, file_in, file_out)
    @phrase = phrase
    @file_in = open(file_in)
    @file_out = open(file_out, 'w')
  end

  def phrase_bits
    @phrase_bits ||= @phrase.bytes.map { |byte| byte.to_s(2) }.join
  end

  def format
    @format ||= WavFile::readFormat(@file_in)
  end

  def data_chunk
    @data ||= WavFile::readDataChunk(@file_in)
  end

  def data
    data_chunk.data
  end

  def write_bites
    wavs = data.unpack('s*')

    n = 0

    wavs = wavs.map.with_index do |byte, i|
      wav = if n >= phrase_bits.length
        byte
      else
        (byte.to_s(2)[0..-3] + phrase_bits[n..n+1]).to_i(2)
      end

      n += 2 and wav
    end

    data_chunk.data = wavs.pack('s*')
  end

  def write_file
    write_bites
    WavFile::write(@file_out, format, [data_chunk])
  end
end

# I thought I'd never use it...
if __FILE__ == $0
  writer = LSBWriter.new(ARGV[0], ARGV[1], ARGV[2])
  writer.write_file
end

