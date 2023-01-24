import pack, unpack, isEmpty, index, set, delete, clear, ripairs, keys, array, empty from require 'lithium.common'
import sort from table

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
	
	.merge = (...) ->
		result = .copy((...))
		for i = 2, select '#', ...
			for k, v in pairs((select i, ...))
				result[k] = v
		return result
	.imerge = (...) ->
		result = .icopy((...))
		count = #result
		for i = 2, select '#', ...
			for v in *select i, ...
				count += 1
				result[count] = v
		return result
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
			