# Requires
queryEngine = @queryEngine or require('../')
assert = @assert or require('assert')
Backbone = @Backbone or (try require?('backbone')) or (try require?('exoskeleton')) or (throw 'Need Backbone or Exoskeleton')
kava = @kava or require('kava')

# =====================================
# Configuration

# -------------------------------------
# Variables

today = new Date()
today.setHours 0
today.setMinutes 0
today.setSeconds 0
tomorrow = new Date()
tomorrow.setDate(today.getDate()+1)
yesterday = new Date()
yesterday.setDate(today.getDate()-1)


# -------------------------------------
# Data

# Store
store =
	associatedStandard: queryEngine.createCollection(
		'index':
			id: 'index'
			title: 'Index Page'
			content: 'this is the index page'
			tags: []
			position: 2
			category: 1
			date: today
			good: true
			order: 1
		'jquery':
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 3
			category: 1
			date: yesterday
			good: false
			order: 2
		'history':
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 4
			category: 1
			date: tomorrow
			order: 3
	)

	associatedModels: queryEngine.createCollection(
		'index': new Backbone.Model
			id: 'index'
			title: 'Index Page'
			content: 'this is the index page'
			tags: []
			position: 2
			category: 1
			date: today
			good: true
			order: 1
		'jquery': new Backbone.Model
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 3
			category: 1
			date: yesterday
			good: false
			order: 2
		'history': new Backbone.Model
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 4
			category: 1
			date: tomorrow
			order: 3
	)


# =====================================
# Tests

# Generate Test Suite
generateTestSuite = (suite, test, collectionName, docs) ->
	suite collectionName, (suite, test) ->
		suite 'sortArray', (suite, test) ->
			test 'string-object', ->
				actual = queryEngine.createCollection(docs.models).sortArray(title: 1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual, expected.toJSON())

			test 'numeric-function', ->
				actual = queryEngine.createCollection(docs.models).sortArray (a,b) -> return b.position - a.position
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual, expected.toJSON())

			test 'numeric-object', ->
				actual = queryEngine.createCollection(docs.models).sortArray(position: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual, expected.toJSON())

			test 'date-function', ->
				actual = queryEngine.createCollection(docs.models).sortArray (a,b) -> return b.date - a.date
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual, expected.toJSON())

			test 'date-object', ->
				actual = queryEngine.createCollection(docs.models).sortArray(date: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual, expected.toJSON())

		suite 'sortCollection', (suite, test) ->
			test 'numeric-function', ->
				actual = queryEngine.createCollection(docs.models).sortCollection (a,b) -> return b.get('position') - a.get('position')
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			test 'numeric-object', ->
				actual = queryEngine.createCollection(docs.models).sortCollection(position: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			test 'date-function', ->
				actual = queryEngine.createCollection(docs.models).sortCollection (a,b) -> return b.get('date') - a.get('date')
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			test 'date-object', ->
				actual = queryEngine.createCollection(docs.models).sortCollection(date: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

		suite 'queryArray', (suite, test) ->
			test 'queryArray', ->
				actual = queryEngine.createCollection(docs.models)
					.queryArray({tags:$has:'jquery'},{position:-1})
				expected = queryEngine.createCollection([docs.get('history'),docs.get('jquery')]).toJSON()
				assert.deepEqual(actual, expected)

			test 'queryArray-paging', ->
				actual = queryEngine.createCollection(docs.models)
					.queryArray({tags:$has:'jquery'},{position:-1},{limit:1})
				expected = queryEngine.createCollection([docs.get('history')]).toJSON()
				assert.deepEqual(actual, expected)

		suite 'findAll', (suite, test) ->
			test 'findAll', ->
				actual = queryEngine.createCollection(docs.models)
					.findAll({tags:$has:'jquery'},{position:-1})
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			test 'findAll-paging', ->
				actual = queryEngine.createCollection(docs.models)
					.findAll({tags:$has:'jquery'},{position:-1},{limit:1})
				expected = queryEngine.createCollection [docs.get('history')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

		suite 'findAllLive', (suite, test) ->
			test 'findAllLive', ->
				actual = (parent = queryEngine.createCollection())
					.findAllLive({tags:$has:'jquery'},{position:-1})
				parent.add(docs.models)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			test 'findAllLive-paging', ->
				actual = (parent = queryEngine.createCollection())
					.findAllLive({tags:$has:'jquery'},{position:-1},{limit:1})
				parent.add(docs.models)
				expected = queryEngine.createCollection [docs.get('history')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

		suite 'comparator', (suite, test) ->
			test 'live-onadd', ->
				actual = queryEngine.createLiveCollection()
					.setComparator(position: -1)
					.add(docs.models)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			test 'live-onchange', ->
				actual = queryEngine.createLiveCollection()
					.setComparator(position:-1)
					.add(docs.models)
				actual.at(0).set({'position':0})
				expected = queryEngine.createCollection [docs.get('jquery'),docs.get('index'),docs.get('history')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

# Generate Suites
kava.suite 'sort', (suite,test) ->
	for own collectionName, docs of store
		generateTestSuite(suite,test,collectionName,docs)

# Return
null
