require.config do
  base-url: '/scripts'
  map:
    '*':
      backbone: 'components/backbone'
      underscore: 'components/underscore'

    'components/backbone':
      backbone: '_backbone'

    'backbone-mutators':
      backbone: '_backbone'

    'backbone-deep-model':
      backbone: '_backbone'

    'components/underscore':
      underscore: '_underscore'

  paths:
    jquery: '../components/jquery/jquery'
    _backbone: '../components/backbone/backbone'
    'backbone-stickit': '../components/backbone.stickit/backbone.stickit'
    'backbone-mutators': '../components/backbone.mutators/backbone.mutators'
    'backbone-deep-model': '../components/backbone-deep-model/distribution/deep-model'
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
    dropbox: 'vendor/dropbox'

  shim:
    _backbone:
      deps: [ 'underscore', 'jquery' ]
      exports: 'Backbone'

    _underscore:
      exports: '_'

    'backbone-stickit':
      deps: [ '_backbone' ],
      exports: 'Backbone.Stickit'

    'backbone-deep-model':
      deps: [ '_backbone', '_underscore' ],
      exports: 'Backbone.DeepModel'

    'underscore-string':
      exports: '_.str'

    prelude:
      exports: 'prelude'

    cookie:
      exports: 'monster'

    dropbox:
      exports: 'DropboxAPI'

require <[ application ]>, (Application) ->
  # Instantiate the application and begin the execution cycle.
  new Application!
