// Create a simple array of all our models
const models = [
  {
    id: 'index',
    title: 'Index Page',
    content: 'this is the index page',
    tags: [],
    position: 1,
    category: 1
  },
  {
    id: 'jquery',
    title: 'jQuery',
    content: 'this is about jQuery',
    tags: ['jquery'],
    position: 2,
    category: 1
  },
  {
    id: 'history',
    title: 'History.js',
    content: 'this is about History.js',
    tags: ['jquery',
  'html5',
  'history'],
    position: 3,
    category: 1
  }
];

// Perform a query to find only the items that have the tag "jquery"
let result
if (true) {
  result = queryEngine.createCollection(models).findAll({
    tags: {
      $has: ['jquery']
    }
  }).toJSON();
// Perform the same query, but as a live collection
} else if (true) {
  result = queryEngine.createLiveCollection().setQuery('only jquery related', {
    tags: {
      $has: ['jquery']
    }
  }).add(models).toJSON();
// Perform a wildcard search
} else if (true) {
  result = queryEngine.createLiveCollection().setFilter('search', function(model, searchString) {
    var pass, searchRegex;
    searchRegex = queryEngine.createSafeRegex(searchString);
    pass = searchRegex.test(model.get('title')) || searchRegex.test(model.get('content'));
    return pass;
  }).setSearchString('about').add(models).toJSON(); // try it with "this", or "the" as well :)
// Perform a pill search
} else if (true) {
  result = queryEngine.createLiveCollection().setPill('id', {
    prefixes: ['id:', '#'],
    callback: function(model, value) {
      var pass, pillRegex;
      pillRegex = queryEngine.createSafeRegex(value);
      pass = pillRegex.test(model.get('id'));
      return pass;
    }
  }).setSearchString('id:index').add(models).toJSON(); // try it with "#index" too!
} else {
  // Otherwise return everything
  result = [];
}

// Return our result
return result;
