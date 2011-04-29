require 'Node'
# require 'ruby-debug'
require 'SymbolTable'
require 'VMWriter'

# In the first version of the compiler, described in Chapter 10, this module emits a structured printout of the code, wrapped in XML tags. In the final version of the compiler, described in Chapter 11, this module generates executable VM code.
class CompilationEngine

#   Creates a new compilation engine with the given input and output. The next routine called must be compileClass().
  def initialize(tokens,xmlFile,outputFile)
#    def initialize(tokens,xmlFile)
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

    @currentMethod = ""
    @symbolTable = SymbolTable.new
    @vm = VMWriter.new(outputFile)
#     @write = outputFile
#    puts tokens.class

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

    if tokens[ptr].tag == :identifier then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")


      @symbolTable.thisLabel = tokens[ptr].token
      ptr = ptr+1
    end


    if tokens[ptr].token == "{" then
      @xml.tag!(tokens[ptr].tag, " { ")
      ptr = ptr+1
    end


    while @classVarDecStart.include?(tokens[ptr].token)
      @xml.classVarDec {
	ptr = ptr + compileClassVarDec(tokens[ptr...tokens.size])
      }
    end

#     puts @symbolTable.printTable

    while @subroutineDecStart.include?(tokens[ptr].token)
      @xml.subroutineDec {
	ptr = ptr + compileSubroutine(tokens[ptr...tokens.size])
      }
    end

    @symbolTable.printTable(:class)
    @symbolTable.printTable(:method)

    if tokens[ptr].token == "}" then
      @xml.tag!(tokens[ptr].tag, " } ")
      ptr = ptr+1
    end


    if ptr > tokens.size then
      puts "Are you pondering what I am pondering, Pinky?"
      puts "I think so Brain, but why is ptr=#{ptr} while token size = #{tokens.size}?"
    end
      puts "finished class"
  end

#   Compiles a static declaration or a field declaration.
  def compileClassVarDec(tokens)
    puts "compiling ClassVarDec"
    ptr = 0

    ## for building the symbol table
    name = ""
    type = ""
    kind = ""

# static int x;
    while tokens[ptr].token != ";"
#       static
      if @classVarDecStart.include?(tokens[ptr].token)
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	kind = tokens[ptr].token
	ptr = ptr+1

      end

#       int
      if @typeStart.include?(tokens[ptr].token) or tokens[ptr].tag == :identifier then
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	type = tokens[ptr].token
	ptr = ptr+1
      end

      if tokens[ptr].tag == :identifier then
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	name = tokens[ptr].token
	ptr = ptr+1
      end

      @symbolTable.addToTable(name,type,kind)

      while tokens[ptr].token == ","
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1

	if tokens[ptr].tag == :identifier then
	  @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	  ptr = ptr+1
	end

	@symbolTable.addToTable(name,type,kind)
      end
    end

    if tokens[ptr].token == ";" then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    puts "finished ClassVarDec"
    return ptr
  end

#   Compiles a complete method, function, or constructor.
  def compileSubroutine(tokens)
    puts "compiling SubroutineDec"
    ptr = 0

    @symbolTable.startSubroutine
    @int_array = []
    @op_array = []
    name = "this"
    type = @symbolTable.thisLabel
    kind = "argument"

    #constructor, method, function ,etc
    if @subroutineDecStart.include?(tokens[ptr].token)
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	if tokens[ptr].token == "method" or tokens[ptr].token == "function"  then
	    @methodHit = true

	else
	   @methodHit = false
	end

	ptr = ptr+1
    end

    # void, int, etc
    if @typeStart.include?(tokens[ptr].token) or tokens[ptr].token == "void" or tokens[ptr].tag == :identifier
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
#       type = tokens[ptr].token
      ptr = ptr+1
    end

#     function name
    if tokens[ptr].tag == :identifier
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

      if @methodHit then
	@currentMethod = tokens[ptr].token
      end
#       name = tokens[ptr].token
      ptr = ptr+1
    end

    if @methodHit then
      puts name,type,kind
      @symbolTable.addToTable(name, type, kind)
    end
#     @symbolTable.addToTable(name,type,kind)

#	parameter list
    if tokens[ptr].token == "(" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

      @xml.parameterList{
	ptr = ptr + compileParameterList(tokens[ptr...tokens.size])
      }

      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end


    if @methodHit then
      functionName = "#{@symbolTable.method_table[0][1]}.#{@currentMethod}"
      count = @symbolTable.varCount("argument")

    end

    @vm.writeFunction(functionName, count)
