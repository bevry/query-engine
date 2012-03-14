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
			else if value instanceof Object
				for own key,item of value
					result.push(item)
			else
				result.push(value)
		
		# Return the result
		result


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



# Base Collection
# Handles basic query engine collection functionality
BaseCollection = Backbone.Collection.extend
	# Model
	# The model that this query engine supports
	model: Backbone.Model

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

	# Sort Array
	sortArray: (comparator) ->
		# Prepare
		arr = @toJSON()

		# Sort
		if comparator instanceof Function
			arr.sort(comparator)
		else if comparator instanceof Object
			for own key,value of comparator
				# Descending
				if value is -1
					arr.sort (a,b) ->
						b[key] - a[key]
				# Ascending
				else if value is 1
					arr.sort (a,b) ->
						a[key] - b[key]
		else
			throw new Error('Cannot sort a set without a comparator')

		# Return sorted array
		return arr

	# Create Live Collection
	createLiveCollection: ->
		collection = new LiveCollection()
			.setParentCollection(@)
		return collection

	# Find
	find: (query) ->
		collection = @createLiveCollection()
			.setQuery('find',query)
			.query()
		return collection

	# Find One
	findOne: (query) ->
		collection = @createLiveCollection()
			.setQuery('find',query)
			.query()
		if collection and collection.length
			return collection.models[0]
		else
			return null



