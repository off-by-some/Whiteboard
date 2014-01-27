'use strict'

module.exports = (route) ->
  route '', 'strokes#strokes'
  route 'home', 'strokes#strokes'
  route ':id', 'strokes#recall'
