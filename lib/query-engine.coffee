# Requires
_ = window? and window._  or  require('underscore')
Backbone = window? and window.Backbone  or  require('backbone')


# Util
# Contains our utility functions
util =
	# Safe Regex
	# Santitize a string for the use inside a regular expression
	safeRegex: (str) ->
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
			if _.isArray(value)
				result = value
			else if _.isObject(value)
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
			if _.isArray(value)
				result = value
			else if _.isObject(value)
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
			else if _.isFunction(comparator)
				return comparator
			else if _.isObject(comparator)
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
			else if _.isArray(comparator)
				return (a,b) ->
					comparison = 0
					for value,key in comparator
						comparison = generateFunction(value)(a,b)
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
		# Bindings
		_.bindAll(@, 'onChange', 'onParentChange', 'onParentRemove', 'onParentAdd', 'onParentReset')

		# Defaults
		@options = _.extend({}, @options or {}, options or {})
		@options.filters = _.extend({}, @options.filters or {})
		@options.queries = _.extend({}, @options.queries or {})
		@options.pills = _.extend({}, @options.pills or {})
		@options.searchString or= null

		# Initialise filters, queries and pills if we have them
		@setFilters(@options.filters)
		@setQueries(@options.queries)
		@setPills(@options.pills)
		@setSearchString(@options.searchString)

		# Initliase live events if we use them
		@live()

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

		# Apply or delete the value
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
			value = new Query(value)  unless (value instanceof Query)
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
		pills = @options.pills
		searchString = @options.searchString

		# Apply or delete the value
		if value?
			value = new Pill(value)  unless (value instanceof Pill)
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
		_.each pills, (pill,pillName) ->
			cleanedSearchString = pill.setSearchString(cleanedSearchString)
			return true

		# Apply
		@options.searchString = searchString
		@options.cleanedSearchString = cleanedSearchString

		# Chain
		@


	# ---------------------------------
	# Parent Collection: Getters and Setters

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
	# Generic API

	# Set Comparator
	setComparator: (comparator) ->
		# Prepare comparator
		comparator = util.generateComparator(comparator)

		# Apply it
		@comparator = comparator

		# Chain
		@

	# Sort Collection
	# Sorts our current collection by our comparator
	sortCollection: (comparator) ->
		# Sort our collection
		if comparator
			comparator = util.generateComparator(comparator)
			@models.sort(comparator)
		else if @comparator
			@models.sort(@comparator)
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
		else if @comparator
			arr.sort(@comparator)
		else
			throw new Error('You need a comparator to sort')

		# Return sorted array
		return arr

	# Query
	# Reset our collection with the new rules that we are using
	query: ->
		# Prepare
		me = @
		models = []
		collection = @getParentCollection() or @

		# Cycle through the parent collection finding passing models
		collection.each (model) ->
			pass = me.test(model)
			if pass
				models.push(model)

		# Reset our collection with the passing models
		@reset(models)

		# Chain
		@

	# Create Child Collection
	createChildCollection: ->
		collection = new (@collection or QueryCollection)().setParentCollection(@)
		collection.comparator ?= @comparator  if @comparator
		return collection

	# Create Live Child Collection
	createLiveChildCollection: ->
		collection = @createChildCollection().live(true)
		return collection

	# Find All
	findAll: (query) ->
		collection = @createChildCollection()
			.setQuery('find',query)
			.query()
		return collection

	# Find One
	findOne: (query) ->
		collection = @createChildCollection()
			.setQuery('find',query)
			.query()
		if collection and collection.length
			return collection.models[0]
		else
			return null


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
	onChange: (model) ->
		pass = @test(model)
		unless pass
			@safeRemove(model)
		else
			@sortCollection()  if @comparator
		@

	# Fired when a model in our parent collection changes
	# We should check if the model now passes our own tests, and if so add it to our own
	# and if it doesn't then we should remove the model from our own
	onParentChange: (model) ->
		pass = @test(model) and @getParentCollection().test(model)
		if pass
			@safeAdd(model)
		else
			@safeRemove(model)
		@

	# Fired when a model in our parent collection is removed
	# We should remove it straight away from our own model
	onParentRemove: (model) ->
		@safeRemove(model)
		@

	# Fired when a model in our parent collection is added
	# We should try and add it to our own collection
	# Try as in, it will call _prepareModel and the tests happen there
	onParentAdd: (model) ->
		@safeAdd(model)
		@

	# Fired when our parent collection is reset
	# We should reset our own collection when this happens with the parent collection's models
	# For each model, it will trigger _prepareModel which will check if the model passes our tests
	onParentReset: (model) ->
		@reset(@getParentCollection().models)
		@


	# ---------------------------------
	# Testers

	# Test everything against the model
	test: (model) ->
		pass = @testFilters(model) and @testQueries(model) and @testPills(model)
		return pass

	# Perform the Filters against a Model
	# Filters work in allow-all, deny by exeception way
	# So if there are no queries, everything should pass
	# If there is one failed query however, it should fail
	testFilters: (model) ->
		# Prepare
		pass = true
		cleanedSearchString = @getCleanedSearchString()
		filters = @getFilters()

		# Cycle
		_.each filters, (filter,filterName) ->
			if filter(model,cleanedSearchString) is false
				pass = false
				return false # break

		# Return result
		return pass

	# Perform the Queries against a Model
	# Queries work in allow-all, deny by exeception way
	# So if there are no queries, everything should pass
	# If there is one failed query however, it should fail
	testQueries: (model) ->
		# Prepare
		pass = true
		queries = @getQueries()

		# Cycle
		_.each queries, (query,queryName) ->
			if query.test(model) is false
				pass = false
				return false # break

		# Return result
		return pass

	# Perform the Pills against a Model
	# Pills work in allow-all, deny by exeception way
	# So if there are no queries, everything should pass
	# If there is one failed query however, it should fail
	testPills: (model) ->
		# Prepare
		pass = true
		searchString = @getSearchString()
		pills = @getPills()

		# Cycle
		if searchString?
			_.each pills, (pill,pillName) ->
				if pill.test(model) is false
					pass = false
					return false # break

		# Return result
		return pass


