SOURCE_TEAL := $(wildcard *.tl)
SOURCE_LUA_GENERATED := $(patsubst %.tl,%.lua,$(SOURCE_TEAL))

.PHONY: compile
compile: $(SOURCE_LUA_GENERATED)

%.lua: %.tl
	tl gen $<