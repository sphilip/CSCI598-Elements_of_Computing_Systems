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

    inputFile = File.open(file,"r")
    print "Reading the file #{file}\n"

    tokens = []
    line = "class Main { test.new('b')"
    y = line.split(/[^\s]/)
    puts y.inspect
    return
    inputFile.readlines.each do |line|
      # parse single / multiline comments
#     line = "class Main {"
      line = line.gsub(/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))/, '').strip

      y = line.split(/\w*/).uniq

      startpos = 0
      endpos = 0

      for i in 0...line.size
	for j in 0...y.size
	  found = false

	  if line[i].chr == y[j] and !y[j].empty?
	    endpos = i
	    found = true
	  end

	  if found then
	    if !y[j].empty? and !line[startpos...endpos].empty? then
	      tokens.push(line[startpos...endpos])
	      tokens.push(y[j])
	    end
	    startpos = endpos+1
	  end

	end
      end

    end

    puts tokens.inspect

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
      when /^\"\w*\"/ then :StringConstant
      when /^[^\d]\w*/ then :identifier
      else :error

    end

    @xml.tag!(tag,t)



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