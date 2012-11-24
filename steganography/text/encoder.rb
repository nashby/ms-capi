# encoding: utf-8
require 'random-word'

class Encoder
  def initialize(text, position, out_file)
    @text = text
    @position = position.to_i
    @out_fle = out_file
  end

  def encode
    File.open(@out_fle, 'w+') do |file|
      @text.each_char do |char|
        if char == ' '
          file.write("🎅 ")
        else
          file.write("#{word_with_char(position: @position, char: char)} ")
        end
      end
    end
  end

  private

  def word_with_char(options)
    word = RandomWord.adjs.next

    while word[options[:position] - 1] != options[:char]
      word = RandomWord.adjs.next
    end

    word
  end
end

# I thought I'd never use it...
if __FILE__ == $0
  encoder = Encoder.new(ARGV[0], ARGV[1], ARGV[2])

  if ARGV[3] == 'encode'
    encoder.encode
  end
end
