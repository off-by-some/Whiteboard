import { merge } from "lodash"
import PropTypes from "prop-types";

import ProgramStore from "../stores/programs";
import ProgramService from "../services/programs";


// Merge our own getChildContext with the component's
function wrapGetChildContext(fn) {
  const oCtx = fn();
  return function(x) {
    const newCtx = merge(oCtx, { 
      glComponent: { registerProgram: this.registerProgram } 
    })

    return newCtx
  };
}


// TODO: Switch to a more composable structure, 
// remove this function, stop using mobx and retain all 
// relevant glInformation on the component itself.
//
// Register's the id of the program with the component. 
// Used for program lookup.
function registerProgram(id) {

  this.programId = id;

  // Resolve any promises waiting for the program id
  if (this.progRs != null) {
    this.progRs.map(x => x(id))
    this.progRs = null;
  }
}

// TODO: Investigate react-16 in the case of cooperative scheduling mode.
//
// Get the program id. There's some possible smell here to return 
// it in an asyncronous fashion  
function getProgramId() {
  if (this.programId) return new Promise((r) => r(this.programId))
  if (this.progRs == null) this.progRs = []

  // Program id is not available (hasn't compiled yet), 
  // unwrap the promise and return it
  // (to be resolved by registerProgram)
  return new Promise((r) => {
    this.progRs.push(r);
  })
}

// After the component updates, call the glrender function. 
// This may have some issues, but seems to be sufficient for now. 
function wrapComponentDidUpdate(fn) {
  this.gl.useProgram(this.program)
  this.glRender(this.canvas, this.gl, this.props)

  if (fn) {
    return fn()
  }
}

// Currently overrides componentWillMount. The start of the gl lifecycle.
async function start() {
  // Request the canvas and gl context from our parent context
  const res = await this.context.glCanvas.get()
  this.canvas = res.canvas;
  this.gl = res.gl;

  // Get our compiled vertex/fragment shader
  const programId = await this.getProgramId()
  const programObj = ProgramStore.getProgram(programId)
  this.program = ProgramService.compile(this.gl, programObj);

  // Bind a reference to the canvas, glContext, 
  // and the program to the glDidUpdate function
  const glDidUpdate = this.glDidUpdate || (x => x)
  this.glDidUpdate = glDidUpdate.bind(this, this.canvas, this.gl, this.program)
  this.componentDidUpdate = wrapComponentDidUpdate.bind(this, this.componentDidUpdate)

  // Kick off the initial render
  this.gl.useProgram(this.program)
  this.glWillMount(res.canvas, res.gl, this.program)
  this.glRender(res.canvas, res.gl, this.props)
}


// Decorator that merges all of the above functions into the 
// component definition
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
