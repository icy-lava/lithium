-- This is meant to be a small dumb parser that generally works.
-- It abuses the token lexer to somewhat skip parsing.
-- It is not descriptive in it's errors, and does not conform to any particular standard.

-- A version 2 should lex smaller tokens that actually get parsed (into AST or final data),
-- possibly also preserving the order of sections, warning of redefinitions, etc.

local string = require 'lithium.string'
local table = require 'lithium.table'
local lexer = require 'lithium.lexer'
local io = require 'lithium.io'

local types = {
	{'blank', '[^%S\r\n]*\r?\n'},
	{'whitespace', '[^%S\r\n]+'},
	
	-- NOTE: a section doesn't actually end at a newline, this means '[config] x = y' is valid.
	{'section', '%[([^%]\r\n#;]*)%][^%S\r\n]*\r?\n?'},
	
	{'comment', '[#;]([^\r\n]*)\r?\n'},
	{'assign', '([^%[=\r\n#;]+)=([^#;\r\n]*)\r?\n?'},
}

local type ININamespace = {string:string | ININamespace}

local function parseKey(key: string): {string}, string
	local keys : {string} = {}
	for subkey in string.delim(key, '.') do
		subkey = string.trimNonEmpty(subkey)
		if not subkey then return nil, 'invalid key' end
		table.insert(keys, subkey:lower())
	end
	return keys
end

local function parseString(str: string): ININamespace, string, integer
	str = str .. '\n'
	local tokens, _, pos = lexer.lexString(str, types)
	
	if not tokens then
		local line = string.lineAt(str, pos)
		return nil, 'failed to lex line ' .. line, line
	end
	
	local currentSection = {'global'}
	local data : ININamespace = {}
	for i = 1, #tokens do
		local token = tokens[i]
		if token.type == 'section' then
			local newSection = parseKey(token.captures[1])
			if not newSection then
				local line = string.lineAt(str, token.start)
				return nil, 'invalid assignment key at line ' .. line, line
			end
			currentSection = newSection
		elseif token.type == 'assign' then
			local keys = parseKey(token.captures[1])
			if not keys then
				local line = string.lineAt(str, token.start)
				return nil, 'invalid assignment key at line ' .. line, line
			end
			local setPath = table.icopy(currentSection)
			for j = 1, #keys do
				table.insert(setPath, keys[j])
			end
			table.insert(setPath, string.trim(token.captures[2]))
			table.set(data, table.unpack(setPath))
		end
	end
	return data
end

return {
	ININamespace = ININamespace,
	parseString = parseString,
	parseFile = function(filename: string): ININamespace, string, integer
		local data, err = io.readBytes(filename)
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