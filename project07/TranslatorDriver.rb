#!/usr/bin/ruby

require 'Parser'
require 'CodeWriter'

ARGV.each do |param|
  param = param.strip

  # seems like user knows what's going on
  if !param.empty?
    parse = Parser.new(param)

  # user is an abject moron.  The only prescription is more cowbell
  else
    print "Nothing specified.\nUsage: ./TranslatorDriver <files or directories>\n\n"
  end
end