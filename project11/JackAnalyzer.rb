#!/usr/bin/ruby
require 'JackTokenizer'

# if any parameters are specified, begin translation
if !ARGV.empty?
  ARGV.each do |param|
    param = param.strip

    # seems like user knows what's going on
    token = JackTokenizer.new(param)

  end

else
  puts "No file/folders specified"

end
