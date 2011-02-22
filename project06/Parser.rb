# split up asm command into field & symbols
class Parser
  
  
  # take input file and open it
  def initialize(file)
  
  end
    
  # if done w/files, close them
  def closeFiles
   
  end
  
  # more commands?
  # inputs: none
  # output: bool
  def hasMoreCommands
  
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
