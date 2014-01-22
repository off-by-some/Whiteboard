'use strict'

require! chaplin

module.exports = class Model extends chaplin.Model implements chaplin.SyncMachine

  #! Name of the resource on the server.
  name: null

  #! cookies to use credentials.
  cookies: true

  #! What URI this collection is bound to.
  bind: 'default'

  #! The current in-flight request.
  _request: null

  initialize: (attributes, options = {}) ->
    @bind = options.bind if options.bind
    super attributes, options

  #! Root of all resources on the server.
  url-root: ->
    "#{ chaplin.mediator.settings.uris[@bind] }#{ @name }"

  #! Files need to do special things because FileReader API only supports IE10+
  #! Fair warning: The vast majority of this is copied from an older project.
  #! There's a good chance there's still bugs in it.
  manual-sync: (method, model, options) ->
    # Make a form
    form = new FormData
    for key, value of model.toJSON!
      # Forms are key value pairs.  Each key corresponds to an array of values
      # So slapping an array inside of the value doesn't make sense.  If we
      # encounter an array, just unroll it.
      if _.is-array value
        for v in value
          form.append key, v
      else
        form.append key, value

    # Add some manual stuff to make jquery happy
    options.processData = false
    options.contentType = false
    options.data = form
    options.url = _.result model, \url

    # Copied from backbone
    methodMap =
      'create': \POST
      'update': \PUT
      'patch':  \PATCH
      'delete': \DELETE
      'read':   \GET

    options.type = methodMap[method]

    # Save the success and error then
    # overload success and error to trigger backbone's usual callbacks
    success = options.success
    error = options.error

    options.success = ->
      if success
        that model, it, options
        model.trigger \sync model, it, options

    options.error = ->
      if error
        that model, it, options
        model.trigger \error model, it, options

    # Send the request off to $.ajax
    options.xhr = promise = Backbone.ajax options

    # Trigger the request going off
    model.trigger \request model, promise, options

    # Return the promise for other people to play with
    promise

  #! Send multipart/formdata if the request contains files
  save: (attrs, options = {}) ->
    # Iterate over the attributes and whatever was passed down.
    for name, value of {} <<< @attributes <<< attrs when value instanceof File
      # If it's a file, force a file flag that `sync` will use.
      options.filesend = true
      # We can leave early because we already know we're dealing with a file.
      return super ...
    super ...

  sync: (method, model, options = {}) ->
    # Abort the currently in-flight request.
    @_request.abort! if @_request

    # Initiate a syncing operation.
    @begin-sync!

    # Configure the request to support CORS.
    options.xhrFields = {withCredentials: @cookies} if @cookies
    options.crossDomain = true if @cookies

    @_request = if options.filesend
      # Do a special sync if we're dealing with files
      @manual-sync ...
    else
      # Otherwise just invoke a new normal request.
      super ...

    # Remove ourself after the request has been complete.
    @_request.done ~>
      @_request = null
      @finish-sync!

    # Abort if the request is cancelled.
    @_request.fail @~abort-sync

  dispose: ->
    return if @disposed

    # Explicitly end all syncing operations.
    @unsync!

    # Abort any currently in-flight requests
    @_request.abort! if @_request

    super ...
