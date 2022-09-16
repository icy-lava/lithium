import format from string

with setmetatable {}, {__index: _G}
	.noop = ->
	.empty = {}
	.index = (t, ...) ->
		for i = 1, select '#', ...
			return nil unless type(t) == 'table'
			t = t[select(i, ...)]
		return t
	
	.pack = table.pack or (...) -> {n: select('#', ...), ...}
	.unpack = table.unpack or unpack
	
	ripairsIterator = (t, i) ->
		return nil if i == 1
		i = i - 1
		i, t[i]
	.ripairs = (t) -> ripairsIterator, t, #t + 1
	
	keysIterator = (t, k) ->
		k = next(t, k)
		return k
	.keys = (t) -> keysIterator, t
	
	.array = (...) -> [v for v in ...]