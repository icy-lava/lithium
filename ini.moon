-- This is meant to be a small dumb parser that generally works.
-- It abuses the token lexer to somewhat skip parsing.
-- It is not descriptive in it's errors, and does not conform to any particular standard.

-- A version 2 should lex smaller tokens that actually get parsed (into AST or final data),
-- possibly also preserving the order of sections, warning of redefinitions, etc.

import lex from require 'lithium.lexer'
import ifilter, imap, icopy, set from require 'lithium.table'
import lineAt, trim, trimNonEmpty, split, delim from require 'lithium.string'

with {}
	types = {
		{'blank', '[^%S\r\n]*\r?\n'}
		{'whitespace', '[^%S\r\n]+'}
		
		-- NOTE: a section doesn't actually end at a newline, this means '[config] x = y' is valid.
		{'section', '%[([^%]\r\n#;]*)%][^%S\r\n]*\r?\n?'}
		
		{'comment', '[#;]([^\r\n]*)\r?\n'}
		{'assign', '([^%[=\r\n#;]+)=([^#;\r\n]*)\r?\n?'}
	}
	
	parseKey = (key) ->
		keys = {}
		for subkey in delim key, '.'
			subkey = trimNonEmpty subkey
			return nil, 'invalid key' unless subkey
			table.insert keys, subkey\lower!
		return keys
	
	.parse = (str) ->
		str = "#{str}\n"
		tokens, err, pos = lex str, types
		
		unless tokens
			line = lineAt str, pos
			return nil, "failed to lex line #{line}", line
		
		-- tokens = ifilter tokens, (token) ->
		-- 	switch token.type
		-- 		when 'blank' then false
		-- 		when 'whitespace' then false
		-- 		else true
		
		currentSection = {'global'}
		data = {}
		for token in *tokens
			switch token.type
				when 'section'
					newSection = parseKey token.captures[1]
					if not newSection
						line = lineAt str, token.start
						return nil, "invalid section at line #{line}", line
					currentSection = newSection
				when 'assign'
					keys = parseKey token.captures[1]
					if not keys
						line = lineAt str, token.start
						return nil, "invalid assignment key at line #{line}", line
					setPath = icopy currentSection
					for key in *keys do table.insert setPath, key
					table.insert setPath, trim(token.captures[2])
					set data, unpack setPath
		
		return data
	.parseFile = (fileName) ->
		stream, err = io.open fileName, 'rb'
		return nil, err unless stream
		data, err = stream\read '*a'
		return nil, err unless data
		stream\close!
		
		result, err, line = .parse data
		return nil, "#{fileName}: #{err}", line unless result
		return result