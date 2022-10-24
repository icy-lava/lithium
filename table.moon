import pack, unpack, index, set, ripairs, keys, array, empty from require 'lithium.common'
import wrap, yield from coroutine
local inspect

with setmetatable {
	:pack
	:unpack
	:index
	:set
	:ripairs
	:keys
	:array
	:empty
}, {__index: table}
	.copy = (t) -> {k, v for k, v in pairs t}
	.clone = (value) ->
		return value if type(value) != 'table'
		return {k, .clone v for k, v in pairs value}
	.invert = (t) -> {v, k for k, v in pairs t}
	.isEmpty = (t) -> not next(t)
	
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
			@length = select('#', ...)
		
		__tostring: =>
			inspect = require 'inspect' if not inspect
			stringified = {}
			for i = 1, @length
				value = @values[i]
				value = inspect value if type(value) != 'table'
				stringified[i] = tostring(value)
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
			