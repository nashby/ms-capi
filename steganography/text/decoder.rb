# encoding: utf-8

class Decoder
  def initialize(position, in_file)
    @position = position.to_i
    @in_file = in_file
  end

  def decode
    encoded_text.split.map do |word|
      word == '🎅' ? ' ' : word[@position - 1]
    end.join
  end

  def encoded_text
    @encoded_text ||= File.read(@in_file)
  end
end

# I thought I'd never use it...
if __FILE__ == $0
  decoder = Decoder.new(ARGV[0], ARGV[1])

  if ARGV[2] == 'decode'
    p decoder.decode
  end
end
