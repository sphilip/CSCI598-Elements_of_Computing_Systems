#!/usr/bin/ruby
require 'Parser'

# if any parameters are specified, begin translation
if !ARGV.empty?
  ARGV.each do |param|
    param = param.strip

    # seems like user knows what's going on
    parse = Parser.new(param)
  end

# user is an abject moron.  The only prescription is more cowbell
else
  print "Nothing specified.\nUsage: ./TranslatorDriver <file or directories>\n\n"
end