#     ptr = ptr + 1
    @xml.subroutineBody {
      ptr = ptr + compileSubroutineBody(tokens[ptr...tokens.size])
#      puts ptr
#     puts " subroutinebody says: #{tokens[ptr].token}"
    }
#     end


    puts "finished SubroutineDec"

    temp=0
    prev_op = false
    for i in 0...@op_array.size
      if @vm.binaryOp_table.has_key?(@op_array[i]) then
	if !prev_op then
	  @vm.writePush("constant",@int_array[temp])
	  @vm.writePush("constant",@int_array[temp+1])
	  @vm.writeArithmetic(@vm.binaryOp_table[@op_array[i]])
	  prev_op = true
	  temp = temp+2
	else
	  @vm.writePush("constant",@int_array[temp])
	  @vm.writeArithmetic(@vm.binaryOp_table[@op_array[i]])
	  temp = temp+1
	  if !@int_array.empty?
	    prev_op = true
	  else prev_op = false
	  end
	end

      elsif @vm.unaryOp_table.has_key?(@op_array[i]) then
	@vm.writePush("constant",@int_array[temp])
	@vm.writeArithmetic(@vm.unaryOp_table[@op_array[i]])
	temp = temp+1
      end
#       temp = temp+1
    end

    @vm.writePush("constant", "0")
                  @vm.writeReturn

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

    while tokens[ptr].token == "var"
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

    name = ""
    type = ""
    kind = "argument"

    while tokens[ptr].token != ")"
    # 	   data type
      if @typeStart.include?(tokens[ptr].token) or tokens[ptr].tag == :identifier then
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

	if @methodHit then
	  type = tokens[ptr].token
	end

	ptr = ptr+1
      end

      if tokens[ptr].tag == :identifier then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

      if @methodHit then
	name = tokens[ptr].token
      end

      ptr = ptr+1
    end

      @symbolTable.addToTable(name,type,kind)

      while tokens[ptr].token == ","

	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1

	if @typeStart.include?(tokens[ptr].token) or tokens[ptr].tag == :identifier then
	  @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

	  if @methodHit then
	    type = tokens[ptr].token
	  end

	  ptr = ptr+1
	end

	if tokens[ptr].tag == :identifier then
	  @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

	  if @methodHit then
	    name = tokens[ptr].token
	    @symbolTable.addToTable(name,type,kind)
	  end

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

    name = ""
    type = ""
    kind = ""

    if tokens[ptr].token == "var" then
  #       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

      if @methodHit then
	kind = tokens[ptr].token
      end

      ptr = ptr+1
    end

    if @typeStart.include?(tokens[ptr].token) or tokens[ptr].tag == :identifier then
    #       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

      if @methodHit then
	type = tokens[ptr].token
      end

      ptr = ptr+1
    end

    if tokens[ptr].tag == :identifier then
    #       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

      if @methodHit then
	name = tokens[ptr].token
      end

      ptr = ptr+1
    end

    @symbolTable.addToTable(name,type,kind)

    while tokens[ptr].token ==","
  #       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

      if tokens[ptr].tag == :identifier then
      # 	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

	if @methodHit then
	  name = tokens[ptr].token
	  @symbolTable.addToTable(name,type,kind)
	end

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
#       @xml.statement{
	ptr = ptr + compileStatement(tokens[ptr...tokens.size])
#       }
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
      else puts "#{tokens[0].token} is not a valid statement"
    end

    return ptr
  end

#   Compiles a do statement.
  def compileDo(tokens)
    puts "compiling Do"
    ptr =0

#     puts tokens.inspect
#     puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"

#     do function.call
    @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
    ptr = ptr+1

    if tokens[ptr].tag == :identifier then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
      @xml.subroutineCall{
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	ptr = ptr + compileSubroutineCall(tokens[ptr..tokens.size])
      }
    end

    if tokens[ptr].token == ";"
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    puts "finished Do"
    return ptr
  end

