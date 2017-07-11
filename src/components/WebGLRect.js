import _ from "lodash";
import React from "react";
import VertexShader from "./VertexShader";
import FragmentShader from "./FragmentShader";
import Program from "./Program";
import { Autobind } from "babel-autobind";
import PropTypes from "prop-types";
import ProgramService from "../services/programs";
import glComponent from "../lib/glComponent";

@Autobind
@glComponent
class WebGLRect extends React.Component {
  static propTypes = {
    color: PropTypes.array.isRequired,
  }

  // Fills the buffer with the values that define a rectangle.
  rect(gl, x, y, width, height) {
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

  webGLDidMount(canvas, gl, programObj) {
    const program = ProgramService.compile(this.gl, programObj);
    gl.useProgram(program)

    this.positionAttributeLocation = gl.getAttribLocation(program, "vPosition");
    this.resolutionUniformLocation = gl.getUniformLocation(program, "u_resolution");
    this.colorUniformLocation = gl.getUniformLocation(program, "u_color");
    this.positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, this.positionBuffer);

    // Rerender onClick
    document.addEventListener("click", () => {
      gl.useProgram(program)
      this.glRender(canvas, gl, this.props)
    });
  }

  glRender(canvas, gl, props) {
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

    this.rect(gl,
      props.x,
      props.y,
      props.width,
      props.height,
    );

    const [r, g, b, a] = this.props.color

    // Set a random color.
    gl.uniform4f(this.colorUniformLocation, r, g, b, a);
    // Draw the rectangle.
    gl.drawArrays(gl.TRIANGLES, 0, 6);
  }

  render() {
      return (
      <Program name="rect">
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
    );
  }
}

export default WebGLRect
