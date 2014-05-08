# command -v entr > /dev/null 2>&1 || { brew install entr; }

all:
	cd lua; \
	moonshine distil *.lua

watch:
	cd lua; \
	find . -name '*.lua' | entr moonshine distil *.lua

coffee:
	coffee --output js -j love.js --compile coffeescript/love.js/
	coffee --output js --compile coffeescript/amore.coffee

web:
	python -m SimpleHTTPServer

clean:
	rm lua/*.json
