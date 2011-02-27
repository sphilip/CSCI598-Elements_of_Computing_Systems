#!/usr/bin/ruby

require 'Parser'


# read each file and determine if it exists
# if it does, open the file and create .hack file with same name
if ARGV.length == 0
  print "To actually use this assembler, try: ./assembler.rb <files to use>\n"

else
  ARGV.each do |file|

    # open file, notify user
    print "Opening ", file, "\n"


    # check extension of file to open, should be .asm
    if File.extname(file) != ".asm"
      # user doesn't understand what they're doing
      print "\nWait! This isn't the right file.  Your extension is ", File.extname(file), " but it should be .asm.  This attempt is a complete failure!\n\n"


    # test if file even exists
    else if !File.exists?(file)
      print "\nI pity the fool that uses ", file, " because it doesn't even exist.\n\n"


    # otherwise begin parsing
    else
      parse = Parser.new(file)
      parse.execute


    end
  end
end
end
