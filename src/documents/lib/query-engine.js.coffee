# Requires
Backbone = @Backbone or (try require?('backbone')) or (try require?('exoskeleton')) or null

# Util
# Contains our utility functions
util =

	# ---------------------------------
	# Types, from bal-util: https://github.com/balupton/bal-util
	# We use these instead of the underscore versions, as sometimes the underscore versions lie!

	# Is an item a string
	toString: (value) ->
		return Object::toString.call(value)

	# Checks to see if a value is an object and only an object
	isPlainObject: (value) ->
		return util.isObject(value) and value.__proto__ is Object.prototype

	# Checks to see if a value is an object
	isObject: (value) ->
		# null and undefined are objects, hence the truthy check
		return value and typeof value is 'object'

	# Checks to see if a value is an error
	isError: (value) ->
		return value instanceof Error

	# Checks to see if a value is a date
	isDate: (value) ->
		return util.toString(value) is '[object Date]'

	# Checks to see if a value is an arguments object
	isArguments: (value) ->
		return util.toString(value) is '[object Arguments]'

	# Checks to see if a value is a function
	isFunction: (value) ->
		return util.toString(value) is '[object Function]'

	# Checks to see if a value is an regex
	isRegExp: (value) ->
		return util.toString(value) is '[object RegExp]'

	# Checks to see if a value is an array
	isArray: (value) ->
		if Array.isArray?
			return Array.isArray(value)
		else
			return util.toString(value) is '[object Array]'

	# Checks to see if a value is a number
	isNumber: (value) ->
		return typeof value is 'number' or util.toString(value) is '[object Number]'

	# Checks to see if a value is a string
	isString: (value) ->
		return typeof value is 'string' or util.toString(value) is '[object String]'

	# Checks to see if a value is a boolean
	isBoolean: (value) ->
		return value is true or value is false or util.toString(value) is '[object Boolean]'

	# Checks to see if a value is null
	isNull: (value) ->
		return value is null

	# Checks to see if a value is undefined
	isUndefined: (value) ->
		return typeof value is 'undefined'

	# Checks to see if a value is defined
	isDefined: (value) ->
		return typeof value isnt 'undefined'

	# Checks to see if a value is empty
	isEmpty: (value) ->
		return value?

	# Checks to see if an objectvalue is empty
	isObjectEmpty: (object) ->
		empty = true
		for own key,value of object
			empty = false
			break
		return empty

	# Checks to see if the value is comparable (date or number)
	isComparable: (value) ->
		return util.isNumber(value) or util.isDate(value)



	# ---------------------------------
	# Helpers

	# Is Equal
	isEqual: (value1,value2) ->
		return JSON.stringify(value1) is JSON.stringify(value2)

	# Clone
	clone: (args...) ->
		return util.shallowExtendPlainObjects({}, args...)

	# Extend
	# Alias for Shallow Extend
	extend: (args...) ->
		return util.shallowExtendPlainObjects(args...)

	# Shallow extend plain objects
	shallowExtendPlainObjects: (target,objs...) ->
		for obj in objs
			obj or= {}
			for own key,value of obj
				target[key] = value
		return target

	# Get
	get: (obj,key) ->
		if obj.get?
			result = obj.get(key)
		else
			result = obj[key]
		return result

	# Safe Regex
	# Santitize a string for the use inside a regular expression
	safeRegex: (str) ->
		if str is false
			return 'false'
		else if str is true
			return 'true'
		else if str is null
			return 'null'
		else
			return (str or '').replace('(.)','\\$1')

	# Create Regex
	# Convert a string into a regular expression
	createRegex: (str) ->
		return new RegExp(str,'ig')

	# Create Safe Regex
	# Convert a string into a safe regular expression
	createSafeRegex: (str) ->
		return util.createRegex util.safeRegex(str)

	# To Array
	toArray: (value) ->
		# Prepare
		result = []

		# Determine the correct type
		valueExists = typeof value isnt 'undefined'
		if valueExists
			if util.isArray(value)
				result = value.slice()
			else if util.isObject(value)
				for own key,item of value
					result.push(item)
			else
				result.push(value)

		# Return the result
		result

	# To Array Group
	toArrayGroup: (value) ->
		# Prepare
		result = []

		# Determine the correct type
		valueExists = typeof value isnt 'undefined'
		if valueExists
			if util.isArray(value)
				result = value.slice()
			else if util.isObject(value)
				for own key,item of value
					obj = {}
					obj[key] = item
					result.push(obj)
			else
				result.push(value)

		# Return the result
		result

	# Generate Comparator
	generateComparator: (input) ->
		# Creates a function for a comparator
		generateFunction = (comparator) ->
			unless comparator
				return null
			else if util.isFunction(comparator)
				return comparator
			else if util.isArray(comparator)
				return (a,b) ->
					comparison = 0
					for value,key in comparator
						comparison = generateFunction(value)(a,b)
						return comparison  if comparison
					# Return likey 0
					return comparison
			else if util.isObject(comparator)
				return (a,b) ->
					comparison = 0
					for own key,value of comparator
						# Prepare
						aValue = util.get(a,key)
						bValue = util.get(b,key)
						# Compare
						if aValue is bValue
							comparison = 0
						else if aValue < bValue
							comparison = -1
						else if aValue > bValue
							comparison = 1
						# If descending, flip the comparison
						if value is -1
							comparison *= -1
						# Return early if we have something
						return comparison  if comparison
					# Return likey 0
					return comparison
			else
				throw new Error('Unknown comparator type')

		# Return the generated function for our comparator
		return generateFunction(input)


