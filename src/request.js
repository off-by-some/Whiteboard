import fetchival from "fetchival"
import config from "config"

// Configure the default, top-level request
export default fetchival(config.api)
