import _ from "lodash"
import React from "react"
import { Autobind } from "babel-autobind"

class Canvas extends React.Component {
  static propTypes = {
    onCanvasLoad: React.PropTypes.func,
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
  }


  render() {
    return [
      <Canvas onCanvasLoad={this.handleCanvasLoad}/>,
      this.props.children
    ];
  }
}

export default WebGLCanvas
