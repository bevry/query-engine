## History

- v1.2.7 August 10, 2012
	- Re-added markdown files to npm distribution as they are required for the npm website

- v1.2.6 July 24, 2012
	- When a pill value receives `true`, `false`, or `null` as a string we will convert it to the non-string equivalent
	- `safeRegex` will now handle the non-string values of `true`, `false` and `null` properly

- v1.2.5 July 24, 2012
	- Query Engine now handles `null` values correctly

- v1.2.4 July 23, 2012
	- Fixed trickling of change events from parent collection to child collections
		- Before if a distant parent collection had a change event that removed or added the model from that event, that change would not be reflected in a distant child collection

- v1.2.3 July 18, 2012
	- Fixed strings in some environments being split into arrays when using `$has` and `$in`

- v1.2.2 June 21, 2012
	- Added `$like`, `$likeSensitive`, `$bt`, `$bte`, `$eq`, `$mod`, and `$not` queries
	- Added paging

- v1.2.1 June 21, 2012
	- Added `QueryCollection::findAllLive(query,[comparator])` shortcut for `QueryCollection::createLiveChildCollection().setQuery('find',query).setComparator(comparator).query()`
	- `QueryCollection::findAll` and `QueryCollection::findOne` now support an optional `comparator` argument as the second argument
	- QueryEngine comparators are now supported for
		- comparators passed through options
		- comparator prototype property on your own custom `QueryCollection` instance

- v1.2.0 June 16, 2012
	- You can now pass the standard `models`, and `options` arguments to `QueryCollection::createChildCollection` and `QueryCollection::createLiveChildCollection`
	- If `options.collection` is specified when creating a child collection, it will be used as the child collectiont type
	- Restructured directories and files
	- Cleaned up demos and added two new demos: [search](http://bevry.github.com/query-engine/demo/search.html) and [visual search](http://bevry.github.com/query-engine/demo/visual-search.html)
	- Updated search string syntax to be compliant with [Visual Search's](http://documentcloud.github.com/visualsearch/) search string syntax
		- Adds support for quotes when using pills, e.g. `user:"Benjamin Lupton"`
		- Adds support for using pills of the same name multiple times, e.g. `tag:node tag:query`
			- Whether this ORs or ANDs is customisable via the pill's `logicalOperator` which can be `AND` or `OR` (defaults to `OR`)
	- Moved tests from Mocha to [Joe](https://github.com/bevry/joe)
	- Added browser tests

- v1.1.14 June 5, 2012
	- Fixed using arrays in `queryEngine.generateComparator`

- v1.1.13 May 30, 2012
	- Made the query source code a bit more readable
	- Fixed `$nor`, `$or`, and `$and` queries
		- They also now support objects (instead of just arrays) as their values
	- Added `queryEngine.toArrayGroup` which returns an array, with an array item for each key-value pair in the object

- v1.1.12 May 17, 2012
	- You can now specify the `collection` property inside your custom collection classes
		- If specified, it will be used as the class for child collections

- v1.1.11 May 17, 2012
	- We now throw errors if `QueryCollection::setFilter`, `QueryCollection::setQuery`, and `QueryCollection::setPill` are called without both arguments

- v1.1.10 May 17, 2012
	- Added sorting on change events if the collection is live
	- Fixed sorting by a value that could be 0

- v1.1.9 May 17, 2012
	- Added
		- `queryEngine.generatorComparator`
		- `QueryCollection::setComparator`
		- `QueryCollection::sortCollection`
	- When creating a child collection, the parent collection's comparator will now be copied over
	- Comparators can now be arrays of comparators too

- v1.1.8 May 15, 2012
	- Fixed boolean comparison
	- Now uses CoffeeScripts `extends` rather than `Backbone.extend`

- v1.1.6 May 8, 2012
	- Cleaned the code up a little bit
	- Aliases `$beginsWith` with `$startsWith`, and `$endsWith` with `$finishesWith`
		- Which all now support array values, e.g. `something: $beginsWith: ['a','b','c']`
	- Exposes the used Backbone.js module through `queryEngine.Backbone`
		- You should use this instead of including your own backbone module due to [this bug](https://github.com/documentcloud/backbone/issues/1288) in Backbone.js

- v1.1.4 and v1.1.5
	- Bugfixes

- v1.1.3 April 19, 2012
	- For development, we've added CoffeeScript as a `devDependency` and added `make dev` to keep the compiled Query-Engine up to date using it
	- Query-Engine for Node now includes the compiled Query-Engine code, rather than the source CoffeeScript version
		- This means you no longer have to `require('coffee-script')` just to use Query-Engine with Node
	- Thanks to [Farid Neshat](https://github.com/alFReD-NSH) for the pull requests

- v1.1.2 April 6, 2012
	- Fixed `reset` on a parent collection not triggering the appropriate handler for a live child collection
		- Thanks to [Nicholas Firth-McCoy](https://github.com/bevry/query-engine/pull/3)
	- Updated the demo with better styling and horizontal columns now instead of vertical
	- Added way more unit tests for live parent collections and live events
	- Added `createLiveChildCollection` to `QueryCollection`

- v1.1.1 April 2, 2012
	- Fixed the ability to specify filters, queries and pills via `options`
	- Fixed an issue with pills and searching

- v1.1.0 April 2, 2012
	- Upgraded Mocha to v1.0.0 from v0.14.0
	- Updated Backbone.js to 0.9.2 from 0.9.1
	- Merged `BaseCollection` and `LiveCollection` into `QueryCollection`
	- Added `live([true/false])` to `QueryCollection`
		- Use this to subscribe to events on your collection and parent collection
	- Renamed `createLiveCollection` to `createChildCollection` on `QueryCollection`
	- Renamed `find` to `findAll` on `QueryCollection` to not conflict with Backbone's find command

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
