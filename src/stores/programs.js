import _ from "lodash";
import { observable, action } from "mobx";
import { Autobind } from "babel-autobind";
import { idExists } from "../lib/id";

@Autobind
class ProgramStore {

  programs = observable([]);
  shaders = observable([]);


  pushShader = action((shader) => {
    const shaderCompiled = idExists(this.shaders, shader.id);
    if (shaderCompiled) {
      console.log(`Shader ${shader.id} already registered, doing nothing`);
      return;
    }

    console.log(`Registered shader ${shader.id}`, shader);
    this.shaders.push(shader);
  });


  pushProgram = action((program) => {
    const programCompiled = idExists(this.programs, program.id);
    if (programCompiled) {
      console.log(`Shader ${program.id} already registered, doing nothing`);
      return;
    }

    console.log(`Registered program ${program.id}`, program);
    this.programs.push(program);
  });


  removeShaders = action((pred = () => false) => {
    this.shaders = _.filter(this.shaders, pred);
  });
}

export default new ProgramStore();
