require 'Node'
require 'ruby-debug'

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

    @keywordConstant = [
      'true',
      'false',
      'null',
      'this'
      ]

    @operands = [
      '+',
      '-',
      '*',
      '/',
      '&',
      '|',
      '<',
      '>',
      '=',
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
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end


      if tokens[ptr].token == "{" then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " { ")
	ptr = ptr+1
      end


      if @classVarDecStart.include?(tokens[ptr].token) then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	# 	@currentElement << "classVarDec"
	@xml.classVarDec {
	  ptr = ptr + compileClassVarDec(tokens[ptr...tokens.size])
	}
      end


      if @subroutineDecStart.include?(tokens[ptr].token) then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
# 	@currentElement << "subroutineDec"
	@xml.subroutineDec {
	  ptr = ptr + compileSubroutine(tokens[ptr...tokens.size])
	}

      end


      if tokens[ptr].token == "}" then
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " } ")
	ptr = ptr+1
      end


#     else
#       puts "Are you pondering what I am pondering, Pinky?"
#       puts "I think so Brain, but why is ptr=#{ptr} while token size = #{tokens.size}?"
#     end
      puts "finished class"
  end

#   Compiles a static declaration or a field declaration.
  def compileClassVarDec(tokens)
    puts "compiling ClassVarDec"
    ptr = 0

    while tokens[ptr].token != ";"
      if @classVarDecStart.include?(tokens[ptr].token)
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end

      if @typeStart.include?(tokens[ptr].token) then
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end

      if tokens[ptr].tag == :identifier then
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end

      while tokens[ptr].token == ","
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1

	if tokens[ptr].tag == :identifier then
# 	  puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	  @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	  ptr = ptr+1
	end
      end

    end

    if tokens[ptr].token == ";" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    puts "finished ClassVarDec"
    return ptr
  end

#   Compiles a complete method, function, or constructor.
  def compileSubroutine(tokens)
    puts "compiling Subroutine"
    ptr = 0

    if @subroutineDecStart.include?(tokens[ptr].token)
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
    end

    if @typeStart.include?(tokens[ptr].token) or tokens[ptr].token == "void"
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].tag == :identifier
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "(" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

      @xml.parameterList{
	ptr = ptr + compileParameterList(tokens[ptr...tokens.size])
#        puts ptr
#     puts " paramlist says: #{tokens[ptr].token}"
      }
#       ptr = ptr + 1
#     end

#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
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
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
    end

    if tokens[ptr].token == "var" then
      @xml.varDec{
	ptr = ptr + compileVarDec(tokens[ptr...tokens.size])
      }
    end

    if tokens[ptr].token != "}" then
      @xml.statements{
	ptr = ptr + compileStatements(tokens[ptr...tokens.size])

      }
    end

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
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end

      if tokens[ptr].tag == :identifier then
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end

      while tokens[ptr].token == ","
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1

	 if tokens[ptr].tag == :identifier then
# 	  puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	  @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	  ptr = ptr+1
	end
      end

    end

    puts "finished ParameterList"
    return ptr
  end

#   Compiles a var declaration.
  def compileVarDec(tokens)
    puts "compiling VarDec"
    ptr = 0

    if tokens[ptr].token == "var" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if @typeStart.include?(tokens[ptr].token) then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].tag == :identifier then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    while tokens[ptr].token ==","
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

      if @typeStart.include?(tokens[ptr].token) then
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end

      if tokens[ptr].tag == :identifier then
# 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
      end
    end

    if tokens[ptr].token == ";" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

     puts "finished VarDec"
     return ptr
  end

#   Compiles a sequence of statements, not including the enclosing “{}”.
  def compileStatements(tokens)
    puts "compiling Statements"
    ptr = 0
    while tokens[ptr].token != "}"
      @xml.statement{
      puts tokens[ptr].token
      ptr = ptr + compileStatement(tokens[ptr...tokens.size])
      }
    end

    puts "finished Statements"
    return ptr
  end

  def compileStatement(tokens)
    ptr = 0
   case tokens[0].token
    when "let" then @xml.letStatement{ ptr = ptr + compileLet(tokens)}
    when "if" then @xml.ifStatement{ ptr = ptr + compileIf(tokens)}
    when "while" then @xml.whileStatement{ ptr = ptr + compileWhile(tokens)}
    when "do" then @xml.doStatement{ ptr = ptr + compileDo(tokens)}
    when "return" then @xml.returnStatement{ ptr = ptr + compileReturn(tokens)}
    end

    return ptr
  end

