# Fetch the globals
CoffeeScript = window.CoffeeScript
queryEngine = window.queryEngine
Js2coffee = window.Js2coffee

# Prepare the editors glboal
editors = window.editors = {}

# Load in the coffescript Ace editor mode
coffeeMode = require('ace/mode/coffee').Mode
coffeeModeInstance = new coffeeMode()

# Set pad widths to half of the screen
$(window)
	.resize ->
		padWidth = $(window).width()/2 - 20
		padHeight = $(window).height() - $('.header:first').height() - 80
		$('.pad,.editor').width(padWidth).height(padHeight)
	.trigger('resize')

# Create our two code editors
for key in ['code','result']
	# Create our editor
	editor = ace.edit(key)

	# Apply settings
	editor.setTheme 'ace/theme/textmate'
	editor.setShowPrintMargin(false)
	editor.getSession().setMode(coffeeModeInstance)
	editor.setHighlightActiveLine(true)
	editor.getSession().setTabSize(4)
	editor.getSession().setUseSoftTabs(false)

	# Assign to the global
	editors[key] = editor

# Run our code snippet and output the result
# We wrap in a try, as perhaps they have invalid syntax - in which case, we want to output the error to result instead
performQuery = ->
	try
		code = CoffeeScript.compile editors.code.getSession().getValue()
		inCollection = eval(code)
		resultCollection = queryEngine.createCollection(inCollection)
		resultCoffee = Js2coffee.build 'var result = ' + JSON.stringify resultCollection
		editors.result.getSession().setValue(resultCoffee)

	catch err
		errMessage = err.toString()
		console.log err
		editors.result.getSession().setValue(errMessage)

# Bind our change event to the code input
editors.code.getSession().on('change', performQuery)

# Set the example code value
editors.code.getSession().setValue """
	# Create a simple array of all our models
	models = [
			id: 'index'
			title: 'Index Page'
			content: 'this is the index page'
			tags: []
			position: 1
			category: 1
		,
			id: 'jquery'
			title: 'jQuery'
			content: 'this is about jQuery'
			tags: ['jquery']
			position: 2
			category: 1
		,
			id: 'history'
			title: 'History.js'
			content: 'this is about History.js'
			tags: ['jquery','html5','history']
			position: 3
			category: 1
	]


	# Perform a query to find only the items that have the tag "jquery"
	if true
		result = queryEngine.createCollection(models)
			.findAll({
				tags:
					$has: ['jquery']
			})
			.toJSON()

	# Perform the same query, but as a live collection
	else if true
		result = queryEngine.createLiveCollection()
			.setQuery('only jquery related', {
				tags:
					$has: ['jquery']
			})
			.add(models)
			.toJSON()

	# Perform a wildcard search
	else if true
		result = queryEngine.createLiveCollection()
			.setFilter('search', (model,searchString) ->
				searchRegex = queryEngine.createSafeRegex(searchString)
				pass = searchRegex.test(model.get('title')) or searchRegex.test(model.get('content'))
				return pass
			)
			.setSearchString('about') # try it with "this", or "the" as well :)
			.add(models)
			.toJSON()

	# Perform a pill search
	else if true
		result = queryEngine.createLiveCollection()
			.setPill('id', {
				prefixes: ['id:','#']
				callback: (model,value) ->
					pillRegex = queryEngine.createSafeRegex value
					pass = pillRegex.test(model.get('id'))
					return pass
			})
			.setSearchString('id:index') # try it with "#index" too!
			.add(models)
			.toJSON()

	# Otherwise return everything
	else
		result = []

	# Return our result
	return result
	"""