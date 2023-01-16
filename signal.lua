local weak = {
  __mode = 'k'
}
local Signal
do
  local _class_0
  local _base_0 = {
    connect = function(self, funcOrObj, event)
      if event == nil then
        event = true
      end
      if event == true then
        self.funcHooks[funcOrObj] = true
      else
        self.objHooks[funcOrObj] = event
      end
    end,
    disconnect = function(self, funcOrObj)
      self.funcHooks[funcOrObj] = nil
      self.objHooks[funcOrObj] = nil
    end,
    emit = function(self, ...)
      for func in pairs(self.funcHooks) do
        func(...)
      end
      for obj, event in pairs(self.objHooks) do
        if obj[event] then
          obj[event](obj, ...)
        end
      end
      return ...
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.funcHooks = { }
      self.objHooks = setmetatable({ }, weak)
    end,
    __base = _base_0,
    __name = "Signal"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Signal = _class_0
  return _class_0
end
