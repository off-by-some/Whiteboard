import _ from "lodash"
import React from "react"
import { Autobind } from "babel-autobind"

@Autobind
class WebGLCanvas extends React.Component {
  static childContextTypes = {
    gl: React.PropTypes.object,
    canvas: React.PropTypes.object,
  }

  static propTypes = {
    shadersWillCompile: React.PropTypes.func,
    WebGLDidMount: React.PropTypes.func,
  }

  static defaultProps = {
    shadersWillCompile: x => x,
    WebGLDidMount: x => x,
  }

  constructor() {
    super()
    this.programs = {}
  }

  getChildContext() {
    return {
      gl: this.gl || {},
      canvas: {instance: this.canvas, registerProgram: this.registerProgram},
    }
  }

  registerProgram(name, program) {
    this.programs[name] = program;
  }

  shouldComponentUpdate() {
    return false;
  }

  componentDidMount() {
    this.canvas = this.refs.canvas;
    this.gl = this.canvas.getContext("experimental-webgl");
    this.gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    this.gl.clearColor(1, 1, 1, 1);
    this.gl.clear(this.gl.COLOR_BUFFER_BIT);

    this.props.shadersWillCompile(this.canvas, this.gl);

    this.program_list = _.map(this.programs, (v) => v.compileProgram(this.gl));

    // Use the first program by default
    this.gl.useProgram(this.program_list[0])

    this.props.WebGLDidMount(this.canvas, this.gl, this.program_list[0])
  }


  render() {
    return (
      <canvas
          {..._.omit(this.props, _.keys(WebGLCanvas.propTypes))}
          id="mycanvas"
          ref="canvas"
      >
        {this.props.children}
      </canvas>
    );
  }
}

export default WebGLCanvas








// <WebGLCanvas>
//   <Program name="foobar">
//     <VertexShader>`
//       attribute vec2 vPosition;
//       uniform vec2 u_resolution;
//       void main(void)
//       {
//         // convert the position from pixels to 0.0 to 1.0
//         vec2 zeroToOne = vPosition / u_resolution;
//
//         // convert from 0->1 to 0->2
//         vec2 zeroToTwo = zeroToOne * 2.0;
//
//         // convert from 0->2 to -1->+1 (clipspace)
//         vec2 clipSpace = zeroToTwo - 1.0;
//
//         // Flip the y clipspace coord to have an API closer to canvas, where the top left is 0,0
//         gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
//       }`
//     </VertexShader>
//
//     <FragmentShader>`
//       precision mediump float;
//       uniform vec4 u_color;
//
//       void main(void)
//       {
//           gl_FragColor = u_color;
//       }`
//     </FragmentShader>
//   </Program>
//
// </WebGLCanvas>
