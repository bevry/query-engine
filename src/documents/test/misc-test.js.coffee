# Requires
queryEngine = @queryEngine or require(__dirname+'/../lib/query-engine')
assert = @assert or require('assert')
Backbone = @Backbone or (try require?('backbone')) or (try require?('exoskeleton')) or (throw 'Need Backbone or Exoskeleton')
joe = @joe or require('joe')
{describe} = joe


# =====================================
# Configuration

describe 'misc', (describe,it) ->

	describe 'collection property', (describe,it) ->

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