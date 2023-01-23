local common = require 'lithium.common'
local packCaptures = common.packCaptures
local type Packed = common.Packed

local type FindFunc = function(str: string, i: integer): integer, integer, string...

local type Token = record
	type: string
	start : integer
	stop : integer
	match: string
	captures: Packed<string>
end

return {
	FindFunc = FindFunc,
	Token = Token,
	
	lexString = function(str: string, patterns: {{string | FindFunc}}): {Token}, string, integer
		local i : integer = 1
		local strlen = #str
		local tokens : {Token} = {}
		while i <= strlen do
			local token : Token
			for _, pattern in ipairs(patterns) do
				local tokenType: string
				local pattern1 = pattern[1]
				if pattern1 is string then
					tokenType = pattern1
				else
					return nil, 'expected a string as first value', i
				end
				for j = 2, #pattern do
					local pat = pattern[j]
					
					local start, stop, captures: integer, integer, Packed<string>
					if pat is string then
						start, stop, captures = packCaptures(str:find(pat:gsub('^%^?', '^'), i))
					else
						start, stop, captures = packCaptures(pat(str, i))
						assert(start <= stop - 1)
					end
					
					if stop and stop >= i then
						if captures.n == 0 then captures = nil end
						token = {
							type = tokenType,
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