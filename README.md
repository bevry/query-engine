# Query-Engine

A NoSQL (and MongoDB compliant) Query Engine coded in CoffeeScript for Server-Side use with Node.js and Client-Side use with Web-Browsers


## Supported Queries

Query-Engine supports the exact same queries as [MongoDb](http://www.mongodb.org/). [Find the full listing of supported queries here](http://www.mongodb.org/display/DOCS/Advanced+Queries)

[You can find the test suite which showcases how to use the supported queries here](https://raw.github.com/balupton/query-engine.npm/master/test/query-engine.coffee)

[You can try it out in real-time on the client side with a web browser here](http://balupton.github.com/query-engine.npm/demo/)



## Installation

- Server-Side with Node.js and CoffeeScript

	1. [Install Node.js](https://github.com/balupton/node/wiki/Installing-Node.js)

	2. Install
		
		``` bash
		npm install query-engine
		```
	
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

You can discover the history inside the [History.md](https://github.com/balupton/query-engine.npm/blob/master/History.md#files) file


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
<br/>Copyright &copy; 2011-2012 [Benjamin Arthur Lupton](http://balupton.com)
