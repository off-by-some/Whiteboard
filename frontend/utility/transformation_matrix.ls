class TransformationMatrix
    (clientwidth, clientheight) ->
        @resetOrigin clientwidth, clientheight
        @globalScale = [1, 1];
        @globalRotation = 0;
        @gtm = [1, 0, 0, 0, 1, 0]
    
    resetOrigin: (clientwidth, clientheight) !->
        @client_origin = [clientwidth / 2, clientheight / 2]
    
    translate: (delta_x, delta_y) !->
        @gtm[2] += delta_x
        @gtm[5] += delta_y
        return
    
    rotate: (delta_theta) !->
        @globalRotation += delta_theta
        sin_theta = Math.sin(delta_theta)
        cos_theta = Math.cos(delta_theta)
        @gtm[0] = (@gtm[0] * cos_theta) + (@gtm[1] * sin_theta)
        @gtm[1] = (@gtm[0] * (-sin_theta)) + (@gtm[1] * cos_theta)
        @gtm[3] = (@gtm[3] * cos_theta) + (@gtm[4] * sin_theta)
        @gtm[4] = (@gtm[3] * (-sin_theta)) + (@gtm[4] * cos_theta)
        return
    
    scale: (delta_width_mult, delta_height_mult) !->
        @globalScale[0] *= delta_width_mult
        @globalScale[1] *= delta_height_mult
        @gtm[0] *= delta_width_mult
        @gtm[4] *= delta_height_mult
        return
    
    addScale: (delta_width, delta_height) !->
        @globalScale[0] += delta_width
        @globalScale[1] += delta_height
        @setScale @globalScale[0], @globalScale[1]

    setTranslation: (x, y) !->
        @gtm[2] = x
        @gtm[5] = y
        return
    
    setRotation: (theta) !->
        @globalRotation = 0
        @gtm[0] = @globalScale[0]
        @gtm[1] = 0
        @gtm[3] = 0
        @gtm[4] = @globalScale[1]
        @rotate(theta)
        return
    
    setScale: (width_mult, height_mult) !->
        @globalScale = [width_mult, height_mult]
        @setRotation(@globalRotation)
        return
    
    # This shouldn't apply the transformation matrix
    # It should only get coords relative to the origin
    getActualCoords: (client_x, client_y) !->
        x = client_x - @client_origin[0]
        y = @client_origin[1] - client_y
        return @inverseTransformPoint(x, y)
    
    # This should restore canvas-specific coordinates
    getCanvasCoords: (x, y) !->
        return [x + @client_origin[0], -(y - @client_origin[1])]
    
    transformPoint: (x, y) !->
        t_x = (@gtm[0] * x) + (@gtm[1] * x) + @gtm[2]
        t_y = (@gtm[3] * y) + (@gtm[4] * y) + @gtm[5]
        return [t_x, t_y]
    
    inverseTransformPoint: (x, y) !->
        t_x = (@gtm[0] * x) + (-@gtm[1] * x) - @gtm[2]
        t_y = (-@gtm[3] * y) + (@gtm[4] * y) - @gtm[5]
        return [t_x, t_y]
    
    transformPoints: (points) !->
        retPoints = []
        for i from 0 til points.length by 1
            t_x = (@gtm[0] * points[i][0]) + (@gtm[1] * points[i][0]) + @gtm[2]
            t_y = (@gtm[3] * points[i][1]) + (@gtm[4] * points[i][1]) + @gtm[5]
            retPoints.push [t_x, t_y]
        return retPoints
