require 'chunky_png'
require 'digest'

module ChunkyPNG::Color
  def self.brightness(value)
    (r(value) + g(value) + b(value)) / 3
  end
end

class Patchwork
  STEP_COUNT = 10_000
  FOOBAR = 3

  def initialize(image_name, key)
    @image_name = image_name
    @image = ChunkyPNG::Image.from_file(image_name)
    @key = key
    @random = Random.new(Digest::MD5.hexdigest(key).to_i(16))
  end

  def write_watermark
    STEP_COUNT.times do
      increase_brightness(@random.rand(@image.width), @random.rand(@image.height))
      decrease_brightness(@random.rand(@image.width), @random.rand(@image.height))
    end

    @image.to_datastream.save("#{@image_name[0..-5]}_with_watermark.png")
  end

  def increase_brightness(x, y)
    old_color = @image[x, y]
    new_color = ChunkyPNG::Color.rgb(new_rgb(ChunkyPNG::Color.r(old_color) + FOOBAR), new_rgb(ChunkyPNG::Color.g(old_color) + FOOBAR), new_rgb(ChunkyPNG::Color.b(old_color) + FOOBAR))
    @image[x, y] = new_color
  end

  def decrease_brightness(x, y)
    old_color = @image[x, y]
    new_color = ChunkyPNG::Color.rgb(new_rgb(ChunkyPNG::Color.r(old_color) - FOOBAR), new_rgb(ChunkyPNG::Color.g(old_color) - FOOBAR), new_rgb(ChunkyPNG::Color.b(old_color) - FOOBAR))
    @image[x, y] = new_color
  end

  def new_rgb(color)
    if color > 255
      255
    elsif color < 0
      0
    else
      color
    end
  end

  def ms
    @random = Random.new(Digest::MD5.hexdigest(@key).to_i(16))
    sum = 0

    STEP_COUNT.times do
      x, y = @random.rand(@image.width), @random.rand(@image.height)
      a = @image[x, y]

      x, y = @random.rand(@image.width), @random.rand(@image.height)
      b = @image[x, y]

      sum += ChunkyPNG::Color.brightness(a) - ChunkyPNG::Color.brightness(b)
    end

    sum / STEP_COUNT
  end
end

# I thought I'd never use it...
if __FILE__ == $0
  pw = Patchwork.new(ARGV[0], ARGV[1])

  if ARGV[2] == 'set'
    pw.write_watermark
  else
    puts pw.ms
  end
end
