import floor from math

with setmetatable {}, {__index: math}
	.tau = math.pi * 2
	
	.root = (x, rpow) -> x ^ (1 / rpow)
	.cbrt = (x) -> x ^ (1 / 3)
	
	.ternary = (condition, ifTrue, ifFalse) -> if condition then ifTrue else ifFalse
	
	.isNAN = (x) -> x != x
	.isNaN = .isNAN
	
	.lerp = (t, a, b) -> a * (1 - t) + b * t
	.damp = (smoothing, dt, a, b) -> .lerp 1 - smoothing ^ dt, a, b
	
	.sign = (x) ->
		if x > 0 then 1
		elseif x < 0 then -1
		else 0
	
	.clamp = (value, vmin = value, vmax = value) ->
		if value < vmin then vmin
		elseif value > vmax then vmax
		else value
	
	.wrap = (v, vmin, vmax) ->
		if vmax == nil then vmax, vmin = vmin, nil
		vmin or= 0
		vmax or= 1
		(v - vmin) % (vmax - vmin) + vmin
	
	.map = (v, fromMin, fromMax, toMin, toMax) ->
		(v - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin
	
	.round = (x) -> floor x + 0.5
	.roundStep = (x, step = 1) -> floor(x / step + 0.5) * step