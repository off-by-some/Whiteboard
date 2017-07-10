import { merge } from "lodash";

export default function createGl(x) {
  return merge({
    VERTEX_SHADER: 0,
    FRAGMENT_SHADER: 1,
    createShader: jest.fn(x => ({})),
    shaderSource: jest.fn(x => ({})),
    compileShader: jest.fn(x => ({})),
    deleteShader: jest.fn(x => ({})),
    getShaderParameter: jest.fn(x => ({})),
    attachShader: jest.fn(x => ({})),
    linkProgram: jest.fn(x => ({})),
    getProgramParameter: jest.fn(x => ({})), // Successful compilation
    getShaderInfoLog: jest.fn(x => "Error: Failed to compile "),
    createProgram: jest.fn(x => ({})),
  }, x)
}
