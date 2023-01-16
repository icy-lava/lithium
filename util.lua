local pack, lazy
do
  local _obj_0 = require('lithium.common')
  pack, lazy = _obj_0.pack, _obj_0.lazy
end
local concat
concat = table.concat
local format
format = string.format
local inspect = lazy(require, 'inspect')
do
  local _with_0 = { }
  _with_0.lazyloader = function(prefix)
    if prefix == nil then
      prefix = ''
    end
    return setmetatable({ }, {
      __index = function(t, key)
        local status, result = pcall(require, prefix .. key)
        if status then
          t[key] = result
          return result
        end
        return nil
      end
    })
  end
  _with_0.printf = function(...)
    return print(format(...))
  end
  local inspectOptions = {
    indent = '    ',
    process = function(item, path)
      if path[#path] ~= inspect.METATABLE then
        return item
      end
    end
  }
  _with_0.printi = function(...)
    local t = pack(...)
    for i = 1, t.n do
      t[i] = inspect(t[i], inspectOptions)
    end
    local str = concat(t, ', ')
    print(str)
    return ...
  end
  local mapLineNumber
  mapLineNumber = function(fileName, lineNumber, cache)
    local reverse_line_number
    reverse_line_number = require('moonscript.errors').reverse_line_number
    local line_tables = require('moonscript.line_tables')
    local line_table = assert(line_tables["@" .. tostring(fileName)])
    local newLineNumber = reverse_line_number(fileName, line_table, lineNumber, cache)
    assert(newLineNumber ~= 'unknown')
    return newLineNumber
  end
  _with_0.rewriteTraceback = function(traceback)
    local cache = { }
    local newLines = traceback:gsub('[^\r\n]+', function(line)
      local whitespace, fileName, lineNumber, message = line:match('^(%s*)(.-):(%d+):(.*)$')
      if not whitespace or not fileName:match('%.moon$') then
        return line
      end
      lineNumber = mapLineNumber(fileName, lineNumber, cache)
      message = message:gsub('in function <([^<>]+%.moon):(%d+)>', function(file, line)
        line = mapLineNumber(file, line, cache)
        return "in function <" .. tostring(file) .. ":" .. tostring(line) .. "(*)>"
      end)
      return tostring(whitespace) .. tostring(fileName) .. ":" .. tostring(lineNumber) .. "(*):" .. tostring(message)
    end)
    return newLines
  end
  return _with_0
end
