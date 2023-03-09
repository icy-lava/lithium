local record json
	type Array = {Value}
	type Object = {string:Value}
	
	-- NOTE: Teal doesn't allow us to union Array and Object, we use a map with a union key as a workaround
	type Mixed = {string|integer:Value}
	
	type Value = string | number | boolean | Mixed
	
	encode: function(value: Value): string, string
	encodeFile: function(path: string, value: Value): boolean, string
	decode: function(data: string, source: string): Value, string
	decodeFile: function(path: string): Value, string
end

return json