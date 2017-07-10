import React from "react";
import { Autobind } from "babel-autobind";
import PropTypes from "prop-types";
import ProgramStore from "../stores/programs";
import ShaderService from "../services/shaders";

@Autobind
class Shader extends React.Component {
  static propTypes = {
    children: PropTypes.string.isRequired,
    shaderType: PropTypes.oneOf(["vertex", "fragment"]),
  };

  static contextTypes = {
    glProgram: PropTypes.object.isRequired,
  }

  shouldComponentUpdate() {
    return false;
  }

  componentWillMount() {
    const shader = ShaderService.create(this.props.shaderType, this.props.children);

    // Register this shader with our program
    this.context.glProgram.registerShader(shader);
  }

  render() {
    return null
  }
}

export default Shader;
