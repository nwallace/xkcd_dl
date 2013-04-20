require 'open-uri'
require 'RMagick'

class Comic
  def initialize(url, file_path)
    @file_path = file_path
    File.open(file_path, "wb") do |f|
      f.write open(url).read
    end
    @img = Magick::ImageList.new(file_path)
  end

  def size_to(width)
    @img.border!((width-@img.columns)/2, 50, "black")
  end

  def annotate(title, hover_text)
    txt = Magick::Draw.new
    @img.annotate(txt,0,0,0,0,title) do
      txt.gravity = Magick::NorthGravity
      txt.font = "Helvetica Neue"
      txt.pointsize = 32
      txt.fill = "#FFFFFF"
      txt.font_weight = Magick::BoldWeight
    end
    size = @img.first.columns
    @img << Magick::Image.read("caption:#{hover_text}") do
      self.size = "#{size}"
      self.font = "Helvetica Neue"
      self.pointsize = 16
      self.fill = "#FFFFFF"
      self.gravity = Magick::SouthGravity
      self.background_color = "#000000"
    end.first
  end

  def save
    @img.append(true).write(@file_path)
  end
end

