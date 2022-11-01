thisModuleName = ...
-- Ensure submodules can just require 'lithium'
unless thisModuleName == 'lithium' then package.preload.lithium = -> require thisModuleName

setmetatable {}, {
	__index: (module) =>
		status, result = pcall require, "lithium.#{module}"
		error result, 2 unless status
		@[module] = result
		return result
}