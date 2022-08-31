import pack, unpack from require 'lithium.common'
import sort from table
import floor from math

with setmetatable {}, {__index: math}
	.clamp = (value, vmin = value, vmax = value) ->
		if value < vmin then vmin
		elseif value > vmax then vmax
		else value
	._sort = (...) ->
		t = pack ...
		sort t
		return t
	.min = (...) -> ._sort(...)[1]
	.max = (...) ->
		t = ._sort ...
		t[t.n]
	.sort = (...) ->
		t = ._sort ...
		unpack t, 1, t.n
	.wrap = (v, vmin, vmax) ->
		if vmax == nil then vmax, vmin = vmin, nil
		vmin or= 0
		vmax or= 1
		(v - vmin) % (vmax - vmin) + vmin
	.map = (v, fromMin, fromMax, toMin, toMax) ->
		(v - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin
	.round = (x) -> floor x + 0.5
	.roundStep = (x, step = 1) -> floor(x / step + 0.5) * step