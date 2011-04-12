require 'rubygems'
require 'builder'
require 'CompilationEngine'

# Removes all comments and white space from the input stream and breaks it into Jack-language tokens, as specified by the Jack grammar.
class JackTokenizer

#   Opens the input file/stream and gets ready to tokenize it.
  def initialize(param)

    if File.directory?(param)
      fileList = Dir.glob("#{param}*.jack")

      fileList.each do |f|

	print "\nReading the file #{f}\n"
	read = File.open(f,"r")
	newFile = File.basename(f,".jack") + ".win.xml"
	path = "./" + param + newFile

	outputFile = File.new(path,"w")

	@xml = Builder::XmlMarkup.new(:target => outputFile, :indent => 2 )
	print "Will be writing to #{param}#{newFile}\n"

	executeTokenization(read)
	 print "Finished with #{f}\n\n"
	outputFile.close
      end


    elsif File.file?(param)

      if File.extname(param) != ".jack"
	puts "This is not the right file.  You gave a file with an #{File.extname(param)} extension.  I must have your .jack!!!"
      
      else
	print "\nReading the file #{param}\n"
	read = File.open(param,"r")
	newFile = File.basename(param,".jack") + ".win.xml"
	path = "./" + File.dirname(param) + "/"  + newFile
	outputFile = File.new(path,'w')
	@xml = Builder::XmlMarkup.new(:target => outputFile, :indent => 1 )

	print "Will be writing to #{newFile}\n"

	executeTokenization(read)
	 print "Finished with #{param}\n\n"
	outputFile.close
      end
    end
  end



  def executeTokenization(file)

    spaceOut= {
      "{" => "{",
      "}" => "}",
      "(" => "(",
      ")" => ")",
      "[" => "[",
      "]" => "]",
      "." => ".",
      "," => ",",
      ";" => ";",
      "+" => "+",
      "-" => "-",
      "*" => "*",
      "/" => "/",
      "&" => "&amp;",
      "|" => "|",
      "<" => "&lt;",
      ">" => "&gt;",
      "=" => "=",
      "~" => "~",
      "\"" => "\"",
      "'" => "'"
          }
    
    tokens = []
    newline = ""
#     lines = "// This file is part of the materials accompanying the book 
# // \"The Elements of Computing Systems\" by Nisan and Schocken, 
# // MIT Press. Book site: www.idc.ac.il/tecs
# // File name: projects/10/Square/Main.jack
# 
# /**
#  * The Main class initializes a new Square Dance game and starts it.
#  */
# class Main {"

    lines = file.readlines.to_s
    lines = lines.strip.gsub(/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))/, '').strip
    lines.each do |l|
      otherQuote = false
      otherIndex = 0
      for i in 0...l.size
	if spaceOut.has_key?(l[i].chr)
	  newline << " #{l[i].chr} "
	else
	  newline << l[i].chr
	end
      end
    end
    
    tokens = newline.split()
#     puts tokens[0..2]
    j=0
    stringDetected = false
    @xml.tokens{
    for i in 0...tokens.size

      tag = tokenType(tokens[i])
#       print "#{tokens[i]} \t #{tag}\n"
      string = ""

      if tag == :stringConstant and j == 0 then
	j=i+1
	stringDetected = true

      elsif tag == :stringConstant and j > 0 then
# 	print "#{:StringConstant} \t #{tokens[j...i]}\n"
	for k in j...i
	  string << tokens[k] << " "
	end
	@xml.tag!(:stringConstant, " #{string}")
	j=0
	stringDetected = false

      elsif tag != :stringConstant and stringDetected == false
	@xml.tag!(tag, " #{tokens[i]} ")
      end

    end }
    return
    file.readlines.each do |line|
      line = line.strip.gsub(/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))/, '').strip
      # /(\/\*[^*]*\*+(?:[^*\/][^*]*\*+)*\/)|(\/\/.*$)/
#       puts line
      otherQuote = false
      otherIndex = 0
      for i in 0...line.size
	if spaceOut.has_key?(line[i].chr)
	  newline << " #{line[i].chr} "
	else
	  newline << line[i].chr
	end

      end

    end

    tokens = newline.split()
#     puts tokens[0..2]
    j=0
    stringDetected = false
    @xml.tokens{
    for i in 0...tokens.size

      tag = tokenType(tokens[i])
#       print "#{tokens[i]} \t #{tag}\n"
      string = ""

      if tag == :stringConstant and j == 0 then
	j=i+1
	stringDetected = true

      elsif tag == :stringConstant and j > 0 then
# 	print "#{:StringConstant} \t #{tokens[j...i]}\n"
	for k in j...i
	  string << tokens[k] << " "
	end
	@xml.tag!(:stringConstant, " #{string}")
	j=0
	stringDetected = false

      elsif tag != :stringConstant and stringDetected == false
	@xml.tag!(tag, " #{tokens[i]} ")
      end

    end }


    file.close
   

  end


  #   Returns the type of the current token.
  def tokenType(token)

    tag = case token
  when /^(class|constructor|function|method|field|static|var|int|char|boolean|void|true|false|null|this|let|do|if|else|while|return)/ then :keyword

      when  /\{|\}|\(|\)|\[|\]|\.|\,|\;|\+|\-|\*|\/|\&|\||\<|\>|\=|\~/ then :symbol

#      when 0...32767 then :integerConstant
          when /\d+/ then :integerConstant
#       when /\"\w*\"/ then :StringConstant
      when /\"/ then :stringConstant
      when /^[^\d]\w*/ then :identifier
  else puts "haveing an issue #{token}"
    :error
    end

    return tag

  end

#   Returns the keyword which is the current token. Should be called only when tokenType() is KEYWORD.
  def keyWord(t)
    return t
  end

#   Returns the character which is the current token. Should be called only when tokenType() is SYMBOL.
  def symbol(t)
    return t
  end

#   Returns the identifier which is the current token. Should be called only when tokenType() is IDENTIFIER
  def identifier(t)
    return t
  end

#   Returns the integer value of the current token. Should be called only when tokenType() is INT_CONST
  def intVal(t)
    return t
  end

#   Returns the string value of the current token, without the double quotes. Should be called only when tokenType() is STRING_CONST.
  def stringVal(t)
  end

end
