local lines
lines = require('lithium.string').lines
do
  local _with_0 = setmetatable({ }, {
    __index = io
  })
  _with_0.readBytes = function(path, bytes)
    if bytes == nil then
      bytes = -1
    end
    assert(path)
    local stream, err = io.open(path, 'rb')
    if not (stream) then
      return nil, err
    end
    do
      local _with_1 = stream
      local data
      if bytes < 0 then
        if bytes == -1 then
          data, err = _with_1:read('*a')
        else
          local size = _with_1:seek('end')
          _with_1:seek('set')
          data, err = _with_1:read(size + bytes + 1)
        end
      else
        data, err = _with_1:read(bytes)
      end
      _with_1:close()
      if not (data) then
        return nil, err or 'could not read file'
      end
      return data
    end
  end
  local stringFile
  do
    local _with_1 = { }
    _with_1.write = function(self, ...)
      local len = select('#', ...)
      for i = 1, len do
        local value = select(i, ...)
        local _exp_0 = type(value)
        if 'string' == _exp_0 or 'number' == _exp_0 then
          self.content = self.content .. value
        else
          error("bad argument #" .. tostring(i) .. " to 'write' (string expected, got " .. tostring(type(value)) .. ")")
        end
      end
    end
    _with_1.lines = function(self)
      return lines(self.content)
    end
    _with_1.setvbuf = function() end
    _with_1.tostring = function(self)
      return self.content
    end
    _with_1.__tostring = function(self)
      return self.content
    end
    stringFile = _with_1
  end
  stringFile.__index = stringFile
  _with_0.openString = function(str, mode)
    if str == nil then
      str = ''
    end
    if mode == nil then
      mode = 'r'
    end
    local modeEnum
    if mode:find('r') then
      modeEnum = 'read'
    elseif mode:find('w') then
      modeEnum = 'write'
    else
      error("unknown mode: '" .. tostring(mode) .. "'")
    end
    return setmetatable({
      content = str,
      mode = modeEnum
    }, stringFile)
  end
  return _with_0
end
