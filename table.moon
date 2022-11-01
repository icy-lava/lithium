import pack, unpack, isEmpty, index, set, delete, clear, ripairs, keys, array, empty, lazy from require 'lithium.common'
import wrap, yield from coroutine
import sort from table
inspect = lazy require, 'inspect'

with setmetatable {
	:pack
	:unpack
	:isEmpty
	:index
	:set
	:delete
	:clear
	:ripairs
	:keys
	:array
	:empty
}, {__index: table}
	.copy = (t) -> {k, v for k, v in pairs t}
	.icopy = (t) -> [v for v in *t]
	.clone = (value) ->
		return value if 'table' != type value
		return {k, .clone v for k, v in pairs value}
	.invert = (t) -> {v, k for k, v in pairs t}
	
	.map = (t, func, ...) -> {key, func value, ... for key, value in pairs t}
	.imap = (t, func, ...) -> [func value, ... for value in *t]
	.filter = (t, func, ...) ->
		newT = {}
		for key, value in pairs t
			newT[key] = value if func value, ...
		return newT
	.ifilter = (t, func, ...) ->
		newT = {}
		newCount = 0
		for value in *t
			if func value, ...
				newCount += 1
				newT[newCount] = value
		return newT
	.reject = (t, func, ...) ->
		newT = {}
		for key, value in pairs t
			newT[key] = value unless func value, ...
		return newT
	.ireject = (t, func, ...) ->
		newT = {}
		newCount = 0
		for value in *t
			unless func value, ...
				newCount += 1
				newT[newCount] = value
		return newT
	.sort = (t, comp) ->
		newT = .icopy t
		if comp == nil or 'function' == type comp
			sort newT, comp
		else
			sort newT, (a, b) -> a[comp] < b[comp]
		return newT
	.reverse = (t) -> [t[i] for i = #t, 1, -1]
	
	defaultReducer = (a, b) -> a + b
	.reduce = (t, reducer = defaultReducer) ->
		value = t[1]
		for i = 2, t.n or #t
			value = reducer value, t[i]
		return value
	
	_, table_new = pcall require, 'table.new'
	.new = table_new or -> {} -- If there's no table.new, just ignore args
	
	gridIterator = (grid) ->
		yield!
		for y, row in pairs grid.rows
			for x, value in pairs row
				yield x, y, value
		while true do yield nil
	
	.Grid = class
		new: =>
			@rows = {}
		
		get: (x, y) => (@rows[y] or empty)[x]
		set: (x, y, value) =>
			@rows[y] = {} if not @rows[y]
			@rows[y][x] = value
			if .isEmpty @rows[y] then @rows[y] = nil
			return @
		each: =>
			iter = wrap gridIterator
			iter @
			return iter
	
	-- TODO: this probably doesn't need to be a closure iterator
	listIterator = (list) ->
		yield!
		for i = 1, list.length do yield i, list.values[i]
		while true do yield nil
	
	concat = table.concat
	.List = class
		new: (...) =>
			@values = {...}
			@length = select '#', ...
		
		__tostring: =>
			stringified = {}
			for i = 1, @length
				value = @values[i]
				value = inspect value if 'table' != type value
				stringified[i] = tostring value
			return "#{@@__name} [ #{concat stringified, ', ', 1, @length} ]"
		
		__len: => @length
		
		push: (value) =>
			@length += 1
			@values[@length] = value
		
		pop: =>
			@values[@length] = nil
			@length -= 1
		
		pushFront: (value) =>
			for i = 1, @length do @values[i + 1] = @values[i]
			@values[1] = value
			@length += 1
		
		popFront: =>
			for i = 1, @getLength! do @values[i] = @values[i + 1]
			@length -= 1
		
		getLength: => @length
		get: (i) => @values[i]
		set: (i, value) =>
			if i < 1 or i > @length then error "invalid list index: #{i}", 2
			@values[i] = value
		
		each: =>
			iter = wrap listIterator
			iter @
			return iter
			