#!/bin/bash

WD=`pwd`
TEST=$WD/Seven/
DEF_COMPILE=./../../tools/JackCompiler.sh
ANALYZE=./JackAnalyzer.rb
CUSTOM_COMPILE=./JackAnalyzer.rb

$DEF_COMPILE $TEST
