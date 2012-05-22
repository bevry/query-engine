# Requires
_ = window? and window._  or  require('underscore')
Backbone = window? and window.Backbone  or  require('backbone')


# Util
# Contains our utility functions


util =
# Safe Regex
# Santitize a string for the use inside a regular expression
  safeRegex: (str) ->
    return (str or '').replace('(.)','\\$1')

  # Create Regex
  # Convert a string into a regular expression
  createRegex: (str) ->
    return new RegExp(str,'ig')

  # Create Safe Regex
  # Convert a string into a safe regular expression
  createSafeRegex: (str) ->
    return util.createRegex util.safeRegex(str)

  # To Array
  toArray: (value) ->
    # Prepare
    result = []

    # Determine the correct type
    if value
      if _.isArray(value)
        result = value
      else if _.isObject(value)
        for own key,item of value
          result.push(item)
      else
        result.push(value)

    # Return the result
    result

  filter: (array, test) -> (val for val in array when test val)
  reject: (array, test) -> (val for val in array when not test val)


# Hash
# Extends the Array class with:
# - the ability to convert anything to an array
# - the hasIn function
# - the hasAll function
class Hash extends Array
# Array
  arr: []

  # Constructor
  constructor: (value) ->
    value = util.toArray(value)
    for item,key in value
      @push(item)

  # Has In
  # Check if the option exists within us
  hasIn: (options) ->
    options = util.toArray(options)
    for value in @
      if value in options
        return true
    return false

  # Has All
  # Check if all the options exist within us
  hasAll: (options) ->
    # Prepare
    options = util.toArray(options)
    empty = true
    pass = true

    # Perform the check
    for value in @
      empty = false
      unless value in options
        pass = false

    # Fail if we are empty
    pass = false  if empty

    # Return whether we passed or not
    return pass

  # Is Same
  # Check if our values are the same as the options
  isSame: (options) ->
    # Prepare
    options = util.toArray(options)

    # Check
    pass = @sort().join() is options.sort().join()

    # Return whether we passed or not
    return pass



