require 'rubygems'
require 'builder'
require 'CompilationEngine'
require 'Node'
# require 'ruby-debug'

# Removes all comments and white space from the input stream and breaks it into Jack-language tokens, as specified by the Jack grammar.
class JackTokenizer

#   Opens the input file/stream and gets ready to tokenize it.
  def initialize(param)

    if File.directory?(param)
      fileList = Dir.glob("#{param}*.jack")

      if fileList.empty?
	puts "No valid jack files"

      else
	fileList.each do |f|
	  startupFile(f)
	end
      end


    elsif File.file?(param)

      if File.extname(param) != ".jack"
	puts "This is not the right file.  You gave a file with an #{File.extname(param)} extension.  I must have your .jack!!!"

      else
	startupFile(param)
      end
    end

  end


  def startupFile(inputFileName)
    print "\nReading the file #{inputFileName}\n"
    inputFile = File.open(inputFileName,"r")


    ###  For part 1 - tokenization  ###
    part1 = File.basename(inputFileName,".jack") + ".tokens.xml"
    dirname = inputFileName.gsub(/\w*\.\w*/,'')

    path = "./" + dirname + part1
    outputFile1 = File.new(path,"w")

    @createTokensFile = Builder::XmlMarkup.new(:target => outputFile1, :indent => 2 )
    print "Will be writing the tokens to #{part1}\n"

    tokensArray = createTokensFrom(inputFile)
    print "Finished with #{inputFileName}\n"
    outputFile1.close
    inputFile.close


    ### For part 2 - parsing  ###
    part2 = File.basename(inputFileName,".jack") + ".parse.xml"
    path = "./" + dirname + part2

    outputFile2 = File.new(path,"w")

    @parseTokensFile = Builder::XmlMarkup.new(:target => outputFile2, :indent => 2 )
    print "\nWill be writing parsed version of the file to #{part2}\n\n"

    
    compiler = CompilationEngine.new(tokensArray.tree[0...tokensArray.tree.size],@parseTokensFile)
    outputFile2.close
  end


  def createTokensFrom(file)

   specialSymbols = [
      "{" ,
      "}" ,
      "(" ,
      ")" ,
      "[" ,
      "]" ,
      "." ,
      "," ,
      ";" ,
      "+" ,
      "-" ,
      "*" ,
      "/" ,
      "&" ,
      "|" ,
      "<" ,
      ">" ,
      "=" ,
      "~" ,
      "\"",
      "'"
    ]

    tokens = []
    newline = ""

    lines = file.readlines.to_s
    lines = lines.strip.gsub(/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))/, '').strip
    lines.each do |l|
      otherQuote = false
      otherIndex = 0
      for i in 0...l.size
# 	if spaceOut.has_key?(l[i].chr)
	if specialSymbols.include?(l[i].chr)
	  newline << " #{l[i].chr} "
	else
	  newline << l[i].chr
	end
      end
    end

    tokens = newline.split()
    tokens = XMLTokenization(tokens)
    return createTreeFrom(tokens)

  end

  ##   for Stage 1 - XML tokenization   ###
  def XMLTokenization(tokens)
    realTokens = []
    j=0
    stringDetected = false

    @createTokensFile.tokens{
      for i in 0...tokens.size

	tag = tokenType(tokens[i])
	string = ""

	if tag == :stringConstant and j == 0 then
	  j=i+1
	  stringDetected = true

	elsif tag == :stringConstant and j > 0 then
	  for k in j...i
	    string << tokens[k] << " "
	  end

	  @createTokensFile.tag!(:stringConstant, " #{string}")
	  j=0
	  stringDetected = false
	  realTokens.push(string)

	elsif tag != :stringConstant and stringDetected == false
	  @createTokensFile.tag!(tag, " #{tokens[i]} ")
	  realTokens.push(tokens[i])
	end

      end
    }

    return realTokens
  end

  ### for Stage 2 - Parsing of tokens ###
  def createTreeFrom(tokens)

    tree = NodeTree.new
    tokens.each do |t|
      node = Node.new(t,tokenType(t))
      tree.addToTree(node)
    end

    return tree
  end


  #   Returns the type of the current token.
  def tokenType(token)

    tag = case token
      when /^(class|constructor|function|method|field|static|var|int|char|boolean|void|true|false|null|this|let|do|if|else|while|return)/ then :keyword

      when  /\{|\}|\(|\)|\[|\]|\.|\,|\;|\+|\-|\*|\/|\&|\||\<|\>|\=|\~/ then :symbol

      when /^\d+/ then :integerConstant
      when /\"/ then :stringConstant
      when /^[^\d]\w+/ then :identifier
      else :error
    end

    return tag

  end

end
