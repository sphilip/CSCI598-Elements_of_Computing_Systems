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

	newFile = File.basename(f,".jack") + ".win.xml"
	path = "./" + param + newFile

	outputFile = File.new(path,"w")

	@xml = Builder::XmlMarkup.new(:target => outputFile, :indent => 2 )
	print "Will be writing to #{param}#{newFile}\n"

	executeTokenization(f)
	outputFile.close
      end


    elsif File.file?(param)

      newFile = File.basename(param,".jack") + ".win.xml"
      path = "./" + File.dirname(param) + "/"  + newFile
      outputFile = File.new(path,'w')
      @xml = Builder::XmlMarkup.new(:target => outputFile, :indent => 2 )

      print "Will be writing to #{newFile}\n"

      executeTokenization(path)
      outputFile.close
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

    inputFile = File.open(file,"r")
    print "Reading the file #{file}\n"

    tokens = []
    newline = ""
    inputFile.readlines.each do |line|
      
      line = line.gsub(/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))/, '').strip
      
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
    for i in 0...tokens.size
      
      tag = tokenType(tokens[i])
#       print "#{tokens[i]} \t #{tag}\n"
      string = ""
      
      if tag == :StringConstant and j == 0 then
	j=i+1
	stringDetected = true
      
      elsif tag == :StringConstant and j > 0 then
# 	print "#{:StringConstant} \t #{tokens[j...i]}\n"
	for k in j...i
	  string << tokens[k] << " "
	end
	@xml.tag!(:StringConstant, " #{string}")
	j=0
	stringDetected = false
      
      elsif tag != :StringConstant and stringDetected == false
	@xml.tag!(tag, " #{tokens[i]} ")
      end
    
    end
        
    inputFile.close

  end


  #   Returns the type of the current token.
  def tokenType(token)

    tag = case token
      when /(class)|(constructor)|(function)|
	    (method)|(field)|(static)|(var)|(int)|
	    (char)|(boolean)|(void)|(true)|(false)|
	(null)|(this)|(let)|(do)|(if)|(else)|(while)|
	(return)/ then :keyword

      when  / \{|\}|\(|\)|\[|\]|\.|\,|\;|\+|\-|\*|\/|\&|\||\<|\>|\=|\~/ then :symbol

      when 0...32767 then :integerConstant
#       when /\"\w*\"/ then :StringConstant
      when /\"/ then :StringConstant
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