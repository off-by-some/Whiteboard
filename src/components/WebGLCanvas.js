import _ from "lodash"
import React from "react"
import PropTypes from "prop-types";
import { Autobind } from "babel-autobind"

class Canvas extends React.Component {
  static propTypes = {
    onCanvasLoad: PropTypes.func,
  }

  static defaultProps = {
    onCanvasLoad: x => x,
  }

  componentDidMount() {
    this.props.onCanvasLoad(this.refs.canvas);
  }

  render() {
    return (
      <canvas
           ref="canvas"
      />
    );
  }
}

@Autobind
class WebGLCanvas extends React.Component {
  static childContextTypes = {
    glCanvas: PropTypes.object
  }

  constructor() {
    super();

    this.resolves = [];
  }

  getChildContext() {
    return {
      glCanvas: { get: this.getCanvas }
    }
  }

  // Returns a promise with the canvas
  getCanvas() {
    debugger;
    if (this.canvas) return new Promise((resolve) => resolve({ canvas: this.canvas, gl: this.gl }));

    let resolve;
    const prom = new Promise((r) => {
      resolve = r;
    });

    this.resolves.push(resolve);
    return prom;
  }

  handleCanvasLoad(canvas) {
    this.canvas = canvas;
    this.gl = this.canvas.getContext("webgl", {
      premultipliedAlpha: false
    });

    window.webglUtils.resizeCanvasToDisplaySize(this.gl.canvas);
    this.gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    this.gl.clearColor(1, 1, 1, 1);
    this.gl.clear(this.gl.COLOR_BUFFER_BIT);
    this.gl.enable(this.gl.BLEND);
    this.gl.blendEquation(this.gl.FUNC_ADD);
    this.gl.blendFunc(this.gl.SRC_ALPHA, this.gl.ONE_MINUS_SRC_ALPHA);
    debugger;
    // Load any components waiting to render
    for (const resolve of this.resolves) {
      resolve({ canvas: this.canvas, gl: this.gl });
    }
  }


  render() {
    return [
      <Canvas onCanvasLoad={this.handleCanvasLoad}/>,
      this.props.children
    ];
  }
}

export default WebGLCanvas
