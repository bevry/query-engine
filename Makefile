test:
	node ./node_modules/mocha/bin/mocha

test-debug:
	node ./node_modules/mocha/bin/mocha --debug-brk

test-global:
	mocha

compile:
	./node_modules/.bin/coffee -c lib/query-engine.coffee

dev:
	./node_modules/.bin/coffee -w -c lib/query-engine.coffee

.PHONY: test test-debug test-global compile dev