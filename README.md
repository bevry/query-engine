# Query-Engine

A NoSQL (and MongoDB compliant) Query Engine coded in CoffeeScript for Server-Side use with Node.js and Client-Side use with Web-Browsers


## Supported Queries

Query-Engine supports the exact same queries as [MongoDb](http://www.mongodb.org/). [Find the full listing of supported queries here.](http://www.mongodb.org/display/DOCS/Advanced+Queries)

[You can find the test suite which showcases how to use the supported queries here.](https://raw.github.com/balupton/query-engine.npm/master/test/query-engine.coffee)


## Installation

- Server-Side with Node.js

	1. [Install Node.js](https://github.com/balupton/node/wiki/Installing-Node.js)

	2. Install

			npm install query-engine
	
	3. Require

		``` coffeescript
		queryEngine = require 'query-engine'
		```

- Client-Side with Web Browsers

	1. [Copy the contents of this file into your clipboard](https://raw.github.com/balupton/query-engine.npm/master/lib/query-engine.coffee)

	2. [Paste the contents of the file into the "Try Coffeescript" area here](http://jashkenas.github.com/coffee-script/)

	3. Copy the result into your clipboard

	4. Save the result as a javascript file on your webserver

	5. Create a script tag pointing to the file on your webserver

	6. Make note of `window.queryEngine`


## Using

- With CoffeeScript

	``` coffeescript
	# Dataset
	documents =
		0:
			title: 'abc'
			tags: ['a','b']
		1:
			title: 'blah'
			tags: ['a','b','c']

	# Query
	documents.find tags: $in: ['a'] # {0: documents.0, 1: documents.1}
	documents.find title: 'blah' # {1: documents.1}
	```

- With JavaScript
	
	> Do yourself a favour and learn CoffeeScript.


## History

- v0.3.1 August 13, 2011
	- Find will now return a ID associated object always
		- Before it was only doing it when the object we were finding was an ID associated object

- v0.3.0 August 11, 2011
	- Now supports models as well as native javascript objects
		- This was done by checking if the record has a `get` function, if it does then we use that instead of directly accessing the field from the object

- v0.2 July 6, 2011
	- Added toArray, sort, findOne, remove, forEach

- v0.1 July 6, 2011
	- Initial commit


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
Copyright 2011 [Benjamin Arthur Lupton](http://balupton.com)