# Live Collection
LiveCollection = BaseCollection.extend

	# Constructor
	initialize: (models,options) ->
		# Defaults
		@options = _.extend({},options);
		@options.filters or= {};
		@options.pills or= {};
		@options.queries or= {};
		@options.searchString or= null

		# Bindings
		_.bindAll(@, 'onChange', 'onParentChange', 'onParentRemove', 'onParentAdd', 'onParentReset')
		@on('change',@onChange)

		# Set
		if @options.parentCollection?
			@setParentCollection(@options.parentCollection,true)

		# Chain
		@

	# Set Parent Collection
	setParentCollection: (parentCollection,skipCheck) ->
		# Check
		if !skipCheck and @options.parentCollection is parentCollection
			return @ # nothing to do

		# Apply
		@options.parentCollection = parentCollection

		# Subscribe the live events to our parent collection
		@options.parentCollection
			.on('change',@onParentChange)
			.on('remove',@onParentRemove)
			.on('add',@onParentAdd)
			.on('reset',@onParentReset)

		# Chain
		@

	# Query
	# Reset our collection with the new rules that we are using
	query: ->
		# Prepare
		me = @
		models = []
		collection = @options.parentCollection or @

		# Cycle through the parent collection finding passing models
		collection.each (model) ->
			pass = me.test(model)
			if pass
				models.push(model)

		# Reset our collection with the passing models
		@reset(models)

		# Chain
		@

	
	# ---------------------------------
	# Live Functionality
	# Used so we can live update the collection when modifications are made to our collection

	# Fired when we want to add some models to our own collection
	# We should check if the models pass our tests, if so then we add them
	add: (models, options) ->
		# Prepare
		options = if options then _.clone(options) else {}
		models = if _.isArray(models) then models.slice() else [models]
		passedModels = []

		# Cycle through the models
		for model in models
			# Prepare
			model = @_prepareModel(model,options)

			# Check
			if model and @test(model)
				passedModels.push(model)

		# Add the passed models
		Backbone.Collection.prototype.add.apply(@,[passedModels,options])

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
			Backbone.Collection.prototype.create.apply(@,[model,options])

		# Chain
		@

	# Fired when a model that is inside our own collection changes
	# We should check if it still passes our tests
	# and if it doesn't then we should remove the model
	onChange: (model) ->
		pass = @test(model)
		unless pass
			@safeRemove(model)
		@

	# Fired when a model in our parent collection changes
	# We should check if the model now passes our own tests, and if so add it to our own
	# and if it doesn't then we should remove the model from our own
	onParentChange: (model) ->
		pass = @test(model)
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
		@reset(@parentCollection.models)
		@


	# ---------------------------------
	# Setters

	# Set Filter
	setFilter: (name,value) ->
		# Prepare
		filters = @options.filters

		# Apply or delete the value
		if value?
			filters[name] = value
		else if filters[name]?
			delete filters[name]

		# Apply or delete the value
		@

	# Set Query
	setQuery: (name,value) ->
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

	# Set Pill
	setPill: (name,value) ->
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

	# Set Search String
	setSearchString: (searchString) ->
		# Prepare
		pills = @options.pills
		cleanedSearchString = searchString

		# Apply the search string to each of our pills
		# and for each applicable pill, clean up our search string
		_.each pills, (pill,pillName) ->
			cleanedSearchString = pill.setSearchString(searchString)

		# Apply
		@options.searchString = searchString
		@options.cleanedSearchString = cleanedSearchString

		# Chain
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
		cleanedSearchString = @options.cleanedSearchString
		filters = @options.filters

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
		queries = @options.queries

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
		searchString = @options.searchString
		pills = @options.pills

		# Cycle
		if searchString
			_.each pills, (pill,pillName) ->
				if pill.test(model) is false
					pass = false
					return false # break

		# Return result
		return pass


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
		match = @regex.exec(searchString)
		if match 
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
		for own field, selector of @query
			match = false
			empty = false
			selectorType = typeof selector
			value = model.get(field)
			id = model.get('id')
			exists = typeof value isnt 'undefined'
			value = false  unless exists

			# The $nor operator lets you use a boolean or expression to do queries. You give $nor a list of expressions, none of which can satisfy the query.
			if field is '$nor'
				match = true
				empty = true
				for query in selector
					empty = false
					query = new Query(query)
					if query.test(model)
						match = false
						break
				match = true  if empty

			# The $or operator lets you use a boolean or expression to do queries. You give $or a list of expressions, any of which can satisfy the query.
			if field is '$or'
				match = false
				empty = true
				for query in selector
					empty = false
					query = new Query(query)
					if query.test(model)
						match = true
						break
				match = true  if empty

			# The $and operator lets you use boolean and in a query. You give $and an array of expressions, all of which must match to satisfy the query.
			if field is '$and'
				match = true
				for query in selector
					query = new Query(query)
					unless query.test(model)
						match = false

			# Standard
			if selectorType in ['string','number'] or selectorType instanceof String
				if exists and value is selector
					match = true

			# Array
			else if _.isArray(selector)
				if exists and (new Hash value).isSame(selector)
					match = true  
				
			# Date
			else if _.isDate(selector)
				if exists and value.toString() is selector.toString()
					match = true  
			
			# Regular Expression
			else if _.isRegExp(selector)
				if exists and selector.test(value)
					match = true

			# Conditional Operators
			else if selector instanceof Object
				# The $beginsWith operator checks if the value begins with a particular value
				if selector.$beginsWith
					if exists
						if typeof value is 'string' and value.substr(0,selector.$beginsWith.length) is selector.$beginsWith
							match = true
				
				# The $endsWith operator checks if the value ends with a particular value
				if selector.$endsWith
					if exists
						if typeof value is 'string' and value.substr(selector.$endsWith.length*-1) is selector.$endsWith
							match = true
				
				# The $all operator is similar to $in, but instead of matching any value in the specified array all values in the array must be matched. 
				if selector.$all
					if exists
						if (new Hash value).hasAll(selector.$all)
							match = true
				
				# The $in operator is analogous to the SQL IN modifier, allowing you to specify an array of possible matches.
				# The target field's value can also be an array; if so then the document matches if any of the elements of the array's value matches any of the $in field's values 
				if selector.$in
					if exists
						if (new Hash value).hasIn(selector.$in)
							match = true
						else if (new Hash selector.$in).hasIn(value)
							match = true

				# Query-Engine Specific
				# The $has operator checks if any of the selector values exist within our model's value
				if selector.$has
					if exists
						if (new Hash value).hasIn(selector.$has)
							match = true

				# Query-Engine Specific
				# The $hasAll operator checks if all of the selector values exist within our model's value
				if selector.$hasAll
					if exists
						if (new Hash value).hasIn(selector.$hasAll)
							match = true

				# The $nin operator is similar to $in except that it selects objects for which the specified field does not have any value in the specified array. 
				if selector.$nin
					if exists
						if (new Hash value).hasIn(selector.$nin) is false and (new Hash selector.$nin).hasIn(value) is false
							match = true
				
				# The $size operator matches any array with the specified number of elements. The following example would match the object {a:["foo"]}, since that array has just one element:
				if selector.$size
					if value.length? and value.length is selector.$size
						match = true
			
				# The $type operator matches values based on their BSON type.
				if selector.$type
					if typeof value is selector.$type
						match = true
				
				# Check for existence (or lack thereof) of a field.
				if selector.$exists
					if selector.$exists
						if exists is true
							match = true
					else
						if exists is false
							match = true
				
				# The $mod operator allows you to do fast modulo queries to replace a common case for where clauses.
				if selector.$mod
					match = false
				
				# Use $ne for "not equals".
				if selector.$ne
					if exists and value isnt selector.$ne
						match = true

				# less than
				if selector.$lt
					if exists and value < selector.$lt
						match = true
				
				# greater than
				if selector.$gt
					if exists and value > selector.$gt
						match = true
				
				# less than or equal to
				if selector.$lte
					if exists and value <= selector.$lte
						match = true

				# greater than or equal to
				if selector.$gte
					if exists and value >= selector.$gte
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
	safeRegex: util.safeRegex,
	createRegex: util.createRegex,
	createSafeRegex: util.createSafeRegex,
	toArray: util.toArray,
	Hash
	BaseCollection
	LiveCollection
	Query
	Pill
	createCollection: (models) ->
		models = util.toArray(models)
		collection = new BaseCollection(models)
		return collection
	createLiveCollection: (models) ->
		models = util.toArray(models)
		collection = new LiveCollection(models)
		return collection
}

# Export
if module? and module.exports?
	module.exports = exports
else if window?
	window.queryEngine = exports

