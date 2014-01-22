'use strict'

require! moment

require! View: 'lib/views/view'
require! Template: 'templates/index'

module.exports = class Home extends View

  id: \home

  template: Template

  initialize: (options = {}) ->
    super ...
    $ window .on 'keyup mouseup', (event) ~>
      @model.set \changed, moment!format 'lll'
      console.log @model.get \changed