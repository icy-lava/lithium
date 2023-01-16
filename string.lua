local insert
insert = table.insert
local wrap, yield
do
  local _obj_0 = coroutine
  wrap, yield = _obj_0.wrap, _obj_0.yield
end
local array
array = require('lithium.common').array
do
  local stringx = setmetatable({ }, {
    __index = string
  })
  local delimIterator
  delimIterator = function(str, delim, plain)
    yield()
    local i, strlen = 1, #str
    while true do
      local start, stop = str:find(delim, i, plain)
      if start then
        if stop < start then
          stop = stop + 1
          start = start + 1
        end
        yield(str:sub(i, start - 1))
        i = stop + 1
        if i > strlen then
          if start <= stop then
            yield('')
          end
          break
        end
      else
        yield(str:sub(i, strlen))
        break
      end
    end
    while true do
      yield(nil)
    end
  end
  stringx.delim = function(str, delim, isPattern)
    local iter = wrap(delimIterator)
    iter(str, delim, not isPattern)
    return iter
  end
  stringx.lines = function(str)
    return stringx.delim(str, '\r?\n', true)
  end
  stringx.lineAt = function(str, i, newlinePattern)
    if newlinePattern == nil then
      newlinePattern = '\n'
    end
    local line = 1
    for _ in str:sub(1, i - 1):gmatch(newlinePattern) do
      line = line + 1
    end
    return line
  end
  stringx.positionAt = function(str, i, newlinePattern)
    if newlinePattern == nil then
      newlinePattern = '\n'
    end
    if i > #str then
      return nil, 'index is out of range'
    end
    local col = 1
    local line = 1
    local j = 1
    while j < i do
      local start, stop = str:find(newlinePattern, j)
      if not start or stop >= i then
        break
      end
      if stop < j then
        return nil, 'newline pattern matches empty string'
      end
      j = stop + 1
      col = 1
      line = line + 1
    end
    return line, i - j + 1
  end
  stringx.split = function(...)
    return array(stringx.delim(...))
  end
  stringx.startsWith = function(str, prefix)
    return prefix == str:sub(1, #prefix)
  end
  stringx.endsWith = function(str, suffix)
    return suffix == str:sub(-#suffix, -1)
  end
  stringx.contains = function(str, substr)
    return not not str:find(substr, 1, true)
  end
  stringx.trimLeft = function(str)
    return (str:gsub('^%s+', '', 1))
  end
  stringx.trimRight = function(str)
    return (str:gsub('%s+$', '', 1))
  end
  stringx.trim = function(str)
    return stringx.trimLeft(stringx.trimRight(str))
  end
  stringx.trimNonEmpty = function(str)
    str = stringx.trim(str)
    if str == '' then
      return nil
    end
    return str
  end
  stringx.patch = function()
    for k, v in pairs(stringx) do
      string[k] = v
    end
  end
  return stringx
end
