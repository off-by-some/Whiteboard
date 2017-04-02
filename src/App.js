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

  handleWebGLMount(canvas, gl, program) {
    this.positionAttributeLocation = gl.getAttribLocation(program, "vPosition");
    this.resolutionUniformLocation = gl.getUniformLocation(program, "u_resolution");
    this.colorUniformLocation = gl.getUniformLocation(program, "u_color");
    this.positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, this.positionBuffer);

    // Rerender onClick
    document.addEventListener("click", () => this.glRender(gl))

    this.glRender(gl)
  }

  glRender(gl) {
    window.webglUtils.resizeCanvasToDisplaySize(gl.canvas);
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
    gl.clearColor(0, 0, 0, 0);
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.enableVertexAttribArray(this.positionAttributeLocation);

    // Bind the position buffer.
    gl.bindBuffer(gl.ARRAY_BUFFER, this.positionBuffer);

    // set the resolution
    gl.uniform2f(this.resolutionUniformLocation, gl.canvas.width, gl.canvas.height);

    // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
    var size = 2;          // 2 components per iteration
    var type = gl.FLOAT;   // the data is 32bit floats
    var normalize = false; // don't normalize the data
    var stride = 0;        // 0 = move forward size * sizeof(type) each iteration to get the next position
    var offset = 0;        // start at the beginning of the buffer
    gl.vertexAttribPointer(
      this.positionAttributeLocation,
      size,
      type,
      normalize,
      stride,
      offset
    );

    // draw 50 random rectangles in random colors
    for (var ii = 0; ii < 22; ++ii) {
      // Setup a random rectangle
      // This will write to positionBuffer because
      // its the last thing we bound on the ARRAY_BUFFER
      // bind point
      rect(
          gl, randomInt(gl.canvas.height), randomInt(gl.canvas.height), randomInt(gl.canvas.height), randomInt(gl.canvas.height));

      // Set a random color.
      gl.uniform4f(this.colorUniformLocation, Math.random(), Math.random(), Math.random(), 1);

      // Draw the rectangle.
      gl.drawArrays(gl.TRIANGLES, 0, 6);
    }
  }

  render() {
    return (
       <WebGLCanvas webGLDidMount={this.handleWebGLMount}>
        <Program name="foobar">
          <VertexShader>{`
            attribute vec2 vPosition;
            uniform vec2 u_resolution;
            void main(void)
            {
              // convert the position from pixels to 0.0 to 1.0
              vec2 zeroToOne = vPosition / u_resolution;

              // convert from 0->1 to 0->2
              vec2 zeroToTwo = zeroToOne * 2.0;

              // convert from 0->2 to -1->+1 (clipspace)
              vec2 clipSpace = zeroToTwo - 1.0;

              // Flip the y clipspace coord to have an API closer to canvas, where the top left is 0,0
              gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
            }`}
          </VertexShader>

          <FragmentShader>{`
            precision mediump float;
            uniform vec4 u_color;

            void main(void)
            {
                gl_FragColor = u_color;
            }`}
          </FragmentShader>
        </Program>

        <Program name="baz">
          <VertexShader>{`
            attribute vec2 vPosition;
            uniform vec2 u_resolution;
            void main(void)
            {
              // convert the position from pixels to 0.0 to 1.0
              vec2 zeroToOne = vPosition / u_resolution;

              // convert from 0->1 to 0->2
              vec2 zeroToTwo = zeroToOne * 2.0;

              // convert from 0->2 to -1->+1 (clipspace)
              vec2 clipSpace = zeroToTwo - 1.0;

              // Flip the y clipspace coord to have an API closer to canvas, where the top left is 0,0
              gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
            }`}
          </VertexShader>

          <FragmentShader>{`
            precision mediump float;
            uniform vec4 u_color;

            void main(void)
            {
                gl_FragColor = u_color;
            }`}
          </FragmentShader>
        </Program>

      </WebGLCanvas>
    );
  }
}

export default App;
