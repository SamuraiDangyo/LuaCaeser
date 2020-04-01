#!/usr/bin/env lua

-- LuaCaeser, a simple cypher in Lua
-- Copyright (C) 2019-2020 Toni Helminen
-- GPLv3

-- --
-- Variables
-- --

local mycypher = {}

-- --
-- Constants
-- --

local ALPHAS = {
    "?","#","$","%","&","'","(",")","*","+",",","-",".","/"," ",":",";","<","=",">","@","[","]","^","_","{","|","}",
    "0","1","2","3","4","5","6","7","8","9",
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
}

local NAME          = "LuaCaeser"
local VERSION       = "1.01"
local AUTHOR        = "Toni Helminen"

local STEPS         = #ALPHAS
local secret_number = 42

-- --
-- Private Functions
-- --

local function between(a, b, c)
  return math.max(a, math.min(b, c))
end

local function char_to_index(char)
  for i, alpha in ipairs(ALPHAS) do
    if (char == alpha) then
      return i
    end
  end

  return 1
end

local function index_to_char(index)
  if (index < 1 or index > #ALPHAS) then
    return "?"
  end

  return ALPHAS[index]
end

local function good_str(str)
  local retstr = ""

  for i=1, #str do
    local char = str:sub(i, i)
    local indx = char_to_index(c)

    if (indx == 0) then
      retstr = retstr.."?"
    else
      retstr = retstr..char
    end
  end

  return retstr
end

-- x = 97 + ((100 + secret_number) % 26)
-- x - 97 = (100 + secret_number) % 26
-- (x - 97) % 26 = (100 + secret_number)
-- ((x - 97) % 26) - secret_number = 100

local function smt()
  str = ""
  for i=35, 125 do
    str = str..string.format("\"%s\",", string.char(i))
  end
  print(str)
end

local function takenext()
  if (arg_i < #arg) then
    arg_i = arg_i + 1
    return arg[arg_i]
  end

  return 0
end

local function cmd_set_secretnum(num)
  secret_number = between(2, tonumber(num), 50)
end

local function cmd_cypher()
  print("# Cypher")
  local str = takenext()
  print(string.format("str    : \"%s\"", str))
  print(string.format("secret : %s", secret_number))
  print(string.format("result : \"%s\"", mycypher.cypher_text(str)))
end

local function cmd_decypher()
  print("# Decypher")
  local str = takenext()
  print(string.format("str     : \"%s\"", str))
  print(string.format("secret  : %s",     secret_number))
  print(string.format("result  : \"%s\"", mycypher.decypher_text(str)))
end

local function print_help()
  print("# Help")
  print("LuaCaeser, a simple cypher in Lua\n")
  print("## Usage")
  print("lua LuaCaeser.lua [CMD] [OPT]? ...")
  print("lua LuaCaeser.lua -secret 25 -cypher \"lorem ipsum\" # Remember the secret number\n")

  print("## Commands")
  print("-help             This help")
  print("-version          Show version")
  print("-license          Show license")
  print("-secretnum [NUM]  Set your secret number [1..50]")
  print("-cypher [STR]     Cypher text STR")
  print("-decypher [STR]   Decypher text STR")
end

local function parse()
  arg_i = 1
  while (arg_i <= #arg) do
    token = arg[arg_i]
    if (token == "-help")          then print_help()
    elseif (token == "-version")   then print(string.format("%s %s by %s", NAME, VERSION, AUTHOR))
    elseif (token == "-license")   then print("GNU General Public License version 3; See 'LICENCE'")
    elseif (token == "-cypher")    then cmd_cypher()
    elseif (token == "-decypher")  then cmd_decypher()
    elseif (token == "-secretnum") then cmd_set_secretnum(takenext())
    elseif (token == "-smt")       then smt()
    end
    arg_i = arg_i + 1
  end
end

local function unittest1()
  assert("s" == index_to_char(char_to_index("s")))
  assert("a" == index_to_char(char_to_index("a")))
  assert("C" == index_to_char(char_to_index("C")))
end

local function unittest2()
  local s = "abcdefg"
  assert(mycypher.decypher_text(mycypher.cypher_text(s)) == s)

  s = "Praesent non ipsum bibendum nulla efficitur porttitor."
  assert(mycypher.decypher_text(mycypher.cypher_text(s)) == s)

  s = "Duis pulvinar tortor eget auctor ullamcorper."
  assert(mycypher.decypher_text(mycypher.cypher_text(s)) == s)

  s = "123 %{} d"
  assert(mycypher.decypher_text(mycypher.cypher_text(s)) == s)

  s = "123 %{} d Praesent non ipsum bibendum nulla efficitur porttitor."
  assert(mycypher.decypher_text(mycypher.cypher_text(s)) == s)

  s = "`` Duis ``"
  assert(mycypher.decypher_text(mycypher.cypher_text(s)) == "?? Duis ??")

  s = " _34adbdd fd f.df g, SDFHGYUIWE67{[[}}"
  assert(mycypher.decypher_text(mycypher.cypher_text(s)) == s)

  s = "my secret message"
  assert(mycypher.decypher_text(mycypher.cypher_text(s)) == s)
end


-- --
-- Public Functions ( So LuaCyher can be used in other software )
-- --

function mycypher.set_secret_number(num)
  cmd_set_secretnum(num)
end

function mycypher.cypher_text(str2)
  local retstr = ""
  local str    = good_str(str2)

  for i=1, #str do
    local char = str:sub(i, i)
    local indx = char_to_index(char)
    local step = indx + secret_number

    if (step > STEPS) then
      step = step - STEPS
    end

    local nc = index_to_char(step)
    retstr = retstr..nc
  end
  return retstr
end

function mycypher.decypher_text(str2)
  local retstr = ""
  local str    = good_str(str2)

  for i=1, #str do
    local char = str:sub(i, i)
    local indx = char_to_index(char)
    local step = indx - secret_number

    if (step > #ALPHAS) then
      step = step - STEPS
    end

    if (step < 1) then
      step = #ALPHAS + step
    end

    retstr = retstr..index_to_char(step)
  end

  return retstr
end

function mycypher.unittests()
  unittest1()
  unittest2()
end

function mycypher.go()
  if (#arg < 1) then
    print_help()
    return nil
  end

  parse()
end

-- "Reason has always existed, but not always in a reasonable form." - Karl Marx
return mycypher
