# Requires
queryEngine = @queryEngine or require('../')
assert = @assert or require('assert')
Backbone = @Backbone or (try require?('backbone')) or (try require?('exoskeleton')) or (throw 'Need Backbone or Exoskeleton')
kava = @kava or require('kava')


# =====================================
# Configuration

# Dates
today = new Date()
today.setHours 0
today.setMinutes 0
today.setSeconds 0
tomorrow = new Date()
tomorrow.setDate(today.getDate()+1)
yesterday = new Date()
yesterday.setDate(today.getDate()-1)

# Models Object
modelsObject =
	index:
		id: 'index'
		title: 'Index Page'
		content: 'welcome home'
		tags: []
		position: 1
		positionNullable: null
		category: 1
		date: today
	jquery:
		id: 'jquery'
		title: 'jQuery'
		content: 'this is about jQuery'
		tags: ['jquery']
		position: 2
		positionNullable: 2
		category: 1
		date: yesterday
	history:
		id: 'history'
		title: 'History.js'
		content: 'this is about History.js'
		tags: ['jquery','html5','history']
		position: 3
		positionNullable: 3
		category: 1
		date: tomorrow
	docpad:
		id: 'docpad'
		title: 'DocPad'
		content: 'this is about DocPad'
		tags: ['nodejs','html5']
		position: 1
		category: 2
		date: today

# Models Array
models = queryEngine.toArray(modelsObject)

# Ajaxy Model
ajaxyModel =
	id: 'ajaxy'
	title: 'jQuery Ajaxy'
	content: 'this is about jQuery Ajaxy'
	tags: ['jquery']
	position: 4
	category: 1
	date: yesterday

# Pokemon Model
pokemonModel =
	id: 'pokemon'
	title: 'Pokemon'
	content: 'Gotta catch em all'
	tags: ['anime']
	position: 4
	category: 1
	date: yesterday

# =====================================
# Tests


