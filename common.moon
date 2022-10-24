with setmetatable {}, {__index: _G}
	.noop = ->
	.empty = setmetatable {}, {
		__metatable: false
		__newindex: ->
	}
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
	_, table_clear = pcall require, 'table.clear'
	.clear = table_clear or (t) ->
		for k in pairs t
			rawset t, k, nil
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
	
	lazyTrigger = (t) ->
		func = t.values[1]
		result = func .unpack t.values, 2, t.values.n
		switch type result
			when 'table'
				setmetatable t, nil
				.clear t
				for k, v in pairs result
					t[k] = v
				setmetatable t, getmetatable(result)
			when 'function'
				setmetatable t, {__call: result}
				.clear t
			else
				error "unsupported type for lazy loader: '#{type result}'"
	
	lazyMetatable = {
		__call: (t, ...) ->
			lazyTrigger t
			t ...
		__index: (t, k) ->
			lazyTrigger t
			return t[k]
		__newindex: (t, k, v) ->
			lazyTrigger t
			t[k] = v
	}
	.lazy = (...) -> setmetatable {values: .pack ...}, lazyMetatable
		