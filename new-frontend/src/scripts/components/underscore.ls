'use strict'

require 'underscore'
str = require 'underscore-string'

_ = window._
_.str = str
_.mixin _.str.exports!

module.exports = _
