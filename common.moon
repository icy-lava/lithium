with setmetatable {}, {__index: _G}
	.noop = ->
	.empty = setmetatable {}, {
		__metatable: false
		__newindex: ->
	}
	.isEmpty = (t) -> nil == next t
	.index = (t, ...) ->
		for i = 1, select '#', ...
			return nil unless 'table' == type t
			t = t[select i, ...]
		return t
	.set = (t, ...) ->
		argLen = select '#', ...
		assert argLen > 0
		if argLen == 1 then return (...)
		for i = 1, argLen - 2
			key = select i, ...
			t[key] = {} if t[key] == nil
			t = t[key]
			assert 'string' != type t, 'tried to index a string, but it\'s not allowed'
		t[select argLen - 1, ...] = select argLen, ...
		return t
	.delete = (t, ...) ->
		argLen = select '#', ...
		assert argLen > 0
		if argLen == 1
			key = ...
			t[key] = nil
			return nil if .isEmpty t
			return t
		
		path = {t}
		for i = 1, argLen - 1
			key = select i, ...
			t = t[key]
			return path[1] if 'table' != type t
			path[i + 1] = t
		for i = argLen, 1, -1
			key = select i, ...
			t = path[i]
			t[key] = nil
			return path[1] if not .isEmpty t
		return nil
			
	_, table_clear = pcall require, 'table.clear'
	.clear = table_clear or (t) ->
		for k in pairs t
			rawset t, k, nil
		return t
	
	.pack = table.pack or (...) -> {n: select('#', ...), ...}
	.packCaptures = (start, stop, ...) -> start, stop, .pack ...
	.unpack = table.unpack or unpack
	
	ripairsIterator = (t, i) ->
		return nil if i == 1
		i = i - 1
		i, t[i]
	.ripairs = (t) -> ripairsIterator, t, #t + 1
	
	keysIterator = (t, k) ->
		k = next t, k
		return k
	.keys = (t) -> keysIterator, t
	
	.array = (...) -> [v for v in ...]
	
	.requireZero = (...) ->
		local firstError
		for i = 1, select '#', ...
			mod = select i, ...
			ok, result = pcall require, mod
			return result, mod if ok
			firstError = result if i == 1
		return nil, firstError
	
	.requireOne = (...) ->
		result, errOrMod = .requireZero ...
		error errOrMod, 2 if result == nil
		return result, errOrMod
	
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
		