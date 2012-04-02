# Requires
assert = require('assert')
queryEngine = require("#{__dirname}/../lib/query-engine.coffee")
Backbone = require('backbone')


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
		content: 'this is the index page'
		tags: []
		position: 1
		category: 1
		date: today
	jquery:
		id: 'jquery'
		title: 'jQuery'
		content: 'this is about jQuery'
		tags: ['jquery']
		position: 2
		category: 1
		date: yesterday
	history:
		id: 'history'
		title: 'History.js'
		content: 'this is about History.js'
		tags: ['jquery','html5','history']
		position: 3
		category: 1
		date: tomorrow
	docpad:
		id: 'docpad'
		title: 'DocPad'
		content: 'this is about DocPad'
		tags: ['nodejs']
		position: 1
		category: 2
		date: today

# Models Array
models = queryEngine.toArray(modelsObject)


# =====================================
# Tests


describe 'live queries', ->

	# Perform a query to find only the items that have the tag "jquery"
	it 'should only keep jquery related models', ->
		# Perform the query
		collection = queryEngine.createLiveCollection()
			.setQuery('only jquery related', {
				tags:
					$has: ['jquery']
			})
			.add(models)

		# Check the result
		actual = collection.toJSON()
		expected = [modelsObject.jquery, modelsObject.history]
		assert.deepEqual actual, expected


	# Perform a wildcard search for "about"
	it 'should support searching', ->
		# Perform the query
		collection = queryEngine.createLiveCollection()
			.setFilter('search', (model,searchString) ->
				searchRegex = queryEngine.createSafeRegex searchString
				pass = searchRegex.test(model.get('title')) or searchRegex.test(model.get('content'))
				return pass
			)
			.setSearchString('about')
			.add(models)

		# Check the result
		actual = collection.toJSON()
		expected = [modelsObject.jquery, modelsObject.history, modelsObject.docpad]
		assert.deepEqual actual, expected


	# Perform a pill search for anything with the id of index
	it 'should support pill searches', ->
		# Perform the query
		collection = queryEngine.createLiveCollection()
			.setPill('id', {
				prefixes: ['id:','#']
				callback: (model,value) ->
					pillRegex = queryEngine.createSafeRegex value
					pass = pillRegex.test(model.get('id'))
					return pass
			})
			.setSearchString('id:index')
			.add(models)

		# Check the result
		actual = collection.toJSON()
		expected = [modelsObject.index]
		assert.deepEqual actual, expected


	# Perform a pill search and a filter
	it 'should support pills and searching at the same time', ->
		# Perform the query
		collection = queryEngine.createLiveCollection()
			.setFilter('search', (model,searchString) ->
				searchRegex = queryEngine.createSafeRegex searchString
				pass = searchRegex.test(model.get('content'))
				return pass
			)
			.setPill('category', {
				prefixes: ['category:']
				callback: (model,value) ->
					pillRegex = queryEngine.createSafeRegex value
					pass = pillRegex.test(model.get('category'))
					return pass
			})
			.setSearchString('category:1 about')
			.add(models)

		# Check the result
		actual = collection.toJSON()
		expected = [modelsObject.jquery, modelsObject.history]
		assert.deepEqual actual, expected


describe 'live parent queries', ->

	# Perform a query with a parent collection
	it 'should support parent collections', ->
		# Perform the query
		parentCollection = queryEngine.createCollection(models)
		collection = queryEngine.createLiveCollection()
			.setParentCollection(parentCollection)
			.setQuery('only jquery related', {
				tags:
					$has: ['jquery']
			})
			.query()

		# Add a model that passes the criteria
		ajaxyModel =
			id: 'ajaxy'
			title: 'jQuery Ajaxy'
			content: 'this is about jQuery Ajaxy'
			tags: ['jquery']
			position: 4
			category: 1
			date: yesterday
		parentCollection.add(ajaxyModel)

		# Check the result
		actual = collection.toJSON()
		expected = [modelsObject.jquery, modelsObject.history, ajaxyModel]
		assert.deepEqual actual, expected


# NEED TO TEST PARENT COLLECTIONS!!!!!


# Return
null