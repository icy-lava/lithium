import pack, unpack from require 'lithium.common'

with setmetatable {}, {__index: table}
	.copy = (t) -> {k, v for k, v in pairs t}
	.clone = (value) ->
		if type(value) != 'table' then return value
		return {k, .clone v for k, v in pairs value}
	.pack = pack
	.unpack = unpack