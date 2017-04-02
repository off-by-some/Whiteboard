import React, { Component } from 'react';
import WebGLCanvas from "./components/WebGLCanvas";
import { Autobind } from "babel-autobind";
import WebGLRect from "./components/WebGLRect";
import WebGLCircle from "./components/WebGLCircle";


@Autobind
class App extends Component {
  render() {
    return (
       <WebGLCanvas>
         <WebGLRect
           x={0}
           y={0}
           width={200}
           height={200}
           color={[Math.random(), Math.random(), Math.random(), 1]}
          />

          <WebGLRect
            x={100}
            y={100}
            width={200}
            height={200}
            color={[Math.random(), Math.random(), Math.random(), 1]}
           />

           <WebGLRect
             x={200}
             y={200}
             width={200}
             height={200}
             color={[Math.random(), Math.random(), Math.random(), 1]}
            />

          <WebGLRect
            x={400}
            y={400}
            width={200}
            height={200}
            color={[Math.random(), Math.random(), Math.random(), 1]}
           />

           <WebGLCircle
             x={450}
             y={450}
             radius={200}
             color={[Math.random(), Math.random(), Math.random(), 1]}
           />
      </WebGLCanvas>
    );
  }
}

export default App;
