-- This is meant to be a small dumb parser that generally works.
-- It abuses the token lexer to somewhat skip parsing.
-- It is not descriptive in it's errors, and does not conform to any particular standard.

-- A version 2 should lex smaller tokens that actually get parsed (into AST or final data),
-- possibly also preserving the order of sections, warning of redefinitions, etc.

local lstring = require 'lithium.string'
local ltable = require 'lithium.table'
local lexer = require 'lithium.lexer'
local common = require 'lithium.common'

local enum TokenType
	'blank'
	'whitespace'
	'section'
	'comment'
	'assign'
end

local types: {lexer.StringPattern<TokenType>} = {
	{type = 'blank', '[^%S\r\n]*\r?\n'},
	{type = 'whitespace', '[^%S\r\n]+'},
	
	-- NOTE: a section doesn't actually end at a newline, this means '[config] x = y' is valid.
	{type = 'section', '%[([^%]\r\n#;]*)%][^%S\r\n]*\r?\n?'},
	
	{type = 'comment', '[#;]([^\r\n]*)\r?\n'},
	{type = 'assign', '([^%[=\r\n#;]+)=([^#;\r\n]*)\r?\n?'},
}

local type Namespace = {string:string | Namespace}

local function parseKey(key: string): {string}, string
	local keys : {string} = {}
	for subkey in lstring.delim(key, '.') do
		subkey = lstring.trimNonEmpty(subkey)
		if not subkey then
			return nil, 'invalid key'
		end
		ltable.insert(keys, subkey:lower())
	end
	return keys
end

local function parseString(str: string): Namespace, string, integer
	str = str .. '\n'
	local tokens, _, pos = lexer.lexString(str, types)
	
	if not tokens then
		local line = lstring.lineAt(str, pos)
		return nil, 'failed to lex line ' .. line, line
	end
	
	local currentSection = {'global'}
	local data : Namespace = {}
	for i = 1, #tokens do
		local token = tokens[i]
		if token.type == 'section' then
			local newSection = parseKey(token.captures[1])
			if not newSection then
				local line = lstring.lineAt(str, token.start)
				return nil, 'invalid assignment key at line ' .. line, line
			end
			currentSection = newSection
		elseif token.type == 'assign' then
			local keys = parseKey(token.captures[1])
			if not keys then
				local line = lstring.lineAt(str, token.start)
				return nil, 'invalid assignment key at line ' .. line, line
			end
			local setPath = ltable.icopy(currentSection)
			for j = 1, #keys do
				ltable.insert(setPath, keys[j])
			end
			ltable.insert(setPath, lstring.trim(token.captures[2]))
			ltable.set(data, ltable.unpack(setPath))
		end
	end
	return data
end

return {
	Namespace = Namespace,
	TokenType = TokenType,
	parseString = parseString,
	parseFile = function(filename: string): Namespace, string, integer
		local data, err = common.readFile(filename)
		if not data then
			return nil, err
		end
		
		local result, err2, line = parseString(data)
		if not result then
			return nil, string.format('%s: %s', filename, err2), line
		end
		return result
	end
}