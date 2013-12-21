(function() {
  var Backbone, assert, describe, joe, queryEngine, store;

  queryEngine = this.queryEngine || require(__dirname + '/../lib/query-engine');

  assert = this.assert || require('assert');

  Backbone = this.Backbone || ((function() {
    try {
      return typeof require === "function" ? require('backbone') : void 0;
    } catch (_error) {}
  })()) || ((function() {
    try {
      return typeof require === "function" ? require('exoskeleton') : void 0;
    } catch (_error) {}
  })()) || ((function() {
    throw 'Need Backbone or Exoskeleton';
  })());

  joe = this.joe || require('joe');

  describe = joe.describe;

  store = {};

  store.models = {};

  store.collection = new queryEngine.QueryCollection();

  store.models.a = new Backbone.Model({
    id: 'a'
  });

  store.models.b = new Backbone.Model({
    id: 'b'
  });

  store.models.c = new Backbone.Model({
    id: 'c'
  });

  store.models.a.set({
    friend: store.models.b,
    parent: store.collection
  });

  store.models.b.set({
    friend: store.models.a,
    parent: store.collection
  });

  store.collection.add([store.models.a, store.models.b, store.models.c]);

  describe('nested', function(describe, it) {
    return describe('models', function(describe, it) {
      it('a references b', function() {
        var actual, expected;
        actual = store.collection.findAll({
          friend: store.models.b
        });
        expected = queryEngine.createCollection([store.models.a]);
        return assert.deepEqual(actual.toJSON(), expected.toJSON());
      });
      it('b references a', function() {
        var actual, expected;
        actual = store.collection.findAll({
          friend: store.models.a
        });
        expected = queryEngine.createCollection([store.models.b]);
        return assert.deepEqual(actual.toJSON(), expected.toJSON());
      });
      return it('a and b reference collection', function() {
        var actual, expected;
        actual = store.collection.findAll({
          parent: store.collection
        });
        expected = queryEngine.createCollection([store.models.a, store.models.b]);
        return assert.deepEqual(actual.toJSON(), expected.toJSON());
      });
    });
  });

  null;

}).call(this);
