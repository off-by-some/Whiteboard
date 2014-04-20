module.exports = (grunt) ->

  # Utilities
  # =========
  _ = grunt.util._
  path = require 'path'

  # Options
  # =======

  # Port offset
  # -----------
  # Increment this for additional gruntfiles that you want
  # to run simultaneously.
  portOffset = 0

  # Host
  # ----
  # You could use this to your IP address to expose it over a local intranet.
  hostname = 'localhost'

  # Router
  # ------
  router = {}
  router[hostname] = "#{ hostname }:#{ 4501 + portOffset }"

  # Base directory
  # --------------
  # Set this to where you're directory structure is
  # based on.
  baseDirectory = '.'

  # Configuration
  # =============
  grunt.initConfig

    # Cleanup
    # -------
    clean:
      all: [
        "#{ baseDirectory }/temp/**/*"
        "!#{ baseDirectory }/temp/components"
        "!#{ baseDirectory }/temp/components/**/*"
      ]

    # File management
    # ---------------
    copy:
      static:
        files: [
          expand: true
          filter: 'isFile'
          cwd: "#{ baseDirectory }/src"
          dest: "#{ baseDirectory }/temp"
          src: [
            '**/*'
            '!**/*.ls'
            '!**/*.scss'
            '!**/*.haml'
          ]
        ]

    # Symlink
    # -------
    # Ensure that the temporary directories can access the bower components.
    symlink:
      bower:
        overwrite: true
        src: "#{ baseDirectory }/bower_components"
        dest: "#{ baseDirectory }/temp/components"

    # LiveScript
    # ----------
    livescript:
      compile:
        files: [
          expand: true
          filter: 'isFile'
          cwd: "#{ baseDirectory }/src/scripts"
          dest: "#{ baseDirectory }/temp/scripts"
          src: '**/*.ls'
          ext: '.js'
        ]

        options:
          bare: true

    # Micro-templates
    # ---------------
    haml:
      options:
        language: 'coffee'
        placement: 'amd'
        uglify: true
        dependencies:
          'haml': 'lib/haml'

      compile:
        files: [
          expand: true
          filter: 'isFile'
          cwd: "#{ baseDirectory }/src/templates"
          dest: "#{ baseDirectory }/temp/scripts/templates"
          src: '**/*.haml'
          ext: '.js'
        ]

        options:
          target: 'js'

      index:
        dest: "#{ baseDirectory }/temp/index.html"
        src: "#{ baseDirectory }/src/index.haml"

    # Stylesheets
    # -----------
    sass:
      compile:
        dest: "#{ baseDirectory }/temp/styles/main.css"
        src: "#{ baseDirectory }/src/styles/main.scss"
        options:
          loadPath: path.join(path.resolve('.'), baseDirectory, 'temp')

      css:
        options:
          out: "#{ baseDirectory }/styles/main.css"
          optimizeCss: 'standard.keepLines'
          cssImportIgnore: null
          cssIn: "#{ baseDirectory }/temp/styles/main.css"

    # LiveReload
    # ----------
    livereload:
      port: 12000 + portOffset

    # Webserver
    # ---------
    connect:
      options:
        port: 3501 + portOffset
        hostname: hostname
        middleware: (connect, options) -> [
          require('grunt-connect-proxy/lib/utils').proxyRequest
          require('connect-url-rewrite') ['^[^.]*$ /']
          require('connect-livereload') {port: 12000 + portOffset}
          connect.static options.base
        ]

      temp:
        proxies: [{context: '/api', host: hostname, port: 8000}]
        options:
          base: "#{ baseDirectory }/temp"

    # Watch
    # -----
    watch:
      sass:
        files: ["#{ baseDirectory }/src/**/*.scss"]
        tasks: ["sass:compile"]

      livescript:
        files: ["#{ baseDirectory }/src/**/*.ls"]
        tasks: ["livescript"]

      haml:
        files: ["#{ baseDirectory }/src/**/*.haml"]
        tasks: ["haml"]

      livereload:
        files: [
          "#{ baseDirectory }/temp/**/*",
          "!#{ baseDirectory }/temp/components/**/*"
        ]
        options:
          livereload: 12000 + portOffset

  # Dependencies
  # ============
  cwd = process.cwd()
  global.process.chdir __dirname
  require('matchdep').filter('grunt-*').forEach grunt.loadNpmTasks
  global.process.chdir cwd

  # Tasks
  # =====

  # Default
  # -------
  grunt.registerTask 'default', [
    'prepare'
    'script'
    'server'
  ]

  # Prepare
  # -------
  grunt.registerTask 'prepare', [
    'clean'
  ]

  # Script
  # ------
  # Compiles scripts through the pipeline; pushing in common.js live-script
  # and outputting AMD javascript.
  grunt.registerTask 'script', [
    'livescript'
  ]

  # Server
  # ------
  grunt.registerTask 'server', [
    'copy:static'
    'symlink:bower'
    'script'
    'haml'
    'sass'
    'configureProxies:temp'
    'connect:temp'
    'watch'
  ]
