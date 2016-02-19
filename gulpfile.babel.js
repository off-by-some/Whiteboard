'use strict'

import _ from "lodash"
import webpack from "webpack"
import WebpackDevServer from "webpack-dev-server"
import gulp from "gulp"
import gutil from "gulp-util"
import del from "del"
import runSequence from "run-sequence"
import config from "config"
import gulpLoadPlugins from "gulp-load-plugins"

const $ = gulpLoadPlugins()

gulp.task("clean", () => {
  return del(["./www", "./lib"])
})

gulp.task("default", (callback) => {
  runSequence("run", callback)
})


gulp.task("run", (callback) => {
  runSequence(
    "clean",
    ["nunjucks", "stylus", "images:symlink", "server:babel"],
    ["webpack-dev-server", "connect"],
    "watch",
  callback)
})


gulp.task("build", (callback) => {
  if (process.env.NODE_ENV == null) process.env.NODE_ENV = "production"
  runSequence(
    "clean",
    ["nunjucks", "stylus", "images", "webpack"],
    ["server:babel"],
    ["minify:js", "minify:html", "minify:css", "server:minify:js"],
  callback)
})


let webpackDevServer = false
gulp.task("webpack-dev-server", (callback) => {
  webpackDevServer = true
  new WebpackDevServer(webpack(_.extend({}, require("./webpack.config"), {
    // compiler configuration
    devtool: "source-map",
  })), {
    // server and middleware options
    contentBase: "./www",
    publicPath: "/assets/",
    noInfo: true,
    stats: {colors: true},
    inline: true,
  }).listen(config.ports.webpack, "0.0.0.0", (err) => {
    if (err) throw new gutil.PluginError("webpack-dev-server", err)
    // Server now listening
    // keep the server alive or continue?
    callback()
  })
})

gulp.task("webpack", (callback) => {
  webpack(require("./webpack.config"), (err) => {
    if (err) throw new gutil.PluginError("webpack", err)
    callback()
  })
})

// Nunjucks
// =============================================================================
// Used to compile *.nunjucks templates; intended for the index HTML.
gulp.task("nunjucks", () => {
  $.nunjucksRender.nunjucks.configure(".", {
    watch: false,
  })

  return gulp.src(["./index.nunjucks"])
    .pipe($.nunjucksRender({
      config: require("./webpack.config").config,
      env: process.env.NODE_ENV || "development",
      host: config.host,
      ports: config.ports,
    }))
    .pipe(gulp.dest("./www"))
    .pipe($.livereload())
})

gulp.task("connect", () => {
  return $.connect.server({
    root: "./www",
    port: config.ports.connect,
    host: "0.0.0.0",
    middleware() {
      const result = [
        require("connect-history-api-fallback")(),
      ]

      if (webpackDevServer) {
        // NOTE: Proxy all javascript files and socket-io requests to
        //       the webpack-dev-server.
        result.push((req, res, next) => {
          if (req.url.indexOf("/assets/") >= 0 ||
              req.url.indexOf("socket.io") >= 0) {
            const proxy = require("proxy-middleware")
            return proxy(`http://${config.host}:${config.ports.webpack}/`)(
              req, res, next)
          }

          next()
        })
      }

      return result
    },
  })
})



gulp.task("stylus", () => {
  return gulp.src("./styles/index.styl")
    .pipe($.plumber())
    .pipe($.sourcemaps.init())
    .pipe($.stylus({use: [require("kouto-swiss")()]}))
    .pipe($.autoprefixer({browsers: ["last 4 versions"]}))
    .pipe($.rename({basename: "app"}))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest("./www/assets"))
    .pipe($.livereload())
})


gulp.task("images:symlink", () => {
  return gulp.src("./images").pipe($.symlink("./www/images"))
})


gulp.task("images", () => {
  return gulp.src("./images/**/*").pipe(gulp.dest("www/images"))
})


gulp.task("watch", () => {
  $.livereload.listen({
    port: config.ports.livereload,
    host: "0.0.0.0",
    quiet: true,
  })

  $.watch("./src/**/*.js", $.batch((events, callback) => {
    gulp.start("server:babel", callback)
  }))

  // Stylus
  $.watch("./styles/**/*.styl", $.batch((events, callback) => {
    gulp.start("stylus", callback)
  }))
})

// Minify
gulp.task("minify:js", () => {
  return gulp.src("./www/assets/*.js")
    .pipe($.uglify())
    .pipe(gulp.dest("./www/assets"))
})

gulp.task("server:minify:js", () => {
  return gulp.src("./lib/**/*.js")
    .pipe($.uglify())
    .pipe(gulp.dest("./lib"))
})

gulp.task("minify:css", () => {
  return gulp.src("./www/assets/*.css")
    .pipe($.csso())
    .pipe($.minifyCss())
    .pipe(gulp.dest("./www/assets"))
})

gulp.task("minify:html", () => {
  return gulp.src("./www/*.html")
    .pipe($.htmlmin({
      collapseWhitespace: true,
      removeComments: true,
      removeScriptTypeAttributes: true,
      removeStyleLinkTypeAttributes: true,
    }))
    .pipe(gulp.dest("./www"))
})

// Babel [server]
// =============================================================================
gulp.task("server:babel", () => {
  return gulp.src("./src/**/*.js")
    .pipe($.babel())
    .pipe(gulp.dest("./lib/"))
})
