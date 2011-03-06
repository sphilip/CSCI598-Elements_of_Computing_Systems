require 'erb'

# tranlsation VM commands into Hack assembly code
class CodeWriter
$label_index=0


  # open output file
  def initialize(path)

    @output = File.open(path,"w")
    @segment_hash = {
      "push constant" => "./templates/push-constant.erb",
      "push local" => "./templates/push-lcl.erb",
      "push argument" => "./templates/push-arg.erb",
      "push this" => "./templates/push-this.erb",
      "push that" => "./templates/push-that.erb",

      "pop constant" => "./templates/pop-constant.erb",
      "pop local" => "./templates/pop-lcl.erb",
      "pop argument" => "./templates/pop-arg.erb",
      "pop this" => "./templates/pop-this.erb",
      "pop that" => "./templates/pop-that.erb"
    }

    @arith_hash = {
      "add" => "./templates/add.erb",
      "sub" => "./templates/sub.erb",
      "eq" => "./templates/eq.erb",
      "lt" => "./templates/lt.erb",
      "gt" => "./templates/gt.erb",
      "and" => "./templates/and.erb",
      "or" => "./templates/or.erb"
    }
  end

  # inform code writer that translation of new VM file is started
  # input: string (file name)
  # output: none
  def  setFileName(path)
  end

  def writeArith(file)
    infile = File.open(file,'r')
    erb = ERB.new(infile.read)
    @output.write erb.result(binding)
  end

  # write assembly code
  # input: string (the command)
  # output: none
  def writeArithmetic(command)
    if @arith_hash.has_key?(command)
      writeArith(@arith_hash[command])
    else puts "#{command} not supported. \n\n"
    end

#     output = ""
#     if command.downcase == "add" then
#       output = "// add
# @SP
# AM=M-1
# D=M
# @SP
# A=M-1
# M=M+D \n\n"
#     writeArith(@arith_hash[command.downcase]
#     elsif command.downcase == "sub" then
#       output = "// subtract
# @SP
# AM=M-1
# D=M
# @SP
# A=M-1
# M=M-D \n\n"
#
#     elsif command.downcase == "eq" then
#       output = "// equals?
# @SP
# AM=M-1
# D=M
# @SP
# A=M-1
# A=M
# D=D-A
# @TRUE_#{$label_index}
# D;JEQ
#
# (FALSE_#{$label_index})
# @SP
# A=M-1
# M=0
# @EXIT_#{$label_index}
# 0;JMP
#
# (TRUE_#{$label_index})
# @SP
# A=M-1
# M=-1
#
# (EXIT_#{$label_index})\n\n"
#       $label_index=$label_index+1
#
#     elsif command.downcase == "lt" then
#       output = "// less than?
# @SP
# AM=M-1
# D=M
# @SP
# A=M-1
# A=M
# D=A-D
# @TRUE_#{$label_index}
# D;JLT
# (FALSE_#{$label_index})
# @SP
# A=M-1
# M=0
# @EXIT_#{$label_index}
# 0;JMP
#
# (TRUE_#{$label_index})
# @SP
# A=M-1
# M=-1
#
# (EXIT_#{$label_index})\n\n"
#       $label_index=$label_index+1
#
#   elsif command.downcase == "gt" then
#     output = "// greater than?
# @SP
# AM=M-1
# D=M
# @SP
# A=M-1
# A=M
# D=A-D
# @TRUE_#{$label_index}
# D;JGT
#
# (FALSE_#{$label_index})
# @SP
# A=M-1
# M=0
# @EXIT_#{$label_index}
# 0;JMP
#
# (TRUE_#{$label_index})
# @SP
# A=M-1
# M=-1
#
# (EXIT_#{$label_index}) \n\n"
#       $label_index=$label_index+1
#
#     elsif command.downcase == "neg" then
#       output = "// negate value at SP-1
# @SP
# AM=M-1
# D=-M
# M=D
# @SP
# M=M+1 \n\n"
#
#     elsif command.downcase == "and" then
#       output = "// bitwise and
# @SP
# AM=M-1
# D=M
# @SP
# AM=M-1
# A=M
# D=A&D
# @SP
# A=M
# M=D
# @SP
# M=M+1 \n\n"
#
#     elsif command.downcase == "or" then
#       output = "// bitwise or
# @SP
# AM=M-1
# D=M
# @SP
# AM=M-1
# A=M
# D=A|D
# @SP
# A=M
# M=D
# @SP
# M=M+1 \n\n"
#
#     end
#     return output
  end

  def writePush(command,segment,index)

    infile = File.open(@segment_hash[command + " " + segment], 'r')
    erb = ERB.new(infile.read)
    @output.write erb.result(binding)

  end

  # write assembly code that's the tranlsation of a
  # given command (for C_PUSH/ C_POP)
  # input: command (C_PUSH/C_POP), string (segment), int (index)
  # output: none
  def writePushPop(command,segment,index)
    output = ""
    # command is push
#     if command == "C_PUSH" then
#       output = "//push #{segment} #{index}
# @#{index}
# D=A
# @SP
# A=M
# M=D
# @SP
# M=M+1\n\n"
if command == "push"
    writePush(command,segment,index)

    # command is pop
    else
      output = "//pop #{segment} #{index}
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
    @output.close
  end
end