require 'Node'

# In the first version of the compiler, described in Chapter 10, this module emits a structured printout of the code, wrapped in XML tags. In the final version of the compiler, described in Chapter 11, this module generates executable VM code.
class CompilationEngine
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

  @currentElement = []

#   Creates a new compilation engine with the given input and output. The next routine called must be compileClass().
  def initialize(tokens,xmlFile)
    @xml = xmlFile
    compileClass(tokens)
  end

  def tagType(token)
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

    return tag
  end

#   Compiles a complete class.
  def compileClass(tokens)
    ptr = 0
    @currentElement << "class"
    @xml.class {

      case tokens[ptr]
	when tokens[ptr].tag == :identifier then
	  @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
	  ptr = ptr+1

	when tokens[ptr].token == "{" then
	  @xml.tag!(tokens[ptr].tag, " { ")
	  ptr = ptr+1

	when @classVarDecStart.include?(tokens[ptr].tag) then
	  @currentElement << "classVarDec"
	  compileClassVarDec(tokens[ptr...tokens.size-1])
	  @currentElement.pop
	  ptr = ptr+1

	when @subroutineDecStart.include?(tokens[ptr].tag) then
	  @currentElement << "subroutineDec"
	  compileSubroutine(tokens[ptr...tokens.size-1])
	  @currentElement.pop
	  ptr = ptr+1

	when tokens[ptr].tag == "}" then
	  @xml.tag!(tokens[ptr].tag, " } ")
	  ptr = ptr+1
	  if ptr >= tokens.size then
	    puts "Are you pondering what I am pondering, Pinky?"
	    print "I think so Brain, but why is ptr=#{ptr} while token size = #{tokens.size}?"
	  end
      end
    }
  end

#   Compiles a static declaration or a field declaration.
  def compileClassVarDec(subToken)
    ptr = 0
    @xml.subroutineDec {
      @xml.tag!(subToken[ptr].tag, subToken[ptr].token)
      ptr = ptr+1
#       case subToken[ptr].token

      end
    }
  end

#   Compiles a complete method, function, or constructor.
  def compileSubroutine(subToken)
  end

#   Compiles a (possibly empty) parameter list, not including the enclosing “()”.
  def compileParameterList
  end

#   Compiles a var declaration.
  def compileVarDec
  end

#   Compiles a sequence of statements, not including the enclosing “{}”.
  def compileStatements
  end

#   Compiles a do statement.
  def compileDo
  end

#   Compiles a let statement.
  def compileLet
  end

  # Compiles a while statement.
  def compileWhile
  end

  # Compiles a return statement.
  def compileReturn
  end

  # Compiles an if statement, possibly with a trailing else clause.
  def compileIf
  end

  # compiles expression
  def compileExpression
  end

  # compiles a term.  This routine is faced w/ a slight difficulty when trying to decide b/w some of the alternative parsing rules.  Specifically, if the current token is an identifier, the routine must distinguish b/w a variable/array entry & subroutine  call.  A signle lookahead token, which may be one of "[", "(", or "." suffices to distinguish b/w the 3 possibilities.  Any other token is not art of this term & shouldn't be advanced over
  def compileTerm
  end

  # compiles a (possibly empty) comma-separated list of expressions
  def compileExpressionList
  end

end