# Query Collection
# Creates a Collection that Supports Querying
# Options:
# - filters: a hash of filter functions
# - queries: a hash of query instances or query objects
# - pills: a hash of pill instances or pill objects
# - parentCollection: a backbone.js collection to be used as the parent
# - live: whether or not to automaticaly perform retests when events fire
class QueryCollection extends Backbone.Collection
# Model
# The model that this query engine supports
  model: Backbone.Model

  # Constructor
  initialize: (models,options) ->
    # Bindings
    _.bindAll(@, 'onChange', 'onParentChange', 'onParentRemove', 'onParentAdd', 'onParentReset')

    # Defaults
    @options = _.extend({}, @options or {}, options or {})
    @options.filters = _.extend({}, @options.filters or {})
    @options.queries = _.extend({}, @options.queries or {})
    @options.pills = _.extend({}, @options.pills or {})
    @options.searchString or= null

    # Initialise filters, queries and pills if we have them
    @setFilters(@options.filters)
    @setQueries(@options.queries)
    @setPills(@options.pills)
    @setSearchString(@options.searchString)

    # Initliase live events if we use them
    @live()

    # Chain
    @


  # ---------------------------------
  # Filters: Getters and Setters

  # Get Filters
  getFilter: (key) ->
    @options.filters[key]

  # Get Filters
  getFilters: ->
    @options.filters

  # Set Filters
  setFilters: (filters) ->
    filters or= {}
    for own key,value of filters
      @setFilter(key,value)
    @

  # Set Filter
  setFilter: (name,value) ->
    # Prepare
    filters = @options.filters

    # Apply or delete the value
    if value?
      filters[name] = value
    else if filters[name]?
      delete filters[name]

    # Apply or delete the value
    @


  # ---------------------------------
  # Queries: Getters and Setters

  # Get Query
  getQuery: (key) ->
    @options.queries[key]

  # Get Queries
  getQueries: ->
    @options.queries

  # Set Queries
  setQueries: (queries) ->
    queries or= {}
    for own key,value of queries
      @setQuery(key,value)
    @

  # Set Query
  setQuery: (name,value) ->
    # Prepare
    queries = @options.queries
    # Apply or delete the value
    if value?
      queries[name] = value
    else if queries[name]?
      delete queries[name]
    # Chain
    @


  # ---------------------------------
  # Pills: Getters and Setters

  # Get Pill
  getPill: (key) ->
    @options.pills[key]

  # Get Pills
  getPills: ->
    @options.pills

  # Set Pills
  setPills: (pills) ->
    pills or= {}
    for own key,value of pills
      @setPill(key,value)
    @

  # Set Pill
  setPill: (name,value) ->
    # Prepare
    pills = @options.pills
    searchString = @options.searchString

    # Apply or delete the value
    if value?
      value = new Pill(value)  unless (value instanceof Pill)
      if searchString
        value.setSearchString(searchString)
      pills[name] = value
    else if pills[name]?
      delete pills[name]

    # Chain
    @


  # ---------------------------------
  # Search String: Getters and Setters

  # Get Cleaned Search String
  getCleanedSearchString: ->
    @options.cleanedSearchString

  # Get Search String
  getSearchString: ->
    @options.searchString

  # Set Search String
  setSearchString: (searchString) ->
    # Prepare
    pills = @options.pills
    cleanedSearchString = searchString

    # Apply the search string to each of our pills
    # and for each applicable pill, clean up our search string
    _.each pills, (pill,pillName) ->
      cleanedSearchString = pill.setSearchString(cleanedSearchString)
      return true

    # Apply
    @options.searchString = searchString
    @options.cleanedSearchString = cleanedSearchString

    # Chain
    @


  # ---------------------------------
  # Parent Collection: Getters and Setters

  # Has Parent Collection
  hasParentCollection: ->
    @options.parentCollection?

  # Get Parent Collection
  getParentCollection: ->
    @options.parentCollection

  # Set Parent Collection
  setParentCollection: (parentCollection,skipCheck) ->
    # Check
    if !skipCheck and @options.parentCollection is parentCollection
      return @ # nothing to do

    # Apply
    @options.parentCollection = parentCollection

    # Live
    @live()

    # Chain
    @


  # ---------------------------------
  # Helpers
  # Used to assist our other functions

  # Has Model
  # Does this model exist within our collection?
  hasModel: (model) ->
    # Prepare
    model or= {}

    # Check by the model's id
    if model.id? and @get(model.id)
      exists = true
      # Check by the model's cid
    else if model.cid? and @getByCid(model.cid)
      exists = true
      # Otherwise fail
    else
      exists = false

    # Return exists
    return exists

  # Safe Remove
  # Remove an item from the collection, only if it exists within the collection
  # Useful for bypassing the "already exists" warning
  safeRemove: (model) ->
    exists = @hasModel(model)
    if exists
      this.remove(model)
    @

  # Safe Add
  # Add an item from the collection, only if it doesn't exist within the collection
  # Useful for bypassing the "already exists" warning
  safeAdd: (model) ->
    exists = @hasModel(model)
    unless exists
      this.add(model)
    @


  # ---------------------------------
  # Generic API

  # Sort Array
  # Return the results as an array sorted by our comparator
  sortArray: (comparator) ->
    # Prepare
    arr = @toJSON()

    # Sort
    if comparator
      if comparator instanceof Function
        arr.sort(comparator)
      else if comparator instanceof Object
        for own key,value of comparator
          # Descending
          if value is -1
            arr.sort (a,b) ->
              b[key] - a[key]
            # Ascending
          else if value is 1
            arr.sort (a,b) ->
              a[key] - b[key]
      else
        throw new Error('Unknown comparator type was passed to QueryCollection::sortArray')
    else
      if @comparator
        return @sortArray(@comparator)
      else
        throw new Error('Cannot sort a set without a comparator')

    # Return sorted array
    return arr

  # Query
  # Reset our collection with the new rules that we are using
  query: ->
    # Prepare
    collection = @getParentCollection() or @
    # Send collection to the test method
    models = @test collection

    # Reset our collection with the passing models
    @reset(models)

    # Chain
    @

  # Create Child Collection
  createChildCollection: ->
    collection = new QueryCollection()
    .setParentCollection(@)
    return collection

  # Create Live Child Collection
  createLiveChildCollection: ->
    collection = @createChildCollection().live(true)
    return collection

  # Find All
  findAll: (query) ->
    collection = @createChildCollection()
    .setQuery('find',query)
    .query()
    return collection

  # Find One
  findOne: (query) ->
    collection = @createChildCollection()
    .setQuery('find',query)
    .query()
    if collection and collection.length
      return collection.models[0]
    else
      return null


  # ---------------------------------
  # Live Functionality
  # Used so we can live update the collection when modifications are made to our collection

  # Live
  live: (enabled) ->
    # Prepare
    enabled ?= @options.live

    # Save live mode
    @options.live = enabled

    # Subscribe to change events on our existing models
    if enabled
      @on('change',@onChange)
    else
      @off('change',@onChange)

    # Subscribe the live events on our parent collection (if we have one)
    parentCollection = @getParentCollection()
    if parentCollection?
      if enabled
        parentCollection.on('change',@onParentChange)
        parentCollection.on('remove',@onParentRemove)
        parentCollection.on('add',@onParentAdd)
        parentCollection.on('reset',@onParentReset)
      else
        parentCollection.off('change',@onParentChange)
        parentCollection.off('remove',@onParentRemove)
        parentCollection.off('add',@onParentAdd)
        parentCollection.off('reset',@onParentReset)

    # Chain
    @

  # Fired when we want to add some models to our own collection
  # We should check if the models pass our tests, if so then we add them
  add: (models, options) ->
    # Prepare
    options = if options then _.clone(options) else {}
    models = if _.isArray(models) then models.slice() else [models]
    passedModels = []

    # Cycle through the models
    for model in models
      # Ensure we have a model
      model = @_prepareModel(model,options)

      # Only add passed models
      if model and @test(model)
        passedModels.push(model)

    # Add the passed models
    Backbone.Collection::add.apply(@,[passedModels,options])

    # Chain
    @

  # Fired when we want to create a model
  # We should check if the model passes our tests, if so then we add them
  create: (model, options) ->
    # Prepare
    options = if options then _.clone(options) else {}
    model = @_prepareModel(model,options)

    # Check
    if model and @test(model)
      # It passed, so create the model
      Backbone.Collection::create.apply(@,[model,options])

    # Chain
    @

  # Fired when a model that is inside our own collection changes
  # We should check if it still passes our tests
  # and if it doesn't then we should remove the model
  onChange: (model) ->
    pass = @test(model)
    unless pass
      @safeRemove(model)
    @

  # Fired when a model in our parent collection changes
  # We should check if the model now passes our own tests, and if so add it to our own
  # and if it doesn't then we should remove the model from our own
  onParentChange: (model) ->
    pass = @test(model) and @getParentCollection().test(model)
    if pass
      @safeAdd(model)
    else
      @safeRemove(model)
    @

  # Fired when a model in our parent collection is removed
  # We should remove it straight away from our own model
  onParentRemove: (model) ->
    @safeRemove(model)
    @

  # Fired when a model in our parent collection is added
  # We should try and add it to our own collection
  # Try as in, it will call _prepareModel and the tests happen there
  onParentAdd: (model) ->
    @safeAdd(model)
    @

  # Fired when our parent collection is reset
  # We should reset our own collection when this happens with the parent collection's models
  # For each model, it will trigger _prepareModel which will check if the model passes our tests
  onParentReset: (model) ->
    @reset(@getParentCollection().models)
    @


  # ---------------------------------
  # Testers

  # Test everything against the model
  test: (data) ->
    booleanReturn = false

    if data.models
      models = data.models
    else if _.isArray(data)
      models = data
    else
      models = [data]
      booleanReturn = true



    query = new Query
      queries: @getQueries()
      pills: @getPills()
      filters: @getFilters()
      cleanedSearchString: @getCleanedSearchString()
      searchString: @getSearchString()

    passed = query.test models

    if booleanReturn
      (passed and passed.length)
    else
      passed




