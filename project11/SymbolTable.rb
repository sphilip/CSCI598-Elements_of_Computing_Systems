# Associates identifier names w/ identifier properties needed for compilation (ie. type,kind, index)
class SymbolTable

  #creates empty symbol table
  def initialize
    @table = []
    @kind_num = {}
  end

  def createMethodTable(name)
  end

  def addToTable(name,type,kind,num)
    if @kind_num.has_key?(kind)
      @kind_num[kind] = @kind_num[kind] +1
    else
      @kind_num[kind] = 0
    end

    temp = [name,type,kind,@kind_num[kind]]
    @table.push(temp)
  end

  def printTables
    for i in 0...@table.size
      puts @table[i].inspect
    end
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
    return @kind_num[kind]
  end

  # return kind of named identifier in current scope
  # input: name (string)
  # output: static,field,arg,var,none
  def kindOf(name)
    for i in 0...@table.size
      if @table[i][0] == name
	return @table[i][2]
      end
    end
  end

  # return type of named identifier
  # input: name (string)
  # output: string
  def typeOf (name)
    for i in 0...@table.size
      if @table[i][0] == name
	return @table[i][1]
      end
    end
  end

  # return index assigned to named identifier
  # input: name (string)
  # output: int
  def indexOf (name)
    for i in 0...@table.size
      if @table[i][0] == name
	return @table[i][3]
      end
    end
  end

end