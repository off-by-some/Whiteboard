'use strict'

require! chaplin
require! cookie

require! Controller: 'lib/controllers/header'

module.exports = class IndexController extends Controller

  home: ->
