import generateId from "../lib/id";
import ShaderService from "./shaders";

class ProgramService {
  create(vertexShader, fragmentShader) {
    if (vertexShader.type !== "vertex") {
      throw new Error(
        `Expected a vertex shader as the first parameter, got type ${vertexShader.type}
      `);
    }

    if (fragmentShader.type !== "fragment") {
      throw new Error(
        `Expected a fragment shader as the second parameter, got type ${vertexShader.type}
      `);
    }

    const id = generateId(vertexShader.id, fragmentShader.id);
    return { vertexShader, fragmentShader, id };
  }

  compile(gl, programObj) {
    const { vertex, fragment } = programObj;
    const fragmentShader = ShaderService.compile(gl, fragment);
    const vertexShader = ShaderService.compile(gl, vertex);
    const program = gl.createProgram();

    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);

    var success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success) {
      console.log(`Successfully compiled Program ${program.id}`)
      return program
    }

    // Failed, clean up and throw
    gl.deleteShader(program);
    throw new Error(gl.getShaderInfoLog(program));
  }
}

export default new ProgramService();
