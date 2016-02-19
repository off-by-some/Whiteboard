import React from "react"
import cx from "classnames"
import connectToStores from "../lib/connectToStores"

import {Link} from "react-router"

class Site extends React.Component {
  static contextTypes = {
    flux: React.PropTypes.object.isRequired,
  }

  render() {
    return (
      <div className="site">
        {this.props.children}
      </div>
    )
  }
}


export default connectToStores(Site)
