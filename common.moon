import format from string.format

with setmetatable {}, {__index: _G}
	.pack = table.pack or (...) -> {n: select('#', ...), ...}
	.unpack = table.unpack or unpack
	
	ripairsIterator = (t, i) ->
		return nil if i == 1
		i - 1, t[i - 1]
	.ripairs = (t) -> ripairsIterator, t, #t + 1
	
	keysIterator = (t, k) ->
		k = next(t, k)
		k
	.keys = (t) -> keysIterator, t
	
	.array = (...) -> [v for v in ...]