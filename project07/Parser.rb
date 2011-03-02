# handles the parsing of single .vm file 
# encapsulates access to input code -> reads, parses & gives 
# 	access to VM commands & their components
# also removes white space & comments

class Parser
  # Opens inputs file
  # input: input file
  # output: none
  def initialize(input)
    # check if given input is a directory
    if File.directory?(input)
      
      # it's a directory!
      dir = Dir.open(input)
      workingDirectory = Dir.pwd
      path = workingDirectory + "/" + input
      
      # go to that directory & get all .vm files
      Dir.chdir(input)
      files = Dir.glob("*.vm")
      
      files.each do |file|
	@vmFile = File.new(file,"r")
	filename = File.basename(file,".vm")
	filename = filename + ".win.asm"

	
	# create path to write file
	#folder = File.dirname(file)
	path = Dir.pwd + "/" + filename
	print "Will be writing to ", input, filename, "\n\n"

	# open output file
	@vm = File.open(path,"w")
      end
      
      
    # it's a file!
    elsif File.file?(input)
      
      # Open file & pull the name of file to give the output the same file name
      @file = File.new(input,"r")
      filename = File.basename(input,".vm")
      filename = filename + ".win.asm"

      # pull the directory
      folder= File.dirname(input)
      path = folder + "/" + filename
      print "Will be writing to ", path, "\n\n"

      # open output file
      @vm = File.open(path,"w")

      
    # maybe the user inputted something wrong?
    else print input, " is not found.  Does it even exist?\n"
    end    
  end
  
  
  # returns type of current VM command
  # use C_ARITHMETIC for all arithmetic commands
  # input: none
  # output: C_ARITHMETIC, C_PUSH, C_POP, C_LABEL, C_GOTO, 
  # 		C_IF, C_FUNCTION, C_RETURN, C_CALL
  def commandType
  end
  
  # return 1st argument of current commands
  # not called if current command = C_RETURN
  # input: none
  # output: string
  def arg1 
  end
  
  # return 2nd argument of current cmd
  # only called w/ C_PUSH, C_POP,  C_FUNCTION, C_CALL
  # input: none
  # output: int
  def arg2
  end
  
end
