import React from "react";
import VertexShader from "./VertexShader";
import FragmentShader from "./FragmentShader";
import Program from "./Program";
import { Autobind } from "babel-autobind";
import PropTypes from "prop-types";
import glComponent from "../lib/glComponent";

@Autobind
@glComponent
class WebGLCircle extends React.Component {
  static propTypes = {
    colors: PropTypes.array.isRequired,
    vartices: PropTypes.array.isRequired,
    radii: PropTypes.array.isRequired,
  }

  color(gl, colors) {

    // Enable color vertex attribute
    gl.enableVertexAttribArray(this.colorAttributeLocation);

    // Bind the color buffer
    gl.bindBuffer(gl.ARRAY_BUFFER, this.colorBuffer);

    // Bind the color buffer data
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW);

    const size = 4;
    const type = gl.FLOAT;
    const normalize = false;
    const stride = 0;
    const offset = 0;
    gl.vertexAttribPointer(this.colorAttributeLocation, size, type, normalize, stride, offset);
  }

  radius(gl, radii) {

    // Enable color vertex attribute
    gl.enableVertexAttribArray(this.radiusAttributeLocation);

    // Bind the color buffer
    gl.bindBuffer(gl.ARRAY_BUFFER, this.radiusBuffer);

    // Bind the color buffer data
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(radii), gl.STATIC_DRAW);

    const size = 1;
    const type = gl.FLOAT;
    const normalize = false;
    const stride = 0;
    const offset = 0;
    gl.vertexAttribPointer(this.radiusAttributeLocation, size, type, normalize, stride, offset);
  }

  // Fills the buffer with the values that define a circle.
  circle(gl, vertices) {

    // NOTE: gl.bufferData(gl.ARRAY_BUFFER, ...) will affect
    // whatever buffer is bound to the `ARRAY_BUFFER` bind point
    // but so far we only have one buffer. If we had more than one
    // buffer we'd want to bind that buffer to `ARRAY_BUFFER` first.
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
  }

  glWillMount(canvas, gl, program) {
    this.positionAttributeLocation = gl.getAttribLocation(program, "vPosition");
    this.colorAttributeLocation = gl.getAttribLocation(program, "a_color");
    this.radiusAttributeLocation = gl.getAttribLocation(program, "a_radius");
    this.resolutionUniformLocation = gl.getUniformLocation(program, "u_resolution");
    this.positionBuffer = gl.createBuffer();
    this.colorBuffer = gl.createBuffer();
    this.radiusBuffer = gl.createBuffer();
  }

  glRender(canvas, gl, props) {

    this.radius(gl, props.radii);

    this.color(gl, props.colors);

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

    this.circle(gl, props.vertices);

    // Draw the rectangle.
    gl.drawArrays(gl.POINTS, 0, props.vertices.length / 2);
  }

  render() {
    return (
      <Program>
        <VertexShader>{`
          attribute vec2 vPosition;
          uniform vec2 u_resolution;
          attribute float a_radius;
          attribute vec4 a_color;
          varying vec4 v_color;

          void main(void)
          {
            gl_PointSize = a_radius;

            // convert the position from pixels to 0.0 to 1.0
            vec2 zeroToOne = vPosition / u_resolution;

            // convert from 0->1 to 0->2
            vec2 zeroToTwo = zeroToOne * 2.0;

            // convert from 0->2 to -1->+1 (clipspace)
            vec2 clipSpace = zeroToTwo - 1.0;

            // Flip the y clipspace coord to have an API closer to canvas, where the top left is 0,0
            gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);

            // Pipe vertex color to fragment shader
            v_color = a_color;
          }`}
        </VertexShader>

        <FragmentShader>{`
          precision mediump float;
          varying vec4 v_color;

          void main(void)
          {
              gl_FragColor = v_color;
              if (distance(gl_PointCoord, vec2(0.5, 0.5)) > 0.5) {
                gl_FragColor.a = 0.0;
              }
          }`}
        </FragmentShader>
      </Program>
    );
  }
}

export default WebGLCircle
