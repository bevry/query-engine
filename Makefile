test:
	./node_modules/.bin/mocha

test-global:
	mocha

compile:
	coffee -c lib/query-engine.coffee

.PHONY: test test-global compile