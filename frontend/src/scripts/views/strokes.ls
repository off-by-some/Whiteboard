'use strict'

require! moment

require! ItemView: 'lib/views/view'
require! CollectionView: 'lib/views/collection-view'

require! CollectionTemplate: 'templates/strokes/list'
require! ItemTemplate: 'templates/strokes/item'

# I imagine this area is where we could keep a faux-photoshop
# layers-type view for a user to keep track of each stroke.
class Stroke extends ItemView

  tag-name: \li

  class-name: \stroke-item

  template: ItemTemplate

  bindings:
    '.created':
      observe: \created
      on-get: -> moment it .format 'L LT'

    '.preview':
      attributes: [
        * name: \src
          observe: \preview
      ]

  #   # Maybe an image of the stroke? We can figure this out later.
  #   '.stroke': \path

  initialize: (options = {}) ->
    super ...
    console.log @model.get \created

module.exports = class Strokes extends CollectionView

  id: \strokes-list

  item-view: Stroke

  list-selector: \.stroke-items

  template: CollectionTemplate
