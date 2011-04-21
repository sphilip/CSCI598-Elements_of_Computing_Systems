# Associates identifier names w/ identifier properties needed for compilation (ie. type,kind, index)
class SymbolTable
  
  #creates empty symbol table
  def initialize
  end
  
  #start new subroutine scope (reset subroutine symbol table)
  def startSubroutine
  end
  
  # defines new identifier of given name, type , kind & assign running index
  # static, field = class scope
  # arg, var = subroutine scope
  # input: name (string), type (string), kind (static,field,etc)
  def define(name, type, kind)
  end
  
  # return # of variables of given kind in current scope
  # input: kind (static, field, arg, var)
  # output: int
  def varCount(kind)
  end
  
  # return kind of named identifier in current scope
  # input: name (string)
  # output: static,field,arg,var,none
  def kindOf(name)
  end
  
  # return type of named identifier
  # input: name (string)
  # output: string
  def typeOf (name)
  end
  
  # return index assigned to named identifier
  # input: name (string)
  # output: int
  def indexOf (name)
  end
  
end