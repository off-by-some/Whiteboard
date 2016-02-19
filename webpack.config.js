const path = require("path")
const webpack = require("webpack")
const ConfigPlugin = require("webpack-config-plugin")
const VendorPlugin = require("webpack-vendor-plugin")
const ExtractTextPlugin = require("extract-text-webpack-plugin")

const extraPlugins = []
const NODE_ENV = process.env.NODE_ENV || "development"
const configPlugin = new ConfigPlugin({
  dir: path.join(__dirname, "config/browser"),
})

if (NODE_ENV === "production") {
  extraPlugins.push(
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin()
  )
}

module.exports = {
  entry: {
    app: "./src/index.js",
    // NOTE: Additional vendor modules that are not explicitly required
    //       can be added here
    vendor: [
      // NOTE: Remove if the project does not use font-awesome
      "font-awesome/css/font-awesome.css",
    ],
  },
  output: {
    path: path.join(__dirname, "www/assets/"),
    filename: "[name].js",
  },
  debug: NODE_ENV === "development",
  config: configPlugin.getConfig(),
  plugins: [
    new VendorPlugin({
      dir: path.join(__dirname, "src"),
    }),
    configPlugin,
    new webpack.ProvidePlugin({
      fetch: "imports?this=>global!exports?global.fetch!whatwg-fetch",
      regeneratorRuntime: "imports?this=>global!exports?global.regeneratorRuntime!regenerator/runtime"
    }),
    new ExtractTextPlugin("[name].css"),
    new webpack.DefinePlugin({
      "process.env": {
        NODE_ENV: JSON.stringify(NODE_ENV),
      },
    }),
    new webpack.ProvidePlugin({
      fetch: "imports?this=>global!exports?global.fetch!whatwg-fetch",
    }),
  ].concat(extraPlugins),
  module: {
    preLoaders: [
      {test: /\.json$/, loader: "json"},
    ],
    loaders: [
      {
        test: /\.jsx?$/,
        exclude: /(node_modules)/,
        loaders: ["babel-loader?cacheDirectory"],
      },

      // CSS (Stylesheets)
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract("style-loader", "css-loader"),
      },

      // Fonts (WOFF[2], TTF, EOT, SVG)
      {
        test: /\.woff(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=application/font-woff",
      }, {
        test: /\.woff2(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=application/font-woff",
      }, {
        test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=application/octet-stream",
      }, {
        test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
        loader: "file",
      }, {
        test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=image/svg+xml",
      },
    ],
  },
}
