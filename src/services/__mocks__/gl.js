import { merge } from "lodash";

export default function createGl(x) {
  return merge({
    attachShader: jest.fn(x => ({})),
    linkProgram: jest.fn(x => ({})),
    getProgramParameter: jest.fn(x => ({})), // Successful compilation
    deleteShader: jest.fn(x => ({})),
    getShaderInfoLog: jest.fn(x => "Error: Failed to compile "),
    createProgram: jest.fn(x => ({})),
  }, x)
}
