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

      newFile = File.basename(f,".jack") + ".win.xml"
      path = "./" + param + newFile
      outputFile = File.new(path,'w')
      @xml = Builder::XmlMarkup.new(:target => outputFile, :indent => 2 )

      print "Will be writing to #{newFile}\n"

      executeTokenization(path)
      outputFile.close
    end

  end



  def executeTokenization(file)

    @xml.instruct!
    inputFile = File.open(file,"r")
    print "Reading the file #{file}\n"

    tokens = []
    inputFile.readlines.each do |line|
      # parse single / multiline comments
      line = line.gsub(/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))/,'')

      if !line.empty? or !line.nil?
	tokens = tokens + line.split()
      end
    end

#     puts tokens.inspect
    compilation = CompilationEngine.new(tokens, @xml)
    inputFile.close

  end


  #   Returns the type of the current token.
  def tokenType
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