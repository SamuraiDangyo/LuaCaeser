#!/usr/bin/env lua

-- LuaCaeser, a simple cypher in Lua
-- Copyright (C) 2019-2020 Toni Helminen
-- GPLv3

local mycypher = require("mycypher")

local function main()
  mycypher.unittests()
  mycypher.go()
end

main()
