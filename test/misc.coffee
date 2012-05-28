# Requires
assert = require('assert')
queryEngine = require(__dirname+'/../lib/query-engine.js')
Backbone = require('backbone')


# =====================================
# Configuration

describe 'misc', ->

	describe 'collection property', ->

		it 'when specificied, should create child collections of the property type', ->
			# Define a custom collection
			class MyQueryCollection extends queryEngine.QueryCollection
				collection: MyQueryCollection
				red: 'dog'

			# Create an instance of that collection
			# then create a child of that collection
			# and check that the child is an instance of our custom collection
			myQueryCollection = new MyQueryCollection()
			myChildCollection = myQueryCollection.createChildCollection()
			assert.ok(myChildCollection instanceof MyQueryCollection)

# Return
null