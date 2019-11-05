#!/usr/bin/env lua

-- LuaCaeser, a simple cypher in Lua
-- Copyright (C) 2019 Toni Helminen
-- GPLv3 license

local mycypher = {}

ALPHAS = { -- const
    "?","#","$","%","&","'","(",")","*","+",",","-",".","/"," ",":",";","<","=",">","@","[","]","^","_","{","|","}",
    "0","1","2","3","4","5","6","7","8","9",
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
}

local NAME    = "LuaCaeser"
local VERSION = "1.0"
local AUTHOR  = "Toni Helminen"

local secret_n = 32
local STEPS    = #ALPHAS

local function print_help() -- private
  print("{ # LuaCaeser help")
  print("}\n")
  print("{ #Usage")
  print("  >       = lua LuaCaeser.lua [CMD] [OPT] ...,")
  print("  sample  = lua LuaCaeser.lua -s 25 -c \"my secret text\" # Remember the secret number,")
  print("}\n")
  print("{")
  print("  -h(elp)       = This help,")
  print("  -v(ersion)    = Show version,")
  print("  -s(ecret) N   = Set cypher key [1..50],")
  print("  -c(ypher) S   = Cypher text S,")
  print("  -d(ecypher) S = Decypher text S")
  print("}")
end

function between(a, b, c)
  return math.max(a, math.min(b, c))
end

local function char_to_index(x)
  for i, c in ipairs(ALPHAS) do
    if (c == x) then return i end
  end
  return 1
end

local function index_to_char(x)
  --assert(x >= 1 and x <= #ALPHAS)
  --print(x, #ALPHAS)
  if (x < 1 or x > #ALPHAS) then return "?" end
  return ALPHAS[x]
end

local function good_str(str)
  local s = ""
  for i=1, #str do
    local c = str:sub(i, i)
    local n = char_to_index(c)
    if (n == 0) then
      s = s.."?"
    else
      s = s..c
    end
  end
  return s
end

function mycypher.cypher_text(str)
  local s = ""
  str = good_str(str)
  for i=1, #str do
    local c = str:sub(i, i)
    local n = char_to_index(c)
    local r = n + secret_n
    if (r > STEPS) then r = r - STEPS end
    local nc = index_to_char(r)
    s = s..nc
  end
  return s
end

function mycypher.decypher_text(str)
  local s = ""
  str = good_str(str)
  for i=1, #str do
    local c = str:sub(i, i)
    local n = char_to_index(c)
    local r = n - secret_n
    if (r > #ALPHAS) then r = r - STEPS end
    if (r < 1) then r = #ALPHAS + r end
    s = s..index_to_char(r)
  end
  return s
end

-- x = 97 + ((100 + secret_n) % 26)
-- x - 97 = (100 + secret_n) % 26
-- (x - 97) % 26 = (100 + secret_n)
-- ((x - 97) % 26) - secret_n = 100

local function smt()
  s = ""
  for i=35, 125 do
    s = s..string.format("\"%s\",", string.char(i))
  end
  print(s)
end

local function takenext()
  if (arg_i < #arg) then
    arg_i = arg_i + 1
    return arg[arg_i]
  end
  return 0
end

local function cmd_secret()
  secret_n = between(2, tonumber(takenext()), 50)
end

local function cmd_cypher()
  print("{ # Cypher")
  local s = takenext()
  print(string.format("  str    = \"%s\",", s))
  print(string.format("  secret = %s,", secret_n))
  print(string.format("  result = \"%s\"", mycypher.cypher_text(s)))
  print("}")
end

local function cmd_decypher()
  print("{ # Decypher")
  local s = takenext()
  print(string.format("  str    = \"%s\",", s))
  print(string.format("  secret = %s,", secret_n))
  print(string.format("  result = \"%s\"", mycypher.decypher_text(s)))
  print("}")
end

function mycypher.go()
  if (#arg < 1) then print_help() return nil end
  arg_i = 1
  while (arg_i <= #arg) do
    v = arg[arg_i]
    if (v == "-h" or v == "-help") then
      print_help()
    elseif (v == "-v" or v == "-version") then
      print(string.format("{ %s %s by %s }", NAME, VERSION, AUTHOR))
    elseif (v == "-c" or v == "-cypher") then
      cmd_cypher()
    elseif (v == "-d" or v == "-decypher") then
      cmd_decypher()
    elseif (v == "-s" or v == "-secret") then
      cmd_secret()
    elseif (v == "-smt") then
      smt()
    end
    arg_i = arg_i + 1
  end
end

local function tests1()
  assert("s" == index_to_char(char_to_index("s")))
  assert("a" == index_to_char(char_to_index("a")))
  assert("C" == index_to_char(char_to_index("C")))
end

local function tests2()
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

function mycypher.unittests()
  tests1()
  tests2()
end

return mycypher