# Hash
# Extends the Array class with:
# - the ability to convert anything to an array
# - the hasIn function
# - the hasAll function
class Hash extends Array
	# Constructor
	constructor: (value) ->
		value = util.toArray(value)
		for item,key in value
			@push(item)

	# Has In
	# Check if the option exists within us
	hasIn: (options) ->
		options = util.toArray(options)
		for value in @
			if value in options
				return true
		return false

	# Has All
	# Check if all the options exist within us
	hasAll: (options) ->
		# Prepare
		options = util.toArray(options)
		empty = true
		pass = true

		# Perform the check
		for value in @
			empty = false
			unless value in options
				pass = false

		# Fail if we are empty
		pass = false  if empty

		# Return whether we passed or not
		return pass

	# Is Same
	# Check if our values are the same as the options
	isSame: (options) ->
		# Prepare
		options = util.toArray(options)

		# Check
		pass = @sort().join() is options.sort().join()

		# Return whether we passed or not
		return pass



# Query Collection
# Creates a Collection that Supports Querying
# Options:
# - filters: a hash of filter functions
# - queries: a hash of query instances or query objects
# - pills: a hash of pill instances or pill objects
# - parentCollection: a backbone.js collection to be used as the parent
# - live: whether or not to automaticaly perform retests when events fire
unless Backbone? then QueryCollection = null else \
class QueryCollection extends Backbone.Collection
	# Model
	# The model that this query engine supports
	model: Backbone.Model

	# Constructor
	initialize: (models,options) ->
		# Prepare
		me = @
		@options ?= {}

		# Proxy Criteria
		for own key,value of Criteria::
			@[key] ?= value

		# Comparator
		@setComparator(@comparator)  if @comparator?
		# @options.comparator is shortcutted here by Backbone

		# Criteria
		@applyCriteriaOptions(options)

		# Options
		if options?
			# Parent Collection
			@options.parentCollection = options.parentCollection  if options.parentCollection?

			# Live
			@options.live = options.live  if options.live?
			@live()

		# Chain
		@


	# ---------------------------------
	# Comparator: Getters and Setters

	# Get Comparator
	getComparator: ->
		return @comparator

	# Set Comparator
	setComparator: (comparator) ->
		# Prepare comparator
		comparator = util.generateComparator(comparator)

		# Apply it
		@comparator = comparator

		# Chain
		@

	# ---------------------------------
	# Parent Collection: Getters and Setters

	# Create Child Collection
	createChildCollection: (models,options) ->
		options or= {}
		options.parentCollection = @
		options.collection ?= @collection or QueryCollection
		options.comparator ?= options.collection::comparator or @comparator
		collection = new (options.collection)(models,options)
		return collection

	# Create Live Child Collection
	createLiveChildCollection: (models,options) ->
		options or= {}
		options.live = true
		collection = @createChildCollection(models,options)
		return collection

	# Has Parent Collection
	hasParentCollection: ->
		@options.parentCollection?

	# Get Parent Collection
	getParentCollection: ->
		@options.parentCollection

	# Set Parent Collection
	setParentCollection: (parentCollection,skipCheck) ->
		# Check
		if !skipCheck and @options.parentCollection is parentCollection
			return @ # nothing to do

		# Apply
		@options.parentCollection = parentCollection

		# Live
		@live()

		# Chain
		@


	# ---------------------------------
	# Helpers
	# Used to assist our other functions

	# Has Model
	# Does this model exist within our collection?
	hasModel: (model) ->
		# Prepare
		model or= {}

		# As of Backbone v0.9.9 @get covers both .id and .cid
		# however as we want to maintain support for v0.9.2 we must do this

		# Check by the model's id
		if model.id? and @get(model.id)
			exists = true
		# Check by the model's cid
		# Use the old v0.9.2 @_byCid method or if that doesn't work use the new v0.9.9 @get method
		else if model.cid? and (@_byCid?[model.cid] ? @get(model.cid))
			exists = true
		# Otherwise fail
		else
			exists = false

		# Return exists
		return exists

	# Safe Remove
	# Remove an item from the collection, only if it exists within the collection
	# Useful for bypassing the "already exists" warning
	safeRemove: (model) ->
		exists = @hasModel(model)
		if exists
			this.remove(model)
		@

	# Safe Add
	# Add an item from the collection, only if it doesn't exist within the collection
	# Useful for bypassing the "already exists" warning
	safeAdd: (model) ->
		exists = @hasModel(model)
		unless exists
			this.add(model)
		@


	# ---------------------------------
	# Sorting and Paging

	# Sort Collection
	# Sorts our current collection by our comparator
	sortCollection: (comparator) ->
		# Sort our collection
		if comparator
			comparator = util.generateComparator(comparator)
			@models.sort(comparator)
		else
			comparator = @getComparator()
			if comparator
				@models.sort(comparator)
			else
				throw new Error('You need a comparator to sort')

		# Chain
		return @

	# Sort Array
	# Return the results as an array sorted by our comparator
	sortArray: (comparator) ->
		# Prepare
		arr = @toJSON()

		# Sort our collection
		if comparator
			comparator = util.generateComparator(comparator)
			arr.sort(comparator)
		else
			comparator = @getComparator()
			if comparator
				arr.sort(comparator)
			else
				throw new Error('You need a comparator to sort')

		# Return sorted array
		return arr

	# Find All
	# args = criteriaInstance
	# args = query, comparator, paging
	findAll: (args...) ->
		# Extract
		if args.length
			if args.length is 1 and args[0] instanceof Criteria
				criteriaOptions = args[0].options
			else
				[query,comparator,paging] = args
				criteriaOptions = {comparator, paging, queries:find:query}
		else
			criteriaOptions = null

		# Create child collection
		collection = @createChildCollection([],criteriaOptions).query()

		# Return
		return collection

	# Find All Live
	# args = criteriaInstance
	# args = query, comparator, paging
	findAllLive: (args...) ->
		# Extract
		if args.length
			if args.length is 1 and args[0] instanceof Criteria
				criteriaOptions = args[0].options
			else
				[query,comparator,paging] = args
				criteriaOptions = {comparator, paging, queries:find:query}
		else
			criteriaOptions = null

		# Create child collection
		collection = @createLiveChildCollection([],criteriaOptions).query()

		# Return
		return collection

	# Find One
	# args = criteriaInstance
	# args = query, comparator, paging
	findOne: (args...) ->
		# Extract
		if args.length
			if args.length is 1 and args[0] instanceof Criteria
				criteriaOptions = args[0].options
			else
				[query,comparator,paging] = args
				criteriaOptions = {comparator, paging, queries:find:query}
		else
			criteriaOptions = null

		# Test
		# We use testModels here instead of queryModels
		# as queryModels will use the parent collection if it exists
		# where we just want to use this collection
		passed = @testModels(@models,criteriaOptions)

		# Return
		if passed?.length isnt 0
			return passed[0]
		else
			return null

	# Query
	# Reset our collection with the models that passed our criteria
	# args = criteriaInstance
	# args = paging
	query: (args...) ->
		# Prepare
		if args.length is 1
			if args[0] instanceof Criteria
				criteria = args[0].options
			else
				criteria = {paging:args[0]}

		# Test
		passed = @queryModels(criteria)

		# Reset
		@reset(passed)

		# Chain
		@

	# Query
	# Return an array of mdoels that passed our criteria
	# args = criteriaInstance
	# args = criteriaOptions
	# args = query, comparator, paging
	queryModels: (args...) ->
		# Extract
		criteriaOptions = @extractCriteriaOptions(args...)

		# Test
		collection = @getParentCollection() or @
		models = collection.models
		passed = @testModels(models,criteriaOptions)

		# Return
		return passed

	# Query Array
	# Return an array of JSON'ified models that passed our criteria
	# args = criteriaInstance
	# args = criteriaOptions
	# args = query, comparator, paging
	queryArray: (args...) ->
		# Prepare
		result = []

		# Fetch
		passed = @queryModels(args...)
		for model in passed
			result.push(model.toJSON())

		# Return
		return result


	# ---------------------------------
	# Live Functionality
	# Used so we can live update the collection when modifications are made to our collection

	# Live
	live: (enabled) ->
		# Prepare
		enabled ?= @options.live

		# Save live mode
		@options.live = enabled

		# Subscribe to change events on our existing models
		if enabled
			@on('change',@onChange)
			# onChange will do our resort
			# we do not need a onAdd for our resort, as backbone already does this
		else
			@off('change',@onChange)

		# Subscribe the live events on our parent collection (if we have one)
		parentCollection = @getParentCollection()
		if parentCollection?
			if enabled
				parentCollection.on('change',  @onParentChange)
				parentCollection.on('remove',  @onParentRemove)
				parentCollection.on('add',     @onParentAdd)
				parentCollection.on('reset',   @onParentReset)
			else
				parentCollection.off('change', @onParentChange)
				parentCollection.off('remove', @onParentRemove)
				parentCollection.off('add',    @onParentAdd)
				parentCollection.off('reset',  @onParentReset)

		# Chain
		@

	# Fired when we want to add some models to our own collection
	# We should check if the models pass our tests, if so then we add them
	add: (models, options) ->
		# Prepare
		options = if options then util.clone(options) else {}
		models = if util.isArray(models) then models.slice() else [models]
		passedModels = []

		# Cycle through the models
		for model in models
			# Ensure we have a model
			model = @_prepareModel(model,options)

			# Only add passed models
			if model and @test(model)
				passedModels.push(model)

		# Add the passed models
		Backbone.Collection::add.apply(@,[passedModels,options])

		# Chain
		@

	# Fired when we want to create a model
	# We should check if the model passes our tests, if so then we add them
	create: (model, options) ->
		# Prepare
		options = if options then util.clone(options) else {}
		model = @_prepareModel(model,options)

		# Check
		if model and @test(model)
			# It passed, so create the model
			Backbone.Collection::create.apply(@,[model,options])

		# Chain
		@

	# Fired when a model that is inside our own collection changes
	# We should check if it still passes our tests
	# and if it doesn't then we should remove the model
	# We should perform a resort
	onChange: (model) =>
		return @query()  if @getPaging()
		pass = @test(model)
		unless pass
			@safeRemove(model)
		else
			@sortCollection()  if @comparator
		@

	# Fired when a model in our parent collection changes
	# We should check if the model now passes our own tests, and if so add it to our own
	# and if it doesn't then we should remove the model from our own
	onParentChange: (model) =>
		return @query()  if @getPaging()
		pass = @test(model) and @getParentCollection().hasModel(model)
		if pass
			@safeAdd(model)
		else
			@safeRemove(model)
		@

	# Fired when a model in our parent collection is removed
	# We should remove it straight away from our own model
	onParentRemove: (model) =>
		return @query()  if @getPaging()
		@safeRemove(model)
		@

	# Fired when a model in our parent collection is added
	# We should try and add it to our own collection
	# Try as in, it will call _prepareModel and the tests happen there
	onParentAdd: (model) =>
		return @query()  if @getPaging()
		@safeAdd(model)
		@

	# Fired when our parent collection is reset
	# We should reset our own collection when this happens with the parent collection's models
	# For each model, it will trigger _prepareModel which will check if the model passes our tests
	onParentReset: (model) =>
		@reset(@getParentCollection().models)
		@



