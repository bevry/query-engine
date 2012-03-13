editors = window.editors
CoffeeScript = window.CoffeeScript
queryEngine = window.queryEngine
Js2coffee = window.Js2coffee

performQuery = ->
	try
		code = CoffeeScript.compile editors.code.getSession().getValue()
		inCollection = eval(code)
		resultCollection = queryEngine.createCollection(inCollection)
		resultCoffee = Js2coffee.build 'var result = ' + JSON.stringify resultCollection
		editors.result.getSession().setValue resultCoffee

	catch err
		console.log err
		editors.result.getSession().setValue err.toString()

editors.code.getSession().on 'change', performQuery
performQuery()