import React, { Component } from 'react';
import WebGLCanvas from "./components/WebGLCanvas";
import { Autobind } from "babel-autobind";
import WebGLRect from "./components/WebGLRect";
import WebGLCircle from "./components/WebGLCircle";


@Autobind
class App extends Component {
  render() {
    const faceColor = [1, 0.85, 0, 1]

    return (
       <WebGLCanvas>
           <WebGLCircle
             x={500}
             y={500}
             radius={200}
             color={faceColor}
           />
           <WebGLCircle
             x={500}
             y={500}
             radius={100}
             color={[Math.random(), Math.random(), Math.random(), 1]}
           />
           <WebGLCircle
             x={500}
             y={500}
             radius={90}
             color={faceColor}
           />

           <WebGLRect
             x={400}
             y={400}
             height={100}
             width={200}
             radius={90}
             color={faceColor}
           />

           <WebGLCircle
             x={450}
             y={450}
             radius={20}
             color={[Math.random(), Math.random(), Math.random(), 1]}
           />
           <WebGLCircle
             x={550}
             y={450}
             radius={20}
             color={[Math.random(), Math.random(), Math.random(), 1]}
           />
      </WebGLCanvas>
    );
  }
}

export default App;
