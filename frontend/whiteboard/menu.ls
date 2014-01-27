# Don't mind this, just trying to translate the JQuery to LS

$ document .ready ->
  $ document .ready ->

    # Init Menu
    $ "#menu > ul > li ul" .each (index, e) ->
      count = $ e .find \li .length
      content = "<span class=\"cnt\">#count</span>"
      $ e .closest \li .children \a .append content

    $ "#menu ul ul li:odd" .add-class \odd
    $ "#menu ul ul li:even" .add-class \even
    $ "#menu > ul > li > a" .click ->
      $ "#menu li" .remove-class \active
      $ this .closest \li .add-class \active
      check-element = $ this .next!
      if (check-element.is \ul) and (check-element.is \:visible)
        $ this .closest \li .remove-class \active
        check-element.slide-up \normal
      if (check-element.is \ul) and (not check-element.is \:visible)
        $ "#menu ul ul:visible" .slide-up \normal
        check-element.slide-down \normal
      if $ this .closest(\li).find(\ul).children!.length is 0
        return true
      else return false


    # Show/Hide Menu + Switch Captions
    a = 0
    $ \.showhide .click (e) ->

      #e.preventDefault!;
      if a is 0
        $ "#menu" .animate {left: \152px}, \slow .show!
        $ "#a-show" .fade-toggle 500
        $ "#a-hide" .fade-toggle 500
        a = 1
      else
        $ "#menu" .animate {left: \-150px}, \slow .show!
        $ "#a-show" .fade-toggle 500
        $ "#a-hide" .fade-toggle 500
        a = 0

    $ "#canvas" .mousedown (e) ->
      $ "#drawhere" .fade-out 150


