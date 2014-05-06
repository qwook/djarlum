# command -v entr > /dev/null 2>&1 || { brew install entr; }

all: lua/main.lua.json

lua/main.lua.json:
	cd lua; \
	moonshine distil *.lua

clean:
	rm lua/*.json