# =================================
# Criteria

class Criteria
	# Constructor
	constructor: (args...) ->
		# Apply Options
		@applyCriteriaOptions(args...)

		# Chain
		@

	# Extract Criteria Options
	# args = query, comparator, paging?
	# args = criteriaOptions
	# args = criteriaInstance
	extractCriteriaOptions: (args...) ->
		# Prepare
		if args.length is 1
			if args[0] instanceof Criteria
				criteriaOptions = args[0].options
			else if args[0]
				criteriaOptions = args[0]
			else
				criteriaOptions = null
		else if args.length > 1
			[query,comparator,paging] = args
			criteriaOptions = {
				queries: find: query or null
				comparator
				paging
			}
		else
			criteriaOptions = null

		# Return
		return criteriaOptions

	# Apply Criteria Options
	applyCriteriaOptions: (args...) =>
		# Prepare
		@options ?= {}
		@options.filters ?= {}
		@options.queries ?= {}
		@options.pills ?= {}
		@options.paging ?= null
		@options.searchString ?= null
		@options.comparator ?= null

		# Extract
		criteriaOptions = @extractCriteriaOptions(args...)

		# Apply
		if criteriaOptions
			@setFilters(criteriaOptions.filters)            if criteriaOptions.filters?
			@setQueries(criteriaOptions.queries)            if criteriaOptions.queries?
			@setPills(criteriaOptions.pills)                if criteriaOptions.pills?
			@setPaging(criteriaOptions.paging)              if criteriaOptions.paging?
			@setSearchString(criteriaOptions.searchString)  if criteriaOptions.searchString?
			@setComparator(criteriaOptions.comparator)      if criteriaOptions.comparator?

		# Chain
		@

	# ---------------------------------
	# Paging: Getters and Setters

	# Get Paging
	getPaging: ->
		return @options.paging

	# Set Paging
	setPaging: (paging) ->
		# Prepare
		paging = util.extend(@getPaging() or {}, paging or {})
		paging.page or= null
		paging.limit or= null
		paging.offset or= null

		# Apply paging
		if paging.page or paging.limit or paging.offset
			@options.paging = paging
		else
			@options.paging = null

		# Chain
		@


	# ---------------------------------
	# Comparator: Getters and Setters

	# Get Comparator
	getComparator: ->
		return @options.comparator

	# Set Comparator
	setComparator: (comparator) ->
		# Prepare comparator
		comparator = util.generateComparator(comparator)

		# Apply it
		@options.comparator = comparator

		# Chain
		@


	# ---------------------------------
	# Filters: Getters and Setters

	# Get Filters
	getFilter: (key) ->
		@options.filters[key]

	# Get Filters
	getFilters: ->
		@options.filters

	# Set Filters
	setFilters: (filters) ->
		filters or= {}
		for own key,value of filters
			@setFilter(key,value)
		@

	# Set Filter
	setFilter: (name,value) ->
		# Check we have been called with both arguments
		throw new Error('QueryCollection::setFilter was called without both arguments')  if typeof value is 'undefined'

		# Prepare
		filters = @options.filters

		# Apply or delete the value
		if value?
			filters[name] = value
		else if filters[name]?
			delete filters[name]

		# Chain
		@


	# ---------------------------------
	# Queries: Getters and Setters

	# Get Query
	getQuery: (key) ->
		@options.queries[key]

	# Get Queries
	getQueries: ->
		@options.queries

	# Set Queries
	setQueries: (queries) ->
		queries or= {}
		for own key,value of queries
			@setQuery(key,value)
		@

	# Set Query
	setQuery: (name,value) ->
		# Check we have been called with both arguments
		throw new Error('QueryCollection::setQuery was called without both arguments')  if typeof value is 'undefined'

		# Prepare
		queries = @options.queries

		# Apply or delete the value
		if value?
			unless value instanceof Query
				value = new Query(value)
			queries[name] = value
		else if queries[name]?
			delete queries[name]

		# Chain
		@


	# ---------------------------------
	# Pills: Getters and Setters

	# Get Pill
	getPill: (key) ->
		@options.pills[key]

	# Get Pills
	getPills: ->
		@options.pills

	# Set Pills
	setPills: (pills) ->
		pills or= {}
		for own key,value of pills
			@setPill(key,value)
		@

	# Set Pill
	setPill: (name,value) ->
		# Check we have been called with both arguments
		throw new Error('QueryCollection::setPill was called without both arguments')  if typeof value is 'undefined'

		# Prepare
		pills = @getPills()
		searchString = @getSearchString()

		# Apply or delete the value
		if value?
			unless value instanceof Pill
				value = new Pill(value)
			if searchString
				value.setSearchString(searchString)
			pills[name] = value
		else if pills[name]?
			delete pills[name]

		# Chain
		@


	# ---------------------------------
	# Search String: Getters and Setters

	# Get Cleaned Search String
	getCleanedSearchString: ->
		@options.cleanedSearchString

	# Get Search String
	getSearchString: ->
		@options.searchString

	# Set Search String
	setSearchString: (searchString) ->
		# Prepare
		pills = @options.pills
		cleanedSearchString = searchString

		# Apply the search string to each of our pills
		# and for each applicable pill, clean up our search string
		for own pillName,pill of pills
			cleanedSearchString = pill.setSearchString(cleanedSearchString)

		# Apply
		@options.searchString = searchString
		@options.cleanedSearchString = cleanedSearchString

		# Chain
		@


	# ---------------------------------
	# Testing

	# Test Model
	test: (args...) -> return @testModel(args...)
	testModel: (model,criteriaOptions={}) ->
		# Test
		passed = @testQueries(model,criteriaOptions.queries) and @testFilters(model,criteriaOptions.filters) and @testPills(model,criteriaOptions.pills)

		# Return
		return passed

	# Test Models
	testModels: (models,criteriaOptions={}) ->
		# Prepare
		me = @
		passed = []
		{paging,comparator} = criteriaOptions

		# Extract
		paging ?= @getPaging()

		# Comparator
		if comparator?
			if comparator
				comparator = util.generateComparator(comparator)
		else
			comparator = @getComparator()

		# Cycle through the parent collection finding passing models
		for model in models
			pass = me.testModel(model,criteriaOptions)
			passed.push(model)  if pass

		# Sort
		if comparator
			passed.sort(comparator)

		# Page our models
		if paging
			start = paging.offset or 0
			if paging.limit? and paging.limit > 0
				start = start + paging.limit * ((paging.page or 1) - 1)
				finish = start + paging.limit
				passed = passed[start...finish]
			else if start
				passed = passed[start..]

		# Return
		return passed

	# Perform the Queries against a Model
	# Queries work in allow-all, deny by exeception way
	# So if there are no queries, everything should pass
	# If there is one failed query however, it should fail
	testQueries: (model,queries) ->
		# Prepare
		passed = true
		queries ?= @getQueries()

		# Cycle
		if queries then \
		for own queryName,query of queries
			unless query instanceof Query
				query = new Query(query)
				queries[queryName] = query
			if query.test(model) is false
				passed = false
				return false # break

		# Return result
		return passed

	# Perform the Filters against a Model
	# Filters work in allow-all, deny by exeception way
	# So if there are no queries, everything should pass
	# If there is one failed query however, it should fail
	testFilters: (model,filters) ->
		# Prepare
		passed = true
		cleanedSearchString = @getCleanedSearchString()
		filters ?= @getFilters()

		# Cycle
		if filters then \
		for own filterName,filter of filters
			if filter(model,cleanedSearchString) is false
				passed = false
				return false # break

		# Return result
		return passed

	# Perform the Pills against a Model
	# Pills work in allow-all, deny by exeception way
	# So if there are no queries, everything should pass
	# If there is one failed query however, it should fail
	testPills: (model,pills) ->
		# Prepare
		passed = true
		searchString = @getSearchString()
		pills ?= @getPills()

		# Cycle
		if searchString? and pills
			for own pillName,pill of pills
				unless pill instanceof Pill
					pill = new Pill(query)
					pill.setSearchString(searchString)
					pills[pillName] = pill
				if pill.test(model) is false
					passed = false
					return false # break

		# Return result
		return passed


