import React from "react";
import PropTypes from "prop-types";
import Shader from "./Shader";

export default class FragmentShader extends React.Component {
  static propTypes = {
    children: PropTypes.string.isRequired,
  };

  render () {
    return <Shader shaderType="fragment" {...this.props} />
  }
}
