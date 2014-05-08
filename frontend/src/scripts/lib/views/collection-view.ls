'use strict'

require! _: underscore
require! chaplin

module.exports = class CollectionView extends chaplin.CollectionView

  # Default the container to be the body.
  container: 'body'

  # Automatically apply stickit bindings.
  auto-stickit: true

  # Don't automatically render.
  auto-render: false

  # Template rendering context.
  context: {}

  # The passed in data for the view.
  _view-data: {}

  #! Extend this to provide the precompiled template.
  #! eg. `template: require 'templates/index'`
  template: -> ''

  get-template-data: ->
    # Grab the original template data,
    # and stuff our context stuff into it.
    (super ...) <<< (_.result this, 'context') <<< _.result this, '_viewData'

  get-template-function: ->
    # Return the template function to hook into
    # chaplin's template system.
    @template

  initialize: (@options = {}) ->
    super ...
    # Copy any thing from the passed in context into the view's context.
    @_view-data = @options.context

  render: ->
    # Hook into chaplin to render and attach us to the DOM.
    super ...

    # Apply basic stickit bindings.
    @stickit! if @autoStickit and @bindings and @model

  dispose: ->
    return if @disposed
    @unstickit! if @autoStickit and @bindings and @model
    super ...
