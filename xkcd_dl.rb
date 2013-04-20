require 'rubygems'
require 'rss'
require 'open-uri'
require 'RMagick'
require 'cgi'

class Comic
  def initialize(url, file_path)
    @file_path = file_path
    File.open(file_path, "wb") do |f|
      f.write open(url).read
    end
    @img = Magick::ImageList.new(file_path)
  end

  def size_to(width=1280, height=720)
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

def parse_attr(attr, text)
  CGI.unescapeHTML(text[/#{attr}="([^"]*)"/, 1])
end

url = "http://xkcd.com/rss.xml"
img_dir = "/home/nathan/Images/xkcd"

open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  puts "Downloading recent comics..."
  feed.items.each do |item|
    print "  #{item.title}"
    url = parse_attr("src", item.description)
    comic = Comic.new(url, "#{img_dir}/#{item.title}.png")
    print "."
    comic.size_to
    print "."
    comic.annotate(item.title, parse_attr("title", item.description))
    print "."
    comic.save
    puts "done"
  end
  puts "Done!"
end

