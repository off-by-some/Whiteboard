'use strict'

# Moment for timestamps.
require! moment

# Require our base views.
require! ItemView: 'lib/views/collection-view'
require! CollectionView: 'lib/views/view'

require! ItemTemplate: 'templates/stroke'
require! CollectionTemplate: 'templates/canvas'

module.exports = class Stroke extends ItemView

  template: ItemTemplate

  tag-name: \li

  class-name: \canvas-stroke

  initialize: (options = {}) ->
    super ...
    console.log options

module.exports = class Canvas extends CollectionView

  id: \canvas

  template: CollectionTemplate

  list-selector: \.items

  item-view: Stroke

  regions:
    'canvas:strokes': \.canvas-strokes

  state-bindings:
    '.menu-icon':
      observe: \menu
      attributes: [
        * name: \class
          on-get: (open) -> switch open
          | true => \icon-chevron-up
          | _ => \icon-chevron-down
      ]
      update-view: false

  # Some custom key bindings to reference.
  ctrl-z: (event)-> event.which is 90_z and event.ctrl-key

  events:
    'click .menu-selector > .toggle-switch': (event) ->
      event.stop-propagation!

      # Toggle the menu.
      @$ 'ul.menu-items' .slide-toggle 250_ms
      @$ '.toggle-switch' .toggle-class \active
      # Toggle the state of the menu.
      @state.set \menu, not @state.get \menu

    'mousedown': (event) ->
      console.log event.src-element
      if event.target is @$ \.toggle-switch
        console.log \menu

      switch event.button
      # Only catch the left mouse click
      | 0 =>
        # Fade out the title screen.
        @$ '.title' .fade-out 250_ms

        # More custom logic.
        console.log 'Instantiate a brush stroke?'

      # We can add different functionality to other buttons.
      | _ =>
        # Let the model know that its time to change.
        @model.set \changed, moment!
        console.log 'Unreserved mouse action.'

    'mouseup': (event) -> switch event.button
    # Only catch the left mouse click
    | 0 =>
      @model.set \changed, moment!
      # console.log @model

  initialize: (options = {}) ->
    super ...

    @state = options.state

    # Check whe window on all keyup events.
    $ window .on 'keyup', (event) ~>
      if ctrl = event.ctrl-key
        switch event.which
        | 90_z =>
          # Undo function call here.
          console.log 'undo function'

  render: ->
    super ...
    @$ '.title' .hide!
    @stickit @state, @state-bindings
