local thisModuleName = ...
if not (thisModuleName == 'lithium') then
  package.preload.lithium = function()
    return require(thisModuleName)
  end
end
return setmetatable({ }, {
  __index = function(self, module)
    local status, result = pcall(require, "lithium." .. tostring(module))
    if not (status) then
      error(result, 2)
    end
    self[module] = result
    return result
  end
})
