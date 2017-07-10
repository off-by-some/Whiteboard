import generateId from "../lib/id";

class ShaderService {
  create(type, source) {
    const shader = {
      source,
      type,
      id: generateId(source),
    };

    return shader;
  }

  compile(gl, shaderObj) {
    const typeMap = {
      "vertex": gl.VERTEX_SHADER,
      "fragment": gl.FRAGMENT_SHADER,
    };

    const { type, source } = shaderObj;
    const shader = gl.createShader(typeMap[type]);

    if (type == null) throw new Error(
        `compileShader expected a shaderType of "vertex" or "fragment", got ${type}`
    );

    gl.shaderSource(source);
    gl.compileShader(shader);
    var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (success) {
      console.log(`Successfully compiled shader ${generateId(source)}`)
      return shader;
    }

    // Failed, clean up and throw
    gl.deleteShader(shader);
    throw new Error(gl.getShaderInfoLog(shader));
  }
}


export default new ShaderService();
