require 'SymbolicTable'
require 'Code'

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

    # instantiate the list of mnemonics
    @code = Code.new

    # read all lines from file
    lines = @asm.readlines
    line_num = 0

    # first pass through file, parse for labels
    lines.each do |line|
      # remove extraneous characters
      line = line.strip

      # is the line an actual command or a comment
      newline = find_command(line)
      if !newline.nil? && newline.size > 0
	line_num = firstPass(newline, line_num)
      end
    end

    # second pass through file, find A-instructions (cmds w/@ that are not labels)
    line_num = 0
    lines.each do |line|
      newline = find_command(line)
      if !newline.nil? && newline.size > 0
	secondPass(newline)
      end
    end

#     test contents of table
    @table.label.sort.each do |key, value|
     print key, "\t", value ,"\n"
    end

    puts ""

    @table.symbols.sort.each do |key, value|
     print key, "\t", value ,"\n"
    end

    puts "Assembly complete!\n"

    @asm.close
    @hack.close
  end


  # add symbols to the symbol table
  # input: string, int
  # output: string form of binary code
  def secondPass(cmd)
    aCommand_regex = Regexp.new(/(\@)(\w*)/)
    aCommand_match = aCommand_regex.match(cmd)

    if !aCommand_match.nil?
      cmd = aCommand_match[0].to_s

      # if cmd is indeed an a-instruction, it should have @ as the 1st character
      if cmd[0].chr == "@"
	new_symbol = cmd[1..cmd.size-1]

	# add symbol to table if it doesn't have it already
	if !@table.contains(new_symbol)
	  #print new_symbol, "\t", addr, "\n"

	  # using the answer to everything as a dummy parameter
	  @table.addEntry(new_symbol,42)
	end
	@hack.print("0", @table.getAddress(new_symbol), "\n")
      end
      else
	parseCInstruction(cmd)
    end
  end



  # parse the C Instruction
  # input: string
  # output: ???
  def parseCInstruction(c)

    sym = c.strip
    dest = "000"
    comp = "000000"
    jump = "000"

    if !sym.nil?
      if !sym.empty?
	c_regex = Regexp.new(/\;|\=/)
	c_match = c_regex.match(sym)

	if !c_match.nil?
	  if c_match[0] == "="
 #print "for =, have ", c_match.pre_match, " and ", c_match.post_match, "\n"
	    dest = @code.dest(c_match.pre_match)
	    comp = @code.comp(c_match.post_match)
	  end

	  if c_match[0] == ";"
	    #print "for ;, have ", c_match.pre_match, " and ", c_match.post_match, "\n"
	    comp = @code.comp(c_match.pre_match)
	    jump = @code.jump(c_match.post_match)
	  end

	  @hack.print("111", comp, dest, jump, "\n")
	end
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
	new_label = cmd[1...cmd.size-1]
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