# Pill
# Provides the ability to perform pill based searches, e.g.
# Searching for "user:ben" will search for the key user, and value ben
# Pills must be coded manually, as otherwise that could be a security problem
class Pill
	# Callback
	# Our pills tester function
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
	# The discovered value of the pill within the search
	value: null # String

	# Constructor
	# Construct our regular expression and apply our properties
	constructor: (pill) ->
		# Apply
		pill or= {}
		@callback = pill.callback
		@prefixes = pill.prefixes

		# Sanitize the prefixes
		safePrefixes = []
		for prefix in @prefixes
			safePrefixes.push util.safeRegex(prefix)

		# Build the regular expression used to match the pill
		safePrefixesStr = safePrefixes.join('|')
		regexString ='('+safePrefixesStr+')([^\\s]+)'

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
		value = null

		# Extract information
		while match = @regex.exec(searchString)
			value = match[2].trim()
			cleanedSearchString = searchString.replace(match[0],'').trim()

		# Apply
		@searchString = searchString
		@value = value

		# Return cleaned search
		return cleanedSearchString

	# Test
	# Test our pill against our discovered values
	# Returns whether our pill passed or not
	test: (model) ->
		# Prepare
		pass = null

		# Extract the pill information from the query
		if @value?
			pass = @callback(model,@value)

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

			# The $nor operator lets you use a boolean or expression to do queries. You give $nor a list of expressions, none of which can satisfy the query.
			if selectorName is '$nor'
				match = true
				queryGroup = util.toArrayGroup(selectorValue)
				unless queryGroup.length then throw new Error('Query called with an empty $nor statement')
				for query in queryGroup
					query = new Query(query)
					if query.test(model)
						match = false
						break

			# The $or operator lets you use a boolean or expression to do queries. You give $or a list of expressions, any of which can satisfy the query.
			if selectorName is '$or'
				queryGroup = util.toArrayGroup(selectorValue)
				unless queryGroup.length then throw new Error('Query called with an empty $or statement')
				for query in queryGroup
					query = new Query(query)
					if query.test(model)
						match = true
						break

			# The $and operator lets you use boolean and in a query. You give $and an array of expressions, all of which must match to satisfy the query.
			if selectorName is '$and'
				match = true
				queryGroup = util.toArrayGroup(selectorValue)
				unless queryGroup.length then throw new Error('Query called with an empty $and statement')
				for query in queryGroup
					query = new Query(query)
					unless query.test(model)
						match = false

			# String, Number, Boolean
			if _.isString(selectorValue) or _.isNumber(selectorValue) or _.isBoolean(selectorValue)
				if modelValueExists and modelValue is selectorValue
					match = true

			# Array
			else if _.isArray(selectorValue)
				if modelValueExists and (new Hash modelValue).isSame(selectorValue)
					match = true

			# Date
			else if _.isDate(selectorValue)
				if modelValueExists and modelValue.toString() is selectorValue.toString()
					match = true

			# Regular Expression
			else if _.isRegExp(selectorValue)
				if modelValueExists and selectorValue.test(modelValue)
					match = true

			# Conditional Operators
			else if _.isObject(selectorValue)
				# The $beginsWith operator checks if the value begins with a particular value or values if an array was passed
				$beginsWith = selectorValue.$beginsWith or selectorValue.$startsWith or null
				if $beginsWith and modelValueExists and _.isString(modelValue)
					$beginsWith = [$beginsWith]  unless _.isArray($beginsWith)
					for $beginsWithValue in $beginsWith
						if modelValue.substr(0,$beginsWithValue.length) is $beginsWithValue
							match = true
							break

				# The $endsWith operator checks if the value ends with a particular value or values if an array was passed
				$endsWith = selectorValue.$endsWith or selectorValue.$finishesWith or null
				if $endsWith and modelValueExists and _.isString(modelValue)
					$endsWith = [$endsWith]  unless _.isArray($endsWith)
					for $endWithValue in $endsWith
						if modelValue.substr($endWithValue.length*-1) is $endWithValue
							match = true
							break

				# The $all operator is similar to $in, but instead of matching any value in the specified array all values in the array must be matched.
				if selectorValue.$all
					if modelValueExists
						if (new Hash modelValue).hasAll(selectorValue.$all)
							match = true

				# The $in operator is analogous to the SQL IN modifier, allowing you to specify an array of possible matches.
				# The target field's value can also be an array; if so then the document matches if any of the elements of the array's value matches any of the $in field's values
				if selectorValue.$in
					if modelValueExists
						if (new Hash modelValue).hasIn(selectorValue.$in)
							match = true
						else if (new Hash selectorValue.$in).hasIn(modelValue)
							match = true

				# Query-Engine Specific
				# The $has operator checks if any of the selectorValue values exist within our model's value
				if selectorValue.$has
					if modelValueExists
						if (new Hash modelValue).hasIn(selectorValue.$has)
							match = true

				# Query-Engine Specific
				# The $hasAll operator checks if all of the selectorValue values exist within our model's value
				if selectorValue.$hasAll
					if modelValueExists
						if (new Hash modelValue).hasIn(selectorValue.$hasAll)
							match = true

				# The $nin operator is similar to $in except that it selects objects for which the specified field does not have any value in the specified array.
				if selectorValue.$nin
					if modelValueExists
						if (new Hash modelValue).hasIn(selectorValue.$nin) is false and (new Hash selectorValue.$nin).hasIn(selectorValue) is false
							match = true

				# The $size operator matches any array with the specified number of elements. The following example would match the object {a:["foo"]}, since that array has just one element:
				$size = selectorValue.$size or selectorValue.$length
				if $size
					if modelValue.length? and modelValue.length is $size
						match = true

				# The $type operator matches values based on their BSON type.
				if selectorValue.$type
					if typeof modelValue is selectorValue.$type
						match = true

				# Check for existence (or lack thereof) of a field.
				if selectorValue.$exists
					if selectorValue.$exists
						if modelValueExists is true
							match = true
					else
						if modelValueExists is false
							match = true

				# The $mod operator allows you to do fast modulo queries to replace a common case for where clauses.
				if selectorValue.$mod
					match = false

				# Use $ne for "not equals".
				if selectorValue.$ne
					if modelValueExists and modelValue isnt selectorValue.$ne
						match = true

				# less than
				if selectorValue.$lt
					if modelValueExists and modelValue < selectorValue.$lt
						match = true

				# greater than
				if selectorValue.$gt
					if modelValueExists and modelValue > selectorValue.$gt
						match = true

				# less than or equal to
				if selectorValue.$lte
					if modelValueExists and modelValue <= selectorValue.$lte
						match = true

				# greater than or equal to
				if selectorValue.$gte
					if modelValueExists and modelValue >= selectorValue.$gte
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
exports = {
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
}

# Export
if module? and module.exports?
	module.exports = exports
else if window?
	window.queryEngine = exports

