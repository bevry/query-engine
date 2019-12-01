// Fetch the globals
const queryEngine = window.queryEngine;

// Prepare the editors global
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
function performQuery() {
	var code, err, errMessage, inCollection, resultCoffee, resultCollection;
	try {
		code = CoffeeScript.compile(editors.code.getSession().getValue());
		inCollection = eval(code);
		resultCollection = queryEngine.createCollection(inCollection);
		resultCoffee = Js2coffee.build(
			"var result = " + JSON.stringify(resultCollection)
		);
		return editors.result.getSession().setValue(resultCoffee);
	} catch (error) {
		err = error;
		errMessage = err.toString();
		console.log(err);
		return editors.result.getSession().setValue(errMessage);
	}
}

// Bind our change event to the code input
editors.code.getSession().on("change", performQuery);

// Set the example code value
const codeSample = "todo";
editors.code.getSession().setValue(codeSample);
