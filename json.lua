local comb = require('lithium.comb')
local literal, pattern = comb.literal, comb.pattern
local common = require 'lithium.common'
local ltable = require 'lithium.table'

local json = {}

local comma = literal(',')
local comma_ws = comma:wse()

local fals = literal 'false' :value(false)
local tru  = literal 'true'  :value(true)
local boolean = tru + fals
boolean = boolean:tag 'boolean'

local null = literal 'null' :null()
null = null:tag 'null'

local number = comb.sequence({
	pattern '%-?%d+'         :match(),
	pattern '%.%d+'          :match():optional():default '',
	pattern '[Ee][%-%+]?%d+' :match():optional():default '',
}) / table.concat / tonumber
number = number:tag('number')

local escape = literal('\\') * (pattern('["\\/bfnrt]') + pattern('u%x%x%x%x')):match()
escape = escape / function(result)
	if 'u' == result:sub(1, 1) then
		return '?' -- FIXME: decode unicode escape properly
	end
	
	if 'b' == result then
		return '\b'
	elseif 'f' == result then
		return '\f'
	elseif 'n' == result then
		return '\n'
	elseif 'r' == result then
		return '\r'
	elseif 't' == result then
		return '\t'
	end
	
	return result
end

local strin = ((escape + comb.uptoPattern('["\\%c]')) ^ 0 / table.concat):enclosed(literal '"')
strin = strin:tag('string')


local array, object
local value = comb.proxy(function()
	return comb.choice {array, object, boolean, null, number, strin}
end)

array = value
:delimited(comma_ws)
:optional()
:default({})
:wse()
:enclosed(literal '[', literal ']')
array = array:tag('array')

local record = comb.sequence({
	strin:index('value'),
	literal(':'):wse(),
	value
}) / function(result)
	return {
		key = result[1],
		value = result[3]
	}
end

object = record
:delimited(comma_ws)
:optional()
:default({})
:wse()
:enclosed(literal '{', literal '}')
object = object:tag('object')

function json.parse(str, source)
	local newState, err = value:enclosed(comb.mws, comb.mws * comb.eof):parseData(str, source)
	if not newState then
		return nil, err
	end
	return newState.result
end

local function decodeValue(val)
	if 'array' == val.tag then
		return ltable.imap(val.value, decodeValue)
	elseif 'object' == val.tag then
		local obj = {}
		for i = 1, #val.value do
			local rec = val.value[i]
			obj[rec.key] = decodeValue(rec.value)
		end
		return obj
	end
	return val.value
end

function json.decode(str, source)
	local result, err = json.parse(str, source)
	if not result then
		return nil, err
	end
	return decodeValue(result)
end

function json.decodeFile(path)
	local data, err = common.readFile(path)
	if not data then
		return nil, err
	end
	return json.decode(data, path)
end

local function ind(level)
	if level == nil then
		level = 0
	end
	return ('    '):rep(level)
end

function json.encode(val, indent)
	if indent == nil then
		indent = 0
	end
	local typ = type(val)
	if 'string' == typ then
		val = val:gsub('[%z\1-\31\\"]', function(char)
			if '\\' == char then
				return '\\\\'
			elseif '"' == char then
				return '\\"'
			elseif '\r' == char then
				return '\\r'
			elseif '\n' == char then
				return '\\n'
			elseif '\t' == char then
				return '\\t'
			elseif '\b' == char then
				return '\\b'
			else
				return string.format('\\u%04x', char:byte())
			end
		end)
		return '"' .. val .. '"'
	elseif 'table' == typ then
		local maxIndex = 0
		local isArray = true
		for k, _ in pairs(val) do
			local kt = type(k)
			if kt ~= 'number' and kt ~= 'string' then
				return nil, 'object key may only be a string or an integer'
			end
			if isArray and kt == 'number' then
				if k < 1 then
					return nil, 'array indices must start from 1'
				end
				if k % 1 ~= 0 then
					return nil, 'array index may only be an integer'
				end
				if k > maxIndex then
					maxIndex = k
				end
			else
				isArray = false
				break
			end
		end
		if isArray then
			local t = {}
			for i = 1, maxIndex do
				local err
				t[i], err = json.encode(val[i], indent)
				if not (t[i]) then
					return nil, err
				end
			end
			return "[" .. tostring(table.concat(t, ', ', 1, maxIndex)) .. "]"
		else
			local t = {}
			for k, v in pairs(val) do
				k = tostring(k)
				if t[k] then
					return nil, 'number - string object key name clash'
				end
				t[k] = true
				local err
				k, err = json.encode(k, indent + 1)
				if not (k) then
					return nil, err
				end
				v, err = json.encode(v, indent + 1)
				if not (v) then
					return nil, err
				end
				table.insert(t, tostring(ind(indent + 1)) .. tostring(k) .. ": " .. tostring(v))
			end
			return "{\n" .. tostring(table.concat(t, ',\n')) .. "\n" .. tostring(ind(indent)) .. "}"
		end
	elseif 'nil' == typ then
		return 'null'
	elseif typ == 'number' or typ == 'boolean' then
		return tostring(val)
	end
	
	return nil, 'can not encode ' .. typ .. ' to json'
end

return json
