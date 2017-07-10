import {
  shaderSource as vShaderSource,
  type as vType
} from "../__mocks__/vertex-shader";

import {
  shaderSource as fShaderSource,
  type as fType
} from "../__mocks__/fragment-shader";


import id from "../../lib/id";
import ShaderService from '../shaders';
import createGl from "../__mocks__/gl";


describe("Services: Programs", () => {
  let gl
  beforeEach(() => {
    gl = createGl()
  });

  describe("unit:", () => {
    it("#create should create a vertex shader object", () => {
      const vertexShader = ShaderService.create(vType, vShaderSource)
      expect(vertexShader.source).toEqual(vShaderSource)
      expect(vertexShader.type).toEqual(vType)
      expect(vertexShader.id).toEqual(id(vShaderSource))
    });

    it("#create should create a fragment shader object", () => {
      const vertexShader = ShaderService.create(fType, fShaderSource)
      expect(vertexShader.source).toEqual(fShaderSource)
      expect(vertexShader.type).toEqual(fType)
      expect(vertexShader.id).toEqual(id(fShaderSource))
    });

    it("#compile should compile a shader object into a gl shader", () => {
      const vertexShader = ShaderService.create(vType, vShaderSource)
      ShaderService.compile(gl, vertexShader)
      expect(gl.createShader).toHaveBeenCalled()
      expect(gl.shaderSource).toHaveBeenCalled()
      expect(gl.compileShader).toHaveBeenCalled()
      expect(gl.getShaderParameter).toHaveBeenCalled()
    });
    //
    // it("#compile should throw an error if compilation failed", () => {
    //   const programObj = ProgramService.create(vertexShader, fragmentShader)
    //
    //   // Failed compilation
    //   gl.getProgramParameter = jest.fn(() => false);
    //   expect(() => ProgramService.compile(gl, programObj)).toThrow();
    //   expect(spy).toHaveBeenCalled()
    //   expect(gl.createProgram).toHaveBeenCalled()
    //   expect(gl.attachShader).toHaveBeenCalled()
    //   expect(gl.linkProgram).toHaveBeenCalled()
    //   expect(gl.getProgramParameter).toHaveBeenCalled()
    // });
  })
});
