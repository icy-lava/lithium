do
  local _with_0 = setmetatable({ }, {
    __index = _G
  })
  _with_0.noop = function() end
  _with_0.empty = setmetatable({ }, {
    __metatable = false,
    __newindex = function() end
  })
  _with_0.isEmpty = function(t)
    return nil == next(t)
  end
  _with_0.index = function(t, ...)
    for i = 1, select('#', ...) do
      if not ('table' == type(t)) then
        return nil
      end
      t = t[select(i, ...)]
    end
    return t
  end
  _with_0.set = function(t, ...)
    local argLen = select('#', ...)
    assert(argLen > 0)
    if argLen == 1 then
      return (...)
    end
    for i = 1, argLen - 2 do
      local key = select(i, ...)
      if t[key] == nil then
        t[key] = { }
      end
      t = t[key]
      assert('string' ~= type(t, 'tried to index a string, but it\'s not allowed'))
    end
    t[select(argLen - 1, ...)] = select(argLen, ...)
    return t
  end
  _with_0.delete = function(t, ...)
    local argLen = select('#', ...)
    assert(argLen > 0)
    if argLen == 1 then
      local key = ...
      t[key] = nil
      if _with_0.isEmpty(t) then
        return nil
      end
      return t
    end
    local path = {
      t
    }
    for i = 1, argLen - 1 do
      local key = select(i, ...)
      t = t[key]
      if 'table' ~= type(t) then
        return path[1]
      end
      path[i + 1] = t
    end
    for i = argLen, 1, -1 do
      local key = select(i, ...)
      t = path[i]
      t[key] = nil
      if not _with_0.isEmpty(t) then
        return path[1]
      end
    end
    return nil
  end
  local _, table_clear = pcall(require, 'table.clear')
  _with_0.clear = table_clear or function(t)
    for k in pairs(t) do
      rawset(t, k, nil)
    end
    return t
  end
  _with_0.pack = table.pack or function(...)
    return {
      n = select('#', ...),
      ...
    }
  end
  _with_0.unpack = table.unpack or unpack
  local ripairsIterator
  ripairsIterator = function(t, i)
    if i == 1 then
      return nil
    end
    i = i - 1
    return i, t[i]
  end
  _with_0.ripairs = function(t)
    return ripairsIterator, t, #t + 1
  end
  local keysIterator
  keysIterator = function(t, k)
    k = next(t, k)
    return k
  end
  _with_0.keys = function(t)
    return keysIterator, t
  end
  _with_0.array = function(...)
    local _accum_0 = { }
    local _len_0 = 1
    for v in ... do
      _accum_0[_len_0] = v
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end
  _with_0.requireZero = function(...)
    local firstError
    for i = 1, select('#', ...) do
      local mod = select(i, ...)
      local ok, result = pcall(require, mod)
      if ok then
        return result, mod
      end
      if i == 1 then
        firstError = result
      end
    end
    return nil, firstError
  end
  _with_0.requireOne = function(...)
    local result, errOrMod = _with_0.requireZero(...)
    if result == nil then
      error(errOrMod, 2)
    end
    return result, errOrMod
  end
  local lazyTrigger
  lazyTrigger = function(t)
    local func = t.values[1]
    local result = func(_with_0.unpack(t.values, 2, t.values.n))
    local _exp_0 = type(result)
    if 'table' == _exp_0 then
      setmetatable(t, nil)
      _with_0.clear(t)
      for k, v in pairs(result) do
        t[k] = v
      end
      return setmetatable(t, getmetatable(result))
    elseif 'function' == _exp_0 then
      setmetatable(t, {
        __call = result
      })
      return _with_0.clear(t)
    else
      return error("unsupported type for lazy loader: '" .. tostring(type(result)) .. "'")
    end
  end
  local lazyMetatable = {
    __call = function(t, ...)
      lazyTrigger(t)
      return t(...)
    end,
    __index = function(t, k)
      lazyTrigger(t)
      return t[k]
    end,
    __newindex = function(t, k, v)
      lazyTrigger(t)
      t[k] = v
    end
  }
  _with_0.lazy = function(...)
    return setmetatable({
      values = _with_0.pack(...)
    }, lazyMetatable)
  end
  return _with_0
end
