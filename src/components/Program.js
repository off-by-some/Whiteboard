import _ from "lodash";
import React from "react";
import { Autobind } from "babel-autobind";
import PropTypes from "prop-types";
import ProgramStore from "../stores/programs";
import ProgramService from "../services/programs";
// import NoopRenderer from "react-noop-renderer";

@Autobind
class GLProgram extends React.Component {
  static propTypes = {
    // children: PropTypes.arrayOf(
    //   PropTypes.oneOfType([
    //   PropTypes.instanceOf(FragmentShader),
    //   PropTypes.instanceOf(VertexShader),
    // ])),
  }

  static contextTypes = {
    glComponent: PropTypes.object.isRequired,
  }

  static childContextTypes = {
    glProgram: PropTypes.object,
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
    if (this.shaders.vertex && this.shaders.fragment) {
      const program = ProgramService.create(this.shaders.vertex, this.shaders.fragment);
      ProgramStore.pushProgram(program);
      this.context.glComponent.registerProgram(program.id)
    }
  }

  getChildContext() {
    return {
      glProgram: { registerShader: this.registerShader }
    }
  }


  render() {
    return <div style={{display: "none"}}>{this.props.children}</div>;
  }
}

export default GLProgram;
