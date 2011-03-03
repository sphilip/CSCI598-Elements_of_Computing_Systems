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
  def writeArithmetic(command)
    output = ""
    if command.downcase == "add" then
      output = "// add
@SP
AM=M-1
D=M
@SP
A=M-1
M=M+D\n\n"
      
    elsif command.downcase == "sub" then
      output = "// subtract
@SP
AM=M-1
D=M
@SP
A=M-1
M=M-D\n\n"
      
    end
    
    return output
  end
  
  
  
  # write assembly code that's the tranlsation of a 
  # given command (for C_PUSH/ C_POP)
  # input: command (C_PUSH/C_POP), string (segment), int (index)
  # output: none
  def writePushPop(command,segment,index)
    output = ""
    # command is push
    if command == "C_PUSH" then
      output = "//push #{segment} #{index}
@#{index}
D=A
@SP
A=M
M=D
@SP
M=M+1\n\n"
      
    # command is pop
    else
      output == "//pop #{segment} #{index}
@#{index}
D=A
@SP
A=M
M=D
@SP
M=M-1\n\n"
    end
    
    return output
  end
  
  # close output file
  def close
  end
end