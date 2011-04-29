# Associates identifier names w/ identifier properties needed for compilation (ie. type,kind, index)
class SymbolTable
  attr_accessor :thisLabel, :method_table

  #creates empty symbol table
  def initialize
    @class_table = []
    @class_kind_num = {}

    @method_table = []
    @method_kind_num = {}

    @total_table = {}
    @thisLabel = ""
  end

  # defines new identifier of given name, type , kind & assign running index
  # static, field = class scope
  # arg, var = subroutine scope
  # input: name (string), type (string), kind (static,field,etc)
  def addToTable(name,type,kind)
    if kind == "argument" or kind == "var" then
      if @method_kind_num.has_key?(kind)
	@method_kind_num[kind] = @method_kind_num[kind] +1
      else
	@method_kind_num[kind] = 0
      end

      temp = [name,type,kind,@method_kind_num[kind]]
      @method_table.push(temp)

    elsif kind =="static" or kind == "field" then
      if @class_kind_num.has_key?(kind)
	  @class_kind_num[kind] = @class_kind_num[kind] +1
      else
	@class_kind_num[kind] = 0
      end

      temp = [name,type,kind,@class_kind_num[kind]]
      @class_table.push(temp)

    else
      puts "#{kind} is not a valid kind"
    end
  end

  def printTable(whichTable)
    puts
    puts "Printing #{whichTable.to_s} table"

    if whichTable == :class
      for i in 0...@class_table.size
	puts @class_table[i].inspect
      end

    elsif whichTable == :method
      for i in 0...@method_table.size
	puts @method_table[i].inspect
      end

    else puts "#{whichTable.to_s} is not a valid table"
    end

    puts
  end

  #start new subroutine scope (reset subroutine symbol table)
  def startSubroutine
    if @method_table.empty?
      puts "Already using an empty method_table"

    else
      puts "Resetting symbol method_table"
      @total_table[@this_label] = @method_table
      @method_table = []

      @method_kind_num = {}
    end
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
    if kind == "static" or kind == "field" then
      return @class_kind_num[kind]
    elsif kind == "argument" or kind == "var" then
      return @method_kind_num[kind]
    else
      puts "#{kind} not a valid kind"
    end
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