#   Compiles a let statement.
  def compileLet(tokens)
    puts "compiling Let"
    ptr = 0

    @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

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

    @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

    if tokens[ptr].token == "(" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.expression{
      ptr = ptr + compileExpression(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == ")" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "{" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.statements{
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      ptr = ptr + compileStatements(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == "}" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
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

    @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

    if tokens[ptr].token != ";" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.expression{
	ptr = ptr + compileExpression(tokens[ptr...tokens.size])
      }
    end

    if tokens[ptr].token == ";" then
#       puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    puts "finished return"
    return ptr
  end

  # Compiles an if statement, possibly with a trailing else clause.
  def compileIf(tokens)
    puts "compiling If"
    ptr =0

    @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
    ptr = ptr+1

    if tokens[ptr].token == "("
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.expression{
      ptr = ptr + compileExpression(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == ")"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "{"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.statements {
      ptr = ptr + compileStatements(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == "}"
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "else"
      @xml.elseStatement{
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
        ptr = ptr+1

        if tokens[ptr].token == "{"
	  @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
          ptr = ptr+1
	end

        @xml.statements {
	  ptr = ptr + compileStatements(tokens[ptr...tokens.size])
        }

        if tokens[ptr].token == "}"
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

      if @vm.binaryOp_table.has_key?(tokens[ptr].token) then
	@op_array.push(tokens[ptr].token)
      end
      ptr = ptr+1

      @xml.term{
	ptr = ptr + compileTerm(tokens[ptr...tokens.size])
      }

    end

    @op_array = @op_array.reverse
    puts @op_array.inspect
    puts @int_array.inspect
    puts "finished expression"
    return ptr
  end

  # compiles a term.  This routine is faced w/ a slight difficulty when trying to decide b/w some of the alternative parsing rules.  Specifically, if the current token is an identifier, the routine must distinguish b/w a variable/array entry & subroutine  call.  A single lookahead token, which may be one of "[",string "(", or "." suffices to distinguish b/w the 3 possibilities.  Any other token is not art of this term & shouldn't be advanced over
  def compileTerm(tokens)
     puts "compiling Term"
     ptr = 0

     if tokens[ptr].tag == :integerConstant
#        debugger
       if (0..32767).include?(tokens[ptr].token.to_i)
	 @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	 @int_array.push(tokens[ptr].token)
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

       elsif tokens[ptr].token == "("
	 @xml.subroutineCall{
	   ptr = ptr + compileSubroutineCall(tokens[ptr...tokens.size])
	 }

       elsif tokens[ptr].token == "."
	 @xml.subroutineCall{
	   ptr = ptr + compileSubroutineCall(tokens[ptr...tokens.size])
	 }
       end
     end

     if tokens[ptr].token == "("
       @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
       ptr = ptr+1

       @xml.expression{
	ptr = ptr+compileExpression(tokens[ptr...tokens.size])
       }

       if tokens[ptr].token == ")"
	 @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	 ptr = ptr+1
       else
	 puts "Can't find the closing parenthesis and now I'm left with all this: #{tokens.inspect}"
       end
     end

     if tokens[ptr].token == "-" or tokens[ptr].token == "~"
       @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
       ptr = ptr+1

       @op_array.push(tokens[ptr].token)
       @xml.term{
	 ptr = ptr + compileTerm(tokens[ptr...tokens.size])
       }
     end

     puts "finishing Term"
     return ptr
  end

  def compileSubroutineCall(tokens)
    puts "compiling subroutineCall"
    ptr = 0

    if tokens[ptr].token == "("
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
      ptr = ptr+1

      @xml.expressionList{
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	ptr = ptr + compileExpressionList(tokens[ptr...tokens.size])
      }

      if tokens[ptr].token == ")"
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	ptr = ptr+1
      end

    elsif tokens[ptr].token == "."
      puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
      @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
      ptr = ptr+1

      if tokens[ptr].tag == :identifier
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	ptr = ptr+1
      end

      if tokens[ptr].token == "("
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	ptr = ptr+1
      end

      @xml.expressionList{
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	ptr = ptr + compileExpressionList(tokens[ptr...tokens.size])
      }

      if tokens[ptr].token == ")"
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	@xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	ptr = ptr+1
      end
    end

    puts "finished with subroutineCall"
    return ptr
  end


# compiles a (possibly empty) comma-separated list of expressions
  def compileExpressionList(tokens)
     puts "compiling ExpressionList"
     ptr = 0

#      puts tokens.inspect
     if tokens[ptr].token != ")"
       @xml.expression{
# 	 puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	 ptr = ptr + compileExpression(tokens[ptr...tokens.size])
       }
       while tokens[ptr].token == ","
# 	 puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"

	 @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	 ptr = ptr+1

	 @xml.expression{
# 	   puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	   ptr = ptr + compileExpression(tokens[ptr...tokens.size])
	 }
       end
     else
       @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
       ptr = ptr+1
     end

     puts "finished ExpressionList"
     return ptr
  end

  def codeWriter(exp)
    if exp.class == "Integer" then
      @vm.writePush("constant",exp.to_s)
#     elsif exp
    end
  end

end


