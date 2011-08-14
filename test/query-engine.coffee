# Requires
assert = require 'assert'
queryEngine = require __dirname+'/../lib/query-engine.coffee'
get = queryEngine.get
set = queryEngine.set
queryEngine.extendNatives()

# Variables
today = new Date()
today.setHours 0
today.setMinutes 0
today.setSeconds 0

# -------------------------------------
# Helpers

Object::getData = ->
	data = {}
	for own key, value of @
		if value.data?
			data[key] = value.data
		else
			data[key] = value
	data


# -------------------------------------
# Data

# Models
model = class
	data:
		id: null
		title: null
		content: null
		tags: []
		position: 1

	constructor: (data={}) ->
		for own key, value of @data
			if typeof data[key] is 'undefined'
				data[key] = value
		@data = data
	
	set: (key,value) ->
		@data[key] = value
	
	get: (key) ->
		@data[key]

# Store
store =
	associatedStandard:
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
			date: new Date()
		'history':
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 3
			category: 1
			date: new Date()

	associatedModels:
		'index': new model
			id: 'index'
			title: 'Index Page'
			content: 'this is the index page'
			tags: []
			position: 1
			category: 1
			date: today
		'jquery': new model
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 2
			category: 1
			date: new Date()
		'history': new model
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 3
			category: 1
			date: new Date()


# -------------------------------------
# Tests

# Test Suite
testSuite = {}

# Generate Test Suite
generateTestSuite = (name,docs) ->
	tests =
		'string': ->
			actual = docs.find id: 'index'
			expected = 'index': docs.index
			assert.deepEqual actual.getData(), expected.getData()
		
		'number': ->
			actual = docs.find position: 3
			expected = 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()
		
		'date': ->
			actual = docs.find date: today
			expected = 'index': docs.index
			assert.deepEqual actual.getData(), expected.getData()
		
		'regex': ->
			actual = docs.find id: /^[hj]/
			expected = 'jquery': docs.jquery, 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()
		
		'async': ->
			docs.find id: /^[hj]/, (err, actual, length) ->
				expected = 'jquery': docs.jquery, 'history': docs.history
				assert.deepEqual actual.getData(), expected.getData()
				assert.equal length, 2
		
		'joint': ->
			actual = docs.find id: 'index', category: 1
			expected = 'index': docs.index
			assert.deepEqual actual.getData(), expected.getData()
		
		'type-and': ->
			actual = docs.find $type: 'and', id: 'index', category: 1
			expected = 'index': docs.index
			assert.deepEqual actual.getData(), expected.getData()
		
		'type-or': ->
			actual = docs.find $type: 'or', id: 'index', position: 2
			expected = 'index': docs.index, 'jquery': docs.jquery
			assert.deepEqual actual.getData(), expected.getData()
		
		'type-nor': ->
			actual = docs.find $type: 'nor', id: 'index', position: 2
			expected = 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()
		
		'$and': ->
			actual = docs.find $all: [{id: 'index'}, {position: 2}]
			expected = {}
			assert.deepEqual actual.getData(), expected.getData()
		
		'$or': ->
			actual = docs.find $or: [{id: 'index'}, {position: 2}]
			expected = 'index': docs.index, 'jquery': docs.jquery
			assert.deepEqual actual.getData(), expected.getData()
		
		'$nor': ->
			actual = docs.find $nor: [{id: 'index'}, {position: 2}]
			expected = 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()
		
		'$ne': ->
			actual = docs.find id: $ne: 'index'
			expected = 'jquery': docs.jquery, 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()
		
		'$all': ->
			actual = docs.find tags: $all: ['jquery']
			expected = 'jquery': docs.jquery
			assert.deepEqual actual.getData(), expected.getData()
		
		'$in': ->
			actual = docs.find tags: $in: ['jquery']
			expected = 'jquery': docs.jquery, 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()

		'$nin': ->
			actual = docs.find tags: $nin: ['history']
			expected = 'index': docs.index, 'jquery': docs.jquery
			assert.deepEqual actual.getData(), expected.getData()

		'$size': ->
			actual = docs.find tags: $size: 3
			expected = 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()

		'$gt': ->
			actual = docs.find position: $gt: 2
			expected = 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()

		'$gt-date': ->
			actual = docs.find date: $gt: today
			expected = 'jquery': docs.jquery, 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()

		'$gte': ->
			actual = docs.find position: $gte: 2
			expected = 'jquery': docs.jquery, 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()

		'$lt': ->
			actual = docs.find position: $lt: 2
			expected = 'index': docs.index
			assert.deepEqual actual.getData(), expected.getData()

		'$lt-date': ->
			actual = docs.find date: $lt: today
			expected = {}
			assert.deepEqual actual.getData(), expected.getData()

		'$lte': ->
			actual = docs.find position: $lte: 2
			expected = 'index': docs.index, 'jquery': docs.jquery
			assert.deepEqual actual.getData(), expected.getData()

		'$lte-date': ->
			actual = docs.find date: $lte: today
			expected = 'index': docs.index
			assert.deepEqual actual.getData(), expected.getData()

		'all': ->
			actual = docs.find({})
			expected = docs
			assert.deepEqual actual.getData(), expected.getData()

		'sort-function': ->
			actual = docs.find({}).sort (a,b) ->
				return get(b,'position') - get(a,'position')
			expected = [docs.history,docs.jquery,docs.index]
			assert.deepEqual actual.getData(), expected.getData()

		'sort-object': ->
			actual = docs.find({}).sort position: -1
			expected = [docs.history,docs.jquery,docs.index]
			assert.deepEqual actual.getData(), expected.getData()

		'findOne': ->
			actual = docs.findOne()
			expected = docs.index
			assert.deepEqual actual.getData(), expected.getData()

		'remove': ->
			actual = docs.remove()
			expected = {}
			assert.deepEqual actual.getData(), expected.getData()
			assert.deepEqual docs, expected
	
	for own key, value of tests
		testSuite[name+'_'+key] = value

# Generate Suites
for own key, value of store
	generateTestSuite key, value


# -------------------------------------
# Export

# Export
module.exports = testSuite