'use strict'

require! $: jquery
require! chaplin
require! routes
require! humane

build = (data = {}) ->
  #! URI to direct local requests to.
  data.local-uri or= '/api/'

  #! URI to direct external requests to.
  data.external-uri or= data.local-uri
  data

settings = (path = '/settings.json') ->
  dfd = new $.Deferred
  $.getJSON path
    ..done (data) -> dfd.resolve build data
    ..fail -> dfd.resolve build!
  dfd

module.exports = class Application extends chaplin.Application

  initialize: ->
    # Initialize chaplin core modules.
    # default: "#{foo}-controller"
    @init-dispatcher controller-suffix: ''
    @init-router routes
    @init-layout!
    @init-composer!
    @init-mediator!

    settings!done (data) ~>
        # Find and resolve settings before moving on.
        chaplin.mediator.settings = data

        # Start routing by taking the current URL and attempting to match it.
        @start!

        # Freeze the object instance; prevent further changes.
        Object.freeze? this

  init-mediator: ->
    # Attach any semi-globals here.
    chaplin.mediator.settings = null
    chaplin.mediator.seal!