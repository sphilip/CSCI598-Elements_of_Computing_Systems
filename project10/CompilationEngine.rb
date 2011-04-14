require 'Node'

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

#   def tagType(token)
#     tag = case token
#       when /(class)|(constructor)|(function)|
# 	    (method)|(field)|(static)|(var)|(int)|
# 	    (char)|(boolean)|(void)|(true)|(false)|
# 	    (null)|(this)|(let)|(do)|(if)|(else)|(while)|
# 	    (return)/ then :keyword
# 
#       when  / \{|\}|\(|\)|\[|\]|\.|\,|\;|\+|\-|\*|\/|\&|\||\<|\>|\=|\~/ then :symbol
# 
#       when 0...32767 then :integerConstant
# 
#       when /^\"\w*\"/ then :StringConstant
# 
#       when /^[^\d]\w*/ then :identifier
# 
#       else :error
# 
#     end
# 
#     return tag
#   end

#   Compiles a complete class.
  def compileClass(tokens)
    ptr = 0
    #     @currentElement << "class"
    
    if tokens[ptr].tag == :identifier then
      @xml.tag!(tokens[ptr].tag, " #{tokens[ptr].token} ")
      ptr = ptr+1
    end
  
    if tokens[ptr].token == "{" then
      @xml.tag!(tokens[ptr].tag, " { ")
      ptr = ptr+1
    end
  
    puts tokens[ptr].token
    if @classVarDecStart.include?(tokens[ptr].token) then
      @currentElement << "classVarDec"
      compileClassVarDec(tokens[ptr...tokens.size-1])
      @currentElement.pop
      ptr = ptr+1
    end
  
    if @subroutineDecStart.include?(tokens[ptr].token) then
      @currentElement << "subroutineDec"
      @xml.subroutineDec { compileSubroutine(tokens[ptr...tokens.size-1])
                          }
      @currentElement.pop
      ptr = ptr+1
    end
    
    if tokens[ptr].token == "}" then
      @xml.tag!(tokens[ptr].tag, " } ")
      ptr = ptr+1
      
      if ptr > tokens.size then
	puts "Are you pondering what I am pondering, Pinky?"
	puts "I think so Brain, but why is ptr=#{ptr} while token size = #{tokens.size}?"
      end
    end
    
#       case tokens.tree[ptr]
# 	  
# 	when tokens.tree[ptr].tag == :identifier then
# 	  @xml.tag!(tokens.tree[ptr].tag, " #{tokens.tree[ptr].token} ")
# 	  ptr = ptr+1
# 
# 	when tokens.tree[ptr].token == "{" then
# 	  @xml.tag!(tokens.tree[ptr].tag, " { ")
# 	  ptr = ptr+1
# 
# 	when @classVarDecStart.include?(tokens.tree[ptr].token) then
# 	  @currentElement << "classVarDec"
# 	  compileClassVarDec(tokens[ptr...tokens.size-1])
# 	  @currentElement.pop
# 	  ptr = ptr+1
# 
# 	when @subroutineDecStart.include?(tokens.tree[ptr].token) then
# 	  @currentElement << "subroutineDec"
# 	  compileSubroutine(tokens[ptr...tokens.size-1])
# 	  @currentElement.pop
# 	  ptr = ptr+1
# 
# 	when tokens.tree[ptr].token == "}" then
# 	  @xml.tag!(tokens.tree[ptr].tag, " } ")
# 	  ptr = ptr+1
# 	  if ptr >= tokens.size then
# 	    puts "Are you pondering what I am pondering, Pinky?"
# 	    print "I think so Brain, but why is ptr=#{ptr} while token size = #{tokens.size}?"
# 	  end
#       end
    
    
  end

#   Compiles a static declaration or a field declaration.
  def compileClassVarDec(subToken)
    
  end

#   Compiles a complete method, function, or constructor.
  def compileSubroutine(subToken)
    if !subToken.empty?
      ptr = 0
      @xml.tag!(subToken[ptr].tag, subToken[ptr].token)
      ptr = ptr+1
      compileSubroutine(subToken[ptr...subToken.size])
      
    else return
    end
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
