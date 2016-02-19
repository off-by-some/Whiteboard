import Alt from "alt"

// Actions
import SiteActions from "./actions/site"

// Stores
import SiteStore from "./stores/site"

export default class Flux extends Alt {
  constructor() {
    super()

    // Add action creators
    this.addActions("Site", SiteActions)


    // Add stores
    this.addStore("Site", SiteStore)

    // If in development; instantiate the ALT development tool
    if (process.env.NODE_ENV === "development") {
      require("alt/utils/chromeDebug")(this)
    }
  }
}
