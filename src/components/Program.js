import _ from "lodash";
import React from "react";
import { Autobind } from "babel-autobind";
import ProgramStore from "../stores/programs";
import ProgramService from "../services/programs";

@Autobind
class GLProgram extends React.Component {
  static propTypes = {
    // children: React.PropTypes.arrayOf(
    //   React.PropTypes.oneOfType([
    //   React.PropTypes.instanceOf(FragmentShader),
    //   React.PropTypes.instanceOf(VertexShader),
    // ])),
  }

  static childContextTypes = {
    glProgram: React.PropTypes.object,
  }

  constructor() {
    super();

    this.shaders = {
      vertex: null,
      fragment: null,
    };
  }

  registerShader(shader) {
    ProgramStore.pushShader(shader);

    this.shaders[shader.type] = shader;
    debugger;
    if (this.shaders.vertex && this.shaders.fragment) {
      const program = ProgramService.create(this.shaders.vertex, this.shaders.fragment);
      ProgramStore.pushProgram(program);
    }
  }

  getChildContext() {
    return {
      glProgram: { registerShader: this.registerShader }
    }
  }


  render() {
    return (
      <div>{this.props.children}</div>
    )
  }
}

export default GLProgram;
