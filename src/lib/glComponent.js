import { merge } from "lodash"
import ProgramStore from "../stores/programs";
import ProgramService from "../services/programs";

import PropTypes from "prop-types";

function wrapGetChildContext(fn) {
  const oCtx = fn();
  return function(x) {
    const newCtx = merge(oCtx, { glComponent: { registerProgram: this.registerProgram } })
    return newCtx
  };
}

function registerProgram(id) {
  this.programId = id;
  if (this.progRs != null) this.progRs.map(x => x(id));
}

function getProgramId() {
  if (this.programId) return new Promise((r) => r(this.programId))
  if (this.progRs == null) this.progRs = []
  return new Promise((r) => {
    this.progRs.push(r);
  })
}

function wrapComponentDidUpdate(fn) {
  console.log("wrapped!")
  this.gl.useProgram(this.program)
  this.glRender(this.canvas, this.gl, this.props)
  if (fn) {
    return fn()
  }
}

async function start() {
  const res = await this.context.glCanvas.get()
  this.canvas = res.canvas;
  this.gl = res.gl;
  const programId = await this.getProgramId()
  const programObj = ProgramStore.getProgram(programId)
  this.program = ProgramService.compile(this.gl, programObj);

  const glDidUpdate = this.glDidUpdate || (x => x)
  this.glDidUpdate = glDidUpdate.bind(this, this.canvas, this.gl, this.program)
  this.componentDidUpdate = wrapComponentDidUpdate.bind(this, this.componentDidUpdate)

  this.gl.useProgram(this.program)
  this.glWillMount(res.canvas, res.gl, this.program)
  this.glRender(res.canvas, res.gl, this.props)
}


export default function glComponent(target) {
  const oCT = target.contextTypes
  const newCT = merge(oCT, { glCanvas: PropTypes.object.isRequired });
  // target.contextTypes = newCT
  const oCCT = target.childContextTypes
  const newCCT = merge(oCCT, { glComponent: PropTypes.object.isRequired })

  const oGCC = target.prototype.getChildContext || (x => {})
  const attrs = {
    getChildContext: wrapGetChildContext(oGCC),
    registerProgram: registerProgram,
    getProgramId: getProgramId,
    // shouldComponentUpdate: (() => true),
    componentWillMount: start
  }

  Object.defineProperty(target, 'contextTypes', {
    enumerable: false,
    configurable: false,
    writable: false,
    value: newCT
  });

  Object.defineProperty(target, 'childContextTypes', {
    enumerable: false,
    configurable: false,
    writable: false,
    value: newCCT
  });

  Object.assign(target, attrs);
  Object.assign(target.prototype, attrs);

  return target
}
