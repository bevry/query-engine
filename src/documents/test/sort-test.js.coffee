# Requires
queryEngine = require?(__dirname+'/../lib/query-engine') or @queryEngine
assert = require?('assert') or @assert
Backbone = require?('backbone') or @Backbone
joe = require?('joe') or @joe
{describe} = joe


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
generateTestSuite = (describe, it, collectionName, docs) ->
	describe collectionName, (describe,it) ->
		describe 'sortArray', (describe,it) ->
			it 'string-object', ->
				actual = queryEngine.createCollection(docs.models).sortArray(title: 1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual, expected.toJSON())

			it 'numeric-function', ->
				actual = queryEngine.createCollection(docs.models).sortArray (a,b) -> return b.position - a.position
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual, expected.toJSON())

			it 'numeric-object', ->
				actual = queryEngine.createCollection(docs.models).sortArray(position: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual, expected.toJSON())

			it 'date-function', ->
				actual = queryEngine.createCollection(docs.models).sortArray (a,b) -> return b.date - a.date
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual, expected.toJSON())

			it 'date-object', ->
				actual = queryEngine.createCollection(docs.models).sortArray(date: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual, expected.toJSON())

		describe 'sortCollection', (describe,it) ->
			it 'numeric-function', ->
				actual = queryEngine.createCollection(docs.models).sortCollection (a,b) -> return b.get('position') - a.get('position')
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'numeric-object', ->
				actual = queryEngine.createCollection(docs.models).sortCollection(position: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'date-function', ->
				actual = queryEngine.createCollection(docs.models).sortCollection (a,b) -> return b.get('date') - a.get('date')
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'date-object', ->
				actual = queryEngine.createCollection(docs.models).sortCollection(date: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

		describe 'queryArray', (describe,it) ->
			it 'queryArray', ->
				actual = queryEngine.createCollection(docs.models)
					.queryArray({tags:$has:'jquery'},{position:-1})
				expected = queryEngine.createCollection([docs.get('history'),docs.get('jquery')]).toJSON()
				assert.deepEqual(actual, expected)

			it 'queryArray-paging', ->
				actual = queryEngine.createCollection(docs.models)
					.queryArray({tags:$has:'jquery'},{position:-1},{limit:1})
				expected = queryEngine.createCollection([docs.get('history')]).toJSON()
				assert.deepEqual(actual, expected)

		describe 'findAll', (describe,it) ->
			it 'findAll', ->
				actual = queryEngine.createCollection(docs.models)
					.findAll({tags:$has:'jquery'},{position:-1})
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'findAll-paging', ->
				actual = queryEngine.createCollection(docs.models)
					.findAll({tags:$has:'jquery'},{position:-1},{limit:1})
				expected = queryEngine.createCollection [docs.get('history')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

		describe 'comparator', (describe,it) ->
			it 'live-onadd', ->
				actual = queryEngine.createLiveCollection()
					.setComparator(position: -1)
					.add(docs.models)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'live-onchange', ->
				actual = queryEngine.createLiveCollection()
					.setComparator(position:-1)
					.add(docs.models)
				actual.at(0).set({'position':0})
				expected = queryEngine.createCollection [docs.get('jquery'),docs.get('index'),docs.get('history')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

# Generate Suites
describe 'sort', (describe,it) ->
	for own collectionName, docs of store
		generateTestSuite(describe,it,collectionName,docs)

# Return
null