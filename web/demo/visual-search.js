// Fetch the globals
const queryEngine = window.queryEngine;

// Prepare the editors glboal
const editors = (window.editors = {});

// Set pad widths to half of the screen
$(window)
	.resize(function() {
		var padHeight, padWidth;
		padWidth = $(window).width() / 2 - 20;
		padHeight = $(window).height() - $(".header:first").height() - 80;
		return $(".pad,.editor")
			.width(padWidth)
			.height(padHeight);
	})
	.trigger("resize");

// Disable backspace redirect as it happens often
$(document).keydown(function(e) {
	var isInput;
	isInput = $(document.activeElement).is(":input");
	if (e.keyCode === 8 && !isInput) {
		return e.preventDefault();
	}
});

// Create our two code editors
for (const key of ["code", "result"]) {
	// Create our editor
	const editor = ace.edit(key);
	// Apply settings
	editor.setTheme("ace/theme/textmate");
	editor.setShowPrintMargin(false);
	editor.getSession().setMode(coffeeModeInstance);
	editor.setHighlightActiveLine(true);
	editor.getSession().setTabSize(4);
	editor.getSession().setUseSoftTabs(false);
	// Assign to the global
	editors[key] = editor;
}

// Run our code snippet and output the result
// We wrap in a try, as perhaps they have invalid syntax - in which case, we want to output the error to result instead
function codeChanged() {
	var codeCoffeeScript, codeJavaScript, collection, err, errMessage;
	try {
		codeCoffeeScript = editors.code.getSession().getValue();
		codeJavaScript = CoffeeScript.compile(codeCoffeeScript);
		collection = eval(codeJavaScript);
		return updateResults(collection);
	} catch (error) {
		err = error;
		errMessage = err.stack.toString();
		console.log(errMessage);
		return editors.result.getSession().setValue(errMessage);
	}
}

function updateResults(collection) {
	var resultArray, resultCoffee, resultJavaScript;
	resultArray = collection != null ? collection.toJSON() : void 0;
	resultJavaScript = JSON.stringify(resultArray);
	resultCoffee = Js2coffee.build(`var result = ${resultJavaScript}`);
	return editors.result.getSession().setValue(resultCoffee);
}

// Bind our change event to the code input
editors.code.getSession().on("change", codeChanged);

// Set the example code value
const sample = "todo";
editors.code.getSession().setValue(sample);
