local mathx = setmetatable({}, {__index = math})

mathx.tau = math.pi * 2

local function lerp(t, a, b)
   return a * (1 - t) + b * t
end
mathx.lerp = lerp

function mathx.damp(smoothing, dt, a, b)
   return lerp(1 - smoothing ^ dt, a, b)
end

function mathx.root(x, rpow)
   return x ^ (1 / rpow)
end

function mathx.cbrt(x)
   return x ^ (1 / 3)
end

function mathx.ternary(condition, ifTrue, ifFalse)
   if condition then return ifTrue end
   return ifFalse
end

function mathx.isnan(x)
   return x ~= x
end

function mathx.sign(x)
   if x > 0 then return 1
   elseif x < 0 then return -1 end
   return 0
end

function mathx.clamp(value, vmin, vmax)
   if vmin == nil then vmin = value end
   if vmax == nil then vmax = value end
   if value < vmin then return vmin
   elseif value > vmax then return vmax end
   return value
end

function mathx.wrap(value, vmin, vmax)
   if vmax == nil then vmax, vmin = vmin, nil end
   vmin = vmin or 0
   vmax = vmax or 1
   return (value - vmin) % (vmax - vmin) + vmin
end

function mathx.map(value, fromMin, fromMax, toMin, toMax)
   return (value - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin
end

local floor = math.floor
function mathx.round(x)
   return floor(x + 0.5)
end

function mathx.roundStep(x, step)
   if step == nil then step = 1 end
   return floor(x / step + 0.5) * step
end

return mathx