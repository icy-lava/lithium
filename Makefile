SOURCE_MOONSCRIPT := $(wildcard *.moon)
SOURCE_LUA_GENERATED := $(patsubst %.moon,%.lua,$(SOURCE_MOONSCRIPT))

.PHONY: compile
compile: $(SOURCE_LUA_GENERATED)

%.lua: %.moon
	moonc $<