import React, { Component } from 'react';
import WebGLCanvas from "./components/WebGLCanvas";
import { Autobind } from "babel-autobind";
import WebGLRect from "./components/WebGLRect";
import WebGLCircle from "./components/WebGLCircle";

@Autobind
class App extends Component {
  state = {
    counter: 0,
  }

  constructor() {
    super()
    // Rerender onClick
    document.addEventListener("click", () => {
      this.setState({ counter: this.state.counter + 1 })
    })
  }

  render() {
    const faceColor = [1, 0.85, 0, 1]

    return (
       <WebGLCanvas>
           <WebGLCircle
             x={500 + this.state.counter}
             y={500 + this.state.counter}
             radius={200 + this.state.counter}
             color={faceColor}
           />
           <WebGLCircle
             x={500 + this.state.counter}
             y={500 + this.state.counter}
             radius={100 + this.state.counter}
             color={[Math.random(), Math.random(), Math.random(), 1]}
           />
           <WebGLCircle
             x={500 + this.state.counter}
             y={500 + this.state.counter}
             radius={90 + this.state.counter}
             color={faceColor}
           />

           <WebGLRect
             x={400 + this.state.counter}
             y={400 + this.state.counter}
             height={100 + this.state.counter}
             width={200 + this.state.counter}
             radius={90 + this.state.counter}
             color={faceColor}
           />

           <WebGLCircle
             x={450 + this.state.counter}
             y={450 + this.state.counter}
             radius={20 + this.state.counter}
             color={[Math.random(), Math.random(), Math.random(), 1]}
           />
           <WebGLCircle
             x={550 + this.state.counter}
             y={450 + this.state.counter}
             radius={20 + this.state.counter}
             color={[Math.random(), Math.random(), Math.random(), 1]}
           />
      </WebGLCanvas>
    );
  }
}

export default App;
