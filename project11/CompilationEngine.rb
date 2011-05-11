require 'Node'
require 'rubygems'
require 'ruby-debug'
require 'SymbolTable'
require 'VMWriter'

# In the first version of the compiler, described in Chapter 10, this module emits a structured printout of the code, wrapped in XML tags. In the final version of the compiler, described in Chapter 11, this module generates executable VM code.
class CompilationEngine

#   Creates a new compilation engine with the given input and output. The next routine called must be compileClass().
  def initialize(tokens,xmlFile,outputFile)
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

    @call = {}

    @currentMethod = ""

    @OS_table = ["Math", "Array", "Output", "Screen", "Keyboard", "Memory" ,"Sys"]

    @symbolTable = SymbolTable.new

    if !outputFile.nil?
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
      ptr = ptr+1
    end

    if @methodHit then
      @symbolTable.addToTable(name, type, kind)
    end

#	parameter list
    if tokens[ptr].token == "(" then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

      @xml.parameterList{
	ptr = ptr + compileParameterList(tokens[ptr...tokens.size])
      }

      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end



    @xml.subroutineBody {
      ptr = ptr + compileSubroutineBody(tokens[ptr...tokens.size])
    }

    puts "finished SubroutineDec"



    return ptr
  end

  def compileSubroutineBody(tokens)
    puts "compiling SubroutineBody"
    ptr = 0

    if tokens[ptr].token == "{" then
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	ptr = ptr+1
    end

    while tokens[ptr].token == "var"
      @xml.varDec{
	ptr = ptr + compileVarDec(tokens[ptr...tokens.size])
      }
    end

    if @methodHit then
      functionName = "#{@symbolTable.method_table[0][1]}.#{@currentMethod}"
      count = @symbolTable.varCount("var")
      @symbolTable.printTable(:method)
    end
#     debugger
    @vm.writeFunction(functionName, count)

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
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

      if @methodHit then
	kind = tokens[ptr].token
      end

      ptr = ptr+1
    end

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

    while tokens[ptr].token ==","
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

      if tokens[ptr].tag == :identifier then
	@xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

	if @methodHit then
	  name = tokens[ptr].token
	  @symbolTable.addToTable(name,type,kind)
	end

	ptr = ptr+1
      end
    end

    if tokens[ptr].token == ";" then
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

#     @vm.writeCall(@possibleCall,@argnum)

    puts "finished Statements"
    return ptr
  end

  def compileStatement(tokens)
    ptr = 0

    case tokens[0].token
      when "let" then @xml.letStatement{ ptr = ptr + compileLet(tokens)}
      when "if" then

	@ifLabel = "IF_TRUE"
	@xml.ifStatement{ ptr = ptr + compileIf(tokens)}
      when "while" then @xml.whileStatement{ ptr = ptr + compileWhile(tokens)}
      when "do" then @xml.doStatement{ ptr = ptr + compileDo(tokens)}
      when "return" then @xml.returnStatement{ ptr = ptr + compileReturn(tokens)}
      else
	puts "#{tokens[0].token} is not a valid statement"
	return
    end

    return ptr
  end

#   Compiles a do statement.
  def compileDo(tokens)
    puts "compiling Do"
    ptr =0

#     do function.call
    @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
    ptr = ptr+1

    @xml.subroutineCall{
      ptr = ptr + compileSubroutineCall(tokens[ptr..tokens.size])
    }

    if @subroutine_called then
      @vm.writePop("temp", 0)
    end

    if tokens[ptr].token == ";"
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

    debugger
    @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

    if tokens[ptr].tag == :identifier then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

      varName = tokens[ptr].token
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
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end


    puts "#{tokens[ptr].inspect}"

