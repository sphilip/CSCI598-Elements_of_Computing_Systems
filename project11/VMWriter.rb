# write VM command to file using VM command syntax
class VMWriter

  # create new file & open for writing
  def initialize(name)

    new_name = File.basename(name,".jack") + ".compiled.vm"

    dirname = name.gsub(/\w*\.\w*/,'')

    path = "./" + dirname + new_name
    @write = File.new(path,"w")
  end

  # write command for push
  # input: segment (const,arg,lcl,etc), index (int)
  def writePush(segment, index)
    @write.puts "push #{segment} #{index}"
  end

  # write command for pop
  # input: segment (const,arg,lcl,etc), index (int)
  def writePop(segment, index)
    @write.puts "push #{segment} #{index}"
  end

  # write arithmetic command
  # input: command (add,sub,etc)
  def writeArithmetic(command)
    @write.puts "#{command}"
  end

  # write label
  # input: label (string)
  def writeLabel(label)
    @write.puts "(#{label})"
  end

  # write goto
  # input: label (string)
  def writeGoto (label)
    @write.puts " if-goto #{label}"
  end

  # write if-goto
  # input: label (string)
  def writeIf (label)
  end

  # write call
  # input: name (string), number of args (int)
  def writeCall (name, numArg)
    @write.puts "call #{name} #{numArg}"
  end

  # write function
  # input: name (string), number of locals (int)
  def writeFunction (name, numLcl)
    @write.puts "function #{name} #{numLcl}"
  end

  # write return
  def writeReturn
    @write.puts "return"
  end

  # close output file
  def close
  end

end