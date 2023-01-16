local pack
pack = require('lithium.common').pack
local concat
concat = table.concat
local execute, getenv
do
  local _obj_0 = os
  execute, getenv = _obj_0.execute, _obj_0.getenv
end
do
  local system = { }
  if jit then
    system.isWindows = jit.os == 'Windows'
  elseif love then
    system.isWindows = require('love.system').getOS() == 'Windows'
  else
    system.isWindows = getenv('OS') == 'Windows_NT'
  end
  system.hasShell = execute() ~= 0
  if system.hasShell then
    system.execute = function(program, ...)
      local args = pack(program, ...)
      for i = 1, args.n do
        args[i] = "\"" .. tostring(args[i]) .. "\""
      end
      local command = concat(args, ' ', 1, args.n)
      if system.isWindows then
        command = "\"" .. tostring(command) .. "\""
      end
      return execute(command)
    end
  end
  return system
end
