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

# Models Array
modelsArray = queryEngine.toArray(modelsObject)


# =====================================
# Tests


describe 'live queries', ->
	it 'should only keep jquery related models', ->
		# Create the live collection
		liveCollection = queryEngine.createLiveCollection()

		# Set a filter on it
		liveCollection.setQuery 'only jquery related', tags: $has: 'jquery'

		# Add our models
		liveCollection.add(modelsArray)

		# Check that they are as expected
		actual = liveCollection.toJSON()
		expected = [modelsObject.jquery, modelsObject.history]
		assert.deepEqual actual, expected



# Return
null