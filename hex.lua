local format, char, byte
do
  local _obj_0 = string
  format, char, byte = _obj_0.format, _obj_0.char, _obj_0.byte
end
do
  local _with_0 = { }
  _with_0.encode = function(str)
    return str:gsub('.', function(char)
      return format('%02x', byte(char))
    end)
  end
  _with_0.decode = function(str)
    if #str % 2 ~= 0 then
      error('string length must be a multiple of 2', 2)
    end
    return (str:gsub('..', function(byte)
      local num = tonumber(byte, 16)
      if num == nil then
        error('string contains non-hex character', 2)
      end
      return char(num)
    end))
  end
  return _with_0
end
