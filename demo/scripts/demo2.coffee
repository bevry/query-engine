# Fetch the globals
editors = window.editors
CoffeeScript = window.CoffeeScript
queryEngine = window.queryEngine
Js2coffee = window.Js2coffee

# Run our code snippet and output the result
# We wrap in a try, as perhaps they have invalid syntax - in which case, we want to output the error to result instead
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

# Bind our change event to the code input
editors.code.getSession().on 'change', performQuery

# Perform the initial query
performQuery()