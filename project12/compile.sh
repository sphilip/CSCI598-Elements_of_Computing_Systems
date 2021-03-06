#!/bin/bash

# TEST=(
# "Math"
# # "String"
# "Sys"
# "Screen"
# )
TEST="Test/"

DONE=("Math" "String" "Sys" "Screen" "Keyboard")
EXT=".jack"

DIR=`echo $HOME`
WD=`pwd`

CSCI="/Desktop/CSCI598/cs598/"
JACK="bash $HOME/Desktop/CSCI598/cs598/tools/JackCompiler.sh"

for index in {0..4}
do
# index=$index-1
    $JACK $WD/"${DONE[$index]}$TEST"
    $JACK $WD/"${DONE[$index]}$EXT"
    mv *.vm $WD/"${DONE[$index]}$TEST"
    echo Compiled "${DONE[$index]}$EXT"
done