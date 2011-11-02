# Query-Engine

A NoSQL (and MongoDB compliant) Query Engine coded in CoffeeScript for Server-Side use with Node.js and Client-Side use with Web-Browsers


## Supported Queries

Query-Engine supports the exact same queries as [MongoDb](http://www.mongodb.org/). [Find the full listing of supported queries here.](http://www.mongodb.org/display/DOCS/Advanced+Queries)

[You can find the test suite which showcases how to use the supported queries here.](https://raw.github.com/balupton/query-engine.npm/master/test/query-engine.coffee)

[You can try it out in real-time on the client side with a web browser here.](http://balupton.github.com/query-engine.npm/demo/)



## Installation

- Server-Side with Node.js and CoffeeScript

	1. [Install Node.js](https://github.com/balupton/node/wiki/Installing-Node.js)

	2. Install

			npm install query-engine
	
	3. Require

		``` coffeescript
		queryEngine = require 'query-engine'
		```

- Client-Side with Web Browsers

	1. [Download Query-Engine](https://github.com/balupton/query-engine.npm/zipball/master) and upload it to your webserver

	2. Include `lib/query-engine.js` inside your page

		``` html
		<script src="path/to/query-engine/lib/query-engine.js"></script>
		```
	
	3. Utilise the `window.queryEngine` namespace


## Using

- Server-Side with Node.js and CoffeeScript

	``` coffeescript
	# Collection
	documents = new queryEngine.Collection
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

- Client-Side with Web Browsers and JavaScript
	
	``` javascript
	//Collection
	var documents = new window.queryEngine.Collection({
		0: {
			title: 'abc',
			tags: ['a', 'b']
		},
		1: {
			title: 'blah',
			tags: ['a', 'b', 'c']
		}
	});

	// Query
	documents.find({
		tags: {
			$in: ['a']
		}
	}); // {0: documents.0, 1: documents.1}
	documents.find({
		title: 'blah'
	}); // {1: documents.1}
	```

- You can also extend the native object prototype so queryEngine will work for all objects (not just collections) by doing:

	``` coffeescript
	queryEngine.extendNatives()
	```


## History

- v0.5.3 November 2, 2011
	- `$in` and `$all` have had considerable improvements and fixes
	- Fixed npm web to url warnings

- v0.5.2 September 5, 2011
	- Array prototype is no longer extended by default. Introduces `queryEngine.Hash` as the extender.

- v0.5.1 August 14, 2011
	- Fixed date comparisons and added some date tests

- v0.5.0 August 13, 2011
	- Added client side demo
	- Added `queryEngine.Collection` class so it doesn't extend the object prototype by default
		- If you would like to still extend the object prototype you can call `queryEngine.extendNatives()`

- v0.4.0 August 13, 2011
	- Find will now return a ID associated object always
		- Before it was only doing it when the object we were finding was an ID associated object
	- Now supports `$and`, `$or` and `$nor`, as well as `$type`

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
