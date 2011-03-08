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
      "push temp" => "./templates/push-temp.erb",
      "push pointer" => "./templates/push-pointer.erb",
      "push static" => "./templates/push-static.erb",
      
      "pop constant" => "./templates/pop-constant.erb",
      "pop local" => "./templates/pop-lcl.erb",
      "pop argument" => "./templates/pop-arg.erb",
      "pop this" => "./templates/pop-this.erb",
      "pop that" => "./templates/pop-that.erb",
      "pop temp" => "./templates/pop-temp.erb",
      "pop pointer" => "./templates/pop-pointer.erb",     
      "pop static" => "./templates/pop-static.erb"
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


  # write assembly code
  # input: string (the command)
  # output: none
  def writeArithmetic(command)

    if @arith_hash.has_key?(command) then
   
      File.open(@arith_hash[command],'r') do |infile|
	erb = ERB.new(infile.read)
	@output.write erb.result(binding)

      end

    else puts "#{command} not supported. \n\n"
    end

  end


  # write assembly code that's the translation of a
  # given command (for C_PUSH/ C_POP)
  # input: command (C_PUSH/C_POP), string (segment), int (index)
  # output: none
  def writePushPop(command,segment,index)
    
    key = command + " " + segment
    if @segment_hash.has_key?(key)

      File.open(@segment_hash[key], 'r') do |infile|
      erb = ERB.new(infile.read)
      @output.write erb.result(binding)
      end

    else puts "#{command} #{segment} not supported\n\n"
    end

  end

  # close output file
  def close
    @output.close
  end
  
  
  
end