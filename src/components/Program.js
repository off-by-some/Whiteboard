import _ from "lodash";
import React from "react";
// import FragmentShader from "./FragmentShader";
// import VertexShader from "./VertexShader";
import { Autobind } from "babel-autobind";
import md5 from "js-md5";

@Autobind
class GLProgram extends React.Component {
  static propTypes = {
    // children: React.PropTypes.arrayOf(
    //   React.PropTypes.oneOfType([
    //   React.PropTypes.instanceOf(FragmentShader),
    //   React.PropTypes.instanceOf(VertexShader),
    // ])),
    name: React.PropTypes.string.isRequired,
  }

  static contextTypes = {
    gl: React.PropTypes.object.isRequired,
    canvas: React.PropTypes.object.isRequired,
    glComponent: React.PropTypes.object,
  }

  static childContextTypes = {
    program: React.PropTypes.object,
  }

  getChildContext() {
    return {
      program: {
        pushShader: this.pushShader,
        popShader: this.popShader,
      }
    };
  }

  constructor() {
    super()

    this.registeredShaders = {
      "vertex": undefined,
      "fragment": undefined
    };
  }

  _internalId() {
    const { vertex, fragment } = this.registeredShaders;
    return md5(vertex._internalId() + fragment._internalId())
  }

  setProgramId(programId) {
    // Register our program id with our GLComponent
    if (this.context.glComponent) {
      this.context.glComponent.setProgramId(programId)
    }
  }

  compileProgram(gl) {
    const programId = this._internalId()
    const cachedProgram = this.context.gl.getProgramWithID(programId);

    if (cachedProgram != null) {
      this.setProgramId(programId);
      console.log(`Program ${programId} already compiled, doing nothing`)
      return { [programId]: cachedProgram };
    }

    const { vertex, fragment } = this.registeredShaders;
    const vertexShader = vertex.compileShader(gl)
    const fragmentShader = fragment.compileShader(gl)

    this.program = gl.createProgram();

    gl.attachShader(this.program, vertexShader);
    gl.attachShader(this.program, fragmentShader);
    gl.linkProgram(this.program);
    var success = gl.getProgramParameter(this.program, gl.LINK_STATUS);

    // Register our program id with our GLComponent


    if (success) {
      this.setProgramId(programId)
      console.log(`Successfully compiled Program with name ${this.props.name} and srcId ${programId}`)
      return {[programId]: this.program};
    }

    // Failed, clean up and log what happened
    console.log(gl.getProgramInfoLog(this.program));
    gl.deleteProgram(this.program);
  }

  componentWillUnmount() {
    this.deleteProgram()
  }

  componentDidMount() {
    this.context.gl.registerProgram(this.props.name, this)
  }

  deleteProgram() {
    if (this.program == null) return;

    this.context.gl.deleteProgram(this.program);
  }

  pushShader(shader, type) {
    this.registeredShaders[type] = shader;
  }

  popShader(shader, type) {
    this.registeredShaders[type] = undefined
  }

  render() {
    return (
      <div>{this.props.children}</div>
    )
  }
}

export default GLProgram;
