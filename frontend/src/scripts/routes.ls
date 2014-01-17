'use strict'

module.exports = (route) ->
  route '', 'index#home'
  route 'home', 'index#home'