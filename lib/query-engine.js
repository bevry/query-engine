(function() {
  var Backbone, BaseCollection, Hash, LiveCollection, Pill, Query, exports, util, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ = (typeof window !== "undefined" && window !== null) && window._ || require('underscore');

  Backbone = (typeof window !== "undefined" && window !== null) && window.Backbone || require('backbone');

  util = {
    safeRegex: function(str) {
      return (str || '').replace('(.)', '\\$1');
    },
    makeRegex: function(str) {
      return new RegExp(str, 'ig');
    },
    makeSafeRegex: function(str) {
      return util.makeRegex(util.safeRegex(str));
    },
    toArray: function(value) {
      var item, key, result;
      result = [];
      if (value) {
        if (_.isArray(value)) {
          result = value;
        } else if (value instanceof Object) {
          for (key in value) {
            if (!__hasProp.call(value, key)) continue;
            item = value[key];
            result.push(item);
          }
        } else {
          result.push(value);
        }
      }
      return result;
    }
  };

  Hash = (function(_super) {

    __extends(Hash, _super);

    Hash.prototype.arr = [];

    function Hash(value) {
      var item, key, _len;
      value = util.toArray(value);
      for (key = 0, _len = value.length; key < _len; key++) {
        item = value[key];
        this.push(item);
      }
    }

    Hash.prototype.hasIn = function(options) {
      var value, _i, _len;
      options = util.toArray(options);
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        value = this[_i];
        if (__indexOf.call(options, value) >= 0) return true;
      }
      return false;
    };

    Hash.prototype.hasAll = function(options) {
      var empty, pass, value, _i, _len;
      options = util.toArray(options);
      empty = true;
      pass = true;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        value = this[_i];
        empty = false;
        if (__indexOf.call(options, value) < 0) pass = false;
      }
      if (empty) pass = false;
      return pass;
    };

    Hash.prototype.isSame = function(options) {
      var pass;
      options = util.toArray(options);
      pass = this.sort().join() === options.sort().join();
      return pass;
    };

    return Hash;

  })(Array);

  BaseCollection = Backbone.Collection.extend({
    model: Backbone.Model,
    hasModel: function(model) {
      var exists;
      model || (model = {});
      if ((model.id != null) && this.get(model.id)) {
        exists = true;
      } else if ((model.cid != null) && this.getByCid(model.cid)) {
        exists = true;
      } else {
        exists = false;
      }
      return this;
    },
    safeRemove: function(model) {
      var exists;
      exists = this.hasModel(model);
      if (exists) this.remove(model);
      return this;
    },
    safeAadd: function(model) {
      var exists;
      exists = this.hasModel(model);
      if (!exists) this.add(model);
      return this;
    },
    sortArray: function(comparator) {
      var arr, key, value;
      arr = this.toJSON();
      if (comparator instanceof Function) {
        arr.sort(comparator);
      } else if (comparator instanceof Object) {
        for (key in comparator) {
          if (!__hasProp.call(comparator, key)) continue;
          value = comparator[key];
          if (value === -1) {
            arr.sort(function(a, b) {
              return b[key] - a[key];
            });
          } else if (value === 1) {
            arr.sort(function(a, b) {
              return a[key] - b[key];
            });
          }
        }
      } else {
        throw new Error('Cannot sort a set without a comparator');
      }
      return arr;
    },
    find: function(query) {
      var collection;
      collection = new LiveCollection().setQuery('find', query).setParentCollection(this).query();
      return collection;
    },
    findOne: function(query) {
      var collection;
      collection = new LiveCollection().setQuery('find', query).setParentCollection(this).query();
      if (collection && collection.length) {
        return collection.models[0];
      } else {
        return null;
      }
    }
  });

  LiveCollection = BaseCollection.extend({
    initialize: function(models, options) {
      var _base, _base2, _base3, _base4;
      this.options = _.extend({}, options);
      (_base = this.options).filters || (_base.filters = {});
      (_base2 = this.options).pills || (_base2.pills = {});
      (_base3 = this.options).queries || (_base3.queries = {});
      (_base4 = this.options).searchString || (_base4.searchString = null);
      _.bindAll(this, 'onChange', 'onParentChange', 'onParentRemove', 'onParentAdd', 'onParentReset');
      this.on('change', this.onChange);
      if (this.options.parentCollection != null) {
        this.setParentCollection(this.options.parentCollection, true);
      }
      return this;
    },
    setParentCollection: function(parentCollection, skipCheck) {
      if (!skipCheck && this.options.parentCollection === parentCollection) {
        return this;
      }
      this.options.parentCollection = parentCollection;
      this.options.parentCollection.on('change', this.onParentChange).on('remove', this.onParentRemove).on('add', this.onParentAdd).on('reset', this.onParentReset);
      return this;
    },
    query: function() {
      var me, models;
      me = this;
      models = [];
      this.options.parentCollection.each(function(model) {
        var pass;
        pass = me.test(model);
        if (pass) return models.push(model);
      });
      this.reset(models);
      return this;
    },
    add: function(models, options) {
      var model, passedModels, _i, _len;
      options = options ? _.clone(options) : {};
      models = _.isArray(models) ? models.slice() : [models];
      passedModels = [];
      for (_i = 0, _len = models.length; _i < _len; _i++) {
        model = models[_i];
        model = this._prepareModel(model, options);
        if (model && this.test(model)) passedModels.push(model);
      }
      Backbone.Collection.prototype.add.apply(this, [passedModels, options]);
      return this;
    },
    create: function(model, options) {
      options = options ? _.clone(options) : {};
      model = this._prepareModel(model, options);
      if (model && this.test(model)) {
        Backbone.Collection.prototype.create.apply(this, [model, options]);
      }
      return this;
    },
    onChange: function(model) {
      var pass;
      pass = this.test(model);
      if (!pass) this.safeRemove(model);
      return this;
    },
    onParentChange: function(model) {
      var pass;
      pass = this.test(model);
      if (pass) {
        this.safeAdd(model);
      } else {
        this.safeRemove(model);
      }
      return this;
    },
    onParentRemove: function(model) {
      this.safeRemove(model);
      return this;
    },
    onParentAdd: function(model) {
      this.safeAdd(model);
      return this;
    },
    onParentReset: function(model) {
      this.reset(this.parentCollection.models);
      return this;
    },
    setFilter: function(name, value) {
      var filters;
      filters = this.options.filters;
      if (value != null) {
        filters[name] = value;
      } else if (filters[name] != null) {
        delete filters[name];
      }
      return this;
    },
    setQuery: function(name, value) {
      var queries;
      queries = this.options.queries;
      if (value != null) {
        if (!(value instanceof Query)) value = new Query(value);
        queries[name] = value;
      } else if (queries[name] != null) {
        delete queries[name];
      }
      return this;
    },
    setPill: function(name, value) {
      var pills;
      pills = this.options.pills;
      if (value != null) {
        if (!(value instanceof Pill)) value = new Pill(value);
        pills[name] = value;
      } else if (pills[name] != null) {
        delete pills[name];
      }
      return this;
    },
    setSearch: function(searchString) {
      _.each(this.pills, function(pill, pillName) {
        var search;
        return search = pill.setSearch(searchString);
      });
      this.options.searchString = searchString;
      return this;
    },
    test: function(model) {
      var pass;
      pass = this.testFilters(model) && this.testQueries(model) && this.testPills(pass);
      return pass;
    },
    testFilters: function(model) {
      var pass;
      pass = true;
      _.each(this.options.filters, function(filter, filterName) {
        if (filter(model, this.search) === false) {
          pass = false;
          return false;
        }
      });
      return pass;
    },
    testQueries: function(model) {
      var pass;
      pass = true;
      _.each(this.options.queries, function(query, queryName) {
        if (query.test(model) === false) {
          pass = false;
          return false;
        }
      });
      return pass;
    },
    testPills: function(model) {
      var pass;
      pass = true;
      if (this.options.searchString) {
        _.each(this.pills, function(pill, pillName) {
          if (pill.test(model) === false) {
            pass = false;
            return false;
          }
        });
      }
      return pass;
    }
  });

  Pill = (function() {

    Pill.prototype.callback = null;

    Pill.prototype.regex = null;

    Pill.prototype.prefixes = null;

    Pill.prototype.search = null;

    Pill.prototype.value = null;

    function Pill(pill) {
      var prefix, regexString, safePrefixes, safePrefixesStr, _i, _len, _ref;
      pill || (pill = {});
      this.callback = pill.callback;
      this.prefixes = pill.prefixes;
      safePrefixes = [];
      _ref = this.prefixes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        prefix = _ref[_i];
        safePrefixes.push(util.safeRegex(prefix));
      }
      safePrefixesStr = safePrefixes.join('|');
      regexString = '(' + safePrefixesStr + ')([^\\s]+)';
      this.regex = util.makeRegex(regexString);
      this;
    }

    Pill.prototype.setSearch = function(search) {
      this.search = search;
      this.match = this.regex.exec(search);
      if (this.match) {
        this.value = this.match[2].trim();
        search = search.replace(this.match[0], '').trim();
      } else {
        this.value = null;
      }
      return this.search;
    };

    Pill.prototype.test = function(model) {
      var pass;
      pass = null;
      if (this.value != null) pass = this.callback(model, this.value);
      return pass;
    };

    return Pill;

  })();

  Query = (function() {

    Query.prototype.query = null;

    function Query(query) {
      if (query == null) query = {};
      this.query = query;
    }

    Query.prototype.test = function(model) {
      var empty, exists, field, id, match, matchAll, matchAny, query, selector, selectorType, value, _i, _j, _k, _len, _len2, _len3, _ref;
      matchAll = true;
      matchAny = false;
      empty = true;
      _ref = this.query;
      for (field in _ref) {
        if (!__hasProp.call(_ref, field)) continue;
        selector = _ref[field];
        match = false;
        empty = false;
        selectorType = typeof selector;
        value = model.get(field);
        id = model.get('id');
        exists = typeof value !== 'undefined';
        if (!exists) value = false;
        if (field === '$nor') {
          match = true;
          empty = true;
          for (_i = 0, _len = selector.length; _i < _len; _i++) {
            query = selector[_i];
            empty = false;
            query = new Query(query);
            if (query.test(model)) {
              match = false;
              break;
            }
          }
          if (empty) match = true;
        }
        if (field === '$or') {
          match = false;
          empty = true;
          for (_j = 0, _len2 = selector.length; _j < _len2; _j++) {
            query = selector[_j];
            empty = false;
            query = new Query(query);
            if (query.test(model)) {
              match = true;
              break;
            }
          }
          if (empty) match = true;
        }
        if (field === '$and') {
          match = true;
          for (_k = 0, _len3 = selector.length; _k < _len3; _k++) {
            query = selector[_k];
            query = new Query(query);
            if (!query.test(model)) match = false;
          }
        }
        if ((selectorType === 'string' || selectorType === 'number') || selectorType instanceof String) {
          if (exists && value === selector) match = true;
        } else if (_.isArray(selector)) {
          if (exists && (new Hash(value)).isSame(selector)) match = true;
        } else if (_.isDate(selector)) {
          if (exists && value.toString() === selector.toString()) match = true;
        } else if (_.isRegExp(selector)) {
          if (exists && selector.test(value)) match = true;
        } else if (selector instanceof Object) {
          if (selector.$beginsWith) {
            if (exists) {
              if (typeof value === 'string' && value.substr(0, selector.$beginsWith.length) === selector.$beginsWith) {
                match = true;
              }
            }
          }
          if (selector.$endsWith) {
            if (exists) {
              if (typeof value === 'string' && value.substr(selector.$endsWith.length * -1) === selector.$endsWith) {
                match = true;
              }
            }
          }
          if (selector.$all) {
            if (exists) if ((new Hash(value)).hasAll(selector.$all)) match = true;
          }
          if (selector.$in) {
            if (exists) {
              if ((new Hash(value)).hasIn(selector.$in)) {
                match = true;
              } else if ((new Hash(selector.$in)).hasIn(value)) {
                match = true;
              }
            }
          }
          if (selector.$has) {
            if (exists) if ((new Hash(value)).hasIn(selector.$has)) match = true;
          }
          if (selector.$hasAll) {
            if (exists) {
              if ((new Hash(value)).hasIn(selector.$hasAll)) match = true;
            }
          }
          if (selector.$nin) {
            if (exists) {
              if ((new Hash(value)).hasIn(selector.$nin) === false && (new Hash(selector.$nin)).hasIn(value) === false) {
                match = true;
              }
            }
          }
          if (selector.$size) {
            if ((value.length != null) && value.length === selector.$size) {
              match = true;
            }
          }
          if (selector.$type) if (typeof value === selector.$type) match = true;
          if (selector.$exists) {
            if (selector.$exists) {
              if (exists === true) match = true;
            } else {
              if (exists === false) match = true;
            }
          }
          if (selector.$mod) match = false;
          if (selector.$ne) if (exists && value !== selector.$ne) match = true;
          if (selector.$lt) if (exists && value < selector.$lt) match = true;
          if (selector.$gt) if (exists && value > selector.$gt) match = true;
          if (selector.$lte) if (exists && value <= selector.$lte) match = true;
          if (selector.$gte) if (exists && value >= selector.$gte) match = true;
        }
        if (match) {
          matchAny = true;
        } else {
          matchAll = false;
        }
      }
      if (matchAll && !matchAny) matchAll = false;
      return matchAll;
    };

    return Query;

  })();

  exports = {
    safeRegex: util.safeRegex,
    makeRegex: util.makeRegex,
    makeSafeRegex: util.makeSafeRegex,
    toArray: util.toArray,
    Hash: Hash,
    BaseCollection: BaseCollection,
    LiveCollection: LiveCollection,
    Query: Query,
    Pill: Pill,
    createCollection: function(models) {
      var collection;
      models = util.toArray(models);
      collection = new BaseCollection(models);
      return collection;
    },
    createLiveCollection: function(models) {
      var collection;
      models = util.toArray(models);
      collection = new LiveCollection(models);
      return collection;
    }
  };

  if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
    module.exports = exports;
  } else if (typeof window !== "undefined" && window !== null) {
    window.queryEngine = exports;
  }

}).call(this);
