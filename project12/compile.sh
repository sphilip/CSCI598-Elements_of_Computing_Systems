#!/bin/bash

TEST=("MathTest/")
DONE=("Math.jack")

DIR=`echo $HOME`
WD=`pwd`
CSCI="/Desktop/CSCI598/cs598/"
JACK="bash $HOME/Desktop/CSCI598/cs598/tools/JackCompiler.sh"

for index in 0
do
    $JACK $WD/${TEST[$index]}
    $JACK $WD/${DONE[$index]}
    mv *.vm $WD/${TEST[$index]}
done