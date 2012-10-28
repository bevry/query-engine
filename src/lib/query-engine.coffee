# Requires
_ = if module? then require('underscore') else @_
Backbone = if module? then require('backbone') else @Backbone


# Util
# Contains our utility functions
util =

	# ---------------------------------
	# Underscore Aliases

	# Is Equal
	isEqual: (value1,value2) ->
		return _.isEqual(value1,value2)


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

	# Checks to see if the value is comparable (date or number)
	isComparable: (value) ->
		return util.isNumber(value) or util.isDate(value)



	# ---------------------------------
	# Other

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
		if value
			if util.isArray(value)
				result = value
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
		if value
			if util.isArray(value)
				result = value
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
				throw new Error('Cannot sort without a comparator')
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
						aValue = a.get?(key) ? a[key]
						bValue = b.get?(key) ? b[key]
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
	# Array
	arr: []

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
class QueryCollection extends Backbone.Collection
	# Model
	# The model that this query engine supports
	model: Backbone.Model

	# Constructor
	initialize: (models,options) ->
		# Prepare
		me = @
		@options ?= {}
		_.extend(@options, options)

		# Proxy Criteria
		for own key,value of Criteria::
			@[key] ?= value

		# Comparator
		@setComparator(@comparator)  if @comparator?
		# @options.comparator is shortcutted here by Backbone

		# Criteria
		@applyCriteria(options)

		# Parent Collection
		# No need to set parent collection, as if it is an option, it has already been set

		# Live
		# Initliase live events if we use them
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

		# Check by the model's id
		if model.id? and @get(model.id)
			exists = true
		# Check by the model's cid
		else if model.cid? and @getByCid(model.cid)
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
	findAll: (args...) ->
		# Prepare
		if args.length
			if args.length is 1 and args[0] instanceof Criteria
				criteria = criteria.options
			else
				[query,comparator,paging] = args
				criteria = {comparator, paging, queries:find:query}

		# Create child collection
		passed = @testModels(@models,criteria)
		collection = @createChildCollection(passed,criteria)

		# Return
		return collection

	# Find All Live
	findAllLive: (args...) ->
		# Prepare
		if args.length
			if args.length is 1 and args[0] instanceof Criteria
				criteria = criteria.options
			else
				[query,comparator,paging] = args
				criteria = {comparator, paging, queries:find:query}

		# Create child collection
		passed = @testModels(@models,criteria)
		collection = @createLiveChildCollection(passed,criteria)

		# Return
		return collection

	# Find One
	findOne: (args...) ->
		# Prepare
		if args.length
			if args.length is 1 and args[0] instanceof Criteria
				criteria = criteria.options
			else
				[query,comparator,paging] = args
				criteria = {comparator, paging, queries:find:query}

		# Create child collection
		passed = @testModels(@models,criteria)

		# Return
		if passed?.length isnt 0
			return passed[0]
		else
			return null

	# Query
	# Reset our collection with the new rules that we are using
	query: (criteria) ->
		# Prepare
		passed = @testModels(@models, criteria)

		# Reset
		@reset(passed)

		# Chain
		@


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
				parentCollection.on('change',@onParentChange)
				parentCollection.on('remove',@onParentRemove)
				parentCollection.on('add',@onParentAdd)
				parentCollection.on('reset',@onParentReset)
			else
				parentCollection.off('change',@onParentChange)
				parentCollection.off('remove',@onParentRemove)
				parentCollection.off('add',@onParentAdd)
				parentCollection.off('reset',@onParentReset)

		# Chain
		@

	# Fired when we want to add some models to our own collection
	# We should check if the models pass our tests, if so then we add them
	add: (models, options) ->
		# Prepare
		options = if options then _.clone(options) else {}
		models = if _.isArray(models) then models.slice() else [models]
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
		options = if options then _.clone(options) else {}
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
		pass = @test(model) and @getParentCollection().hasModel(model)
		if pass
			@safeAdd(model)
		else
			@safeRemove(model)
		@

	# Fired when a model in our parent collection is removed
	# We should remove it straight away from our own model
	onParentRemove: (model) =>
		@safeRemove(model)
		@

	# Fired when a model in our parent collection is added
	# We should try and add it to our own collection
	# Try as in, it will call _prepareModel and the tests happen there
	onParentAdd: (model) =>
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
	constructor: (options) ->
		# Prepare
		@options ?= {}
		_.extend(@options, options)

		# Chain
		@

	# Apply Criteria
	applyCriteria: (options={}) =>
		# Apply
		@options.filters = _.extend({}, @options.filters or {})
		@options.queries = _.extend({}, @options.queries or {})
		@options.pills = _.extend({}, @options.pills or {})
		@options.searchString or= null
		@options.paging = _.extend({}, @options.paging or {})

		# Initialise filters, queries and pills if we have them
		@setFilters(@options.filters)
		@setQueries(@options.queries)
		@setPills(@options.pills)
		@setSearchString(@options.searchString)  if @options.searchString?
		@setPaging(@options.paging)
		@setComparator(@options.comparator)  if @options.comparator?

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
		paging = _.extend(@getPaging(), paging or {})
		paging.page or= null
		paging.limit or= null
		paging.offset or= null

		# Apply paging
		@options.paging = paging

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
	testModel: (model,criteria={}) ->
		passed = @testFilters(model,criteria.filters) and @testQueries(model,criteria.queries) and @testPills(model,criteria.pills)
		return passed

	# Test Models
	testModels: (models,criteria={}) ->
		# Prepare
		me = @
		passed = []
		models ?= @models
		paging = criteria.paging ? @getPaging()

		# Cycle through the parent collection finding passing models
		for model in models
			pass = me.testModel(model,criteria)
			passed.push(model)  if pass

		# Page our models
		start = paging.offset or 0
		if paging.limit? and paging.limit > 0
			start = start + paging.limit * ((paging.page or 1) - 1)
			finish = start + paging.limit
			passed = passed[start...finish]
		else
			passed = passed[start..]

		# Sort
		comparator = @getComparator()
		passed.sort(comparator)  if comparator

		# Return
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
		for own filterName,filter of filters
			if filter(model,cleanedSearchString) is false
				passed = false
				return false # break

		# Return result
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
		for own queryName,query of queries
			unless query instanceof Query
				query = new Query(query)
				queries[queryName] = query
			if query.test(model) is false
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
		if searchString?
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
	# Prepare
	query: null

	constructor: (query={}) ->
		# Apply
		@query = query

	test: (model) ->
		# Match
		matchAll = true
		matchAny = false
		empty = true

		# Selectors
		for own selectorName, selectorValue of @query
			match = false
			empty = false
			modelValue = model.get(selectorName)
			modelId = model.get('id')
			modelValueExists = typeof modelValue isnt 'undefined'
			modelValue = false  unless modelValueExists

			# The $or operator lets you use a boolean or expression to do queries. You give $or a list of expressions, any of which can satisfy the query.
			# The $nor operator is the opposite of $or (pass if they all don't match the query)
			if selectorName in ['$or','$nor']
				queryGroup = util.toArrayGroup(selectorValue)
				unless queryGroup.length then throw new Error("Query called with an empty #{selectorName} statement")
				# Match if at least one item passes
				for query in queryGroup
					query = new Query(query)
					if query.test(model)
						match = true
						break
				# If we are $nor, then invert
				if selectorName is '$nor'
					match = !match

			# The $and operator lets you use boolean and in a query. You give $and an array of expressions, all of which must match to satisfy the query.
			# The $not operator is the opposite of $and (pass if only one doesn't match the query)
			else if selectorName in ['$and','$not']
				queryGroup = util.toArrayGroup(selectorValue)
				unless queryGroup.length then throw new Error("Query called with an empty #{selectorName} statement")
				for query in queryGroup
					query = new Query(query)
					match = query.test(model)
					break  unless match
				# If we are $not, then inver
				if selectorName is '$not'
					match = !match


			# String, Number, Boolean
			else if util.isString(selectorValue) or util.isNumber(selectorValue) or util.isBoolean(selectorValue)
				if modelValueExists and modelValue is selectorValue
					match = true

			# Array
			else if util.isArray(selectorValue)
				if modelValueExists and (new Hash modelValue).isSame(selectorValue)
					match = true

			# Date
			else if util.isDate(selectorValue)
				if modelValueExists and modelValue.toString() is selectorValue.toString()
					match = true

			# Regular Expression
			else if util.isRegExp(selectorValue)
				if modelValueExists and selectorValue.test(modelValue)
					match = true

			# Null
			else if util.isNull(selectorValue)
				if modelValue is selectorValue
					match = true

			# Conditional Operators
			else if util.isObject(selectorValue)
				# The $beginsWith operator checks if the value begins with a particular value or values if an array was passed
				$beginsWith = selectorValue.$beginsWith or selectorValue.$startsWith or null
				if $beginsWith and modelValueExists and util.isString(modelValue)
					$beginsWith = [$beginsWith]  unless util.isArray($beginsWith)
					for $beginsWithValue in $beginsWith
						if modelValue.substr(0,$beginsWithValue.length) is $beginsWithValue
							match = true
							break

				# The $endsWith operator checks if the value ends with a particular value or values if an array was passed
				$endsWith = selectorValue.$endsWith or selectorValue.$finishesWith or null
				if $endsWith and modelValueExists and util.isString(modelValue)
					$endsWith = [$endsWith]  unless util.isArray($endsWith)
					for $endWithValue in $endsWith
						if modelValue.substr($endWithValue.length*-1) is $endWithValue
							match = true
							break

				# The $all operator is similar to $in, but instead of matching any value in the specified array all values in the array must be matched.
				if selectorValue.$all?
					if modelValueExists
						if (new Hash modelValue).hasAll(selectorValue.$all)
							match = true

				# The $in operator is analogous to the SQL IN modifier, allowing you to specify an array of possible matches.
				# The target field's value can also be an array; if so then the document matches if any of the elements of the array's value matches any of the $in field's values
				if selectorValue.$in?
					if modelValueExists
						if (new Hash modelValue).hasIn(selectorValue.$in)
							match = true
						else if (new Hash selectorValue.$in).hasIn(modelValue)
							match = true

				# Query-Engine Specific
				# The $has operator checks if any of the selectorValue values exist within our model's value
				if selectorValue.$has?
					if modelValueExists
						if (new Hash modelValue).hasIn(selectorValue.$has)
							match = true

				# Query-Engine Specific
				# The $hasAll operator checks if all of the selectorValue values exist within our model's value
				if selectorValue.$hasAll?
					if modelValueExists
						if (new Hash modelValue).hasIn(selectorValue.$hasAll)
							match = true

				# The $nin operator is similar to $in except that it selects objects for which the specified field does not have any value in the specified array.
				if selectorValue.$nin?
					if modelValueExists
						if (new Hash modelValue).hasIn(selectorValue.$nin) is false and (new Hash selectorValue.$nin).hasIn(selectorValue) is false
							match = true

				# The $size operator matches any array with the specified number of elements. The following example would match the object {a:["foo"]}, since that array has just one element:
				$size = selectorValue.$size or selectorValue.$length
				if $size?
					if modelValue.length? and modelValue.length is $size
						match = true

				# The $type operator matches values based on their BSON type.
				if selectorValue.$type
					if typeof modelValue is selectorValue.$type
						match = true

				# Query-Engine Specific
				# The $like operator checks if selectorValue string exists within the modelValue string (case insensitive)
				if selectorValue.$like?
					if util.isString(modelValue) and modelValue.toLowerCase().indexOf(selectorValue.$like.toLowerCase()) isnt -1
						match = true

				# Query-Engine Specific
				# The $likeSensitive operator checks if selectorValue string exists within the modelValue string (case sensitive)
				if selectorValue.$likeSensitive?
					if util.isString(modelValue) and modelValue.indexOf(selectorValue.$likeSensitive) isnt -1
						match = true

				# Check for existence (or lack thereof) of a field.
				if selectorValue.$exists?
					if selectorValue.$exists
						if modelValueExists is true
							match = true
					else
						if modelValueExists is false
							match = true

				# The $mod operator allows you to do fast modulo queries to replace a common case for where clauses.
				if selectorValue.$mod?
					if modelValueExists
						$mod = selectorValue.$mod
						$mod = [$mod]  unless util.isArray($mod)
						$mod.push(0)  if $mod.length is 1
						if (modelValue % $mod[0]) is $mod[1]
							match = true

				# Query-Engine Specific
				# Use $eq for deep equals
				if util.isDefined(selectorValue.$eq)
					if util.isEqual(modelValue,selectorValue.$eq)
						match = true

				# Use $ne for "not equals".
				if util.isDefined(selectorValue.$ne)
					if modelValue isnt selectorValue.$ne
						match = true

				# less than
				if selectorValue.$lt?
					if util.isComparable(modelValue) and modelValue < selectorValue.$lt
						match = true

				# greater than
				if selectorValue.$gt?
					if util.isComparable(modelValue) and modelValue > selectorValue.$gt
						match = true

				# Query-Engine Specific
				# between
				if selectorValue.$bt?
					if util.isComparable(modelValue) and selectorValue.$bt[0] < modelValue and modelValue < selectorValue.$bt[1]
						match = true

				# less than or equal to
				if selectorValue.$lte?
					if util.isComparable(modelValue) and modelValue <= selectorValue.$lte
						match = true

				# greater than or equal to
				if selectorValue.$gte?
					if util.isComparable(modelValue) and modelValue >= selectorValue.$gte
						match = true

				# Query-Engine Specific
				# between or equal to
				if selectorValue.$bte?
					if util.isComparable(modelValue) and selectorValue.$bte[0] <= modelValue and modelValue <= selectorValue.$bte[1]
						match = true

			# Matched
			if match
				matchAny = true
			else
				matchAll = false

		# Match all
		if matchAll and !matchAny
			matchAll = false

		# Return
		return matchAll


# -------------------------------------
# Exports

# Prepare
queryEngine =
	safeRegex: util.safeRegex
	createRegex: util.createRegex
	createSafeRegex: util.createSafeRegex
	generateComparator: util.generateComparator
	toArray: util.toArray
	Backbone: Backbone
	Hash: Hash
	QueryCollection: QueryCollection
	Query: Query
	Pill: Pill
	createCollection: (models,options) ->
		models = util.toArray(models)
		collection = new QueryCollection(models,options)
		return collection
	createLiveCollection: (models,options) ->
		models = util.toArray(models)
		collection = new QueryCollection(models,options).live(true)
		return collection

# Export for node.js and the browser
if module? then (module.exports = queryEngine) else (@queryEngine = queryEngine)