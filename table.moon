import pack, unpack, ripairs, keys, array from require 'lithium.common'

with setmetatable {
	:pack
	:unpack
	:ripairs
	:keys
	:array
}, {__index: table}
	.copy = (t) -> {k, v for k, v in pairs t}
	.clone = (value) ->
		if type(value) != 'table' then return value
		return {k, .clone v for k, v in pairs value}
	.isEmpty = (t) -> not next(t)