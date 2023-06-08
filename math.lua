local lmath = setmetatable({}, {__index = math})

lmath.tau = math.pi * 2

local function lerp(t, a, b)
	return a * (1 - t) + b * t
end
lmath.lerp = lerp

function lmath.damp(smoothing, dt, a, b)
	return lerp(1 - smoothing ^ dt, a, b)
end

function lmath.root(x, rpow)
	return x ^ (1 / rpow)
end

function lmath.cbrt(x)
	return x ^ (1 / 3)
end

function lmath.ternary(condition, ifTrue, ifFalse)
	if condition then return ifTrue end
	return ifFalse
end

function lmath.isnan(x)
	return x ~= x
end

function lmath.sign(x)
	if x > 0 then return 1
	elseif x < 0 then return -1 end
	return 0
end

function lmath.clamp(value, vmin, vmax)
	if vmin == nil then vmin = value end
	if vmax == nil then vmax = value end
	if value < vmin then return vmin
	elseif value > vmax then return vmax end
	return value
end

function lmath.wrap(value, vmin, vmax)
	if vmax == nil then vmax, vmin = vmin, nil end
	vmin = vmin or 0
	vmax = vmax or 1
	return (value - vmin) % (vmax - vmin) + vmin
end

function lmath.map(value, fromMin, fromMax, toMin, toMax)
	return (value - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin
end

local floor = math.floor
function lmath.round(x)
	return floor(x + 0.5)
end

function lmath.roundStep(x, step)
	if step == nil then step = 1 end
	return floor(x / step + 0.5) * step
end

return lmath