require 'optparse'
require 'rss'
require 'cgi'
require_relative 'comic'

def parse_attr(attr, text)
  CGI.unescapeHTML(text[/#{attr}="([^"]*)"/, 1])
end

options = {}
OptionParser.new do |opt|
  opt.on("-w", "--width WIDTH", "Width of the output image in pixels") do |w|
    options[:width] = w.to_i
  end
end.parse!

options[:width] = 1280 if options[:width].nil?
url = "http://xkcd.com/rss.xml"
output_dir = File.expand_path(File.dirname(__FILE__)) + "/output"
img_dir = output_dir + "/#{options[:width]}"

puts "writing to #{img_dir}"

Dir.mkdir(output_dir) unless File.directory?(output_dir)
Dir.mkdir(img_dir) unless File.directory?(img_dir)

open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  puts "Downloading recent comics..."
  feed.items.each do |item|
    print "  #{item.title}"
    url = parse_attr("src", item.description)
    file_path = "#{img_dir}/#{item.title}.png"
    if File.file? file_path
      puts " (found)"
    else
      comic = Comic.new(url, file_path)
      comic.size_to(options[:width])
      comic.annotate(item.title, parse_attr("title", item.description))
      comic.save
      puts
    end
  end
  puts "Done!"
end

