## History

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
