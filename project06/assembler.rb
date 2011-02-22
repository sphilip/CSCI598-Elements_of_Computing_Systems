#!/usr/bin/ruby

# read each file and determine if it exists
# if it does, open the file and create .hack file with same name
ARGV.each do |file|
  if File.exists?(file)
    # open file, notify user
    print "Opening ", file
    asm = File.open(file, "r")

    # extract filename to change extension for output file
    filename = File.basename(file,".asm")
    filename = filename + ".hack"

    folder_regex = Regexp.new(/\A[A-Za-z]*/)
    folder_match = folder_regex.match(file)
    folder= folder_match[0]
    path = folder + "/" + filename
     print "\nWill be writing to ", path, "\n"

    # open output file
    hack = File.open(path,"w")
    hack.print("Testing writing to file\n")
    asm.close
    hack.close
  end
end