#   debugger
    @xml.expression{
      ptr = ptr + compileExpression(tokens[ptr...tokens.size])
      }

    if @subroutine_called then
      @vm.writePop(@symbolTable.kindOf(varName), @symbolTable.indexOf(varName))
    end

    if tokens[ptr].token == ";" then
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
    whileCount = 0
    whileLabel = "WHILE_EXP" + whileCount.to_s
    @vm.writeLabel(whileLabel)

    @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1

    if tokens[ptr].token == "(" then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      createExp(tokens[ptr...tokens.size])
      ptr = ptr+1
    end

    @xml.expression{
      ptr = ptr + compileExpression(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == ")" then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    if tokens[ptr].token == "{" then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    @xml.statements{
      ptr = ptr + compileStatements(tokens[ptr...tokens.size])
    }

    if tokens[ptr].token == "}" then
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
      @xml.expression{
	ptr = ptr + compileExpression(tokens[ptr...tokens.size])
      }
    end

    if tokens[ptr].token == ";" then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end

    puts "finished return"

    @vm.writePush("constant", "0")
    @vm.writeReturn
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
      debugger
      createExp(tokens[ptr...tokens.size])
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
      ptr = ptr+1

      @xml.term{
	ptr = ptr + compileTerm(tokens[ptr...tokens.size])
      }
    end

    puts "finished expression"
    return ptr
  end

  # compiles a term.  This routine is faced w/ a slight difficulty when trying to decide b/w some of the alternative parsing rules.  Specifically, if the current token is an identifier, the routine must distinguish b/w a variable/array entry & subroutine  call.  A single lookahead token, which may be one of "[",string "(", or "." suffices to distinguish b/w the 3 possibilities.  Any other token is not art of this term & shouldn't be advanced over
  def compileTerm(tokens)
     puts "compiling Term"
     ptr = 0
#      debugger

     if tokens[ptr].tag == :integerConstant
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

     if @keywordConstant.include?(tokens[ptr].token) then
       @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")

       if tokens[ptr].token == "true"
	 @vm.writePush("constant", 0)
	 @vm.writeArithmetic("not")
       elsif tokens[ptr].token == "false"
	 @vm.writePush("constant", 0)
       end

       ptr = ptr+1
     end

     if tokens[ptr].tag == :identifier then
       @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
       ptr = ptr+1

       if tokens[ptr].token == "[" then
# 	 ptr = ptr+1
	 @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	 ptr = ptr+1

	 ptr = ptr + compileExpression(tokens[ptr...tokens.size])
# let position = position +1
	 @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	 ptr = ptr+1

       elsif tokens[ptr].token == "(" or tokens[ptr].token == "."
	 @xml.subroutineCall{
	   ptr = ptr + compileSubroutineCall(tokens[ptr-1...tokens.size])
	 }


# 	 @vm.writeCall(@possibleCall,@argnum)
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
    puts "Starting subcall"
    @possibleCall=""
#     classCall = ""
    methodCall = ""
    @subroutine_called = true
#     debugger

    if tokens[ptr].tag == :identifier then
      puts "I am #{tokens[ptr].token}!"

      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")

      @possibleCall = tokens[ptr].token
      classCall = tokens[ptr].token
      ptr = ptr+1
      @argnum = 0
    end

#     debugger
    if tokens[ptr].token == "("
      @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
      if tokens[ptr+1].tag == :identifier or tokens[ptr+1].tag == :integerConstant then
	createExp(tokens[ptr...tokens.size])
      end
      ptr = ptr+1

      @xml.expressionList{
	ptr = ptr + compileExpressionList(tokens[ptr...tokens.size])
      }

      if tokens[ptr].token == ")"
	@xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	ptr = ptr+1

      end

    elsif tokens[ptr].token == "."
      @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
      @possibleCall = @possibleCall + "."
      ptr = ptr+1
      methodCall = methodCall + "."

      if tokens[ptr].tag == :identifier
	@xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	@possibleCall = @possibleCall + tokens[ptr].token
	methodCall = methodCall + tokens[ptr].token
	ptr = ptr+1
      end

      if tokens[ptr].token == "("
	@xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")

	if tokens[ptr+1].tag == :identifier or tokens[ptr+1].tag == :integerConstant then
	  createExp(tokens[ptr...tokens.size])
	end
	ptr = ptr+1
      end

      @xml.expressionList{
	puts "parsing #{tokens[ptr].token} => #{tokens[ptr].tag}"
	ptr = ptr + compileExpressionList(tokens[ptr...tokens.size])
      }

      if tokens[ptr].token == ")"
	@xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	ptr = ptr+1
	puts "wrote subcall"
      end
    end

#     debugger
#     @vm.writeCall(@possibleCall,@argnum)
    #     putargnums "calling #{@possibleCall}"
    @vm.writeCall(classCall+methodCall,@argnum)
    puts "calling #{classCall+methodCall} #{@argnum}"
#     @possibleCall = ""
    methodCall = ""
    puts "finished with subroutineCall"
    return ptr
  end


# compiles a (possibly empty) comma-separated list of expressions
  def compileExpressionList(tokens)
     puts "compiling ExpressionList"
     ptr = 0

     if tokens[ptr].tag == :identifier or tokens[ptr].tag == :integerConstant then
#        codeWriter(tokens)
#        createExp(tokens[ptr...tokens.size])
     end
# debugger
     if tokens[ptr].token != ")"
       @xml.expression{
	@argnum = @argnum +1
	 ptr = ptr + compileExpression(tokens[ptr...tokens.size])
       }

       while tokens[ptr].token == ","
	 @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
	 ptr = ptr+1

	 @argnum = @argnum + 1

	 @xml.expression{
	   ptr = ptr + compileExpression(tokens[ptr...tokens.size])
	 }
       end
# debugger
     else
       @xml.tag!(tokens[ptr].tag , " #{tokens[ptr].token} ")
       ptr = ptr+1
     end

     puts "finished ExpressionList"
     return ptr
  end

  def createExp(tokens)
    exp = []
    ptr = 0

    open_parenthesis = -1
    closed_parenthesis = 0

    if tokens[ptr].token == "(" then match = 1
    else match = 0
    end
#     match = 0
# debugger
    for i in 0...tokens.size
      if tokens[i].token == "(" and open_parenthesis == -1
	open_parenthesis = i
	match = match+1

      elsif tokens[i].token == ")"
	closed_parenthesis = i
	match = match-1

	if match == 0 then
	  for j in open_parenthesis..closed_parenthesis
	    exp.push(tokens[j])
	  end
	  break
	end

#        elsif match == 0
# 	exp.push(tokens[i])
      end
    end

    codeWriter(exp)
#     debugger
  end

  def codeWriter(exp)
    ptr = 0
#     puts "exp= #{exp.inspect}"
#     debugger

    if exp[ptr].token == "(" then
      exp = exp[ptr+1...exp.size-1]
    end

#     debugger
    while ptr < exp.size
      if exp[ptr].tag == :integerConstant then
	puts "push constant #{exp[ptr].token}"
	@vm.writePush("constant", exp[ptr].token)
	ptr = ptr+1
#       end

      elsif exp[ptr].tag == :identifier then
	if @symbolTable.hasName(exp[ptr].token)
	  puts "push #{@symbolTable.kindOf(exp[ptr].token)} #{@symbolTable.indexOf(exp[ptr].token)}"
	  @vm.writePush(@symbolTable.kindOf(exp[ptr].token),@symbolTable.indexOf(exp[ptr].token))
	  ptr = ptr+1
	elsif @OS_table.include?(exp[ptr].token) then
	  puts "calling #{exp[ptr].token} #{exp[ptr+1]}"
	else
	  puts "#{exp[ptr].token} doesn't seem to be a valid variable name"
	  return
	end
#       end

      elsif @vm.op_table.has_key?(exp[ptr].token) then
	op_ptr = ptr
# debugger
	ptr=ptr+1
	if exp[ptr].tag == :integerConstant then
	  puts "push constant #{exp[ptr].token}"
	  @vm.writePush("constant", exp[ptr].token)
	  ptr = ptr+1

	elsif exp[ptr].tag == :identifier
	  if @symbolTable.hasName(exp[ptr].token)
	    puts "push #{@symbolTable.kindOf(exp[ptr].token)} #{@symbolTable.indexOf(exp[ptr].token)}"
	    @vm.writePush(@symbolTable.kindOf(exp[ptr].token),@symbolTable.indexOf(exp[ptr].token))
	    ptr = ptr+1
	  else
	    puts "#{exp[ptr].token} doesn't seem to be a valid variable name"
	    return
	  end

	elsif exp[ptr].token == "(" then
	  ptr = ptr + 1 + codeWriter(exp[ptr+1...exp.size])
# 	  ptr = ptr+1+(ptr+1-exp.size)
	  #       end

	end
# 	debugger
	# 	end

	puts "then #{@vm.op_table[exp[op_ptr].token]}"
	@vm.writeArithmetic(@vm.op_table[exp[op_ptr].token])
#       end

      elsif exp[ptr].token == "(" then
	  new_e = createExp(exp[ptr+1...exp.size])
	  new_ptr = 0
	  op_index = find_op(new_e)

	  if op_index != -1 then
	    puts "looking into #{new_e[0...op_index].inspect}"
	    puts "looking into  #{new_e[op_index...new_e.size].inspect}"
	    puts "#{@vm.op_table[new_e[op_index]]}"
	  end
	#       end

      elsif exp[ptr].token == "," then
	ptr = ptr +1

      else return ptr
	end

#       return ptr
      end
#     end
  end

  def find_op(exp)

    for i in 0...exp.size
      if @vm.op_table.has_key?(exp[i].token)
	return i
      end
    end

    return -1
  end
#   end

end