# Pill
# Provides the ability to perform pill based searches, e.g.
# Searching for "user:ben" will search for the key user, and value ben
# Pills must be coded manually, as otherwise that could be a security problem
class Pill
	# Callback
	# Our pills criteria function
	callback: null # Function

	# Regex
	# Our pills regex that we will use to extract the values
	regex: null # RegExp

	# Prefixes
	# The prefixes that our pill matches
	prefixes: null # Array

	# Search String
	# The search string that we are comparing against
	searchString: null # String

	# Value
	# The discovered values of the pill within the search
	values: null # Array of Strings

	# Logical Operator
	# If this pill exists multiple times in our search string, this the style of combination to use
	logicalOperator: 'OR'

	# Constructor
	# Construct our regular expression and apply our properties
	constructor: (pill) ->
		# Apply
		pill or= {}
		@callback = pill.callback
		@prefixes = pill.prefixes
		@logicalOperator = pill.logicalOperator  if pill.logicalOperator?

		# Sanitize the prefixes
		safePrefixes = []
		for prefix in @prefixes
			safePrefixes.push util.safeRegex(prefix)

		# Build the regular expression used to match the pill
		safePrefixesStr = safePrefixes.join('|')
		regexString = """(#{safePrefixesStr})\\s*('[^']+'|\\"[^\\"]+\\"|[^'\\"\\s]\\S*)"""

		# Apply the regular expression
		@regex = util.createRegex(regexString)

		# Chain
		@

	# Set Search String
	# Apply the search string to the pill, and extract our value
	# Returns the cleaned search string
	setSearchString: (searchString) ->
		# Prepare
		cleanedSearchString = searchString
		values = []

		# Extract information
		while match = @regex.exec(searchString)
			value = match[2].trim().replace(/(^['"]\s*|\s*['"]$)/g, '')
			switch value
				when 'true','TRUE'
					value = true
				when 'false','FALSE'
					value = false
				when 'null','NULL'
					value = null
			values.push(value)
			cleanedSearchString = cleanedSearchString.replace(match[0],'').trim()

		# Apply
		@searchString = searchString
		@values = values

		# Return cleaned search
		return cleanedSearchString

	# Test
	# Test our pill against our discovered values
	# Returns whether our pill passed or not
	test: (model) ->
		# Prepare

		# Extract the pill information from the query
		if @values?.length
			if @logicalOperator is 'OR'
				pass = false
				for value in @values
					pass = @callback(model,value)
					break  if pass
			else if @logicalOperator is 'AND'
				pass = false
				for value in @values
					pass = @callback(model,value)
					break  unless pass
			else
				throw new Error('Unkown logical operator type')
		else
			pass = null

		# Return
		return pass


# Query
# A NoSQL type query wrapper
# http://www.mongodb.org/display/DOCS/Advanced+Queries
class Query
	# Source Query
	source: null

	# Compiled Selectors
	compiledSelectors: null

	# Selectors
	selectors:
		# The $or operator lets you use a boolean or expression to do queries. You give $or a list of expressions, any of which can satisfy the query.
		'$or':
			compile: (opts) ->
				# Prepare
				queries = []
				queryGroup = util.toArrayGroup(opts.selectorValue)
				unless queryGroup.length then throw new Error("Query called with an empty #{selectorName} statement")
				# Match if at least one item passes
				for querySource in queryGroup
					query = new Query(querySource)
					queries.push(query)
				# Return
				return {queries}
			test: (opts) ->
				for query in opts.queries
					if query.test(opts.model)
						return true
				return false

		# The $nor operator is the opposite of $or (pass if they all don't match the query)
		'$nor':
			compile: (opts) ->
				return opts.selector('$or',opts)
			test: (opts) ->
				return !opts.selector('$or',opts)

		# The $and operator lets you use boolean and in a query. You give $and an array of expressions, all of which must match to satisfy the query.
		'$and':
			compile: (opts) ->
				return opts.selector('$or',opts)
			test: (opts) ->
				for query in opts.queries
					if query.test(opts.model) is false
						return false
				return true
		# The $not operator is the opposite of $and (pass if only one doesn't match the query)
		'$not':
			compile: (opts) ->
				return opts.selector('$and',opts)
			test: (opts) ->
				return !opts.selector('$and',opts)


		# Types
		'string':
			test: (opts) ->
				return opts.modelValueExists and opts.modelValue is opts.selectorValue
		'number':
			test: (opts) ->
				return opts.selector('string',opts)
		'boolean':
			test: (opts) ->
				return opts.selector('string',opts)
		'array':
			test: (opts) ->
				return opts.modelValueExists and (new Hash opts.modelValue).isSame(opts.selectorValue)
		'date':
			test: (opts) ->
				return opts.modelValueExists and opts.modelValue.toString() is opts.selectorValue.toString()
		'regexp':
			test: (opts) ->
				return opts.modelValueExists and opts.selectorValue.test(opts.modelValue)
		'null':
			test: (opts) ->
				return opts.modelValue is opts.selectorValue
		'model':
			test: (opts) ->
				return (opts.modelValue?.cid or opts.modelValue) is (opts.selectorValue?.cid or opts.selectorValue)
		'collection':
			test: (opts) ->
				return opts.modelValue is opts.selectorValue

		# The $beginsWith operator checks if the value begins with a particular value or values if an array was passed
		'$beginsWith':
			test: (opts) ->
				if opts.selectorValue and opts.modelValueExists and util.isString(opts.modelValue)
					beginsWithParts = util.toArray(opts.selectorValue)
					for beginsWithValue in beginsWithParts
						if opts.modelValue.substr(0,beginsWithValue.length) is beginsWithValue
							return true
							break
				return false
		'$startsWith':
			test: (opts) ->
				return opts.selector('$beginsWith',opts)

		# The $endsWith operator checks if the value ends with a particular value or values if an array was passed
		'$endsWith':
			test: (opts) ->
				if opts.selectorValue and opts.modelValueExists and util.isString(opts.modelValue)
					endsWithParts = util.toArray(opts.selectorValue)
					for endsWithValue in endsWithParts
						if opts.modelValue.substr(endsWithValue.length*-1) is endsWithValue
							return true
							break
				return false
		'$finishesWith':
			test: (opts) ->
				return opts.selector('$endsWith',opts)

		# The $all operator is similar to $in, but instead of matching any value in the specified array all values in the array must be matched.
		'$all':
			test: (opts) ->
				if opts.selectorValue? and opts.modelValueExists
					if (new Hash opts.modelValue).hasAll(opts.selectorValue)
						return true
				return false

		# The $in operator is analogous to the SQL IN modifier, allowing you to specify an array of possible matches.
		# The target field's value can also be an array; if so then the document matches if any of the elements of the array's value matches any of the $in field's values
		'$in':
			test: (opts) ->
				if opts.selectorValue? and opts.modelValueExists
					if (new Hash opts.modelValue).hasIn(opts.selectorValue) or (new Hash opts.selectorValue).hasIn(opts.modelValue)
						return true
				return false

		# The $nin operator is similar to $in except that it selects objects for which the specified field does not have any value in the specified array.
		'$nin':
			test: (opts) ->
				if opts.selectorValue? and opts.modelValueExists
					if (new Hash opts.modelValue).hasIn(opts.selectorValue) is false and (new Hash opts.selectorValue).hasIn(opts.modelValue) is false
						return true
				return false

		# Query-Engine Specific
		# The $has operator checks if any of the selectorValue values exist within our opts.model's value
		'$has':
			test: (opts) ->
				if opts.modelValueExists
					if (new Hash opts.modelValue).hasIn(opts.selectorValue)
						return true
				return false

		# Query-Engine Specific
		# The $hasAll operator checks if all of the selectorValue values exist within our opts.model's value
		'$hasAll':
			test: (opts) ->
				if opts.modelValueExists
					if (new Hash opts.modelValue).hasIn(opts.selectorValue)
						return true
				return false

		# The $size operator matches any array with the specified number of elements. The following example would match the object {a:["foo"]}, since that array has just one element:
		'$size':
			test: (opts) ->
				if opts.modelValue.length?
					if opts.modelValue.length is opts.selectorValue
						return true
				return false
		'$length':
			test: (opts) ->
				return opts.selector('$size',opts)

		# The $type operator matches values based on their BSON type.
		'$type':
			test: (opts) ->
				if typeof opts.modelValue is opts.selectorValue
					return true
				return false

		# Query-Engine Specific
		# The $like operator checks if selectorValue string exists within the opts.modelValue string (case insensitive)
		'$like':
			test: (opts) ->
				if util.isString(opts.modelValue) and opts.modelValue.toLowerCase().indexOf(opts.selectorValue.toLowerCase()) isnt -1
					return true
				return false

		# Query-Engine Specific
		# The $likeSensitive operator checks if selectorValue string exists within the opts.modelValue string (case sensitive)
		'$likeSensitive':
			test: (opts) ->
				if util.isString(opts.modelValue) and opts.modelValue.indexOf(opts.selectorValue) isnt -1
					return true
				return false

		# Check for existence (or lack thereof) of a field.
		'$exists':
			test: (opts) ->
				if opts.selectorValue is opts.modelValueExists
					return true
				return false

		# The $mod operator allows you to do fast modulo queries to replace a common case for where clauses.
		'$mod':
			test: (opts) ->
				if opts.modelValueExists
					$mod = opts.selectorValue
					$mod = [$mod]  unless util.isArray($mod)
					$mod.push(0)  if $mod.length is 1
					if (opts.modelValue % $mod[0]) is $mod[1]
						return true
				return false

		# Query-Engine Specific
		# Use $eq for deep equals
		'$eq':
			test: (opts) ->
				if util.isEqual(opts.modelValue,opts.selectorValue)
					return true
				return false
		'$equal':
			test: (opts) ->
				return opts.selector('$eq',opts)

		# Use $ne for "not equals".
		'$ne':
			test: (opts) ->
				if opts.modelValue isnt opts.selectorValue
					return true
				return false

		# less than
		'$lt':
			test: (opts) ->
				if opts.selectorValue? and util.isComparable(opts.modelValue) and opts.modelValue < opts.selectorValue
					return true
				return false

		# greater than
		'$gt':
			test: (opts) ->
				if opts.selectorValue? and util.isComparable(opts.modelValue) and opts.modelValue > opts.selectorValue
					return true
				return false

		# Query-Engine Specific
		# between
		'$bt':
			test: (opts) ->
				if opts.selectorValue? and util.isComparable(opts.modelValue) and opts.selectorValue[0] < opts.modelValue and opts.modelValue < opts.selectorValue[1]
					return true
				return false

		# less than or equal to
		'$lte':
			test: (opts) ->
				if opts.selectorValue? and util.isComparable(opts.modelValue) and opts.modelValue <= opts.selectorValue
					return true
				return false

		# greater than or equal to
		'$gte':
			test: (opts) ->
				if opts.selectorValue? and util.isComparable(opts.modelValue) and opts.modelValue >= opts.selectorValue
					return true
				return false

		# Query-Engine Specific
		# between or equal to
		'$bte':
			test: (opts) ->
				if opts.selectorValue? and util.isComparable(opts.modelValue) and opts.selectorValue[0] <= opts.modelValue and opts.modelValue <= opts.selectorValue[1]
					return true
				return false

	# Constructor
	constructor: (source={}) ->
		# Apply
		@source = source
		@compileQuery()

	# Compile Selector
	compileSelector: (selectorName,selectorOpts={}) ->
		# Prepare
		query = @
		selectors = @selectors
		opts = {selectorName}

		# Fetch selector
		selector = selectors[selectorName]
		throw new Error("Couldn't find the selector #{selectorName}")  unless selector

		# Add selector opts
		opts[key] = value  for own key,value of selectorOpts

		# We hav ea compile step, use that
		if selector.compile?
			# Add the selector helper
			opts.selector = (selectorName,opts) ->
				return selectors[selectorName].compile(opts)
			# Add compile opts
			compileOpts = selector.compile(opts)
			opts[key] = value  for own key,value of compileOpts

		# Add the selector helper
		opts.selector = (selectorName,opts) ->
			return selectors[selectorName].test(opts)

		# Add the selector with its compiled opts
		compiledSelector =
			opts: opts
			test: selector.test

		# return
		return compiledSelector

	# Test Compiled Selector
	testCompiledSelector: (compiledSelector, model) ->
		# Prepare
		opts = compiledSelector.opts
		test = compiledSelector.test

		# Add model opts
		opts.model = model
		opts.modelValue = util.get(opts.model, opts.fieldName)
		opts.modelId = util.get(opts.model, 'id')
		opts.modelValueExists = typeof opts.modelValue isnt 'undefined'
		opts.modelValue = false  unless opts.modelValueExists

		# Fire selector
		match = test(opts)

		# Return
		return match

	# Compile Query
	# Transform the query into a series of compiled selectors
	compileQuery: ->
		# Prepare
		query = @
		compiledSelectors = []

		# Selectors
		for own fieldName, selectorValue of @source

			# Advanced Selectors
			if fieldName in ['$or','$nor','$and','$not']
				compiledSelector = @compileSelector(fieldName,{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# String
			else if util.isString(selectorValue)
				compiledSelector = @compileSelector('string',{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# Number
			else if util.isNumber(selectorValue)
				compiledSelector = @compileSelector('number',{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# Boolean
			else if util.isBoolean(selectorValue)
				compiledSelector = @compileSelector('boolean',{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# Array
			else if util.isArray(selectorValue)
				compiledSelector = @compileSelector('array',{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# Date
			else if util.isDate(selectorValue)
				compiledSelector = @compileSelector('date',{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# Regular Expression
			else if util.isRegExp(selectorValue)
				compiledSelector = @compileSelector('regexp',{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# Null
			else if util.isNull(selectorValue)
				compiledSelector = @compileSelector('null',{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# Model
			else if selectorValue instanceof Backbone.Model
				compiledSelector = @compileSelector('model',{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# Collection
			else if selectorValue instanceof Backbone.Collection
				compiledSelector = @compileSelector('collection',{fieldName,selectorValue})
				compiledSelectors.push(compiledSelector)

			# Advanced Selectors
			else if util.isObject(selectorValue)
				for own advancedSelectorName,advancedSelectorValue of selectorValue
					compiledSelector = @compileSelector(advancedSelectorName,{fieldName,selectorValue:advancedSelectorValue})
					compiledSelectors.push(compiledSelector)

		# Apply
		@compiledSelectors = compiledSelectors

		# Chain
		@

	# Test
	# Test the Query
	test: (model) ->
		# Match
		match = true

		# Selectors
		for compiledSelector in @compiledSelectors
			# Test Selector
			match = @testCompiledSelector(compiledSelector, model)
			if match is false
				break

		# Return
		return match



# -------------------------------------
# Exports

# Prepare
queryEngine =
	# Aliases
	safeRegex: util.safeRegex
	createRegex: util.createRegex
	createSafeRegex: util.createSafeRegex
	generateComparator: util.generateComparator
	toArray: util.toArray
	util: util
	Backbone: Backbone
	Hash: Hash
	QueryCollection: QueryCollection
	Criteria: Criteria
	Query: Query
	Pill: Pill

	# Set a Query Selector on the Query Prototype
	# selectorHandle = string to be used for the selector (e.g. $like)
	# selectorObject = {compile?:function(opts),test:function(opts)}, opts = {fieldName,selectorName,selectorValue,model,modelId,modelValue,modelValueExists}
	setQuerySelector: (selectorHandle, selectorObject) ->
		if selectorObject?
			Query::selectors[selectorHandle] = selectorObject
		else
			delete Query::selectors[selectorHandle]
		return @

	# Test Models
	# args = criteriaInstance
	# args = criteriaOptions
	testModels: (models,args...) ->
		# Handle
		models = util.toArray(models)
		criteria = new Criteria(args...)
		result = criteria.testModels(models)
		return result

	# Create Collection
	createCollection: (models,options) ->
		models = util.toArray(models)
		collection = new QueryCollection(models,options)
		return collection

	# Create a Live Collection
	createLiveCollection: (models,options) ->
		models = util.toArray(models)
		collection = new QueryCollection(models,options).live(true)
		return collection

# Export for node.js and the browser
if module? then (module.exports = queryEngine) else (@QueryEngine = @queryEngine = queryEngine)
