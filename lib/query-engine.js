(function() {
  var Collection, extendNatives, get, set;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  }, __hasProp = Object.prototype.hasOwnProperty;
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
  Array.prototype.hasIn = function(options) {
    var value, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      value = this[_i];
      if (__indexOf.call(options, value) >= 0) {
        return true;
      }
    }
    return false;
  };
  Array.prototype.hasAll = function(options) {
    return this.sort().join() === options.sort().join();
  };
  Collection = (function() {
    function _Class(data) {
      var key, value;
      if (data == null) {
        data = {};
      }
      for (key in data) {
        if (!__hasProp.call(data, key)) continue;
        value = data[key];
        this[key] = value;
      }
    }
    _Class.prototype.find = function(query, next) {
      var $and, $nor, $or, append, empty, exists, expression, field, id, key, length, match, matchAll, matchAny, matchType, matches, newMatches, record, selector, selectorType, value, _i, _j, _k, _len, _len2, _len3, _ref, _ref2;
      if (query == null) {
        query = {};
      }
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
          if (!exists) {
            value = false;
          }
          if ((selectorType === 'string' || selectorType === 'number') || selectorType instanceof String) {
            if (exists && value === selector) {
              match = true;
            }
          } else if (selector instanceof Array) {
            if (exists && value.hasAll(selector)) {
              match = true;
            }
          } else if (selector instanceof RegExp) {
            if (exists && selector.test(value)) {
              match = true;
            }
          } else if (selector instanceof Object) {
            if (selector.$all) {
              if (exists && value.hasAll(selector.$all)) {
                match = true;
              }
            }
            if (selector.$in) {
              if (exists) {
                if (((value.hasIn != null) && value.hasIn(selector.$in)) || (__indexOf.call(selector.$in, value) >= 0)) {
                  match = true;
                }
              }
            }
            if (selector.$nin) {
              if (exists) {
                if (!((value.hasIn != null) && value.hasIn(selector.$nin)) && !(__indexOf.call(selector.$nin, value) >= 0)) {
                  match = true;
                }
              }
            }
            if (selector.$size) {
              if ((value.length != null) && value.length === selector.$size) {
                match = true;
              }
            }
            if (selector.$type) {
              if (typeof value === selector.$type) {
                match = true;
              }
            }
            if (selector.$exists) {
              if (selector.$exists) {
                if (exists === true) {
                  match = true;
                }
              } else {
                if (exists === false) {
                  match = true;
                }
              }
            }
            if (selector.$mod) {
              match = false;
            }
            if (selector.$ne) {
              if (exists && value !== selector.$ne) {
                match = true;
              }
            }
            if (selector.$lt) {
              if (exists && value < selector.$lt) {
                match = true;
              }
            }
            if (selector.$gt) {
              if (exists && value > selector.$gt) {
                match = true;
              }
            }
            if (selector.$lte) {
              if (exists && value <= selector.$lte) {
                match = true;
              }
            }
            if (selector.$gte) {
              if (exists && value >= selector.$gte) {
                match = true;
              }
            }
          }
          if (match) {
            matchAny = true;
          } else {
            matchAll = false;
          }
        }
        if (matchAll && !matchAny) {
          matchAll = false;
        }
        append = false;
        if (empty) {
          append = true;
        } else {
          switch (matchType) {
            case 'none':
            case 'nor':
              if (!matchAny) {
                append = true;
              }
              break;
            case 'any':
            case 'or':
              if (matchAny) {
                append = true;
              }
              break;
            default:
              if (matchAll) {
                append = true;
              }
          }
        }
        if (append) {
          matches[id] = record;
        }
      }
      if ($nor) {
        newMatches = {};
        for (_i = 0, _len = $nor.length; _i < _len; _i++) {
          expression = $nor[_i];
          _ref = matches.find(expression);
          for (key in _ref) {
            if (!__hasProp.call(_ref, key)) continue;
            value = _ref[key];
            newMatches[key] = value;
          }
        }
        for (key in newMatches) {
          if (!__hasProp.call(newMatches, key)) continue;
          value = newMatches[key];
          if (matches[key] != null) {
            delete matches[key];
          }
        }
      }
      if ($or) {
        newMatches = {};
        for (_j = 0, _len2 = $or.length; _j < _len2; _j++) {
          expression = $or[_j];
          _ref2 = matches.find(expression);
          for (key in _ref2) {
            if (!__hasProp.call(_ref2, key)) continue;
            value = _ref2[key];
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
      if (query == null) {
        query = {};
      }
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
      if (query == null) {
        query = {};
      }
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
    var key, value, _base, _ref, _ref2, _results;
    _ref = Collection.prototype;
    _results = [];
    for (key in _ref) {
      if (!__hasProp.call(_ref, key)) continue;
      value = _ref[key];
      _results.push((_ref2 = (_base = Object.prototype)[key]) != null ? _ref2 : _base[key] = value);
    }
    return _results;
  };
  if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
    module.exports = {
      set: set,
      get: get,
      Collection: Collection,
      extendNatives: extendNatives
    };
  } else if (typeof window !== "undefined" && window !== null) {
    window.queryEngine = {
      set: set,
      get: get,
      Collection: Collection,
      extendNatives: extendNatives
    };
  }
}).call(this);
