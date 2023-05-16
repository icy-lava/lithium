local bit = require 'lithium.bit'
local rshift = bit.rshift
local bnot = bit.bnot
local band = bit.band
local bxor = bit.bxor

return function(str: string): integer
	local crc = 0xffffffff
	for i = 1, #str do
		local byte = str:byte(i)
		crc = bxor(crc, byte)
		for _ = 1, 8 do
			local mask = -(crc % 2)
			crc = bxor(rshift(crc, 1), band(0xedb88320, mask))
		end
	end
	crc = bnot(crc)
	if crc < 0 then
		crc = (crc + 2 ^ 31) as integer
	end
	return crc
end