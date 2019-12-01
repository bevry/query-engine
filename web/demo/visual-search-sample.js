// Create our project collection from an array of models
// and set several pills that we can use for searching
var $searchbar,
	$visualsearch,
	projectCollection,
	projectSearchCollection,
	visualsearch,
	indexOf = [].indexOf;

projectCollection = window.queryEngine.createLiveCollection([
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

projectSearchCollection = projectCollection
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
			var pass;
			pass = indexOf.call(model.get("tags"), value) >= 0;
			return pass;
		}
	})
	.setPill("title", {
		prefixes: ["title:"],
		callback: function(model, value) {
			var pass;
			pass = model.get("title") === value;
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

// Setup Visual Search
$searchbar = $("#searchbar").empty();

$visualsearch = $("<div>").appendTo($searchbar);

visualsearch = window.VS.init({
	container: $visualsearch,
	callbacks: {
		search: function(searchString, searchCollection) {
			searchString = "";
			searchCollection.forEach(function(pill) {
				var category, value;
				category = pill.get("category");
				value = pill.get("value");
				if (category !== "text") {
					return (searchString += " " + category + ':"' + value + '"');
				} else {
					return (searchString += " " + value);
				}
			});
			return window.updateResults(
				projectSearchCollection.setSearchString(searchString).query()
			);
		},
		facetMatches: function(callback) {
			var pillNames, pills;
			pills = projectSearchCollection.getPills();
			pillNames = _.keys(pills);
			return callback(pillNames);
		},
		valueMatches: function(facet, searchTerm, callback) {
			var i, ids, len, model, ref;
			switch (facet) {
				case "id":
					ids = [];
					ref = projectCollection.models;
					for (i = 0, len = ref.length; i < len; i++) {
						model = ref[i];
						ids.push(String(model.id));
					}
					return callback(ids);
				case "tag":
					return callback(_.uniq(_.flatten(projectCollection.pluck("tags"))));
				case "title":
					return callback(projectCollection.pluck("title"));
			}
		}
	}
});

visualsearch.searchBox.value('tag:"node.js"');

return projectSearchCollection;
