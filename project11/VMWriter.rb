# write VM command to file using VM command syntax
class VMWriter

  # create new file & open for writing
  def initialize
  end
  
  # write command for push 
  # input: segment (const,arg,lcl,etc), index (int)
  def writePush(segment, index)
  end
  
  # write command for pop
  # input: segment (const,arg,lcl,etc), index (int)
  def writePop(segment, index)
  end
  
  # write arithmetic command
  # input: command (add,sub,etc)
  def writeArithmetic(command)
  end
  
  # write label
  # input: label (string)
  def writeLabel(label)
  end
  
  # write goto
  # input: label (string)
  def writeGoto (label)
  end
  
  # write if-goto
  # input: label (string)
  def writeIf (label)
  end
  
  # write call
  # input: name (string), number of args (int)
  def writeCall (name, numArg)
  end
  
  # write function
  # input: name (string), number of locals (int) 
  def writeFunction (name, numLcl)
  end
  
  # write return
  def writeReturn
  end
  
  # close output file
  def close
  end
  
end