local byte, format = string.byte, string.format
local floor = math.floor

local bmap = {[0]='A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','2','3','4','5','6','7'}
local ibmap = {[65]=0,[66]=1,[67]=2,[68]=3,[69]=4,[70]=5,[71]=6,[72]=7,[73]=8,[74]=9,[75]=10,[76]=11,[77]=12,[78]=13,[79]=14,[80]=15,[81]=16,[82]=17,[83]=18,[84]=19,[85]=20,[86]=21,[87]=22,[88]=23,[89]=24,[90]=25,[50]=26,[51]=27,[52]=28,[53]=29,[54]=30,[55]=31}

return {
	encode = function(str: string): string
		local result = str:gsub('..?.?.?.?', function(chars: string): string
			local b1, b2, b3, b4, b5 = byte(chars, 1, 5)
			local value = (b1 * (2 ^ 32) + (b2 or 0) * (2 ^ 24) + (b3 or 0) * (2 ^ 16) + (b4 or 0) * (2 ^ 8) + (b5 or 0)) as integer
			local c1 : integer
			local c2 : integer
			local c3 : integer
			local c4 : integer
			local c5 : integer
			local c6 : integer
			local c7 : integer
			local c8 : integer
			c8, value = value % 32, floor(value / 32)
			c7, value = value % 32, floor(value / 32)
			c6, value = value % 32, floor(value / 32)
			c5, value = value % 32, floor(value / 32)
			c4, value = value % 32, floor(value / 32)
			c3, value = value % 32, floor(value / 32)
			c2, value = value % 32, floor(value / 32)
			c1 = value
			local charCount = #chars
			if charCount == 5 then
				return format('%s%s%s%s%s%s%s%s', bmap[c1], bmap[c2], bmap[c3], bmap[c4], bmap[c5], bmap[c6], bmap[c7], bmap[c8])
			elseif charCount == 4 then
				return format('%s%s%s%s%s%s%s=', bmap[c1], bmap[c2], bmap[c3], bmap[c4], bmap[c5], bmap[c6], bmap[c7])
			elseif charCount == 3 then
				return format('%s%s%s%s%s===', bmap[c1], bmap[c2], bmap[c3], bmap[c4], bmap[c5])
			elseif charCount == 2 then
				return format('%s%s%s%s====', bmap[c1], bmap[c2], bmap[c3], bmap[c4])
			else
				return format('%s%s======', bmap[c1], bmap[c2])
			end
		end)
		return result
	end,
	decode = function(str: string): string, string
		str = str:gsub('=+$', '', 1):upper()
		local strlen8 = #str % 8
		if strlen8 == 6 or strlen8 == 3 or strlen8 == 1 then
			return nil, 'invalid number of characters'
		end
		local result = str:gsub('..?.?.?.?.?.?.?', function(chars: string): string
			local b1, b2, b3, b4, b5, b6, b7, b8 = byte(chars, 1, 8)
			b1, b2, b3, b4, b5, b6, b7, b8 = ibmap[b1 or 0], ibmap[b2 or 0], ibmap[b3 or 0], ibmap[b4 or 0], ibmap[b5 or 0], ibmap[b6 or 0], ibmap[b7 or 0], ibmap[b8 or 0]
			local value = (b1 * (2 ^ 35) + (b2 or 0) * (2 ^ 30) + (b3 or 0) * (2 ^ 25) + (b4 or 0) * (2 ^ 20) + (b5 or 0) * (2 ^ 15) + (b6 or 0) * (2 ^ 10) + (b7 or 0) * (2 ^ 5) + (b8 or 0)) as integer
			local c5 : integer
			local c4 : integer
			local c3 : integer
			local c2 : integer
			local c1 : integer
			c5, value = value % 256, floor(value / 256)
			c4, value = value % 256, floor(value / 256)
			c3, value = value % 256, floor(value / 256)
			c2, value = value % 256, floor(value / 256)
			c1 = value
			local charCount = #chars
			if charCount == 8 then
				return format('%c%c%c%c%c', c1, c2, c3, c4, c5)
			elseif charCount == 7 then
				return format('%c%c%c%c', c1, c2, c3, c4)
			elseif charCount == 5 then
				return format('%c%c%c', c1, c2, c3)
			elseif charCount == 4 then
				return format('%c%c', c1, c2)
			elseif charCount == 2 then
				return format('%c', c1)
			end
			-- We already check for invalid char length above
		end)
		return result
	end
}