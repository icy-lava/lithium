local record expr
	type Value = Namespace | function | number
	type Namespace = {string:Value}
	eval: function(str: string, env: Namespace): Value
end

return expr