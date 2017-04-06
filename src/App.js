import React, { Component } from 'react';
import WebGLCanvas from "./components/WebGLCanvas";
import { Autobind } from "babel-autobind";
import WebGLRect from "./components/WebGLRect";
import WebGLCircle from "./components/WebGLCircle";
import VertexShader from "./components/VertexShader";
import FragmentShader from "./components/FragmentShader";
import Program from "./components/Program";

@Autobind
class App extends Component {
  render() {

    return (
      <WebGLCanvas>
        <Program>
          <VertexShader>{`
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
            }`}
          </VertexShader>

          <FragmentShader>{`
            precision mediump float;
            uniform vec4 u_color;

            void main(void)
            {
                gl_FragColor = u_color;
                if (distance(gl_PointCoord, vec2(0.5, 0.5)) > 0.5) {
                  gl_FragColor.a = 0.0;
                }
            }`}
          </FragmentShader>
        </Program>
      </WebGLCanvas>
    );
  }
}

export default App;
