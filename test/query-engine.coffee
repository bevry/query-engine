# Requires
assert = require 'assert'
queryEngine = require __dirname+'/../lib/query-engine.coffee'
get = queryEngine.get
set = queryEngine.set


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
		'jquery':
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 2
		'history':
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 3

	associatedModels:
		'index': new model
			id: 'index'
			title: 'Index Page'
			content: 'this is the index page'
			tags: []
			position: 1
		'jquery': new model
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 2
		'history': new model
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 3


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
		
		'regex': ->
			actual = docs.find id: /^[hj]/
			expected = 'jquery': docs.jquery, 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()
		
		'async': ->
			docs.find id: /^[hj]/, (err, actual, length) ->
				expected = 'jquery': docs.jquery, 'history': docs.history
				assert.deepEqual actual.getData(), expected.getData()
				assert.equal length, 2
		
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

		'$gte': ->
			actual = docs.find position: $gte: 2
			expected = 'jquery': docs.jquery, 'history': docs.history
			assert.deepEqual actual.getData(), expected.getData()

		'$lt': ->
			actual = docs.find position: $lt: 2
			expected = 'index': docs.index
			assert.deepEqual actual.getData(), expected.getData()

		'$lte': ->
			actual = docs.find position: $lte: 2
			expected = 'index': docs.index, 'jquery': docs.jquery
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