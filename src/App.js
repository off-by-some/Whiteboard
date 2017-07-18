import _ from "lodash"
import React, { Component } from 'react';
import WebGLCanvas from "./components/WebGLCanvas";
import { Autobind } from "babel-autobind";
import WebGLRect from "./components/WebGLRect";
import WebGLCircle from "./components/WebGLCircle";
import { unstable_deferredUpdates } from "react-dom";

@Autobind
class App extends Component {
  state = {
    circles: [],
    colors: [],
  }

  constructor() {
    super()
    // Rerender onClick
    document.addEventListener("click", () => {
      this.setState({ counter: this.state.counter + 1 })
    })
  }

  handleClickForCanvas(event) {
    let totalOffsetX = 0;
    let totalOffsetY = 0;
    let canvasX = 0;
    let canvasY = 0;
    let currentElement = event.target;

    do {
        totalOffsetX += currentElement.offsetLeft - currentElement.scrollLeft;
        totalOffsetY += currentElement.offsetTop - currentElement.scrollTop;
    }
    while(currentElement = currentElement.offsetParent)

    canvasX = event.pageX - totalOffsetX;
    canvasY = event.pageY - totalOffsetY;

    unstable_deferredUpdates(() => {
      this.setState({
        circles: this.state.circles.concat([[canvasX, canvasY]]),
        colors: this.state.colors.concat([[Math.random(), Math.random(), Math.random(), 1.0]])
      })
    })

  }

  handleMouseDown() {
    this.setState({mouseDown: true})
  }

  handleMouseUp() {
    this.setState({mouseDown: false})
  }

  handleMouseMove(event) {
    if (!this.state.mouseDown) return;

    let totalOffsetX = 0;
    let totalOffsetY = 0;
    let canvasX = 0;
    let canvasY = 0;
    let currentElement = event.target;

    do {
        totalOffsetX += currentElement.offsetLeft - currentElement.scrollLeft;
        totalOffsetY += currentElement.offsetTop - currentElement.scrollTop;
    }
    while(currentElement = currentElement.offsetParent)

    canvasX = event.pageX - totalOffsetX;
    canvasY = event.pageY - totalOffsetY;

    this.setState({
      circles: this.state.circles.concat([[canvasX, canvasY]]),
      colors: this.state.colors.concat([[Math.random(), Math.random(), Math.random(), 1.0]])
    })
  }

  render() {
    return (
       <WebGLCanvas
         onMouseDown={this.handleMouseDown}
         onMouseUp={this.handleMouseUp}
         onMouseMove={this.handleMouseMove}
        >
          <WebGLCircle
              vertices={_.flatten(this.state.circles)}
              radius={4}
              colors={_.flatten(this.state.colors)}
          />
      </WebGLCanvas>
    );
  }
}

export default App;
