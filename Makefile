test:
	./node_modules/.bin/mocha

test-global:
	mocha

compile:
	./node_modules/.bin/coffee -c lib/query-engine.coffee

dev:
	./node_modules/.bin/coffee -w -c lib/query-engine.coffee

.PHONY: test test-global compile dev