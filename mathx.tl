local floor = math.floor

local function lerp(t: number, a: number, b: number): number
	return a * (1 - t) + b * t
end

return {
	tau = math.pi * 2,
	
	root = function(x: number, rpow: number): number
		return x ^ (1 / rpow)
	end,
	cbrt = function(x: number): number
		return x ^ (1 / 3)
	end,
	
	ternary = function<T, F>(condition: any, ifTrue: T, ifFalse: F): T | F
		if condition then return ifTrue end
		return ifFalse
	end,
	
	isNAN = function(x: number): boolean
		return x ~= x
	end,
	
	lerp = lerp,
	damp = function(smoothing: number, dt: number, a:  number, b:  number):  number
		lerp(1 - smoothing ^ dt, a, b)
	end,
	
	sign = function(x: number): integer
		if x > 0 then return 1
		elseif x < 0 then return -1 end
		return 0
	end,
	
	clamp = function(value: number, vmin: number, vmax: number): number
		if vmin == nil then vmin = value end
		if vmax == nil then vmax = value end
		if value < vmin then return vmin
		elseif value > vmax then return vmax end
		return value
	end,
	
	wrap = function(v: number, vmin: number, vmax: number): number
		if vmax == nil then vmax, vmin = vmin, nil end
		vmin = vmin or 0
		vmax = vmax or 1
		return (v - vmin) % (vmax - vmin) + vmin
	end,
	
	map = function(v: number, fromMin: number, fromMax: number, toMin: number, toMax: number): number
		return (v - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin
	end,
	
	round = function(x: number): integer
		return floor(x + 0.5)
	end,
	roundStep = function(x: number, step: number): number
		if step == nil then step = 1 end
		return floor(x / step + 0.5) * step
	end
}