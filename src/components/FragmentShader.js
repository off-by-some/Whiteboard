import React from "react";
import Shader from "./Shader";

export default class FragmentShader extends React.Component {
  static propTypes = {
    children: React.PropTypes.string.isRequired,
  };

  render () {
    return <Shader shaderType="fragment" {...this.props} />
  }
}