class Query
  compoundKeys = ["$and", "$not", "$or", "$nor"]

  constructor: ({queries, filters, pills, @searchString, @cleanedSearchString}) ->

    compoundQuery =
      $and: []
      $not: []
      $or: []
      $nor: []

    if queries
      for own name, query of queries
        matchKeys = _.intersection compoundKeys, _(query).keys()
        if matchKeys.length is 0
          if _.isArray(query)
            queryObj = $and: query
          else
            queryObj = $and: [query]
        else
          queryObj = query

        for keyType in compoundKeys when queryObj[keyType]
          compoundQuery[keyType] = compoundQuery[keyType].concat queryObj[keyType]

    if pills and @searchString?
      for own name, pill of pills
        o = {}
        o[name] = $pill: pill
        compoundQuery.$and.push o

    if filters and @cleanedSearchString?
      for own name, filter of filters
        o = {}
        o[name] = $filter: filter
        compoundQuery.$and.push o


    @compoundQuery = compoundQuery

  test: (models) ->

    # iterate through the compound methods using underscore reduce
    # The reduce iterator takes an array of models, performs the query and returns
    # the matched models for the next query
    reduce_iterator = (memo, queryKey) =>
      query = @compoundQuery[queryKey]
      if query.length
        @[queryKey] memo, query
      else memo

    _.reduce compoundKeys, reduce_iterator, models

  $and: (models, queries) =>  @iterator models, queries, false, util.filter
  $or: (models, queries) =>   @iterator models, queries, true, util.filter
  $nor: (models, queries) =>  @iterator models, queries, true, util.reject
  $not: (models, queries) =>  @iterator models, queries, false, util.reject

  iterator: (models, queries, andOr, filterFunction) ->
    me = @
    parsedQuery = @parseQuery queries
    # The collections filter or reject method is used to iterate through each model in the collection
    filterFunction models, (model) ->
      # For each model in the collection, iterate through the supplied queries
      for q in parsedQuery
        # Retrieve the attribute value from the model
        modelValue = model.get(q.key)

        test = me.performQuery q.type, q.value, modelValue, model, q.key

        # If the query is an "or" query than as soon as a match is found we return "true"
        # Whereas if the query is an "and" query then we return "false" as soon as a match isn't found.
        return andOr if andOr is test

      # For an "or" query, if all the queries are false, then we return false
      # For an "and" query, if all the queries are true, then we return true
      not andOr

  parseQuery: (rawQuery) ->

    # To allow queries of the following forms:
    # findAll
    #   name: "test"
    #   id: $gte: 10
    #
    # OR
    # findAll [
    #   {name:"test"}
    #   {id:$gte:10}
    # ]
    #
    if rawQuery.length is 1 and _(rawQuery[0]).keys().length > 1
      queryArray = (for key, query_param of rawQuery[0]
        o = {}
        o[key] = query_param
        o)
    else
      queryArray = rawQuery

    (for query in queryArray
      o = {}
      for own key, query_param of query
        o = {key}
        # Test for Regexs as they can be supplied without an operator
        if _.isRegExp(query_param)
          o.type = "$regex"
          o.value = query_param

        # Test for Dates as they can be supplied without an operator
        else if _.isDate(query_param)
          o.type = "$date"
          o.value = query_param

          # If the query paramater is an object then extract the key and value
        else if _(query_param).isObject() and not _(query_param).isArray()
          for type, value of query_param
            # Before adding the query, its value is checked to make sure it is the right type
            if @testQueryValue type, value
              o.type = type
              switch type
                when "$elemMatch", "$relationMatch"
                  o.value = parse_query value
                when "$computed"
                  q = {}
                  q[key] = value
                  o.value = parse_query q
                else
                  o.value = value
          # If the query_param is not an object or a regexp then revert to the default operator: $equal
        else
          o.type = "$equal"
          o.value = query_param

        # For "$equal" queries with arrays or objects we need to perform a deep equal
        if o.type is "$equal" and _(o.value).isObject() then o.type = "$oEqual"
      o)

  # Tests query value, to ensure that it is of the correct type
  testQueryValue: (type, value) ->
    switch type
      when "$in","$nin","$all", "$any"  then _.isArray(value)
      when "$size"                      then _.isNumber(value)
      when "$regex"                     then _.isRegExp(value)
      when "$like", "$likeI"            then _.isString(value)
      when "$between"                   then _.isArray(value) and (value.length is 2)
      when "$cb"                        then _.isFunction(value)
      else true


  # Perform the actual query logic for each query and each model/attribute
  performQuery: (queryType, queryValue, modelValue, model, key) ->
    switch queryType
      # Standard equality test for query values that are strings or numbers
      when "$equal"           then modelValue is queryValue

      # Deep equalilty test for arrays and objects
      when "$oEqual"          then _.isEqual modelValue, queryValue

      # Checks that the the model value is an array and that the supplied query value is present
      # Possibly depreciate in favour of more versatile $in?
      when "$contains"        then _.isArray(modelValue) and queryValue in modelValue

      # Query-Engine Specific
      # The $has operator checks if any of the selector values exist within our model's value
      when "$has"             then (new Hash modelValue).hasIn(queryValue)

      # "Not Equal" - opposite of basic eqaulity test
      when "$ne"              then modelValue isnt queryValue

      # Less than
      when "$lt"              then modelValue? and (modelValue < queryValue)

      # Greater than
      when "$gt"              then modelValue? and (modelValue > queryValue)

      # Less than or equal to
      when "$lte"             then modelValue? and (modelValue <= queryValue)

      # Greater than or equal to
      when "$gte"             then modelValue? and (modelValue >= queryValue)

      # Query Engine Specific
      # Tests that the model value is between 2 query values
      when "$between"         then queryValue[0] < modelValue < queryValue[1]

      # The $in operator is analogous to the SQL IN modifier, allowing you to specify an array of possible matches.
      # The target field's value can also be an array; if so then the document matches if any of the elements of the
      # array's value matches any of the $in field's values
      when "$in"              then (new Hash queryValue).hasIn(modelValue) or (new Hash modelValue).hasIn(queryValue)

      # The $nin operator is similar to $in except that it selects objects for which the specified field does not
      # have any value in the specified array.
      when "$nin"             then not ((new Hash queryValue).hasIn(modelValue) or (new Hash modelValue).hasIn(queryValue))

      # The $all operator is similar to $in, but instead of matching any value in the specified array all values
      # in the array must be matched.
      when "$all"             then _.isArray(modelValue)  and (new Hash modelValue).hasAll(queryValue)
      when "$any"             then _.isArray(modelValue) and _.any modelValue, (item) -> item in queryValue

      # The $size operator matches any array with the specified number of elements.
      # The following example would match the object {a:["foo"]}, since that array has just one element:
      when "$size"            then modelValue?.length is queryValue

      # MongoDB - Check for existence (or lack thereof) of a field.
      # collection.find({ a: {$exists: true} }) model will be returned if attribute a exists
      # collection.find({ a: {$exists: false} }) model will be returned if attribute a is missing
      when "$exists"          then modelValue? is queryValue

      # Query Engine Specific - performs a text search using indexOf
      # collection.find({ a: {$like: "test"} }) model will be returned if attribute a contains the string "test"
      when "$like"            then _.isString(modelValue) and modelValue.indexOf(queryValue) isnt -1

      # Query Engine Specific - performs a case-insensitive text search using indexOf
      # collection.find({ a: {$like: "test"} }) model will be returned if attribute a contains the string "test", "Test", "teST", etc.
      when "$likeI"           then _.isString(modelValue) and modelValue.toLowerCase().indexOf(queryValue.toLowerCase()) isnt -1

      # MongoDB - Regular expression test
      when "$regex"           then queryValue.test modelValue

      # Query Engine Specific - calls the supplied function with the model scoped to this and the modelValue as an argument
      when "$cb"              then queryValue.call model, modelValue

      # Query Engine Specific - calls the pills test method with the model
      when "$pill"            then queryValue.test model

      # Query Engine Specific - calls the supplied filter function with the model and the cleaned serach string
      when "$filter"          then queryValue model, @cleanedSearchString

      # Date equality using the toString method
      when "$date"            then queryValue.toString() is modelValue.toString()

      # The $beginsWith operator checks if the value begins with a particular value or values if an array was passed
      when "$beginsWith", "$startsWith"
        queryValue = [queryValue] unless _.isArray(queryValue)
        for $beginsWithValue in queryValue
          return true if modelValue.substr(0,$beginsWithValue.length) is $beginsWithValue
        false

      # The $endsWith operator checks if the value ends with a particular value or values if an array was passed
      when "$endsWith", "$finishesWith"
        queryValue = [queryValue] unless _.isArray(queryValue)
        for $endsWithValue in queryValue
          return true if modelValue.substr($endsWithValue.length*-1) is $endsWithValue
        false



    #when "$elemMatch"       then iterator attr, value, false, detect, "elemMatch"
    #when "$relationMatch"   then iterator attr.models, value, false, detect, "relationMatch"
    #when "$computed"        then iterator [model], value, false, detect, "computed"
      else false




