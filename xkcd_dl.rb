require 'rss'
require 'open-uri'
require 'rmagick'
require 'cgi'

def download_image(item, path)
  desc = item.description
  src = get_attr("src", desc)
  title = get_attr("title", desc)
  file_path = "#{path}/#{item.title}.png"
  File.open(file_path, "wb") do |f|
    f.write open(src).read
  end
  annotate_img(file_path, item.title, title)
end

def get_attr(attr, element)
  CGI.unescapeHTML(element[/#{attr}="([^"]*)"/, 1])
end

def annotate_img(path, title, desc)
  img = Magick::ImageList.new(path)
  size_to_screen(img)
  add_text(img, title, desc)
  img.append(true).write(path)
end

def size_to_screen(img)
  resolution = `xdpyinfo | grep 'dimensions:' | awk '{print $2}'`
  width = resolution[/\d+[^x]/].to_i
  height = resolution[/x(\d+)/, 1].to_i
  img.border!((width-img.columns)/2, 50, "black")
end

def add_text(img, title, desc)
  txt = Magick::Draw.new
  img.annotate(txt,0,0,0,0,title) do
    txt.gravity = Magick::NorthGravity
    txt.font = "Helvetica Neue"
    txt.pointsize = 32
    txt.fill = "#FFFFFF"
    txt.font_weight = Magick::BoldWeight
  end
  img << Magick::Image.read("caption:#{desc}") do
    self.size = "#{img.first.columns}"
    self.font = "Helvetica Neue"
    self.pointsize = 16
    self.fill = "#FFFFFF"
    self.gravity = Magick::SouthGravity
    self.background_color = "#000000"
  end.first
end

url = "http://xkcd.com/rss.xml"
img_dir = "/Users/Nathan/Desktop/xkcd"

open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  puts "Downloading recent comics..."
  feed.items.each do |item|
    download_image(item, img_dir)
    puts "  #{item.title}"
  end
  puts "Done!"
end

