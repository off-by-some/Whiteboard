import React from "react";
import { Autobind } from "babel-autobind";
import md5 from "js-md5";

@Autobind
class Shader extends React.Component {
  static propTypes = {
    children: React.PropTypes.string.isRequired,
    shaderType: React.PropTypes.oneOf(["vertex", "fragment"]),
  };

  static contextTypes = {
    program: React.PropTypes.object.isRequired,
    gl: React.PropTypes.object.isRequired,
  }

  _internalId() {
    return md5(this.props.children)
  }

  compileShader(gl) {
    const typeMap = {
      "vertex": gl.VERTEX_SHADER,
      "fragment": gl.FRAGMENT_SHADER,
    };

    const type = typeMap[this.props.shaderType];

    this.shader = gl.createShader(type);

    gl.shaderSource(this.shader, this.props.children);
    gl.compileShader(this.shader);

    var success = gl.getShaderParameter(this.shader, gl.COMPILE_STATUS);
    if (success) {
      console.log(`Successfully compiled ${this.props.shaderType} shader ${this._internalId()}`)
      return this.shader;
    }

    // Failed, clean up and log what happened
    console.log(gl.getShaderInfoLog(this.shader));
    gl.deleteShader(this.shader);
    this.shader = undefined;
  }

  registerShader() {
    this.context.program.pushShader(this, this.props.shaderType);
  }

  deleteShader() {
    // If the shader failed to load, it's already been cleaned up
    if (this.shader == null) return;

    this.context.program.popShader(this, this.props.shaderType);
    this.context.gl.deleteShader(this.shader);
    this.shader = undefined;
  }

  componentWillMount() {
    this.registerShader()
  }

  componentWillUnmount() {
    this.deleteShader();
  }

  render() {
    return null
  }
}


export default Shader;
