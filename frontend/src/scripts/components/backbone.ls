'use strict'

require 'backbone'
require 'backbone-stickit'
require 'backbone-mutators'
require 'backbone-deep-model'

# Replace model with deep-model
window.Backbone.Model = window.Backbone.DeepModel

module.exports = window.Backbone
