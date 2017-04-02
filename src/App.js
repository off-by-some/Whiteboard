import React, { Component } from 'react';
import WebGLCanvas from "./components/WebGLCanvas";
import Program from "./components/Program";
import VertexShader from "./components/VertexShader";
import FragmentShader from "./components/FragmentShader";
import { Autobind } from "babel-autobind";
import WebGLRect from "./components/WebGLRect";

// // Returns a random integer from 0 to range - 1.
function randomInt(range) {
  return Math.floor(Math.random() * range);
}

// Fills the buffer with the values that define a rectangle.
function rect(gl, x, y, width, height) {
  var x1 = x;
  var x2 = x + width;
  var y1 = y;
  var y2 = y + height;

  // NOTE: gl.bufferData(gl.ARRAY_BUFFER, ...) will affect
  // whatever buffer is bound to the `ARRAY_BUFFER` bind point
  // but so far we only have one buffer. If we had more than one
  // buffer we'd want to bind that buffer to `ARRAY_BUFFER` first.
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
     x1, y1,
     x2, y1,
     x1, y2,
     x1, y2,
     x2, y1,
     x2, y2]), gl.STATIC_DRAW);
}

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
            x={40}
            y={40}
            width={20}
            height={20}
            color={[Math.random(), Math.random(), Math.random(), 1]}
           />

           <WebGLRect
             x={30}
             y={30}
             width={20}
             height={20}
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
