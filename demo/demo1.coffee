coffeeMode = require('ace/mode/coffee').Mode
coffeeModeInstance = new coffeeMode()
editors = window.editors = {}

for key in ['data','query','result']
	editor = ace.edit key
	editor.setTheme 'ace/theme/textmate'
	editor.setShowPrintMargin false
	editor.getSession().setMode coffeeModeInstance
	editor.setHighlightActiveLine true
	#editor.getSession().setUseWrapMode true
	editors[key] = editor
