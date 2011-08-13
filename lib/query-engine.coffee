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


# -------------------------------------
# Array Prototypes

# Has In
Array::hasIn = (options) ->
	for value in @
		if value in options
			return true
	return false

# Has All
Array::hasAll = (options) ->
	@.sort().join() is options.sort().join()


# -------------------------------------
# Object Prototypes

# Find
Object::find = (query={},next) ->
	# Matches
	matches = {}
	length = 0

	# Start with entire set
	for own id,record of @
		# Match
		match = false
		empty = true

		# Selectors
		for own field, selector of query
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
				if exists and value.hasAll(selector)
					match = true  
				
			# Regular Expression
			else if selector instanceof RegExp
				if exists and selector.test(value)
					match = true

			# Conditional Operators
			else if selector instanceof Object
				# The $nor operator lets you use a boolean or expression to do queries. You give $nor a list of expressions, none of which can satisfy the query.
				if selector.$nor
					match = false

				# The $or operator lets you use a boolean or expression to do queries. You give $or a list of expressions, any of which can satisfy the query.
				if selector.$or
					match = false

				# The $all operator is similar to $in, but instead of matching any value in the specified array all values in the array must be matched. 
				if selector.$all
					if exists and value.hasAll(selector.$all)
						match = true
				
				# The $in operator is analogous to the SQL IN modifier, allowing you to specify an array of possible matches.
				if selector.$in
					if exists
						if (value.hasIn? and value.hasIn(selector.$in)) or (value in selector.$in)
							match = true  
				
				# The $nin operator is similar to $in except that it selects objects for which the specified field does not have any value in the specified array. 
				if selector.$nin
					if exists 
						if !(value.hasIn? and value.hasIn(selector.$nin)) and !(value in selector.$nin)
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

		# Append
		if match or empty
			++length
			matches[id] = record
	
	# Async
	if next?
		next false, matches, length
	# Sync
	else
		matches

# Find One
Object::findOne = (query={},next) ->
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
Object::forEach ?= (callback) ->
	# Prepare
	for own id,record of @
		callback record, id

# To Array
Object::toArray = (next) ->
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
Object::sort = (comparison,next) ->
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
Object::remove = (query={},next) ->
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


# -------------------------------------
# Exports

# Exports
if module? and module.exports?
	module.exports = {set,get}
else if window?
	window.queryEngine = {set,get}
