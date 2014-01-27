'use strict'

require! chaplin
require! cookie

require! Controller: 'lib/controllers/canvas'

require! StrokesView: 'views/strokes'

module.exports = class IndexController extends Controller

  strokes: ->

    canvas_id = cookie.get \canvas_id

    @collection = new chaplin.Collection

    for num in [1 til 10]
      number = 140 + num
      model = new chaplin.Model {
        preview: "http://www.placekitten.com/#number/#number"
        stroke_number: num
        created: moment!
      }
      @collection.push model

    console.log @collection

    @subscribe-event 'stroke:add', (model) ~>
      @collection.push model

    @view = new StrokesView {
      collection: @collection
      region: \canvas:strokes
      +auto-render
    }
