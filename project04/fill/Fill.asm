(SETUP)
@SCREEN
D=A

@pos
M=D

@24575
D=A

@end
M=D

	
(INPUT)	
@KBD
D=M
	
@WHITESCREEN
D;JEQ

(BLACKSCREEN)

@SCREEN
D=A

@pos
M=D

@end
D=M

@pos
A=M

D=D-A
@INPUT
D;JEQ

(BLACKDRAW)
@pos
A=M
M=-1

@pos
M=M+1

@end
D=M

@pos
A=M

D=D-A
@BLACKDRAW
D;JGE

@INPUT
0;JMP

(WHITESCREEN)
@SCREEN
D=A

@pos
M=D

@end
D=M

@pos
A=M

D=D-A
@INPUT
D;JEQ

(WHITEDRAW)
@pos
A=M
M=0

@pos
M=M+1

@end
D=M

@pos
A=M

D=D-A
@WHITEDRAW
D;JGE

@INPUT
0;JMP

	