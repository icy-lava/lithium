local common = require 'lithium.common'
local pack = common.pack
local type Packed = common.Packed

local function packCaptures<T>(start: integer, stop: integer, ...: T): integer, integer, {T}
	return start, stop, pack(...)
end

local type StringFind = function(str: string, i: integer): integer, integer, string...

local type StringToken = record<T>
	type: T
	start: integer
	stop: integer
	match: string
	captures: Packed<string>
end

local type StringPattern = record<T>
	{string | StringFind}
	type: T
end

local type ArrayFind = function<V>(array: {V}, i: integer): integer, integer, V...

local type ArrayToken = record<T, V>
	type: T
	start: integer
	stop: integer
	captures: Packed<V>
end

local type ArrayPattern = record<T, V>
	{V | {V} | ArrayFind<V>}
	type: T
end

return {
	StringFind = StringFind,
	StringToken = StringToken,
	StringPattern = StringPattern,
	ArrayFind = ArrayFind,
	ArrayToken = ArrayToken,
	ArrayPattern = ArrayPattern,
	
	lexArray = function<T, V>(array: {V}, patterns: {ArrayPattern<T, V>}): {ArrayToken<T, V>}, string, integer
		local i: integer = 1
		local arraylen = #array
		local tokens: {ArrayToken<T, V>} = {}
		while i <= arraylen do
			local token: ArrayToken<T, V>
			for _, pattern in ipairs(patterns) do
				for j = 1, #pattern do
					local pat = pattern[j]
					
					local start, stop, captures: integer, integer, Packed<V>
					if pat is ArrayFind<V> then
						start, stop, captures = packCaptures(pat(array, i))
						assert(start <= stop)
					elseif pat is {V} then
						local match = true
						local patlen = #pat
						for k = 1, patlen do
							if pat[k] ~= array[i + k - 1] then
								match = false
								break
							end
						end
						if match then
							start, stop = i, i + patlen - 1
							captures = common.toPacked(common.sub(array, start, stop), patlen)
						end
					elseif pat == array[i] then
						start, stop, captures = i, i, pack(array[i])
					end
					
					if stop and stop >= i then
						token = {
							type = assert(pattern.type, 'each pattern should have a type'),
							start = start,
							stop = stop,
							captures = captures,
						}
						i = stop + 1
						break
					end
				end
				if token then break end
			end
			if not token then
				return nil, 'token not found', i
			end
			table.insert(tokens, token)
		end
		return tokens
	end,
	
	lexString = function<T>(str: string, patterns: {StringPattern<T>}): {StringToken<T>}, string, integer
		local i: integer = 1
		local strlen = #str
		local tokens: {StringToken<T>} = {}
		while i <= strlen do
			local token: StringToken<T>
			for _, pattern in ipairs(patterns) do
				for j = 1, #pattern do
					local pat = pattern[j]
					
					local start, stop, captures: integer, integer, Packed<string>
					if pat is string then
						start, stop, captures = packCaptures(str:find(pat:gsub('^%^?', '^'), i))
					else
						start, stop, captures = packCaptures(pat(str, i))
						assert(not start or start <= stop)
					end
					
					if stop and stop >= i then
						token = {
							type = assert(pattern.type, 'each pattern should have a type'),
							start = start,
							stop = stop,
							match = str:sub(start, stop),
							captures = captures,
						}
						i = stop + 1
						break
					end
				end
				if token then break end
			end
			if not token then
				return nil, 'token not found', i
			end
			table.insert(tokens, token)
		end
		return tokens
	end
}