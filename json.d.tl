local record json
	type JsonArray = {JsonValue}
	type JsonObject = {string:JsonValue}
	
	-- NOTE: Teal doesn't allow us to union JsonArray and JsonObject, we use a map with a union key as a workaround
	type JsonValue = {string|integer:JsonValue} | string | boolean | number | nil
	
	decode: function(data: string): JsonValue
	encode: function(JsonValue): string
end

return json