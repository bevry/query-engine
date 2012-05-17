# Requires
assert = require('assert')
queryEngine = require(__dirname+'/../lib/query-engine.js')
Backbone = require('backbone')


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
	associatedStandard: queryEngine.createCollection
		'index':
			id: 'index'
			title: 'Index Page'
			content: 'this is the index page'
			tags: []
			position: 2
			category: 1
			date: today
			good: true
		'jquery':
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 3
			category: 1
			date: yesterday
			good: false
		'history':
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 4
			category: 1
			date: tomorrow

	associatedModels: queryEngine.createCollection
		'index': new Backbone.Model
			id: 'index'
			title: 'Index Page'
			content: 'this is the index page'
			tags: []
			position: 2
			category: 1
			date: today
			good: true
		'jquery': new Backbone.Model
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 3
			category: 1
			date: yesterday
			good: false
		'history': new Backbone.Model
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 4
			category: 1
			date: tomorrow


# =====================================
# Tests

# Generate Test Suite
generateTestSuite = (collectionName,docs) ->
	describe collectionName, ->
		describe 'sortArray', ->
			it 'numeric-function', ->
				actual = docs.sortArray (a,b) -> return b.position - a.position
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual, expected.toJSON())

			it 'numeric-object', ->
				actual = docs.sortArray(position: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual, expected.toJSON())

			it 'date-function', ->
				actual = docs.sortArray (a,b) -> return b.date - a.date
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual, expected.toJSON())

			it 'date-object', ->
				actual = docs.sortArray(date: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual, expected.toJSON())

		describe 'sortCollection', ->
			it 'numeric-function', ->
				actual = docs.sortCollection (a,b) -> return b.get('position') - a.get('position')
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'numeric-object', ->
				actual = docs.sortCollection(position: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'date-function', ->
				actual = docs.sortCollection (a,b) -> return b.get('date') - a.get('date')
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'date-object', ->
				actual = docs.sortCollection(date: -1)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'live-onadd', ->
				actual = queryEngine.createLiveCollection().setComparator(position: -1).add(docs.models)
				expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

			it 'live-onchange', ->
				actual = queryEngine.createLiveCollection().setComparator(position:-1).add(docs.models)
				actual.at(0).set({'position':0})
				expected = queryEngine.createCollection [docs.get('jquery'),docs.get('index'),docs.get('history')]
				assert.deepEqual(actual.toJSON(), expected.toJSON())

# Generate Suites
describe 'sort', ->
	for own key, value of store
		generateTestSuite(key,value)

# Return
null