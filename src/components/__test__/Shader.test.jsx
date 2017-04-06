import React from "react";
import { mount } from "enzyme";
import Shader from "../Shader";
import ProgramStore from "../../stores/programs";

global.window = global;
window.addEventListener = () => {};
window.requestAnimationFrame = () => {
  throw new Error('requestAnimationFrame is not supported in Node');
};

const shaderSource = `
  attribute vec2 vPosition;
  uniform vec2 u_resolution;
  uniform float u_radius;

  void main(void)
  {
    gl_PointSize = u_radius;

    // convert the position from pixels to 0.0 to 1.0
    vec2 zeroToOne = vPosition / u_resolution;

    // convert from 0->1 to 0->2
    vec2 zeroToTwo = zeroToOne * 2.0;

    // convert from 0->2 to -1->+1 (clipspace)
    vec2 clipSpace = zeroToTwo - 1.0;

    // Flip the y clipspace coord to have an API closer to canvas, where the top left is 0,0
    gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
  }
`

describe("<Shader />", () => {
  beforeEach(() => {
    ProgramStore.removeShaders(() => true);
  });

  it("Should register a shader to the ProgramStore onComponentMount", () => {
    const element = mount(<Shader type="vertex">{shaderSource}</Shader>);

    expect(ProgramStore.shaders.length).toEqual(1);
    expect(ProgramStore.shaders[0].source).toEqual(shaderSource)
  });
});
