import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import {flatten} from "lodash"

function createShader(gl, type, source) {
  var shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
  if (success) {
    return shader;
  }

  // Failed, clean up and log what happened
  console.log(gl.getShaderInfoLog(shader));
  gl.deleteShader(shader);
}

// Returns a random integer from 0 to range - 1.
function randomInt(range) {
  return Math.floor(Math.random() * range);
}

// Fills the buffer with the values that define a rectangle.

function setRectangle(gl, x, y, width, height) {
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

function createProgram(gl, vertexShader, fragmentShader) {
  var program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  var success = gl.getProgramParameter(program, gl.LINK_STATUS);
  if (success) {
    return program;
  }

  // Failed, clean up and log what happened
  console.log(gl.getProgramInfoLog(program));
  gl.deleteProgram(program);
}

class App extends Component {

  componentDidMount() {
    const canvas = this.refs.canvas;
    const gl = canvas.getContext("experimental-webgl");
    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.clearColor(1, 1, 1, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);
    //
    var v = document.getElementById("vertex").firstChild.nodeValue;
    var f = document.getElementById("fragment").firstChild.nodeValue;

    var vertexShader = createShader(gl, gl.VERTEX_SHADER, v);
    var fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, f);

    const program = createProgram(gl, vertexShader, fragmentShader)

    gl.useProgram( program );

    this.positionAttributeLocation = gl.getAttribLocation(program, "vPosition");
    this.resolutionUniformLocation = gl.getUniformLocation(program, "u_resolution");
    this.colorUniformLocation = gl.getUniformLocation(program, "u_color");

    this.positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, this.positionBuffer);

    var positions = [
      10, 20,
      80, 20,
      10, 30,
      10, 30,
      80, 20,
      80, 30,
    ];

    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

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
    for (var ii = 0; ii < 5000; ++ii) {
      // Setup a random rectangle
      // This will write to positionBuffer because
      // its the last thing we bound on the ARRAY_BUFFER
      // bind point
      setRectangle(
          gl, randomInt(500), randomInt(500), randomInt(500), randomInt(500));

      // Set a random color.
      gl.uniform4f(this.colorUniformLocation, Math.random(), Math.random(), Math.random(), 1);

      // Draw the rectangle.
      gl.drawArrays(gl.TRIANGLES, 0, 6);
    }
  }


  render() {
    return (
      <div>
        <canvas id="mycanvas" ref="canvas" width="800" height="500"></canvas>
      </div>
    );
  }
}

export default App;
