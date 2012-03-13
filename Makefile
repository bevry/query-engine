test:
	./node_modules/.bin/mocha

test-debug:
	node --debug-brk ./node_modules/.bin/mocha

docs:
	./node_modules/.bin/docco lib/*.coffee

.PHONY: test