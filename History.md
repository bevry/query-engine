## History

- v1.0.0 March 14, 2012
	- Large rewrite, and backwards compatibility breaking release
	- Introduces the dependencies:
		- [Underscore.js](http://documentcloud.github.com/underscore/)
		- [Backbone.js](http://documentcloud.github.com/backbone/)
	- Introduces these features:
		- Live Collections
			- Live Collections, instead of re-querying everything when something changes, instead we test a model when it is added or changed. This means that our live collections are always in the correct state, and update dynamicly.
			- They also support binding to a parent collection
		- Queries
			- These are the v0.x NoSQL type queries
		- Filters
			- These are custom functions that will fire and test the models
		- Searching
			- You can now do text based searches against collections, the search string is passed to the filters
		- Pills
			- For text based searches we allow for the concept of pills, e.g. `user:ben status:awesome`
	- Other changes:
		- New demo page allows you to modify the actual code that performs the query, instead of just the query itself


- v0.6.0 February 11, 2012
	- Moved unit tests to [Mocha](http://visionmedia.github.com/mocha/)
	- Added [docco](http://jashkenas.github.com/docco/) docs

- v0.5.4 January 26, 2012
	- Fixed `$nin`
	- Added `$beginsWith` and `$endsWith`

- v0.5.3 November 2, 2011
	- `$in` and `$all` have had considerable improvements and fixes
	- Fixed npm web to url warnings
	- Fixed demo

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
