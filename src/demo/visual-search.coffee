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

# Disable backspace redirect as it happens often
$(document).keydown (e) ->
	isInput = $(document.activeElement).is(':input')
	e.preventDefault()  if e.keyCode is 8 and not isInput

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
codeChanged = ->
	try
		codeCoffeeScript = editors.code.getSession().getValue()
		codeJavaScript = CoffeeScript.compile(codeCoffeeScript)
		collection = eval(codeJavaScript)
		window.updateResults(collection)
	catch err
		errMessage = err.stack.toString()
		console.log(errMessage)
		editors.result.getSession().setValue(errMessage)
window.updateResults = (collection) ->
	resultArray = collection?.toJSON()
	resultJavaScript = JSON.stringify(resultArray)
	resultCoffee = Js2coffee.build("var result = #{resultJavaScript}")
	editors.result.getSession().setValue(resultCoffee)

# Bind our change event to the code input
editors.code.getSession().on('change', codeChanged)

# Set the example code value
editors.code.getSession().setValue """
	# Create our project collection from an array of models
	# and set several pills that we can use for searching
	projectCollection = window.queryEngine.createLiveCollection([
				id: 1
				title: "Query Engine"
				tags: ["backbone", "node.js"]
				description: "Query-Engine provides extensive Querying, Filtering, and Searching abilities for Backbone.js Collections as well as JavaScript arrays and objects"
			,
				id: 2
				title: "Joe"
				tags: ["testing", "node.js"]
				description: "Node.js asynchronous testing framework, runner and reporter"
		])
	projectSearchCollection = projectCollection.createLiveChildCollection()
		.setPill('id', {
			prefixes: ['id:']
			callback: (model,value) ->
				pass = model.get('id') is parseInt(value,10)
				return pass
		})
		.setPill('tag', {
			logicalOperator: 'AND'
			prefixes: ['tag:']
			callback: (model,value) ->
				pass = value in model.get('tags')
				return pass
		})
		.setPill('title', {
			prefixes: ['title:']
			callback: (model,value) ->
				pass = model.get('title') is value
				return pass
		})
		.setFilter('search', (model,searchString) ->
			searchRegex = queryEngine.createSafeRegex(searchString)
			pass = searchRegex.test(model.get('description'))
			return pass
		)
		.query()

	# Setup Visual Search
	$searchbar = $('#searchbar').empty()
	$visualsearch = $('<div>').appendTo($searchbar)
	visualsearch = window.VS.init({
		container: $visualsearch
		callbacks:
			search: (searchString, searchCollection) ->
				searchString = ""
				searchCollection.forEach (pill) ->
					category = pill.get("category")
					value = pill.get("value")
					if category isnt "text"
						searchString += " " + category + ":\\"" + value + "\\""
					else
						searchString += " " + value
				window.updateResults  projectSearchCollection.setSearchString(searchString).query()

			facetMatches: (callback) ->
				pills = projectSearchCollection.getPills()
				pillNames = _.keys(pills)
				callback(pillNames)

			valueMatches: (facet, searchTerm, callback) ->
				switch facet
					when 'id'
						ids = []
						ids.push(String(model.id))  for model in projectCollection.models
						callback(ids)
					when 'tag'
						callback  _.uniq  _.flatten  projectCollection.pluck('tags')
					when 'title'
						callback  projectCollection.pluck('title')
	})
	visualsearch.searchBox.value('tag:"node.js"');


	# Return our project collection
	return projectSearchCollection
	"""