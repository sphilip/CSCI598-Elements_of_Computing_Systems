#!/bin/bash

WD=`pwd`
# TEST=$WD/Seven/
# TEST=$WD/ConvertToBin/
TEST=$WD/$1
DEF_COMPILE=./../../tools/JackCompiler.sh
ANALYZE=./JackAnalyzer.rb
CUSTOM_COMPILE=./JackAnalyzer.rb

if [ $# -eq 0 ]
then
echo "Must include dir to compile. Ya gotta compile with your analyzer by yourself!"
else
$DEF_COMPILE $TEST
# $ANALYZE $TEST -- doesn't work
fi