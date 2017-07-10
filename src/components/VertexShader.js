import PropTypes from "prop-types";
import React from "react";
import Shader from "./Shader";

export default class VertexShader extends React.Component {
  static propTypes = {
    children: PropTypes.string.isRequired,
  };

  render () {
    return <Shader shaderType="vertex">{this.props.children}</Shader>
  }
}
