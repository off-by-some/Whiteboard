const _ = require("lodash")

// NOTE: Adjust this for additional projects
const portOffset = 0

module.exports = _.extend({
  name: "Foobar",
  host: "localhost",

  // URL of the API
  api: "localhost:9001",

  ports: {
    server: 8000 + portOffset,
    webpack: 7000 + portOffset,
    connect: 8500 + portOffset,
    livereload: 32000 + portOffset,
  },
})
