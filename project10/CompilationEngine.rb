# In the first version of the compiler, described in Chapter 10, this module emits a structured printout of the code, wrapped in XML tags. In the final version of the compiler, described in Chapter 11, this module generates executable VM code.
class CompilationEngine
@keyword = ["class",
            "constructor", "function", "method",
            "field", "static",
            "var", "let", "do",
	    "int", "char", "boolean", "void",
            "true", "false", "null",
            "this",
            "if", "else", "while", "return"
           ]

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

#   Creates a new compilation engine with the given input and output. The next routine called must be compileClass().
  def initialize(tokens, xmlFile)
    @xml = xmlFile
    compileClass(tokens)
  end

#   Compiles a complete class.
  def compileClass(tokens)

    if tokens[0].downcase == "class"
      @xml.class{
	for i in 1...tokens.size
	  @xml.title(tokens[i])
	end
      }
    end
  end

#   Compiles a static declaration or a field declaration.
  def compileClassVarDec
  end

#   Compiles a complete method, function, or constructor.
  def compileSubroutine
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