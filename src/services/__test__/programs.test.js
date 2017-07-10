import id from "../../lib/id";
import ProgramService from "../programs";
import ShaderService from '../shaders';
import createGl from "../__mocks__/gl";

const vertexShader = {
  type: "vertex",
  id: id("vertex"),
}

const fragmentShader = {
  type: "fragment",
  id: id("fragment"),
}

describe("Services: Programs", () => {
  let spy, gl
  beforeEach(() => {
    spy = jest.spyOn(ShaderService, "compile").mockImplementation((gl, x) => x)
    gl = createGl()
  });

  afterEach(() => {
    spy.mockReset()
  })

  describe("unit:", () => {
    it("#create should create a program object given a vertex shader and a fragment shader", () => {
      const programObj = ProgramService.create(vertexShader, fragmentShader)

      expect(programObj.vertexShader).toEqual(vertexShader)
      expect(programObj.fragmentShader).toEqual(fragmentShader)

      const progId = id(vertexShader.id, fragmentShader.id)
      expect(programObj.id).toEqual(progId)
    });

    it("#compile should compile a program object into a gl program", () => {
      const programObj = ProgramService.create(vertexShader, fragmentShader)
      ProgramService.compile(gl, programObj);

      expect(spy).toHaveBeenCalled()
      expect(gl.createProgram).toHaveBeenCalled()
      expect(gl.attachShader).toHaveBeenCalled()
      expect(gl.linkProgram).toHaveBeenCalled()
      expect(gl.getProgramParameter).toHaveBeenCalled()
    });

    it("#compile should throw an error if compilation failed", () => {
      const programObj = ProgramService.create(vertexShader, fragmentShader)

      // Failed compilation
      gl.getProgramParameter = jest.fn(() => false);
      expect(() => ProgramService.compile(gl, programObj)).toThrow();
      expect(spy).toHaveBeenCalled()
      expect(gl.createProgram).toHaveBeenCalled()
      expect(gl.attachShader).toHaveBeenCalled()
      expect(gl.linkProgram).toHaveBeenCalled()
      expect(gl.getProgramParameter).toHaveBeenCalled()
    });
  })
});
