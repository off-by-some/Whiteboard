import { merge } from "lodash"
import ProgramStore from "../stores/programs";
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
  debugger;
  if (this.programId) return new Promise((r) => r(this.programId))
  if (this.progRs == null) this.progRs = []
  return new Promise((r) => {
    this.progRs.push(r);
  })
}

async function start() {
  const res = await this.context.glCanvas.get()
  this.canvas = res.canvas;
  this.gl = res.gl;
  const programId = await this.getProgramId()
  const program = ProgramStore.getProgram(programId)

  this.glDidMount(res.canvas, res.gl, program)
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
    shouldComponentUpdate: (() => false),
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
