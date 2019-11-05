#!/usr/bin/env lua

-- LuaCaeser, a simple cypher in Lua
-- Copyright (C) 2019 Toni Helminen
-- GPLv3 license

local mycypher = require("mycypher")

local function main()
  mycypher.unittests()
  mycypher.go()
end

main()