# Pill
# Provides the ability to perform pill based searches, e.g.
# Searching for "user:ben" will search for the key user, and value ben
# Pills must be coded manually, as otherwise that could be a security problem
class Pill
# Callback
# Our pills tester function
  callback: null # Function

  # Regex
  # Our pills regex that we will use to extract the values
  regex: null # RegExp

  # Prefixes
  # The prefixes that our pill matches
  prefixes: null # Array

  # Search String
  # The search string that we are comparing against
  searchString: null # String

  # Value
  # The discovered value of the pill within the search
  value: null # String

  # Constructor
  # Construct our regular expression and apply our properties
  constructor: (pill) ->
    # Apply
    pill or= {}
    @callback = pill.callback
    @prefixes = pill.prefixes

    # Sanitize the prefixes
    safePrefixes = []
    for prefix in @prefixes
      safePrefixes.push util.safeRegex(prefix)

    # Build the regular expression used to match the pill
    safePrefixesStr = safePrefixes.join('|')
    regexString ='('+safePrefixesStr+')([^\\s]+)'

    # Apply the regular expression
    @regex = util.createRegex(regexString)

    # Chain
    @

  # Set Search String
  # Apply the search string to the pill, and extract our value
  # Returns the cleaned search string
  setSearchString: (searchString) ->
    # Prepare
    cleanedSearchString = searchString
    value = null

    # Extract information
    while match = @regex.exec(searchString)
      value = match[2].trim()
      cleanedSearchString = searchString.replace(match[0],'').trim()

    # Apply
    @searchString = searchString
    @value = value

    # Return cleaned search
    return cleanedSearchString

  # Test
  # Test our pill against our discovered values
  # Returns whether our pill passed or not
  test: (model) ->
    # Prepare
    pass = null

    # Extract the pill information from the query
    if @value?
      pass = @callback(model,@value)

    # Return
    return pass


# -------------------------------------
# Exports

# Prepare
exports = {
  safeRegex: util.safeRegex
  createRegex: util.createRegex
  createSafeRegex: util.createSafeRegex
  toArray: util.toArray
  Backbone: Backbone
  Hash: Hash
  QueryCollection: QueryCollection
  Query: Query
  Pill: Pill
  createCollection: (models,options) ->
    models = util.toArray(models)
    collection = new QueryCollection(models,options)
    return collection
  createLiveCollection: (models,options) ->
    models = util.toArray(models)
    collection = new QueryCollection(models,options).live(true)
    return collection
}

# Export
if module? and module.exports?
  module.exports = exports
else if window?
  window.queryEngine = exports

