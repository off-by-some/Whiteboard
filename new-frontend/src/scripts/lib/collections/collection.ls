'use strict'

require! _: underscore
require! chaplin
require! inquire

module.exports = class Collection extends chaplin.Collection implements chaplin.SyncMachine

  #! Name of the resource on the server.
  name: null

  #! What URI this collection is bound to.
  bind: 'default'

  #! Query to apply when syncing the collection.
  query: null

  initialize: (attributes, options = {}) ->
    if options.query
      if @query
        @query <<< options.query

      else
        @query = options.query

    @query = inquire @query
    @bind = options.bind if options.bind
    super attributes, options

  #! Root of all resources on the server.
  url-root: ->
    "#{ chaplin.mediator.settings.uris[@bind] }#{ @name }"

  #! Produce an entire url for the model.
  url: -> "#{@url-root!}#{@query.generate!}"

  sync: (method, model, options = {}) ->
    # Initiate a syncing operation.
    @begin-sync!

    # Configure the request to support CORS.
    options.xhrFields = {+withCredentials}
    options.crossDomain = true

    # Invoke a new request.
    request = super method, model, options

    # Remove ourself after the request has been complete.
    request.done @~finish-sync

    # Abort if the request is cancelled.
    request.fail @~abort-sync

  dispose: ->
    return if @disposed

    # Explicitly end all syncing operations.
    @unsync!

    super ...
