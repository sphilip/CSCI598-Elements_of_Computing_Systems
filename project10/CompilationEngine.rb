require 'Node'
# require 'ruby-debug'

# In the first version of the compiler, described in Chapter 10, this module emits a structured printout of the code, wrapped in XML tags. In the final version of the compiler, described in Chapter 11, this module generates executable VM code.
class CompilationEngine



#   Creates a new compilation engine with the given input and output. The next routine called must be compileClass().
  def initialize(tokens,xmlFile)
    @xml = xmlFile

    @classVarDecStart = [
    'static',
    'field'
    ]

    @typeStart = [
      'int',
      'char',
      'boolean'
      ]

    @subroutineDecStart = [
      'constructor',
      'function',
      'method'
      ]

    @keywordConstantStart = [
      'true',
      'false',
      'null',
      'this'
      ]

    @currentElement = ["class"]


  #     tokens.printTree
    if tokens[0].token == "class" then
      @xml.class {
	@xml.tag!(tokens[0].tag,  " class ")
	compileClass(tokens[1...tokens.size])
      }

    else puts "Syntax error: #{tokens[0].token}"
    end
  end


#   Compiles a complete class.
  def compileClass(tokens)
    puts "Compiling class"
    ptr = 0

    #     @currentElement << "class"
#     if ptr < tokens.size then
      
      if tokens[ptr].tag == :identifier then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end
      
      
      if tokens[ptr].token == "{" then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " { ")
	ptr = ptr+1      
      end
      
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      if @classVarDecStart.include?(tokens[ptr].token) then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	# 	@currentElement << "classVarDec"
	@xml.classVarDec { 
	  ptr = ptr + compileClassVarDec(tokens[ptr...tokens.size])
# 	 puts ptr
#     puts " classvardec says: #{tokens[ptr].token}"
# 	@currentElement.pop
	}
# 	ptr = ptr+1
      end
      
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      if @subroutineDecStart.include?(tokens[ptr].token) then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
# 	@currentElement << "subroutineDec"
	@xml.subroutineDec { 
	  ptr = ptr + compileSubroutine(tokens[ptr...tokens.size])
# 	 puts ptr
#     puts " subroutine says: #{tokens[ptr].token}"
	}
# 	@currentElement.pop
# 	ptr = ptr+1  
      end
      
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      if tokens[ptr].token == "}" then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " } ")
	ptr = ptr+1
      end
#       comp
      
#     else 
#       puts "Are you pondering what I am pondering, Pinky?"
#       puts "I think so Brain, but why is ptr=#{ptr} while token size = #{tokens.size}?"
#     end
      puts "finished class"
  end
  
#   Compiles a static declaration or a field declaration.
  def compileClassVarDec(subToken)
    puts "compiling ClassVarDec"
    ptr = 0
    
    puts "finished ClassVarDec"
    return ptr
  end

#   Compiles a complete method, function, or constructor.
  def compileSubroutine(tokens)
    puts "compiling Subroutine"
    ptr = 0

    if @subroutineDecStart.include?(tokens[ptr].token)
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
    end

    if @typeStart.include?(tokens[ptr].token) or tokens[ptr].token == "void"
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end
      
    if tokens[ptr].tag == :identifier
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end
      
    if tokens[ptr].token == "(" then
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
   
      @xml.parameterList{  
	ptr = ptr + compileParameterList(tokens[ptr...tokens.size])
#        puts ptr
#     puts " paramlist says: #{tokens[ptr].token}"
      }
#       ptr = ptr + 1
#     end
      
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end
      
    
     
#     ptr = ptr + 1
    @xml.subroutineBody {
      ptr = ptr + compileSubroutineBody(tokens[ptr...tokens.size])
#      puts ptr
#     puts " subroutinebody says: #{tokens[ptr].token}"
    }
#     end
   
    puts "finished Subroutine"
    return ptr
  end

  def compileSubroutineBody(tokens)
    puts "compiling SubroutineBody"
    ptr = 0
    
    if tokens[ptr].token == "{" then
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
    end
    
    if tokens[ptr].token == "var" then
      @xml.varDec{
	ptr = ptr + compileVarDec(tokens[ptr...tokens.size])
#        puts ptr
#     puts " VarDec says: #{tokens[ptr].token}"
      }
    end
    
    @xml.statements{
      ptr = ptr + compileStatements(tokens[ptr...tokens.size])
#     puts ptr
#     puts " Statements says: #{tokens[ptr].token}"
    }
    
    if tokens[ptr].token == "}" then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end
    
    return ptr
    puts "finished SubroutineBody"
  end
  
#   Compiles a (possibly empty) parameter list, not including the enclosing “()”.
  def compileParameterList(tokens)
    puts "compiling ParameterList"
    ptr = 0
    while tokens[ptr].token != ")"
      if @typeStart.include?(tokens[ptr].token) then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end
      
      if tokens[ptr].tag == :identifier then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end
	
      if tokens[ptr].token == "," then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end
    end    
    
    puts "finished ParameterList"
    return ptr
  end

#   Compiles a var declaration.
  def compileVarDec(tokens)
     puts "compiling VarDec"
     puts "finished VarDec"
  end

#   Compiles a sequence of statements, not including the enclosing “{}”.
  def compileStatements(tokens)
     puts "compiling Statements"
     ptr = 0
     
     
     puts "finished Statements"
     return ptr
  end

#   Compiles a do statement.
  def compileDo
     puts "compiling Do"
  end

#   Compiles a let statement.
  def compileLet
     puts "compiling Let"
  end

  # Compiles a while statement.
  def compileWhile
     puts "compiling While"
  end

  # Compiles a return statement.
  def compileReturn
     puts "compiling Return"
  end

  # Compiles an if statement, possibly with a trailing else clause.
  def compileIf
     puts "compiling If"
  end

  # compiles expression
  def compileExpression
     puts "compiling Expression"
  end

  # compiles a term.  This routine is faced w/ a slight difficulty when trying to decide b/w some of the alternative parsing rules.  Specifically, if the current token is an identifier, the routine must distinguish b/w a variable/array entry & subroutine  call.  A signle lookahead token, which may be one of "[", "(", or "." suffices to distinguish b/w the 3 possibilities.  Any other token is not art of this term & shouldn't be advanced over
  def compileTerm
     puts "compiling Term"
  end

  # compiles a (possibly empty) comma-separated list of expressions
  def compileExpressionList
     puts "compiling ExpressionList"
  end

end
