'use strict'

require! moment

require! View: 'lib/views/view'
require! Template: 'templates/index'

module.exports = class Home extends View

  id: \home

  template: Template

  # Some custom key bindings to reference.
  ctrl-z: (event)-> event.which is 90_z and event.ctrl-key

  events:
    'mousedown': (event) -> switch event.button
    | 0 =>
      # Fade out the title screen.
      @$ '.title' .fade-out 250_ms

      # Let the model know that its time to change.
      @model.set \changed, moment!format "dddd, MMMM Do YYYY, h:mm:ss:ms a"

      # More custom logic.
      console.log 'Instantiate a brush stroke?'

    | _ =>
      # We can add different functionality to other buttons.
      console.log 'Reserve other mouse actions'

  initialize: (options = {}) ->
    super ...

    # Check whe window on all keyup events.
    $ window .on 'keyup', (event) ~>
      ctrl = event.ctrl-key
      switch event.which
      | 90_z =>
        # Undo function call here.
        if ctrl
          console.log 'undo function'
