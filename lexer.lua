local pack
pack = require('lithium.common').pack
do
  local _with_0 = { }
  _with_0.lex = function(str, lexTypes)
    local i = 1
    local strlen = #str
    local tokens = { }
    while i <= strlen do
      local success = false
      for _index_0 = 1, #lexTypes do
        local lexType = lexTypes[_index_0]
        local ltype = lexType[1]
        for j = 2, #lexType do
          local parser = lexType[j]
          local values
          if 'string' == type(parser) then
            local pattern = parser:gsub('^%^?', '^', 1)
            values = pack(str:find(pattern, i))
          else
            values = pack(parser(str, i, strlen))
          end
          local start, stop = values[1], values[2]
          if start and stop then
            table.remove(values, 2)
            table.remove(values, 1)
            values.n = values.n - 2
            values[0] = str:sub(start, stop)
            table.insert(tokens, {
              type = ltype,
              start = start,
              stop = stop,
              captures = values
            })
            i = stop + 1
            success = true
            break
          end
        end
        if success then
          break
        end
      end
      if not (success) then
        return nil, "couldn't parse byte '" .. tostring(str:sub(i, i)) .. "' at index " .. tostring(i), i
      end
    end
    return tokens
  end
  return _with_0
end
