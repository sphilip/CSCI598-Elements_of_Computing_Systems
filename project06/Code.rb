# convert hack assembly language mnemonics into binary
class Code
  attr_accessor :comp, :dest, :jump

  def initialize
    @comp = {}
    @comp["0"] =   ["0101010"]
    @comp["1"] =   ["0111111"]
    @comp["-1"] =  ["0111010"]
    @comp["D"] =   ["0001100"]

    @comp["A"] =   ["0110000"]
    @comp["M"] =   ["1110000"]
    @comp["!D"] =  ["0001101"]
    @comp["!A"] =  ["0110001"]
    @comp["!M"] =  ["1110001"]
    @comp["-D"] =  ["0001111"]

    @comp["-A"] =  ["0110011"]
    @comp["-M"] =  ["1110011"]
    @comp["D+1"] = ["0011111"]
    @comp["A+1"] = ["0110111"]
    @comp["M+1"] = ["1110111"]

    @comp["D-1"] = ["0001110"]
    @comp["A-1"] = ["0110010"]
    @comp["M-1"] = ["1110010"]
    @comp["D+A"] = ["0000010"]
    @comp["D+M"] = ["1000010"]
    @comp["D-A"] = ["0010011"]
    @comp["D-M"] = ["1010011"]

    @comp["A-D"] = ["0000111"]
    @comp["M-D"] = ["1000111"]
    @comp["D&A"] = ["0000000"]
    @comp["D&M"] = ["1000000"]
    @comp["D|A"] = ["0010101"]
    @comp["D|M"] = ["1010101"]


    @dest = {}
    @dest["null"] = [0]
    @dest["M"] = [1]
    @dest["D"] = [2]
    @dest["MD"] = [3]

    @dest["A"] = [4]
    @dest["AM"] = [5]
    @dest["AD"] = [6]
    @dest["AMD"] = [7]

    @jump = {}
    @jump["null"] = [0]
    @jump["JGT"] = [1]
    @jump["JEQ"] = [2]
    @jump["JGE"] = [3]

    @jump["JLT"] = [4]
    @jump["JNE"] = [5]
    @jump["JLE"] = [6]
    @jump["JMP"] = [7]
  end

  # shamelessly stolen from Andy Niccolai's gist, yet again
  def zero_pad(input_string)
    pad_length = 3 - input_string.length
    "0" * pad_length + input_string
  end


  # returns the binary code of dest
  # input: string
  # output: 3 bits
  def dest(mnemonic)
    zero_pad(@dest[mnemonic][0].to_s(2))

  end

  # return the binary code of comp
  # input: string
  # output: 7 bits
  def comp(mnemonic)
    @comp[mnemonic][0]
  end



  # return the binary code of jump
  # input: string
  # output: 3 bits
  def jump(mnemonic)
    zero_pad(@jump[mnemonic][0].to_s(2))
  end
end