//@vk
//	.asm Computer test jumps specification 

(START)
@5
D=A
@positive
M=D
@negative
M=!D
@zero
M=0
(DUMMY)

// positive non-jumps
@positive
D=M
@DUMMY
D;JEQ
D;JLT
D;JLE

// negative non-jumps
@negative
D=M
@DUMMY
D;JEQ
D;JGT
D;JGE

// zero non-jumps
@zero
D=M
D;JNE
D;JGT
D;JLT

//positive jumps
@positive
D=M
@POS1
D;JGT
D=D
(POS1)
@POS2
D;JGE
D=D
(POS2)
@POS3
D;JNE
D=D
(POS3)
@POS4
D;JMP
D=D
(POS4)

// negative jumps
@negative
D=M
@NEG1
D;JLT
D=D
(NEG1)
@NEG2
D;JLE
D=D
(NEG2)
@NEG3
D;JNE
D=D
(NEG3)
@NEG4
D;JMP
D=D
(NEG4)

// zero jumps
@zero
D=M
@ZERO1
D;JGE
D=D
(ZERO1)
@ZERO2
D;JLE
D=D
(ZERO2)
@ZERO3
D;JEQ
D=D
(ZERO3)
// Unconditional jump to the beginning
@START
0;JMP