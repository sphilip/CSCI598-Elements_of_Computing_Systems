# handles the parsing of single .vm fil
# encapsulates access to input code -> reads, parses & gives access to VM commands & their components

# also removes white space & comments

require 'CodeWriter'

class Parser
  # Opens inputs file
  # input: input file
  # output: none

  def initialize(input)
    # check if given input is a directory

    if File.directory?(input)

      # it's a directory!
      # go to that directory & get all .vm files
      if input[input.size-1].chr != "/" then
	input = input + "/"
      end

 
      # get all vm files from that foler
      files = Dir.glob("#{input}*.vm")
#       filename = ""
     
     output_filename= input.gsub(/^(\w)*/,"")
     output_filename= output_filename[1,output_filename.size-2] + ".asm"
  
       # create path to write file
      path = Dir.pwd + "/" + input + output_filename
      print "Will be writing to #{input}#{output_filename}\n\n"

      # open output file
      @code = CodeWriter.new(path)
      
      files.each do |file|
	
	inputFile = File.new(file,"r")
	inputFileLines = inputFile.readlines
	bootstrap = Class.new
	inputFileLines.each do | inputFileLine|
	
	  if !inputFileLine.gsub!(/(Sys.init)/,"").nil?
# 	    bootstrap = true
	    @code.writeBootstrap()
	    break
# 	  else bootstrap = false
	  end
	
	end
	
	inputFile.close      
      end
      
      files.each do |file|
	print "Reading from #{file}\n"
	@code.staticName = File.basename(file, ".vm")
	inputFile = File.new(file,"r")
	readFile(inputFile)
	inputFile.close
      end
      
      # count the # of vm files in this folder
#       file_count = 0
#       fileList = Array.new(files.length)

#       # for each vm file
#       files.each do |file|
# 
# 	vmFile = File.new(file,"r")
# 	#filename = File.basename(file,".vm")
# 	#filename = filename + ".asm"
# 	fileList[file_count] = vmFile
# 	file_count=file_count+1
#       end
#    
#       fileList.each do |file|
# 	print "Reading from #{file}\n"
# 	readFile(file)
# 	file.close
#       end

      

      @code.close


    # it's a file!
    elsif File.file?(input)

      if File.extname(input) != ".vm"
	puts "#{File.basename(input)} is not a valid file\n\n"
		
      else
	# Open file & pull the name of file to give the output the same file name
	file = File.new(input,"r")
	filename = File.basename(input,".vm")
	filename = filename + ".asm"

	# pull the directory
	folder= File.dirname(input)
	path = folder + "/" + filename
	print "Will be writing to #{File.dirname(input)}/#{filename}\n\n"

	# open output file
	@code = CodeWriter.new(path)

	# check file for Sys.init
	inputFile = File.new(input,"r")
	inputFileLines = inputFile.readlines
	bootstrap = Class.new
	inputFileLines.each do | inputFileLine|
	
	  if !inputFileLine.gsub!(/(Sys.init)/,"").nil?
# 	    bootstrap = true
	    @code.writeBootstrap()
	    break
# 	  else bootstrap = false
	  end
	
	end
	
	inputFile.close   
	@code.staticName = File.basename(file, ".vm")
	readFile(file)
	file.close
	@code.close
      end
      
    # maybe the user inputted something wrong?
    else puts "#{input} is not found.  Does it even exist?\n"
    end

  end

  def readFile(file)
    
    
    
    # store all lines as an array
    lines = file.readlines
    lines.each do |line|

      # remove all comments from file
      line = line.gsub(/\/{2}.*/, '')

      # split each line on whitespace
      commands = line.split
      if !commands.empty?

	type = commandType(commands[0])

	if type == "C_PUSH" or type == "C_POP" then
	  @code.writePushPop(commands[0],commands[1], commands[2])
	elsif type == "C_LABEL"
	  @code.writeLabel(commands[1])
	elsif type == "C_GOTO"
	  @code.writeGoto(commands[1])
	elsif type == "C_IF"
	  @code.writeIf(commands[1])
	elsif type == "C_FUNCTION"
	  @code.writeFunction(commands[1], commands[2])
	elsif type == "C_RETURN"
	  @code.writeReturn
	elsif type == "C_CALL"
	  @code.writeCall(commands[1], commands[2])
	else
	 @code.writeArithmetic(commands[0])
	end

      end
    end
  end



  # returns type of current VM command
  # use C_ARITHMETIC for all arithmetic commands
  # input: none
  # output: C_ARITHMETIC, C_PUSH, C_POP, C_LABEL, C_GOTO, C_IF, C_FUNCTION, C_RETURN, C_CALL
  def commandType(command)

    if command.downcase == "push"
      return "C_PUSH"

    elsif command.downcase == "pop"
      return "C_POP"

    elsif command.downcase == "goto"
      return "C_GOTO"

    elsif command.downcase == "label"
      return "C_LABEL"

    elsif command.downcase == "if-goto"
      return "C_IF"

    elsif command.downcase == "function"
      return "C_FUNCTION"

    elsif command.downcase == "return"
      return "C_RETURN"

    elsif command.downcase == "call"
      return "C_CALL"

    else
      return "C_ARITHMETIC"
    end

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
