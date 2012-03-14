# Load in the coffescript Ace editor mode
coffeeMode = require('ace/mode/coffee').Mode
coffeeModeInstance = new coffeeMode()

# Prepare the editors glboal
editors = window.editors = {}

# Create our two code editors
for key in ['code','result']
	# Create our editor
	editor = ace.edit key

	# Apply settings
	editor.setTheme 'ace/theme/textmate'
	editor.setShowPrintMargin false
	editor.getSession().setMode coffeeModeInstance
	editor.setHighlightActiveLine true
	editor.getSession().setTabSize 4
	editor.getSession().setUseSoftTabs false

	# Assign to the global
	editors[key] = editor
