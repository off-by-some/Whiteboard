import React from "react"
import {connect} from "alt-react"

export default function connectToStores(component) {
  if (component.contextTypes == null) component.contextTypes = {}
  if (component.contextTypes.flux == null) {
    component.contextTypes.flux = React.PropTypes.object.isRequired
  }

  let storeNames = []
  if (component.getStores != null) storeNames = component.getStores()
  if (component.stores != null) storeNames = component.stores
  if (component.store) storeNames = [component.store]

  return connect(component, (__, flux) => {
    return {
      listenTo(__, context) {
        let stores = []

        for (let storeName of storeNames) {
          stores.push(flux.stores[storeName])
        }

        return stores
      },
      getProps(__, context) {
        if (component.getPropsFromStores != null) {
          return component.getPropsFromStores.apply(this, arguments)
        }

        let props = {}
        for (let storeName of storeNames) {
          props[storeName] = flux.stores[storeName].getState()
        }

        return props
      }
    }
  })
}
