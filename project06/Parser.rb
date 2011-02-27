require 'SymbolicTable'

# split up asm command into field & symbols
class Parser
attr_accessor :table
  # take input file and open it
  def initialize(file)
      # extract filename to change extension for output file
      @asm = File.open(file, "r")
      filename = File.basename(file,".asm")
      filename = filename + ".win.hack"


      # pull the directory that the file was taken from
      folder= File.dirname(file)
      path = folder + "/" + filename
      print "Will be writing to ", path, "\n\n"

      # open output file
      @hack = File.open(path,"w")

  end


  # begin the parsing of files
  def execute
    # create new hash table
    @table = SymbolicTable.new

    # read all lines from file
    lines = @asm.readlines
    line_num = 0

    # parse each line, perform first pass on the file`
    lines.each do |line|
      # remove extraneous characters
      line = line.strip

      # is the line an actual command or a comment
      newline = find_command(line)
      if !newline.nil? && newline.size > 0
	line_num = firstPass(newline, line_num)
      end
    end

    line_num = 0
    lines.each do |line|
      newline = find_command(line)
      if !newline.nil? && newline.size > 0
	secondPass(line, line_num)
	line_num = line_num+1
      end
    end

    # test contents of table
    @table.label.each do |key, value|
     print key, "\t", value ,"\n"
    end

    @asm.close
    @hack.close
  end

  # add symbols to the symbol table
  # input: string, int
  # output: ???
  def secondPass(cmd, addr)
    aCommand_regex = Regexp.new(/(\@)(\w*)/)
    aCommand_match = aCommand_regex.match(cmd)

    if !aCommand_match.nil?
      cmd = aCommand_match[0].to_s
      if cmd[0].chr == "@"
	addr = addr-1
	new_symbol = cmd[1..cmd.size-1]
	if !@table.contains(new_symbol)
	  #print new_symbol, "\t", addr, "\n"
	  @table.addEntry(new_symbol,addr)
	end
	#puts cmd
      #[1...cmd.size-1], "\n"
    #else
     # print "1st char: ", cmd[0].chr, "\n"
      end
    end
  end

  # add each label to the labels table
  # input: string, int
  # output: int (new line-number)
  def firstPass(cmd, addr)
    if cmd.size > 0
      # checking if line is a label
      if cmd[0].chr == "("
	#addr = addr+1
	new_label = cmd[1...cmd.size-1]
	#addr = addr-1
	#print new_label, "\t", addr, "\n"
	if !@table.contains(new_label)#,"label")
	  @table.addEntry(new_label,addr)
	  addr = addr
	end
      else addr = addr+1
      end
    else addr = addr+1
    end
  end



  # find commands (ie. parse out comments)
  # inputs: string
  # output: bool --> true = line doesn't have comments
  def find_command(line)
    comments = Regexp.new(/(\s)*(\/{2}.*)/)
    #\/{2}(\s)*[A-Za-z]*/)
    comment_match = comments.match(line)

    # if nil then contains commands
    if !comment_match.nil?
      comment_match.pre_match
    else
      line
    end
  end

  # if done w/files, close them
  def closeFiles
    @asm.close
    @hack.close
  end



  # read next cmd from input & make it the current cmd
  # input: none
  # output: none
  def advance
  end

  # returns the cmd type (A vs C vs L)
  # input: none
  # output: A/C/L_COMMAND
  def commandType
  end

  # return symbol/ decimal value of current commands
  # only called when the type of command = A_COMMAND or L_COMMAND.
  # input: none
  # output: string
  def symbol
  end

  # returns the dest mnemonic for the current C-command
  # input: none
  # output: string
  def dest
  end

  # returns the comp mnemonic for the current C-command
  # only called when type of command = C_COMMAND
  # input: none
  # output: string
  def comp
  end

  # returns the jump mnemonic for the current C-command
  # only called when type of command = C_COMMAND.
  # input: none
  # output: string
  def jump
  end

end
