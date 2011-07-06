# -------------------------------------
# Header

# Requires
assert = require 'assert'
queryEngine = require __dirname+'/../lib/query-engine.coffee'

# Prepare
data =
	documents:
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
			id: 'history.js'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 3

# -------------------------------------
# Tests

# Tests
tests =

	'string': ->
		actual = data.documents.find id: 'index'
		expected = 'index': data.documents.index
		assert.deepEqual actual, expected
	
	'number': ->
		actual = data.documents.find position: 3
		expected = 'history': data.documents.history
		assert.deepEqual actual, expected
	
	'regex': ->
		actual = data.documents.find id: /^[hj]/
		expected = 'jquery': data.documents.jquery, 'history': data.documents.history
		assert.deepEqual actual, expected
	
	'$ne': ->
		actual = data.documents.find id: $ne: 'index'
		expected = 'jquery': data.documents.jquery, 'history': data.documents.history
		assert.deepEqual actual, expected
	
	'$all': ->
		actual = data.documents.find tags: $all: ['jquery']
		expected = 'jquery': data.documents.jquery
		assert.deepEqual actual, expected
	
	'$in': ->
		actual = data.documents.find tags: $in: ['jquery']
		expected = 'jquery': data.documents.jquery, 'history': data.documents.history
		assert.deepEqual actual, expected

	'$nin': ->
		actual = data.documents.find tags: $nin: ['history']
		expected = 'index': data.documents.index, 'jquery': data.documents.jquery
		assert.deepEqual actual, expected

	'$size': ->
		actual = data.documents.find tags: $size: 3
		expected = 'history': data.documents.history
		assert.deepEqual actual, expected

	'$gt': ->
		actual = data.documents.find position: $gt: 2
		expected = 'history': data.documents.history
		assert.deepEqual actual, expected

	'$gte': ->
		actual = data.documents.find position: $gte: 2
		expected = 'jquery': data.documents.jquery, 'history': data.documents.history
		assert.deepEqual actual, expected

	'$lt': ->
		actual = data.documents.find position: $lt: 2
		expected = 'index': data.documents.index
		assert.deepEqual actual, expected

	'$lte': ->
		actual = data.documents.find position: $lte: 2
		expected = 'index': data.documents.index, 'jquery': data.documents.jquery
		assert.deepEqual actual, expected

	'all': ->
		actual = data.documents.find({})
		expected = data.documents
		assert.deepEqual actual, expected

	'sort': ->
		actual = data.documents.find({}).sort (a,b) ->
			return b.position - a.position
		expected = [data.documents.history,data.documents.jquery,data.documents.index]
		assert.deepEqual actual, expected

	'findOne': ->
		actual = data.documents.findOne()
		expected = data.documents.index
		assert.deepEqual actual, expected

	'remove': ->
		actual = data.documents.remove()
		expected = {}
		assert.deepEqual actual, expected
		assert.deepEqual data.documents, expected

# Export
module.exports = tests
