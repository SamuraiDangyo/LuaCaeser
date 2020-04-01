#!/bin/sh

# Interpreter
CC=lua

runprogram()
{
  $CC LuaCaeser.lua
}

helpme()
{
  echo "# Help"
  echo "> sh luacaser.sh"
  echo ""
  echo "## Targets"
  echo "... help  This help"
}

if [ "$1" = "help" ]; then
  helpme
else
  runprogram
fi
