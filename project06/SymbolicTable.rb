# match symbolic labels to numeric addresses
class SymbolicTable
  attr_accessor :symbols, :label
  # Creates a new empty symbol table
  def initialize
    # hash table containing predefined symbols
    @symbols = {}

    @symbols["SP"] = [0]
    @symbols["LCL"] = [1]
    @symbols["ARG"] = [2]
    @symbols["THIS"] = [3]
    @symbols["THAT"] = [4]

    @symbols["R0"] = [0]
    @symbols["R1"] = [1]
    @symbols["R2"] = [2]
    @symbols["R3"] = [3]
    @symbols["R4"] = [4]
    @symbols["R5"] = [5]
    @symbols["R6"] = [6]
    @symbols["R7"] = [7]
    @symbols["R8"] = [8]
    @symbols["R9"] = [9]
    @symbols["R10"] = [10]
    @symbols["R11"] = [11]
    @symbols["R12"] = [12]
    @symbols["R13"] = [13]
    @symbols["R14"] = [14]
    @symbols["R15"] = [15]

    @symbols["SCREEN"] = [16384]
    @symbols["KBD"] = [24576]

    @symbols_address = 16
    # also create table for labels
    @label = {}

  end

  # add (symbol, address) pair to the table.
  # input: string, int
  # output: bool (if addition of pair is successful)
  def addEntry (symbol, address)#, type)
    # all caps = labels
    # all or most small letters = symbol/ variables
    #label_reg = Regexp.new(/[A-Z]*/)
    #label_match = label_reg.match(symbol)

    label_reg = Regexp.new(/\d/)
    label_match = label_reg.match(symbol)

    # nil = no digits in symbol, add to labels table
    if label_match.nil?
      @label[symbol.to_s] = [address]
    else
      @symbols[label_match[0]] = [@symbols_address]
      @symbols_address = @symbols_address+1
      if @symbols_address > 24576
	puts "\n------------\nError: addressing memory greater than accessible memory space\n------------\n"
      end
    end
#     if type == "label"
#       @label[symbol.to_s] = [address]
#     else
#       @symbols[symbol.to_s] = [address]
#     end

  end

  # does the symbol table have the provided symbol?
  # input: string for desired symbol, string for desired table
  # output: bool
  def contains (symbol)#, table)
    label_reg = Regexp.new(/\d/)
    label_match = label_reg.match(symbol)

    # nil = no digits in symbol, symbol is a label
    if label_match.nil?
      @label.has_key?(symbol)
    else
      @symbols.has_key?(symbol)
    end
#     if table == "symbols"
#       @symbols.has_key?(symbol)
#     else
#       @label.has_key?(symbol)
#     end
  end

  # return the address associated w/symbol
  # input: string for symbol, string for table
  # output: int
  def getAddress (symbol, table)
    if table == "label"
      @label[symbol]
    else
      @symbols[symbol]
    end
  end


end
