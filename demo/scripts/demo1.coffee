coffeeMode = require('ace/mode/coffee').Mode
coffeeModeInstance = new coffeeMode()
editors = window.editors = {}

for key in ['code','result']
	editor = ace.edit key
	editor.setTheme 'ace/theme/textmate'
	editor.setShowPrintMargin false
	editor.getSession().setMode coffeeModeInstance
	editor.setHighlightActiveLine true
	editor.getSession().setTabSize 4
	editor.getSession().setUseSoftTabs false
	editors[key] = editor
