# Query-Engine

Query-Engine is a [NoSQL](http://www.mongodb.org/display/DOCS/Advanced+Queries) and [MongoDb](http://www.mongodb.org/) compliant query engine. It can run on the server-side with [Node.js](http://nodejs.org/), or on the client-side within web browsers.

[You can give Query-Engine a go inside your web browser by clicking here.](http://bevry.github.com/query-engine/demo/)



## Installation

- Server-Side with Node.js

	1. [Install Node.js](https://github.com/balupton/node/wiki/Installing-Node.js)

	2. Install
		
		``` bash
		npm install query-engine
		```
	
	3. Require

		``` javascript
		var queryEngine = require('query-engine');
		```


- Client-Side with Web Browsers

	1. Include the necessary scripts
		
		``` html
		<script src="http://documentcloud.github.com/underscore/underscore-min.js"></script>
		<script src="http://documentcloud.github.com/backbone/backbone-min.js"></script>
		<script src="http://raw.github.com/bevry/query-engine/master/lib/query-engine.js"></script>
		```
	
	2. Access Query-Engine via the `window.queryEngine` variable



## History

You can discover the history inside the [History.md](https://github.com/bevry/query-engine/blob/master/History.md#files) file



## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
<br/>Copyright &copy; 2012 [Bevry Pty Ltd](http://bevry.me)
<br/>Copyright &copy; 2011 [Benjamin Lupton](http://balupton.com)
