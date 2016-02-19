import React from "react"

export default class Whiteboard extends React.Component {
  constructor() {
    super(...arguments)
    this.canvas = null
    this.isDrawing = false;
    this.endLine = this.endLine.bind(this);
    this.update = this.update.bind(this);
    this.initDraw = this.initDraw.bind(this);
    this.handleDraw = this.handleDraw.bind(this);
    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleResize = this.handleResize.bind(this);


  }

  shouldComponentUpdate() {
    return false
  }

  handleResize() {
    const ctx = this.canvas.getContext('2d')
    ctx.canvas.width = window.innerWidth
    ctx.canvas.height = window.innerHeight
  }

  componentDidMount() {
    this.stage = new createjs.Stage("whiteboard")
    this.offset = this.canvas.getBoundingClientRect()
    this.line = null
    this.canvas.addEventListener("mousedown", this.handleMouseDown)
    this.canvas.addEventListener("mousemove", this.handleDraw)
    this.canvas.addEventListener("mouseup", this.endLine)
    this.canvas.addEventListener("resize", this.resize)
    this.handleResize()


  }

  handleDraw(e) {
    if (this.isDrawing) {
      this.drawTo(e.clientX, e.clientY)
    }
  }

  handleMouseDown(e) {
    this.initDraw(e.clientX, e.clientY)
  }

  initDraw(startX, startY) {
    this.isDrawing = true
    this.line = new createjs.Shape()
    this.stage.addChild(this.line)
    this.line.graphics.setStrokeStyle(3000).beginStroke("rgba(0,0,0,1)")
    this.line.graphics.moveTo(startX, startY)
  }

  drawTo(x, y) {
    this.line.graphics.lineTo(x, y)
    this.stage.update()

  }

  update() {
    console.log("updateing")
    this.stage.update()
  }

  endLine() {
    this.isDrawing = false
    this.line.graphics.endStroke()
    this.update()
  }

  render() {
    return (
      <canvas ref={x => this.canvas = x} id="whiteboard"></canvas>
    )
  }
}
