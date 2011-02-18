//@Kostyantyn Vorobyov
//	.asm CPU test jumps specification 
//Positive non-jumps
D=1
@1111
D;JEQ
D=1
@1111
D;JLT
D=1
@1111
D;JLE

//Negative non-jumps
D=0
D=!D
@2222
D;JGE
D=0
D=!D
@2222
D;JGT
D=0
D=!D
@2222
D;JEQ

//Zero non-jumps
D=0
@0
D;JNE
D=0
@0
D;JGT
D=0
@0
D;JLT

//Positive jumps
D=1
@1100
D;JGT

@2100
D=1
D;JGE

@3100
D=1
D;JNE

/// Reset the counter
@0
D;JMP

//Negative jumps
D=0
D=!D
@1200
D;JLT

D=0
D=!D
@2200
D;JLE

D=0
D=!D
@3200
D;JNE

/// Reset the counter
@0
D;JMP

//Zero jumps
@1000
D=0
D;JGE

D=0
@2000
D;JLE

D=0
@3000
D;JEQ

D=0
@1111
D;JMP
D=1
@2222
D;JMP
D=0
D=!D
@3333
D;JMP