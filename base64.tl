local byte, format = string.byte, string.format
local floor = math.floor

local bmap = {[0]='A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'}
local ibmap = {[65]=0,[66]=1,[67]=2,[68]=3,[69]=4,[70]=5,[71]=6,[72]=7,[73]=8,[74]=9,[75]=10,[76]=11,[77]=12,[78]=13,[79]=14,[80]=15,[81]=16,[82]=17,[83]=18,[84]=19,[85]=20,[86]=21,[87]=22,[88]=23,[89]=24,[90]=25,[97]=26,[98]=27,[99]=28,[100]=29,[101]=30,[102]=31,[103]=32,[104]=33,[105]=34,[106]=35,[107]=36,[108]=37,[109]=38,[110]=39,[111]=40,[112]=41,[113]=42,[114]=43,[115]=44,[116]=45,[117]=46,[118]=47,[119]=48,[120]=49,[121]=50,[122]=51,[48]=52,[49]=53,[50]=54,[51]=55,[52]=56,[53]=57,[54]=58,[55]=59,[56]=60,[57]=61,[43]=62,[47]=63}

return {
	encode = function(str: string): string
		local result = str:gsub('..?.?', function(chars: string): string
			local b1, b2, b3 = byte(chars, 1, 3)
			local value = (b1 * (2 ^ 16) + (b2 or 0) * (2 ^ 8) + (b3 or 0)) as integer
			local c1 : integer
			local c2 : integer
			local c3 : integer
			local c4 : integer
			c4, value = value % 64, floor(value / 64)
			c3, value = value % 64, floor(value / 64)
			c2, value = value % 64, floor(value / 64)
			c1 = value
			local charCount = #chars
			if charCount == 3 then
				return format('%s%s%s%s', bmap[c1], bmap[c2], bmap[c3], bmap[c4])
			elseif charCount == 2 then
				return format('%s%s%s=', bmap[c1], bmap[c2], bmap[c3])
			else
				return format('%s%s==', bmap[c1], bmap[c2])
			end
		end)
		return result
	end,
	decode = function(str: string): string, string
		str = str:gsub('=+$', '', 1)
		if #str % 4 == 1 then
			return nil, 'invalid number of characters'
		end
		local result = str:gsub('..?.?.?', function(chars: string): string
			local b1, b2, b3, b4 = byte(chars, 1, 4)
			b1, b2, b3, b4 = ibmap[b1 or 0], ibmap[b2 or 0], ibmap[b3 or 0], ibmap[b4 or 0]
			local value = (b1 * (2 ^ 18) + (b2 or 0) * (2 ^ 12) + (b3 or 0) * (2 ^ 6) + (b4 or 0)) as integer
			local c1 : integer
			local c2 : integer
			local c3 : integer
			c3, value = value % 256, floor(value / 256)
			c2, value = value % 256, floor(value / 256)
			c1 = value
			local charCount = #chars
			if charCount == 4 then
				return format('%c%c%c', c1, c2, c3)
			elseif charCount == 3 then
				return format('%c%c', c1, c2)
			elseif charCount == 2 then
				return format('%c', c1)
			end
		end)
		return result
	end
}