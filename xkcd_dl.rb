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

puts "Width: #{options[:width]}"

options[:width] = 1280 if options[:width].nil?
url = "http://xkcd.com/rss.xml"
img_dir = "/home/nathan/projects/xkcd/output/#{options[:width]}"

Dir.mkdir("output/#{options[:width]}") unless File.directory?("output/#{options[:width]}")

open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  puts "Downloading recent comics..."
  feed.items.each do |item|
    puts "  #{item.title}"
    url = parse_attr("src", item.description)
    comic = Comic.new(url, "#{img_dir}/#{item.title}.png")
    comic.size_to(options[:width])
    comic.annotate(item.title, parse_attr("title", item.description))
    comic.save
  end
  puts "Done!"
end

