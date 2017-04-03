# Whiteboard ala WebGL


Example WebGL API:
```
<WebGLCanvas>
    <WebGLCircle
      x={500}
      y={500}
      radius={200}
      color={faceColor}
    />
    <WebGLCircle
      x={500}
      y={500}
      radius={100}
      color={[Math.random(), Math.random(), Math.random(), 1]}
    />
    <WebGLCircle
      x={500}
      y={500}
      radius={90}
      color={faceColor}
    />

    <WebGLRect
      x={400}
      y={400}
      height={100}
      width={200}
      radius={90}
      color={faceColor}
    />

    <WebGLCircle
      x={450}
      y={450}
      radius={20}
      color={[Math.random(), Math.random(), Math.random(), 1]}
    />
    <WebGLCircle
      x={550}
      y={450}
      radius={20}
      color={[Math.random(), Math.random(), Math.random(), 1]}
    />
</WebGLCanvas>
```
