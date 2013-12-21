(function() {
  var Backbone, assert, describe, joe, queryEngine,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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

  describe('misc', function(describe, it) {
    return describe('collection property', function(describe, it) {
      return it('when specificied, should create child collections of the property type', function() {
        var MyQueryCollection, myChildCollection, myQueryCollection, _ref;
        MyQueryCollection = (function(_super) {
          __extends(MyQueryCollection, _super);

          function MyQueryCollection() {
            _ref = MyQueryCollection.__super__.constructor.apply(this, arguments);
            return _ref;
          }

          MyQueryCollection.prototype.collection = MyQueryCollection;

          MyQueryCollection.prototype.red = 'dog';

          return MyQueryCollection;

        })(queryEngine.QueryCollection);
        myQueryCollection = new MyQueryCollection();
        myChildCollection = myQueryCollection.createChildCollection();
        return assert.ok(myChildCollection instanceof MyQueryCollection);
      });
    });
  });

  null;

}).call(this);