kava.suite 'live', (suite,test) ->

	suite 'queries', (suite,test) ->
		# Perform a query to find only the items that have the tag "jquery"
		test 'should only keep jquery related models', ->
			# Perform the query
			liveCollection = queryEngine.createLiveCollection()
				.setQuery('only jquery related', {
					tags:
						$has: ['jquery']
				})
				.add(models)

			# Check the result
			actual = liveCollection.toJSON()
			expected = [modelsObject.jquery, modelsObject.history]
			assert.deepEqual actual, expected

		# Perform a wildcard search for "about"
		test 'should support searching', ->
			# Perform the query
			liveCollection = queryEngine.createLiveCollection()
				.setFilter('search', (model,searchString) ->
					searchRegex = queryEngine.createSafeRegex(searchString)
					pass = searchRegex.test(model.get('title')) or searchRegex.test(model.get('content'))
					return pass
				)
				.setSearchString('about')
				.add(models)

			# Check the result
			actual = liveCollection.toJSON()
			expected = [modelsObject.jquery, modelsObject.history, modelsObject.docpad]
			assert.deepEqual actual, expected

		# Perform a pill search for anything with the id of index
		suite 'pill searches', (suite,test) ->
			# Without spacing
			test 'should support pill searches without spacing', ->
				# Perform the query
				liveCollection = queryEngine.createLiveCollection()
					.setPill('id', {
						prefixes: ['id:','#']
						callback: (model,value) ->
							pillRegex = queryEngine.createSafeRegex(value)
							pass = pillRegex.test(model.get('id'))
							return pass
					})
					.setSearchString('id:index')
					.add(models)

				# Check the result
				actual = liveCollection.toJSON()
				expected = [modelsObject.index]
				assert.deepEqual actual, expected

			# With spacing
			test 'should support pill searches with null', ->
				# Perform the query
				liveCollection = queryEngine.createLiveCollection()
					.setPill('positionNullable', {
						prefixes: ['positionNullable:']
						callback: (model,value) ->
							pillRegex = queryEngine.createSafeRegex(value)
							pass = pillRegex.test(model.get('positionNullable'))
							return pass
					})
					.setSearchString('positionNullable:null')
					.add(models)

				# Check the result
				actual = liveCollection.toJSON()
				expected = [modelsObject.index]
				assert.deepEqual actual, expected

			# With spacing
			test 'should support pill searches with spacing', ->
				# Perform the query
				liveCollection = queryEngine.createLiveCollection()
					.setPill('id', {
						prefixes: ['id:','#']
						callback: (model,value) ->
							pillRegex = queryEngine.createSafeRegex(value)
							pass = pillRegex.test(model.get('id'))
							return pass
					})
					.setSearchString('id: index')
					.add(models)

				# Check the result
				actual = liveCollection.toJSON()
				expected = [modelsObject.index]
				assert.deepEqual actual, expected

			# With quotes
			test 'should support pill searches with quotes', ->
				# Perform the query
				liveCollection = queryEngine.createLiveCollection()
					.setPill('title', {
						prefixes: ['title:']
						callback: (model,value) ->
							pass = value is model.get('title')
							return pass
					})
					.setSearchString('title:"Index Page"')
					.add(models)

				# Check the result
				actual = liveCollection.toJSON()
				expected = [modelsObject.index]
				assert.deepEqual actual, expected

			# With OR pills
			test 'should support pill searches with OR pills', ->
				# Perform the query
				liveCollection = queryEngine.createLiveCollection()
					.setPill('tag', {
						prefixes: ['tag:']
						callback: (model,value) ->
							pass = value in model.get('tags')
							return pass
					})
					.setSearchString('tag:html5 tag:jquery')
					.add(models)

				# Check the result
				actual = liveCollection.toJSON()
				expected = [modelsObject.jquery, modelsObject.history, modelsObject.docpad]
				assert.deepEqual actual, expected

			# With AND pills
			test 'should support pill searches with AND pills', ->
				# Perform the query
				liveCollection = queryEngine.createLiveCollection()
					.setPill('tag', {
						logicalOperator: 'AND'
						prefixes: ['tag:']
						callback: (model,value) ->
							pass = value in model.get('tags')
							return pass
					})
					.setSearchString('tag:html5 tag:jquery')
					.add(models)

				# Check the result
				actual = liveCollection.toJSON()
				expected = [modelsObject.history]
				assert.deepEqual actual, expected

			# With filter
			test 'should support pills searches with filters', ->
				# Perform the query
				liveCollection = queryEngine.createLiveCollection()
					.setFilter('search', (model,searchString) ->
						searchRegex = queryEngine.createSafeRegex(searchString)
						pass = searchRegex.test(model.get('content'))
						return pass
					)
					.setPill('category', {
						prefixes: ['category:']
						callback: (model,value) ->
							pillRegex = queryEngine.createSafeRegex(value)
							pass = pillRegex.test(model.get('category'))
							return pass
					})
					.setSearchString('category:1 about')
					.add(models)

				# Check the result
				actual = liveCollection.toJSON()
				expected = [modelsObject.jquery, modelsObject.history]
				assert.deepEqual actual, expected


	suite 'events', (suite,test) ->
		# Create a liveCollection
		liveCollection = queryEngine.createLiveCollection()

		# test childCollection query
		test 'when query is called on our liveCollection, it should successfully filter our models', ->
			# Create a liveCollection, with some rules, and query it
			liveCollection
				.add(models)
				.setQuery('only jquery related', {
					tags:
						$has: ['jquery']
				})
				.query()

			# Check the childCollection to see if it has the new model
			actual = liveCollection.toJSON()
			expected = [modelsObject.jquery, modelsObject.history]
			assert.deepEqual(actual, expected)

		# test add pass checker
		test 'when a model that passes our rules is added to our liveCollection, it should be added', ->
			# Add a model that passes the query to the liveCollection
			liveCollection.add(ajaxyModel)

			# Check the childCollection to see if it has the new model
			actual = liveCollection.toJSON()
			expected = [modelsObject.jquery, modelsObject.history, ajaxyModel]
			assert.deepEqual(actual, expected)

		# test add fail checker
		test 'when a model that fails our rules is added to our liveCollection, it should NOT be added', ->
			# Add a model that fails the query to the liveCollection
			liveCollection.add(pokemonModel)

			# Check the childCollection to see if it has the new model
			actual = liveCollection.toJSON()
			expected = [modelsObject.jquery, modelsObject.history, ajaxyModel]
			assert.deepEqual(actual, expected)

		# test remove check
		test 'when a model is removed from our liveCollection, it should be removed', ->
			# Remove history from the liveCollection
			liveCollection.remove(liveCollection.get('history'))

			# Check the childCollection to see if  history has been removed
			actual = liveCollection.toJSON()
			expected = [modelsObject.jquery, ajaxyModel]
			assert.deepEqual(actual, expected)

		# test change remove check
		test 'when a model is changed in our liveCollection (and no longer supports our rules), it should be removed', ->
			# Change the jquery model so it no longer has the jquery tag
			# thus making it no longer be applicable to the liveCollection
			liveCollection.get('jquery').set('tags',[])

			# Check the childCollection to see if  history has been removed
			actual = liveCollection.toJSON()
			expected = [ajaxyModel]
			assert.deepEqual(actual, expected)

		# test reset check
		test 'when our liveCollection is reset, it should be empty', ->
			# Reset the liveCollection
			liveCollection.reset([])

			# Check our childCollection
			actual = liveCollection.toJSON()
			expected = []
			assert.deepEqual(actual, expected)


	suite 'parent collections', (suite,test) ->
		# Create a parentCollection with the models
		parentCollection = queryEngine.createCollection(models)

		# Perform a query to find only the items that have the tag "jquery"
		test 'should work with findAllLive with query', ->
			# Perform the query
			childCollection = parentCollection.findAllLive({tags: $has: ['jquery']})

			# Check the result
			actual = childCollection.toJSON()
			expected = [modelsObject.jquery, modelsObject.history]
			assert.deepEqual actual, expected

		# Perform a query to find only the items that have the tag "jquery"
		test 'should work with findAllLive with query and comparator', ->
			# Perform the query
			childCollection = parentCollection
				.findAllLive(
					# Query
					{
						tags:
							$has: ['jquery']
					}
					# Comparator
					{
						position: -1
					}
				)

			# Check the result
			actual = childCollection.toJSON()
			expected = [modelsObject.history, modelsObject.jquery]
			assert.deepEqual actual, expected

		# Create a childCollection from the parentCollection
		childCollection = parentCollection.createLiveChildCollection()

		# test childCollection query
		test 'when query is called on our childCollection, it should successfully filter our parentCollection', ->
			# Create a childCollection, with some rules, and query the parentCollection
			childCollection
				.setQuery('only jquery related', {
					tags:
						$has: ['jquery']
				})
				.query()

			# Check the childCollection to see if it has the new model
			actual = childCollection.toJSON()
			expected = [modelsObject.jquery, modelsObject.history]
			assert.deepEqual(actual, expected)

		# test add pass checker
		test 'when a model that passes our rules is added to the parentCollection, it should be added to the childCollection', ->
			# Add a model that passes the query to the parentCollection
			parentCollection.add(ajaxyModel)

			# Check the childCollection to see if it has the new model
			actual = childCollection.toJSON()
			expected = [modelsObject.jquery, modelsObject.history, ajaxyModel]
			assert.deepEqual(actual, expected)

		# test add fail checker
		test 'when a model that fails our rules is added to the parentCollection, it should NOT be added to the childCollection', ->
			# Add a model that fails the query to the parentCollection
			parentCollection.add(pokemonModel)

			# Check the childCollection to see if it has the new model
			actual = childCollection.toJSON()
			expected = [modelsObject.jquery, modelsObject.history, ajaxyModel]
			assert.deepEqual(actual, expected)

		# test remove check
		test 'when a model is removed from our parentCollection, it should be removed from our childCollection', ->
			# Remove history from the parentCollection
			parentCollection.remove(parentCollection.get('history'))

			# Check the childCollection to see if  history has been removed
			actual = childCollection.toJSON()
			expected = [modelsObject.jquery, ajaxyModel]
			assert.deepEqual(actual, expected)

		# test change remove check
		test 'when a model is changed from our parentCollection (and no longer supports our rules), it should be removed from our childCollection', ->
			# Change the jquery model so it no longer has the jquery tag
			# thus making it no longer be applicable to the parentCollection
			parentCollection.get('jquery').set('tags',[])

			# Check the childCollection to see if  history has been removed
			actual = childCollection.toJSON()
			expected = [ajaxyModel]
			assert.deepEqual(actual, expected)

		# test change add check
		test 'when a model is changed from our parentCollection (and now supports our rules), it should be added to our childCollection', ->
			# Change the jquery model so it no longer has the jquery tag
			# thus making it no longer be applicable to the parentCollection
			parentCollection.get('jquery').set('tags',['jquery'])

			# Check the childCollection to see if  history has been removed
			actual = childCollection.toJSON()
			expected = [ajaxyModel, modelsObject.jquery]
			assert.deepEqual(actual, expected)

		# test reset check
		test 'when our parentCollection is reset, our childCollection should be reset too', ->
			# Reset the parentCollection
			parentCollection.reset([])

			# Check our childCollection
			actual = childCollection.toJSON()
			expected = []
			assert.deepEqual(actual, expected)

	suite 'parent collections: many levels', (suite,test) ->
		# Create a parentCollection with the models
		parentCollection = queryEngine.createCollection(models)

		# Create the child collections
		childCollectionLevel2 = parentCollection.findAllLive({tags: $has: ['jquery']})
		childCollectionLevel3 = childCollectionLevel2.findAllLive({tags: $has: ['html5']})
		childCollectionLevel4 = childCollectionLevel3.findAllLive({category: 1})

		# a change that removes from a parent collection should have the model removed from child collections
		test 'removes triggered by changes trickle through children correctly', ->
			# Perform a change on the history model
			parentCollection.where(id:'history')[0].set({'tags':['html5','history']})

			# Check our childCollection
			actual = childCollectionLevel4.toJSON()
			expected = []
			assert.deepEqual(actual, expected)

		# a change that adds to a parent collection should have the model added to child collections (if tests pass)
		test 'additions triggered by changes trickle through children correctly', ->
			# Reset the change
			parentCollection.where(id:'history')[0].set({'tags':['jquery','html5','history']})

			# Check our childCollection
			actual = childCollectionLevel4.toJSON()
			expected = [modelsObject.history]
			assert.deepEqual(actual, expected)




# Return
null
