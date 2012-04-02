# Requires
assert = require('assert')
queryEngine = require("#{__dirname}/../lib/query-engine.coffee")
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
			position: 1
			category: 1
			date: today
		'jquery':
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 2
			category: 1
			date: yesterday
		'history':
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 3
			category: 1
			date: tomorrow

	associatedModels: queryEngine.createCollection 
		'index': new Backbone.Model
			id: 'index'
			title: 'Index Page'
			content: 'this is the index page'
			tags: []
			position: 1
			category: 1
			date: today
		'jquery': new Backbone.Model
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 2
			category: 1
			date: yesterday
		'history': new Backbone.Model
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 3
			category: 1
			date: tomorrow


# =====================================
# Tests

# Generate Test Suite
generateTestSuite = (name,docs) ->
	describe name, ->
		it 'beginsWith', ->
			actual = docs.findAll title: $beginsWith: 'Index'
			expected = queryEngine.createCollection 'index': docs.get('index')
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it 'endsWidth', ->
			actual = docs.findAll title: $endsWith: '.js'
			expected = queryEngine.createCollection 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it 'string', ->
			actual = docs.findAll id: 'index'
			expected = queryEngine.createCollection 'index': docs.get('index')
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it 'number', ->
			actual = docs.findAll position: 3
			expected = queryEngine.createCollection 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it 'date', ->
			actual = docs.findAll date: today
			expected = queryEngine.createCollection 'index': docs.get('index')
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it 'regex', ->
			actual = docs.findAll id: /^[hj]/
			expected = queryEngine.createCollection 'jquery': docs.get('jquery'), 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it 'joint', ->
			actual = docs.findAll id: 'index', category: 1
			expected = queryEngine.createCollection 'index': docs.get('index')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$and', ->
			actual = docs.findAll $all: [{id: 'index'}, {position: 2}]
			expected = queryEngine.createCollection()
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it '$or', ->
			actual = docs.findAll $or: [{id: 'index'}, {position: 2}]
			expected = queryEngine.createCollection 'index': docs.get('index'), 'jquery': docs.get('jquery')
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it '$nor', ->
			actual = docs.findAll $nor: [{id: 'index'}, {position: 2}]
			expected = queryEngine.createCollection 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it '$ne', ->
			actual = docs.findAll id: $ne: 'index'
			expected = queryEngine.createCollection 'jquery': docs.get('jquery'), 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it '$all', ->
			actual = docs.findAll tags: $all: ['jquery']
			expected = queryEngine.createCollection 'jquery': docs.get('jquery')
			assert.deepEqual actual.toJSON(), expected.toJSON()
		
		it '$in', ->
			actual = docs.findAll tags: $in: ['jquery']
			expected = queryEngine.createCollection 'jquery': docs.get('jquery'), 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$nin', ->
			actual = docs.findAll tags: $nin: ['history']
			expected = queryEngine.createCollection 'index': docs.get('index'), 'jquery': docs.get('jquery')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$size', ->
			actual = docs.findAll tags: $size: 3
			expected = queryEngine.createCollection 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$gt', ->
			actual = docs.findAll position: $gt: 2
			expected = queryEngine.createCollection 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$gt-date', ->
			actual = docs.findAll date: $gt: today
			expected = queryEngine.createCollection 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$gte', ->
			actual = docs.findAll position: $gte: 2
			expected = queryEngine.createCollection 'jquery': docs.get('jquery'), 'history': docs.get('history')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$lt', ->
			actual = docs.findAll position: $lt: 2
			expected = queryEngine.createCollection 'index': docs.get('index')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$lt-date', ->
			actual = docs.findAll date: $lt: today
			expected = queryEngine.createCollection 'jquery': docs.get('jquery')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$lte', ->
			actual = docs.findAll position: $lte: 2
			expected = queryEngine.createCollection 'index': docs.get('index'), 'jquery': docs.get('jquery')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it '$lte-date', ->
			actual = docs.findAll date: $lte: today
			expected = queryEngine.createCollection 'index': docs.get('index'), 'jquery': docs.get('jquery')
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it 'all', ->
			actual = docs
			expected = docs
			assert.deepEqual actual.toJSON(), expected.toJSON()

		it 'sort-numeric-function', ->
			actual = docs.sortArray (a,b) ->
				return b.position - a.position
			expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
			assert.deepEqual actual, expected.toJSON()

		it 'sort-numeric-object', ->
			actual = docs.sortArray position: -1
			expected = queryEngine.createCollection [docs.get('history'),docs.get('jquery'),docs.get('index')]
			assert.deepEqual actual, expected.toJSON()

		it 'sort-date-function', ->
			actual = docs.sortArray (a,b) ->
				return b.date - a.date
			expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
			assert.deepEqual actual, expected.toJSON()

		it 'sort-date-object', ->
			actual = docs.sortArray date: -1
			expected = queryEngine.createCollection [docs.get('history'),docs.get('index'),docs.get('jquery')]
			assert.deepEqual actual, expected.toJSON()

		it 'findOne', ->
			actual = docs.findOne()
			expected = docs.get('index')
			assert.deepEqual actual.toJSON(), expected.toJSON()

# Generate Suites
for own key, value of store
	generateTestSuite key, value

# Return
null