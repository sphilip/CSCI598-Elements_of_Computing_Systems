@R2
M=0


(LOOP)
@R1
D=M
@RESULT
D;JEQ

@R1
M=M-1

@R0
D=M

@R2
M=D+M

@LOOP
0;JMP

(RESULT)
@RESULT
0;JMP




