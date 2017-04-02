import React, { Component } from 'react';
import WebGLCanvas from "./components/WebGLCanvas";
import { Autobind } from "babel-autobind";
import WebGLRect from "./components/WebGLRect";


@Autobind
class App extends Component {
  render() {
    return (
       <WebGLCanvas>
         <WebGLRect
           x={0}
           y={0}
           width={20}
           height={20}
           color={[Math.random(), Math.random(), Math.random(), 1]}
          />

          <WebGLRect
            x={10}
            y={10}
            width={20}
            height={20}
            color={[Math.random(), Math.random(), Math.random(), 1]}
           />

           <WebGLRect
             x={20}
             y={20}
             width={20}
             height={20}
             color={[Math.random(), Math.random(), Math.random(), 1]}
            />

          <WebGLRect
            x={200}
            y={200}
            width={20}
            height={20}
            color={[Math.random(), Math.random(), Math.random(), 1]}
           />

           <WebGLRect
             x={500}
             y={500}
             width={80}
             height={80}
             color={[Math.random(), Math.random(), Math.random(), 1]}
            />

            <WebGLRect
              x={50}
              y={50}
              width={20}
              height={20}
              color={[Math.random(), Math.random(), Math.random(), 1]}
             />
      </WebGLCanvas>
    );
  }
}

export default App;
