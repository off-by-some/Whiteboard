# A collaborative Whiteboard powered by WebGL + react-fiber

Example WebGL API:

![img](http://i.imgur.com/Tzyft1m.png)

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

### Running the app:
`$ yarn`

### Running tests (enzyme's a bit borked right now with react-fiber):
`$ yarn test`
