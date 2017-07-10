export const shaderSource = `
  attribute vec2 vPosition;
  uniform vec2 u_resolution;
  void main(void)
  {
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

export const type = "vertex"
