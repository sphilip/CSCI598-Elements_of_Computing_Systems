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

    @symbol = {
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
  "~" => "~"
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
	if @symbol.has_key?(line[i].chr)
	  newline << " #{line[i].chr} "
	else
	  newline << line[i].chr  
	end
	
# 	if line[i].chr == "\"" and otherQuote == false then
# 	  otherIndex = i
# 	  otherQuote = true
# 	  	  
# 	elsif line[i].chr == "\"" and otherQuote == true then
# 	  newline << line[otherIndex..i] << " "
# 	  otherQuote = false
# 	  	
# 	elsif @symbol.has_key?(line[i].chr)
# 	  newline << " #{line[i].chr} "
# 	
# 	else
# 	  newline << line[i].chr  
# 	end
	
	
      end
      
    end

    tokens = newline.split()
            
#     for i in 0...tokens.size
#       j=0
#       tag = tokenType(tokens[i])
#     
#       if tag == :StringConstant and j >= 0 then
# 	j=j+1
#       end
# 
#       if tag != :StringConstant and j == 0 then
# 	@xml.tag!(tag, " #{tokens[i]} ")
#       elsif tag != :StringConstant and j>0 then
# 	@xml.tag!(:StringConstant, " #{tokens[j-1...i-1]} ")
# 	@xml.tag!(tag, " #{tokens[i]} ")
#       end
#     
#     end
    
    tokens.each do |t|
      @xml.tag!(tokenType(t), " #{t} ")
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
#       when /^\"\w*\"/ then :StringConstant
	when /[^\"]/ then :StringConstant
      when /^[^\d]\w*/ then :identifier
      else :error

    end

    return tag

  end

#   Returns the keyword which is the current token. Should be called only when tokenType() is KEYWORD.
  def keyWord
  end

#   Returns the character which is the current token. Should be called only when tokenType() is SYMBOL.
  def symbol
  end

#   Returns the identifier which is the current token. Should be called only when tokenType() is IDENTIFIER
  def identifier
  end

#   Returns the integer value of the current token. Should be called only when tokenType() is INT_CONST
  def intVal
  end

#   Returns the string value of the current token, without the double quotes. Should be called only when tokenType() is STRING_CONST.
  def stringVal
  end

end