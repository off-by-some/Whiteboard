'use strict'

require! chaplin
require! moment
require! cookie

require! HeaderView: 'views/canvas'

module.exports = class Index extends chaplin.Controller

  before-action: ->
    <~ $.when super ... .then

    @compose 'canvas', ->
      # The collection of strokes on this canvas.
      @collection = new chaplin.Collection

      @state = new chaplin.Model {menu: false}

      # Test canvas.
      @model = new chaplin.Model do
        # Track the changes for potential reversion tools.
        created: moment!
        changed: moment!

        # Some fake contributors for display purposes.
        contributors: [
          * name: \taystack
            email: \taystack@example.com
            active: true
          * name: \pholey
            email: \pholey@example.com
            active: true
          * name: \bla
            email: \pholey@example.com
            active: true
        ]
      @view = new HeaderView {
        model: @model
        collection: @collection
        state: @state
        container: \body
      }
      @view.render!
