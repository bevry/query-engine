# Requires
queryEngine = @queryEngine or require('../')
assert = @assert or require('assert')
Backbone = @Backbone or (try require?('backbone')) or (try require?('exoskeleton')) or (throw 'Need Backbone or Exoskeleton')
kava = @kava or require('kava')



# =====================================
# Fixtures

# Store
store = {}
store.models = {}

# Collection
store.collection = new queryEngine.QueryCollection()

# Models
store.models.a = new Backbone.Model
	id: 'a'

store.models.b = new Backbone.Model
	id: 'b'

store.models.c = new Backbone.Model
	id: 'c'

# Create references
store.models.a.set(friend: store.models.b, parent: store.collection)
store.models.b.set(friend: store.models.a, parent: store.collection)
# ignore c

# Add models to collection
store.collection.add([store.models.a, store.models.b, store.models.c])



# =====================================
# Tests

# Nested Test Suite
kava.suite 'nested', (suite,test) ->
	suite 'models', (suite,test) ->
		test 'a references b', ->
			actual = store.collection.findAll(friend: store.models.b)
			expected = queryEngine.createCollection [store.models.a]
			assert.deepEqual(actual.toJSON(), expected.toJSON())

		test 'b references a', ->
			actual = store.collection.findAll(friend: store.models.a)
			expected = queryEngine.createCollection [store.models.b]
			assert.deepEqual(actual.toJSON(), expected.toJSON())

		test 'a and b reference collection', ->
			actual = store.collection.findAll(parent: store.collection)
			expected = queryEngine.createCollection [store.models.a, store.models.b]
			assert.deepEqual(actual.toJSON(), expected.toJSON())

# Return
null
