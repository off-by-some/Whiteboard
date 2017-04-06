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
        <WebGLRect
          x={400}
          y={400}
          height={100}
          width={200}
          radius={90}
          color={[1,2,3,4]}
        />
      </WebGLCanvas>
    );
  }
}

export default App;