#   Compiles a do statement.
  def compileDo(tokens)
    puts "compiling Do"
    ptr =0

    puts "finished Do"
    return ptr
  end

#   Compiles a let statement.
  def compileLet(tokens)
    puts "compiling Let"
    ptr = 0

    if tokens[ptr].token == "let" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].tag == :identifier then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "[" then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

      @xml.expression {
	ptr = ptr + compileExpression(tokens[ptr...tokens.size])
      }
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "=" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.expression{
      ptr = ptr + compileExpression(tokens[ptr...tokens.size])
      }

    if tokens[ptr].token == ";" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    puts "finished Let"
    return ptr
  end

  # Compiles a while statement.
  def compileWhile(tokens)
    puts "compiling While"
    ptr =0

    if tokens[ptr].token == "while" then
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "(" then
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.expression{
      ptr = ptr + compileExpression(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == ")" then
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "{" then
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.statements{
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      ptr = ptr + compileStatements(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == "}" then
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    puts "finished While"
    return ptr
  end

  # Compiles a return statement.
  def compileReturn(tokens)
    puts "compiling Return"
    ptr =0

    puts "finished return"
    return ptr
  end

  # Compiles an if statement, possibly with a trailing else clause.
  def compileIf(tokens)
    puts "compiling If"
    ptr =0

    if tokens[ptr].token == "if"
      puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "("
      puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"

      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.expression{
      puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"

      ptr = ptr + compileExpression(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == ")"
      puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"

      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "{"
      puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"

      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.statements {
      puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"

      ptr = ptr + compileStatements(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == "}"
      puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"

      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "else"
      @xml.elseStatement{
	puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"

	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
        ptr = ptr+1

        if tokens[ptr].token == "{"
	  puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"
	  @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
          ptr = ptr+1
	end

        @xml.statements {
	  puts "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"
	  ptr = ptr + compileStatements(tokens[ptr...tokens.size])
        }

        if tokens[ptr].token == "}"
	  "#{ tokens[ptr].token} => #{ tokens[ptr].tag}"
	  @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
          ptr = ptr+1
        end
      }
    end

    puts "finished if"
    return ptr
  end

  # compiles expression
  def compileExpression(tokens)
    puts "compiling Expression"
    ptr = 0

    @xml.term{
      ptr = compileTerm(tokens)
    }

    while @operands.include?(tokens[ptr].token)
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

      @xml.term{
	ptr = ptr + compileTerm(tokens[ptr...tokens.size])
      }
    end

    puts "finished expression"
    return ptr
  end

  # compiles a term.  This routine is faced w/ a slight difficulty when trying to decide b/w some of the alternative parsing rules.  Specifically, if the current token is an identifier, the routine must distinguish b/w a variable/array entry & subroutine  call.  A signle lookahead token, which may be one of "[",string "(", or "." suffices to distinguish b/w the 3 possibilities.  Any other token is not art of this term & shouldn't be advanced over
  def compileTerm(tokens)
     puts "compiling Term"
     ptr = 0

     if tokens[ptr].tag == :integerConstant
#        debugger
       if (0..32767).include?(tokens[ptr].token.to_i)
	 @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
       else
	 puts "While compiling term #{tokens[ptr].token}, I noticed that it's not a valid integer constant!"
       end
       ptr = ptr+1
     end

     while tokens[ptr].tag == :stringConstant
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
     end

     if @keywordConstant.include?(tokens[ptr].token)
       @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
       ptr = ptr+1
     end

     if tokens[ptr].tag == :identifier
       @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
       ptr = ptr+1

       if tokens[ptr].token == "["
	 @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	 ptr = ptr+1

	 ptr = ptr + compileExpression(tokens[ptr...tokens.size])

	 @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	 ptr = ptr+1
       end
     end

     if tokens[ptr].token == "-" or tokens[ptr].token == "~"
       @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
       ptr = ptr+1

       @xml.term{
	 ptr = ptr + compileTerm(tokens[ptr...tokens.size])
       }
     end

     puts "finishing Term"
     return ptr
  end

  # compiles a (possibly empty) comma-separated list of expressions
  def compileExpressionList
     puts "compiling ExpressionList"
  end

end
