import React from "react"
import {Route, IndexRoute} from "react-router"

import Home from "./pages/home"
import Site from "./components/site"

export default (flux) => {
  return (
    <Route component={Site} path="/">
      <IndexRoute component={Home}/>
    </Route>
  )
}
