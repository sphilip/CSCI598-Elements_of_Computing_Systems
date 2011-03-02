#!/usr/bin/ruby

require 'Parser'
require 'CodeWriter'

ARGV.each do |param|
  param = param.strip
  
  # seems like user knows what's going on
  if param.size > 0
    parse = Parser.new(param)
    
  # user is completely clueless
  else
    print "Nothing specified.\nUsage: ./TranslatorDriver <files or directories>\n\n"
  end
end