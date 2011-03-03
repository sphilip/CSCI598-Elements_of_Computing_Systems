# tranlsation VM commands into Hack assembly code
class CodeWriter
  
  # open output file
  def initialize
  end
  
  # inform code writer that translation of new VM file is started
  # input: string (file name)
  # output: none
  def  setFileName(path)
  end
  
  # write assembly code 
  # input: string (the command)
  # otuput: none
  def writeArithmetic
  end
  
  # write assembly code that's the tranlsation of a 
  # given command (for C_PUSH/ C_POP)
  # input: command (C_PUSH/C_POP), string (segment), int (index)
  # output: none
  def writePushPop
  end
  
  # close output file
  def close
  end
end