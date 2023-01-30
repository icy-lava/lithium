# Lithium

Lithium is a heavy-weight "standard" library for Lua, Teal and LÖVE.

***It is currently considered unstable and the API is also unstable. Don't use this yet unless you want to cry :)***

## Install

```shell
# Install Teal using luarocks
# (Teal files will be compiled into Lua in the future)
luarocks install tl

# Within a git repository
git submodule add https://github.com/icy-lava/lithium.git lithium

# Or, without a git repository
git clone https://github.com/icy-lava/lithium.git lithium
```

## Usage

```lua
-- main.lua
require('tl').loader() -- If using uncompiled Teal files

local lithium = require('lithium') -- or 'lithium.init' if it fails
local stringx, tablex, mathx = lithium.stringx, lithium.tablex, lithium.mathx

for line in stringx.lines('hello\nworld') do
    print(line)
end
```
