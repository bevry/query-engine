// Create our project collection from an array of models
// and set several pills that we can use for searching
const projectCollection = window.queryEngine.createLiveCollection([
	{
		id: 1,
		title: "Query Engine",
		tags: ["backbone", "node.js"],
		description:
			"Query-Engine provides extensive Querying, Filtering, and Searching abilities for Backbone.js Collections as well as JavaScript arrays and objects"
	},
	{
		id: 2,
		title: "Joe",
		tags: ["testing", "node.js"],
		description: "Node.js asynchronous testing framework, runner and reporter"
	}
]);

const projectSearchCollection = projectCollection
	.createLiveChildCollection()
	.setPill("id", {
		prefixes: ["id:"],
		callback: function(model, value) {
			var pass;
			pass = model.get("id") === parseInt(value, 10);
			return pass;
		}
	})
	.setPill("tag", {
		logicalOperator: "AND",
		prefixes: ["tag:"],
		callback: function(model, value) {
			var i, len, pass, ref, searchRegex, tag;
			ref = model.get("tags");
			for (i = 0, len = ref.length; i < len; i++) {
				tag = ref[i];
				searchRegex = queryEngine.createSafeRegex(value);
				pass = searchRegex.test(tag);
				if (pass) {
					break;
				}
			}
			return pass;
		}
	})
	.setPill("title", {
		prefixes: ["title:"],
		callback: function(model, value) {
			var pass, valueRegex;
			valueRegex = queryEngine.createSafeRegex(value);
			pass = valueRegex.test(model.get("title"));
			return pass;
		}
	})
	.setFilter("search", function(model, searchString) {
		var pass, searchRegex;
		if (searchString == null) {
			return true;
		}
		searchRegex = queryEngine.createSafeRegex(searchString);
		pass = searchRegex.test(model.get("description"));
		return pass;
	})
	.query();

// Setup Search
const $searchbar = $("#searchbar").val("tag:node.js");

$searchbar.off("keyup").on("keyup", function(event) {
	var searchString;
	searchString = $(this).val();
	return window.updateResults(
		projectSearchCollection.setSearchString(searchString).query()
	);
});

// Return our project collection
return projectSearchCollection;
