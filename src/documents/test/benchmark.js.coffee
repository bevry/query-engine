queryEngine = require?(__dirname+'/../lib/query-engine') or @queryEngine
Benchmark = require('benchmark')

console.log('Benchmarking...')
suite = new Benchmark.Suite()

models = []
for i in [0..1000]
	models.push(
		name: "Name #{i}"
		description: Math.random()
		second: !!(i % 2)
		third: !!(i % 3)
	)
collection = new queryEngine.QueryCollection(models)

suite.add '$or', ->
	collection.findAll({
		$or: [
			{second: true},
			{third: true}
		]
	})

suite.add '$and', ->
	collection.findAll({
		second: true
		third: true
	})

suite.add '$and - one', ->
	collection.findOne({
		second: true
		third: true
	})

suite
	.on 'cycle', (event) ->
		console.log(String(event.target))
	.on 'complete', ->
		console.log('Fastest is ' + this.filter('fastest').pluck('name'))

suite.run()