import format from string

with setmetatable {}, {__index: _G}
	.noop = ->
	.empty = {}
	.index = (t, ...) ->
		for i = 1, select '#', ...
			return nil unless type(t) == 'table'
			t = t[select(i, ...)]
		return t
	.set = (t, ...) ->
		argLen = select '#', ...
		assert argLen > 0
		if argLen == 1 then return (...)
		for i = 1, argLen - 2
			key = select(i, ...)
			t[key] = {} if t[key] == nil
			t = t[key]
			assert type(t) != 'string', 'tried to index a string, but it\'s not allowed'
		t[select(argLen - 1, ...)] = select(argLen, ...)
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