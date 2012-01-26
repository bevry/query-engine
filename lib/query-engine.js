(function() {
  var Collection, Hash, extendNatives, get, key, set, toArray, value, _ref,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __slice = Array.prototype.slice,
    __hasProp = Object.prototype.hasOwnProperty;

  get = function(obj, key) {
    if (obj.get != null) {
      return obj.get(key);
    } else {
      return obj[key];
    }
  };

  set = function(obj, key, value) {
    if (obj.set != null) {
      return obj.set(key, value);
    } else {
      return obj[key] = value;
    }
  };

  toArray = function(value) {
    if (!value) {
      return [];
    } else if (!(value instanceof Array)) {
      return [value];
    } else {
      return value;
    }
  };

  Hash = (function() {

    _Class.prototype.arr = [];

    function _Class(arr) {
      this.arr = toArray(arr);
    }

    _Class.prototype.hasIn = function(options) {
      var value, _i, _len, _ref;
      options = toArray(options);
      _ref = this.arr;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        value = _ref[_i];
        if (__indexOf.call(options, value) >= 0) return true;
      }
      return false;
    };

    _Class.prototype.hasAll = function(options) {
      return this.arr.sort().join() === options.sort().join();
    };

    return _Class;

  })();

  _ref = Array.prototype;
  for (key in _ref) {
    value = _ref[key];
    Hash.prototype[key] = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return value.apply(this.arr, args);
    };
  }

  Collection = (function() {

    function _Class(data) {
      var key, value;
      if (data == null) data = {};
      for (key in data) {
        if (!__hasProp.call(data, key)) continue;
        value = data[key];
        this[key] = value;
      }
    }

    _Class.prototype.find = function(query, next) {
      var $and, $nor, $or, append, empty, exists, expression, field, id, key, length, match, matchAll, matchAny, matchType, matches, newMatches, record, selector, selectorType, value, _i, _j, _k, _len, _len2, _len3, _ref2, _ref3;
      if (query == null) query = {};
      matches = new Collection;
      length = 0;
      $nor = false;
      $or = false;
      $and = false;
      matchType = 'and';
      if (query.$type) {
        matchType = query.$type;
        delete query.$type;
      }
      if (query.$nor) {
        $nor = query.$nor;
        delete query.$nor;
      }
      if (query.$or) {
        $or = query.$or;
        delete query.$or;
      }
      if (query.$and) {
        $and = query.$and;
        delete query.$and;
      }
      for (id in this) {
        if (!__hasProp.call(this, id)) continue;
        record = this[id];
        matchAll = true;
        matchAny = false;
        empty = true;
        for (field in query) {
          if (!__hasProp.call(query, field)) continue;
          selector = query[field];
          match = false;
          empty = false;
          selectorType = typeof selector;
          value = get(record, field);
          id = get(record, 'id') || id;
          exists = typeof value !== 'undefined';
          if (!exists) value = false;
          if ((selectorType === 'string' || selectorType === 'number') || selectorType instanceof String) {
            if (exists && value === selector) match = true;
          } else if (selector instanceof Array) {
            if (exists && (new Hash(value)).hasAll(selector)) match = true;
          } else if (selector instanceof Date) {
            if (exists && value.toString() === selector.toString()) match = true;
          } else if (selector instanceof RegExp) {
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
              if (exists) {
                if ((new Hash(value)).hasAll(selector.$all)) match = true;
              }
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
        append = false;
        if (empty) {
          append = true;
        } else {
          switch (matchType) {
            case 'none':
            case 'nor':
              if (!matchAny) append = true;
              break;
            case 'any':
            case 'or':
              if (matchAny) append = true;
              break;
            default:
              if (matchAll) append = true;
          }
        }
        if (append) matches[id] = record;
      }
      if ($nor) {
        newMatches = {};
        for (_i = 0, _len = $nor.length; _i < _len; _i++) {
          expression = $nor[_i];
          _ref2 = matches.find(expression);
          for (key in _ref2) {
            if (!__hasProp.call(_ref2, key)) continue;
            value = _ref2[key];
            newMatches[key] = value;
          }
        }
        for (key in newMatches) {
          if (!__hasProp.call(newMatches, key)) continue;
          value = newMatches[key];
          if (matches[key] != null) delete matches[key];
        }
      }
      if ($or) {
        newMatches = {};
        for (_j = 0, _len2 = $or.length; _j < _len2; _j++) {
          expression = $or[_j];
          _ref3 = matches.find(expression);
          for (key in _ref3) {
            if (!__hasProp.call(_ref3, key)) continue;
            value = _ref3[key];
            newMatches[key] = value;
          }
        }
        matches = newMatches;
      }
      if ($and) {
        for (_k = 0, _len3 = $and.length; _k < _len3; _k++) {
          expression = $and[_k];
          matches = matches.find(expression);
        }
      }
      length = 0;
      for (match in matches) {
        if (!__hasProp.call(matches, match)) continue;
        ++length;
      }
      if (next != null) {
        return next(false, matches, length);
      } else {
        return matches;
      }
    };

    _Class.prototype.findOne = function(query, next) {
      var match, matches;
      if (query == null) query = {};
      matches = this.find(query).toArray();
      match = matches.length >= 1 ? matches[0] : void 0;
      if (next != null) {
        return next(false, match);
      } else {
        return match;
      }
    };

    _Class.prototype.forEach = function(callback) {
      var id, record, _results;
      _results = [];
      for (id in this) {
        if (!__hasProp.call(this, id)) continue;
        record = this[id];
        _results.push(callback(record, id));
      }
      return _results;
    };

    _Class.prototype.toArray = function(next) {
      var arr, key, value;
      arr = [];
      for (key in this) {
        if (!__hasProp.call(this, key)) continue;
        value = this[key];
        arr.push(value);
      }
      if (next != null) {
        return next(false, arr);
      } else {
        return arr;
      }
    };

    _Class.prototype.sort = function(comparison, next) {
      var arr, key, value;
      arr = this.toArray();
      if (comparison instanceof Function) {
        arr.sort(comparison);
      } else {
        for (key in comparison) {
          if (!__hasProp.call(comparison, key)) continue;
          value = comparison[key];
          if (value === -1) {
            arr.sort(function(a, b) {
              return get(b, key) - get(a, key);
            });
          } else if (value === 1) {
            arr.sort(function(a, b) {
              return get(a, key) - get(b, key);
            });
          }
        }
      }
      if (next != null) {
        return next(false, arr);
      } else {
        return arr;
      }
    };

    _Class.prototype.remove = function(query, next) {
      var id, matches, record;
      if (query == null) query = {};
      matches = this.find(query);
      for (id in this) {
        if (!__hasProp.call(this, id)) continue;
        record = this[id];
        delete this[id];
      }
      if (next != null) {
        return next(false, this);
      } else {
        return this;
      }
    };

    return _Class;

  })();

  extendNatives = function() {
    var key, value, _base, _base2, _ref2, _ref3, _ref4, _results;
    _ref2 = Hash.prototype;
    for (key in _ref2) {
      if (!__hasProp.call(_ref2, key)) continue;
      value = _ref2[key];
      if ((_base = Array.prototype)[key] == null) _base[key] = value;
    }
    _ref3 = Collection.prototype;
    _results = [];
    for (key in _ref3) {
      if (!__hasProp.call(_ref3, key)) continue;
      value = _ref3[key];
      _results.push((_ref4 = (_base2 = Object.prototype)[key]) != null ? _ref4 : _base2[key] = value);
    }
    return _results;
  };

  if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
    module.exports = {
      set: set,
      get: get,
      Collection: Collection,
      Hash: Hash,
      extendNatives: extendNatives
    };
  } else if (typeof window !== "undefined" && window !== null) {
    window.queryEngine = {
      set: set,
      get: get,
      Collection: Collection,
      Hash: Hash,
      extendNatives: extendNatives
    };
  }

}).call(this);
