# http://www.mongodb.org/display/DOCS/Advanced+Queries


# -------------------------------------
# Helpers

# Get the value of the object
get = (obj,key) ->
	if obj.get?
		obj.get key
	else
		obj[key]

# Set the value of the object
set = (obj,key,value) ->
	if obj.set?
		obj.set key, value
	else
		obj[key] = value

# To array
toArray = (value) ->
	unless value
		[]
	else unless value instanceof Array
		[value]
	else
		value


# -------------------------------------
# Array Prototypes

Hash = class
	# Array
	arr: []

	# Constructor
	constructor: (arr) ->
		@arr = toArray(arr)
		
	# Has In
	hasIn: (options) ->
		options = toArray(options)
		for value in @arr
			if value in options
				return true
		return false

	# Has All
	hasAll: (options) ->
		@arr.sort().join() is options.sort().join()

for key,value of Array::
	Hash::[key] = (args...) ->
		value.apply(@arr,args)


# -------------------------------------
# Collection

Collection = class
	# Constructor
	constructor: (data={}) ->
		for own key,value of data
			@[key] = value

	# Find
	find: (query={},next) ->
		# Matches
		matches = new Collection
		length = 0
		$nor = false
		$or = false
		$and = false
		matchType = 'and'
		
		# Determine matching type
		if query.$type
			matchType = query.$type
			delete query.$type

		# The $nor operator lets you use a boolean or expression to do queries. You give $nor a list of expressions, none of which can satisfy the query.
		if query.$nor
			$nor = query.$nor
			delete query.$nor

		# The $or operator lets you use a boolean or expression to do queries. You give $or a list of expressions, any of which can satisfy the query.
		if query.$or
			$or = query.$or
			delete query.$or

		# The $and operator lets you use boolean and in a query. You give $and an array of expressions, all of which must match to satisfy the query.
		if query.$and
			$and = query.$and
			delete query.$and

		# Start with entire set
		for own id,record of @
			# Match
			matchAll = true
			matchAny = false
			empty = true

			# Selectors
			for own field, selector of query
				match = false
				empty = false
				selectorType = typeof selector
				value = get(record,field)
				id = get(record,'id') or id
				exists = typeof value isnt 'undefined'
				value = false  unless exists

				# Standard
				if selectorType in ['string','number'] or selectorType instanceof String
					if exists and value is selector
						match = true

				# Array
				else if selector instanceof Array
					if exists and (new Hash value).hasAll(selector)
						match = true  
					
				# Date
				else if selector instanceof Date
					if exists and value.toString() is selector.toString()
						match = true  
				
				# Regular Expression
				else if selector instanceof RegExp
					if exists and selector.test(value)
						match = true

				# Conditional Operators
				else if selector instanceof Object
					# The $all operator is similar to $in, but instead of matching any value in the specified array all values in the array must be matched. 
					if selector.$all
						if exists
							if (new Hash value).hasAll(selector.$all)
								match = true
					
					# The $in operator is analogous to the SQL IN modifier, allowing you to specify an array of possible matches.
					if selector.$in
						if exists
							if (new Hash value).hasIn(selector.$in)
								match = true
							else if (new Hash selector.$in).hasIn(value)
								match = true
					
					# The $nin operator is similar to $in except that it selects objects for which the specified field does not have any value in the specified array. 
					if selector.$nin
						if exists
							if (new Hash value).hasIn(selector.$in) is false and (new Hash selector.$in).hasIn(value) is false
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

			# Append
			append = false
			if empty
				append = true
			else
				switch matchType
					when 'none','nor'
						append = true  unless matchAny
						
					when 'any','or'
						append = true  if matchAny

					#when 'all','and'
					else
						append = true  if matchAll
			
			# Append
			matches[id] = record  if append

		# The $nor operator lets you use a boolean or expression to do queries. You give $nor a list of expressions, none of which can satisfy the query.
		if $nor
			newMatches = {}
			for expression in $nor
				for own key,value of matches.find expression
					newMatches[key] = value
			for own key,value of newMatches
				if matches[key]?
					delete matches[key]

		# The $or operator lets you use a boolean or expression to do queries. You give $or a list of expressions, any of which can satisfy the query.
		if $or
			newMatches = {}
			for expression in $or
				for own key,value of matches.find expression
					newMatches[key] = value
			matches = newMatches

		# The $and operator lets you use boolean and in a query. You give $and an array of expressions, all of which must match to satisfy the query.
		if $and
			for expression in $and
				matches = matches.find expression
		
		# Calculate length
		length = 0
		for own match of matches
			++length

		# Async
		if next?
			next false, matches, length
		# Sync
		else
			matches

	# Find One
	findOne: (query={},next) ->
		# Cycle
		matches = @find(query).toArray()
		match = if matches.length >= 1 then matches[0] else undefined

		# Async
		if next?
			next false, match
		# Sync
		else
			match

	# For Each
	forEach: (callback) ->
		# Prepare
		for own id,record of @
			callback record, id

	# To Array
	toArray: (next) ->
		# Prepare
		arr = []

		# Cycle
		for own key,value of @
			arr.push value

		# Async
		if next?
			next false, arr
		# Sync
		else
			arr

	# Sort
	sort: (comparison,next) ->
		# Prepare
		arr = @toArray()
		if comparison instanceof Function
			arr.sort(comparison)
		else
			for own key,value of comparison
				if value is -1
					arr.sort (a,b) ->
						get(b,key) - get(a,key)
				else if value is 1
					arr.sort (a,b) ->
						get(a,key) - get(b,key)

		# Async
		if next?
			next false, arr
		# Sync
		else
			arr

	# Remove
	remove: (query={},next) ->
		# Prepare
		matches = @find(query)

		# Delete
		for own id,record of @
			delete @[id]
		
		# Async
		if next?
			next false, @
		# Sync
		else
			@

extendNatives = ->
	Array.prototype[key] ?= value  for own key,value of Hash.prototype
	Object.prototype[key] ?= value  for own key,value of Collection.prototype

# -------------------------------------
# Exports

# Exports
if module? and module.exports?
	module.exports = {set,get,Collection,Hash,extendNatives}
else if window?
	window.queryEngine = {set,get,Collection,Hash,extendNatives}