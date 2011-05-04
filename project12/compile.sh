#!/bin/bash

TEST=("MathTest/")
DONE=("Math.jack")
JACK="bash /home/satellite/Desktop/CSCI598/cs598/tools/JackCompiler.sh"
DIR=`pwd`

for index in 0
do
$JACK $DIR/${TEST[$index]}
$JACK $DIR/${DONE[$index]}
`cp *.vm $DIR/${TEST[$index]}`
done