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
        "#{ baseDirectory }/index.html",
        "#{ baseDirectory }/styles/**/*",
        "#{ baseDirectory }/scripts/**/*",
        "#{ baseDirectory }/robots.txt",
        "#{ baseDirectory }/settings.json",
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

      build:
        files: [
          expand: true
          filter: 'isFile'
          dest: "#{ baseDirectory }"
          cwd: "#{ baseDirectory }/temp"
          src: [
            '*',
            'styles/**/*.css',
            'media/**/*'
          ]
        ]

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

    # Dependency tracing
    # ------------------
    requirejs:
      compile:
        options:
          out: "#{ baseDirectory }/scripts/main.js"
          include: (_(grunt.file.expandMapping(['controllers/**/*'], ''
            cwd: "#{ baseDirectory }/src/scripts/"
            rename: (base, path) -> path.replace /\.coffee$|\.ls$/, ''
          )).pluck 'dest').concat(['main'])
          mainConfigFile: "#{ baseDirectory }/temp/components/concordus-base/lib/main.js"
          baseUrl: "#{ baseDirectory }/temp/scripts"
          keepBuildDir: true
          cjsTranslate: true
          almond: true
          replaceRequireScript: [
            files: ["#{ baseDirectory }/temp/index.html"],
            module: 'main'
          ]
          insertRequire: ['main']
          optimize: 'uglify2'

      css:
        options:
          out: "#{ baseDirectory }/styles/main.css"
          optimizeCss: 'standard.keepLines'
          cssImportIgnore: null
          cssIn: "#{ baseDirectory }/temp/styles/main.css"

    # CSS Compressor
    # --------------
    cssc:
      build:
        dest: "#{ baseDirectory }/styles/main.css"
        src: "#{ baseDirectory }/styles/main.css"
        options:
          sortSelectors: true
          lineBreaks: true
          sortDeclarations: true
          consolidateViaDeclarations: true
          consolidateViaSelectors: true
          consolidateMediaQueries: true
          compress: true
          sort: true
          safe: false

    # HTML Compressor
    # ---------------
    htmlmin:
      build:
        options:
          removeComments: true
          removeCommentsFromCDATA: true
          removeCDATASectionsFromCDATA: true
          collapseWhitespace: true
          collapseBooleanAttributes: true
          removeAttributeQuotes: true
          removeRedundantAttributes: true
          useShortDoctype: true
          removeEmptyAttributes: true
          removeOptionalTags: true

        src: "#{ baseDirectory }/index.html"
        dest: "#{ baseDirectory }/index.html"

    # Resource file hasher
    # --------------------
    hashres:
      options:
        fileNameFormat: '${hash}.${name}.${ext}'
        renameFiles: true

      build:
        src: [
          "#{ baseDirectory }/styles/main.css"
          "#{ baseDirectory }/scripts/main.js"
        ]

        dest: "#{ baseDirectory }/index.html"

    # Filesize reporter
    # -----------------
    bytesize:
      all:
        files: [
          src: [
            "#{ baseDirectory }/index.html",
            "#{ baseDirectory }/styles/*main.css",
            "#{ baseDirectory }/scripts/*main.js",
          ]
        ]

    # LiveReload
    # ----------
    livereload:
      port: 12000 + portOffset

    # Webserver
    # ---------
    connect:
      options:
        port: 4501 + portOffset
        hostname: hostname
        middleware: (connect, options) -> [
          require('connect-url-rewrite') ['^[^.]*$ /']
          require('grunt-contrib-livereload/lib/utils').livereloadSnippet
          connect.static options.base
        ]

      build:
        options:
          keepalive: true
          base: "#{ baseDirectory }"

      temp:
        options:
          base: "#{ baseDirectory }/temp"

    # Proxy
    # -----
    proxy:
      serve:
        options:
          port: 3501 + portOffset
          router: router

    # Watcher
    # -------
    regarde:
      livescript:
        files: "#{ baseDirectory }/src/**/*.ls"
        tasks: ['script', 'livereload']

      haml:
        files: "#{ baseDirectory }/src/templates/**/*.haml"
        tasks: ['haml:compile', 'livereload']

      index:
        files: "#{ baseDirectory }/src/index.haml"
        tasks: ['haml:index', 'livereload']

      sass:
        files: "#{ baseDirectory }/src/styles/**/*.scss"
        tasks: ['sass:compile', 'livereload']

      static:
        tasks: ['copy:static', 'livereload']
        files: [
          "#{ baseDirectory }/src/**/*.js"
          '!**/*.ls'
          '!**/*.scss'
          '!**/*.haml'
        ]

    # Infinite Wisdom
    # ---------------
    compliment: grunt.file.readYAML 'compliments.yml'

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
    'livereload-start'
    'copy:static'
    'script'
    'haml'
    'sass'
    'connect:temp'
    'proxy',
    'compliment',
    'regarde'
  ]

  # Build
  # -----
  grunt.registerTask 'build', [
    'prepare',
    'copy:static'
    'script'
    'haml'
    'sass'
    'requirejs:compile'
    'copy:build'
    'requirejs:css'
    'cssc:build'
    'hashres'
    'htmlmin'
    'bytesize'
  ]
