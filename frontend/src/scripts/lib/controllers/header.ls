'use strict'

require! chaplin

require! moment

require! HeaderView: 'views/home'

module.exports = class Index extends chaplin.Controller

  before-action: ->
    <~ $.when super ... .then

    @compose 'header', ->
      @model = new chaplin.Model do
        created: moment!format 'lll'
        changed: moment!format 'lll'
        people: [{name: \taystack, active: true}, {name: \pholey, active: true}]
      @view = new HeaderView {
        model:@model
        container: \body
      }
      @view.render!
