local floor
floor = math.floor
do
  local _with_0 = setmetatable({ }, {
    __index = math
  })
  _with_0.tau = math.pi * 2
  _with_0.root = function(x, rpow)
    return x ^ (1 / rpow)
  end
  _with_0.cbrt = function(x)
    return x ^ (1 / 3)
  end
  _with_0.ternary = function(condition, ifTrue, ifFalse)
    if condition then
      return ifTrue
    else
      return ifFalse
    end
  end
  _with_0.isNAN = function(x)
    return x ~= x
  end
  _with_0.isNaN = _with_0.isNAN
  _with_0.lerp = function(t, a, b)
    return a * (1 - t) + b * t
  end
  _with_0.damp = function(smoothing, dt, a, b)
    return _with_0.lerp(1 - smoothing ^ dt, a, b)
  end
  _with_0.sign = function(x)
    if x > 0 then
      return 1
    elseif x < 0 then
      return -1
    else
      return 0
    end
  end
  _with_0.clamp = function(value, vmin, vmax)
    if vmin == nil then
      vmin = value
    end
    if vmax == nil then
      vmax = value
    end
    if value < vmin then
      return vmin
    elseif value > vmax then
      return vmax
    else
      return value
    end
  end
  _with_0.wrap = function(v, vmin, vmax)
    if vmax == nil then
      vmax, vmin = vmin, nil
    end
    vmin = vmin or 0
    vmax = vmax or 1
    return (v - vmin) % (vmax - vmin) + vmin
  end
  _with_0.map = function(v, fromMin, fromMax, toMin, toMax)
    return (v - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin
  end
  _with_0.round = function(x)
    return floor(x + 0.5)
  end
  _with_0.roundStep = function(x, step)
    if step == nil then
      step = 1
    end
    return floor(x / step + 0.5) * step
  end
  return _with_0
end
