local pack, unpack, isEmpty, index, set, delete, clear, ripairs, keys, array, empty, lazy
do
  local _obj_0 = require('lithium.common')
  pack, unpack, isEmpty, index, set, delete, clear, ripairs, keys, array, empty, lazy = _obj_0.pack, _obj_0.unpack, _obj_0.isEmpty, _obj_0.index, _obj_0.set, _obj_0.delete, _obj_0.clear, _obj_0.ripairs, _obj_0.keys, _obj_0.array, _obj_0.empty, _obj_0.lazy
end
local wrap, yield
do
  local _obj_0 = coroutine
  wrap, yield = _obj_0.wrap, _obj_0.yield
end
local sort, insert
do
  local _obj_0 = table
  sort, insert = _obj_0.sort, _obj_0.insert
end
local inspect = lazy(require, 'inspect')
do
  local _with_0 = setmetatable({
    pack = pack,
    unpack = unpack,
    isEmpty = isEmpty,
    index = index,
    set = set,
    delete = delete,
    clear = clear,
    ripairs = ripairs,
    keys = keys,
    array = array,
    empty = empty
  }, {
    __index = table
  })
  _with_0.copy = function(t)
    local _tbl_0 = { }
    for k, v in pairs(t) do
      _tbl_0[k] = v
    end
    return _tbl_0
  end
  _with_0.icopy = function(t)
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #t do
      local v = t[_index_0]
      _accum_0[_len_0] = v
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end
  _with_0.clone = function(value)
    if 'table' ~= type(value) then
      return value
    end
    local _tbl_0 = { }
    for k, v in pairs(value) do
      _tbl_0[k] = _with_0.clone(v)
    end
    return _tbl_0
  end
  _with_0.invert = function(t)
    local _tbl_0 = { }
    for k, v in pairs(t) do
      _tbl_0[v] = k
    end
    return _tbl_0
  end
  _with_0.merge = function(...)
    local result = _with_0.copy((...))
    for i = 2, select('#', ...) do
      for k, v in pairs((select(i, ...))) do
        result[k] = v
      end
    end
    return result
  end
  _with_0.imerge = function(...)
    local result = _with_0.icopy((...))
    local count = #result
    for i = 2, select('#', ...) do
      local _list_0 = select(i, ...)
      for _index_0 = 1, #_list_0 do
        local v = _list_0[_index_0]
        count = count + 1
        result[count] = v
      end
    end
    return result
  end
  _with_0.map = function(t, func, ...)
    local _tbl_0 = { }
    for key, value in pairs(t) do
      _tbl_0[key] = func(value, ...)
    end
    return _tbl_0
  end
  _with_0.imap = function(t, func, ...)
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #t do
      local value = t[_index_0]
      _accum_0[_len_0] = func(value, ...)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end
  _with_0.filter = function(t, func, ...)
    local newT = { }
    for key, value in pairs(t) do
      if func(value, ...) then
        newT[key] = value
      end
    end
    return newT
  end
  _with_0.ifilter = function(t, func, ...)
    local newT = { }
    local newCount = 0
    for _index_0 = 1, #t do
      local value = t[_index_0]
      if func(value, ...) then
        newCount = newCount + 1
        newT[newCount] = value
      end
    end
    return newT
  end
  _with_0.reject = function(t, func, ...)
    local newT = { }
    for key, value in pairs(t) do
      if not (func(value, ...)) then
        newT[key] = value
      end
    end
    return newT
  end
  _with_0.ireject = function(t, func, ...)
    local newT = { }
    local newCount = 0
    for _index_0 = 1, #t do
      local value = t[_index_0]
      if not (func(value, ...)) then
        newCount = newCount + 1
        newT[newCount] = value
      end
    end
    return newT
  end
  _with_0.sort = function(t, comp)
    local newT = _with_0.icopy(t)
    if comp == nil or 'function' == type(comp) then
      sort(newT, comp)
    else
      sort(newT, function(a, b)
        return a[comp] < b[comp]
      end)
    end
    return newT
  end
  _with_0.reverse = function(t)
    local _accum_0 = { }
    local _len_0 = 1
    for i = #t, 1, -1 do
      _accum_0[_len_0] = t[i]
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end
  local defaultReducer
  defaultReducer = function(a, b)
    return a + b
  end
  _with_0.reduce = function(t, reducer)
    if reducer == nil then
      reducer = defaultReducer
    end
    local value = t[1]
    for i = 2, t.n or #t do
      value = reducer(value, t[i])
    end
    return value
  end
  local _, table_new = pcall(require, 'table.new')
  _with_0.new = table_new or function()
    return { }
  end
  local gridIterator
  gridIterator = function(grid)
    yield()
    for y, row in pairs(grid.rows) do
      for x, value in pairs(row) do
        yield(x, y, value)
      end
    end
    while true do
      yield(nil)
    end
  end
  do
    local _class_0
    local _base_0 = {
      get = function(self, x, y)
        return (self.rows[y] or empty)[x]
      end,
      set = function(self, x, y, value)
        if not self.rows[y] then
          self.rows[y] = { }
        end
        self.rows[y][x] = value
        if _with_0.isEmpty(self.rows[y]) then
          self.rows[y] = nil
        end
        return self
      end,
      each = function(self)
        local iter = wrap(gridIterator)
        iter(self)
        return iter
      end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
      __init = function(self)
        self.rows = { }
      end,
      __base = _base_0,
      __name = "Grid"
    }, {
      __index = _base_0,
      __call = function(cls, ...)
        local _self_0 = setmetatable({}, _base_0)
        cls.__init(_self_0, ...)
        return _self_0
      end
    })
    _base_0.__class = _class_0
    _with_0.Grid = _class_0
  end
  local listIterator
  listIterator = function(list)
    yield()
    for i = 1, list.length do
      yield(i, list.values[i])
    end
    while true do
      yield(nil)
    end
  end
  local concat = table.concat
  do
    local _class_0
    local _base_0 = {
      __tostring = function(self)
        local stringified = { }
        for i = 1, self.length do
          local value = self.values[i]
          if 'table' ~= type(value) then
            value = inspect(value)
          end
          stringified[i] = tostring(value)
        end
        return tostring(self.__class.__name) .. " [ " .. tostring(concat(stringified, ', ', 1, self.length)) .. " ]"
      end,
      __len = function(self)
        return self.length
      end,
      push = function(self, value)
        self.length = self.length + 1
        self.values[self.length] = value
      end,
      pop = function(self)
        self.values[self.length] = nil
        self.length = self.length - 1
      end,
      pushFront = function(self, value)
        for i = 1, self.length do
          self.values[i + 1] = self.values[i]
        end
        self.values[1] = value
        self.length = self.length + 1
      end,
      popFront = function(self)
        for i = 1, self:getLength() do
          self.values[i] = self.values[i + 1]
        end
        self.length = self.length - 1
      end,
      getLength = function(self)
        return self.length
      end,
      get = function(self, i)
        return self.values[i]
      end,
      set = function(self, i, value)
        if i < 1 or i > self.length then
          error("invalid list index: " .. tostring(i), 2)
        end
        self.values[i] = value
      end,
      each = function(self)
        local iter = wrap(listIterator)
        iter(self)
        return iter
      end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
      __init = function(self, ...)
        self.values = {
          ...
        }
        self.length = select('#', ...)
      end,
      __base = _base_0,
      __name = "List"
    }, {
      __index = _base_0,
      __call = function(cls, ...)
        local _self_0 = setmetatable({}, _base_0)
        cls.__init(_self_0, ...)
        return _self_0
      end
    })
    _base_0.__class = _class_0
    _with_0.List = _class_0
  end
  return _with_0
end
