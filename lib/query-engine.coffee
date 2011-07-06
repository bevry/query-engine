# http://www.mongodb.org/display/DOCS/Advanced+Queries

# Array
Array::hasIn = (options) ->
	for value in @
		if value in options
			return true
	return false
Array::hasAll = (options) ->
	@.sort().join() is options.sort().join()

# Create
Object::find = (query) ->
	# Matches
	matches = {}

	# Start with entire set
	for own id,record of @
		# Match
		match = false

		# Selectors
		for own field, selector of query
			selectorType = typeof selector
			exists = record[field]?
			value = if exists then record[field] else false

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
		if match
			matches[id] = record
	
	# Return matches
	matches
