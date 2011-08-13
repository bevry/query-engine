editors = window.editors

performQuery = ->
	try
		data = window.CoffeeScript.eval 'return '+editors.data.getSession().getValue()
		query = window.CoffeeScript.eval 'return (collection) -> '+editors.query.getSession().getValue()
		result = window.Js2coffee.build 'var result = ' + JSON.stringify query(new window.queryEngine.Collection data)
		editors.result.getSession().setValue result
		console.log 'updated'

	catch err
		console.log err
		editors.result.getSession().setValue err.toString()

editors.data.getSession().on 'change', performQuery
editors.query.getSession().on 'change', performQuery

performQuery()