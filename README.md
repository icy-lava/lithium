# Lithium

Lithium is a heavy-weight "standard" library for Lua, MoonScript and LÖVE.

***It is currently considered unstable and the API is also unstable. Don't use this yet unless you want to cry :)***

## Install

```shell
# Install moonscript using luarocks
# (MoonScript files will be compiled into Lua in the future)
luarocks install moonscript

# Within a git repository
git submodule add https://github.com/icy-lava/lithium.git lithium

# Or, without a git repository
git clone https://github.com/icy-lava/lithium.git lithium
```

## Usage

```lua
-- main.lua
require('moonscript') -- If using uncompiled moonscript files

local lithium = require('lithium') -- or 'lithium.init' if it fails
local string, table, math = lithium.string, lithium.table, lithium.math

for line in string.lines('hello\nworld') do
    print(line)
end
```

With moonscript

```moonscript
-- main.moon
import string, table, math from require 'lithium' -- or 'lithium.init'
import lines from string

for line in lines 'hello\nworld'
    print line
```
