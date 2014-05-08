require.config do

  base-url: '/scripts'
  map:
    '*':
      backbone: 'components/backbone'
      underscore: 'components/underscore'

    'components/backbone':
      backbone: '_backbone'

    'components/underscore':
      underscore: '_underscore'

  paths:
    jquery: '../components/jquery/jquery'
    _backbone: '../components/exoskeleton/exoskeleton'
    'backbone-stickit': '../components/backbone.stickit/backbone.stickit'
    _underscore: '../components/lodash/dist/lodash.compat'
    'underscore-string': '../components/underscore.string/lib/underscore.string'
    haml: 'lib/haml'
    chaplin: '../components/chaplin/chaplin'
    moment: '../components/moment/moment'
    prelude: '../components/prelude-ls/prelude-browser'
    inquire: '../components/inquire/lib/inquire-browser'
    cookie: '../components/cookie-monster/lib/cookie-monster'
    md5: '../components/spark-md5/spark-md5'
    humane: '../components/humane-js/humane'

  shim:

    _underscore:
      exports: '_'

    'backbone-stickit':
      deps: [ '_backbone' ],
      exports: 'Backbone.Stickit'

    'underscore-string':
      exports: '_.str'

    prelude:
      exports: 'prelude'

    cookie:
      exports: 'monster'

require <[ application ]>, (Application) ->
  # Instantiate the application and begin the execution cycle.
  new Application!
