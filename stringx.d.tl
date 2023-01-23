local record stringx
	lines: function(str: string): function(): string
end

return setmetatable(stringx, {__index = string})