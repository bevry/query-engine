compile:
	./node_modules/.bin/coffee -o out/ -c src/

dev:
	./node_modules/.bin/coffee -w -o out/ -c src/

bench:
	node ./out/test/benchmark.js

test:
	node ./out/test/everything.test.js --joe-reporter=list

test-debug:
	node --debug-brk ./out/test/everything.test.js

.PHONY: compile dev bench test test-debug