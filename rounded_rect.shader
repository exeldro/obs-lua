uniform int corner_radius;
uniform int border_thickness;
uniform float4 border_color;

float4 mainImage(VertData v_in) : TARGET
{
    float4 output = image.Sample(textureSampler, v_in.uv);
    if(output.a < 0.5){
        return float4(0.0,0.0,0.0,0.0);
    }
    int closedEdgeX = 0;
    if(image.Sample(textureSampler, v_in.uv + float2(corner_radius*uv_pixel_interval.x,0)).a < 0.5){
        closedEdgeX = corner_radius;
    }else if(image.Sample(textureSampler, v_in.uv + float2(-corner_radius*uv_pixel_interval.x,0)).a < 0.5){
        closedEdgeX = corner_radius;
    }
    int closedEdgeY = 0;
    if(image.Sample(textureSampler, v_in.uv + float2(0,corner_radius*uv_pixel_interval.y)).a < 0.5){
         closedEdgeY = corner_radius;
    }else if(image.Sample(textureSampler, v_in.uv + float2(0,-corner_radius*uv_pixel_interval.y)).a < 0.5){
         closedEdgeY = corner_radius;
    }
    if(closedEdgeX == 0 && closedEdgeY == 0){
        return output;
    }
    if(closedEdgeX != 0){
        [loop] for(int x = 1;x<corner_radius;x++){
            if(image.Sample(textureSampler, v_in.uv + float2(x*uv_pixel_interval.x, 0)).a < 0.5){
                closedEdgeX = x;
                break;
            }
            if(image.Sample(textureSampler, v_in.uv + float2(-x*uv_pixel_interval.x, 0)).a < 0.5){
                closedEdgeX = x;
                break;
            }
        }
    }
    if(closedEdgeY != 0){
        [loop] for(int y = 1;y<corner_radius;y++){
            if(image.Sample(textureSampler, v_in.uv + float2(0, y*uv_pixel_interval.y)).a < 0.5){
                closedEdgeY = y;
                break;
            }
            if(image.Sample(textureSampler, v_in.uv + float2(0, -y*uv_pixel_interval.y)).a < 0.5){
                closedEdgeY = y;
                break;
            }
        }
    }
    if(closedEdgeX == 0){
        if(closedEdgeY < border_thickness){
            return border_color;
        }else{
            return output;
        }
    }
    if(closedEdgeY == 0){
        if(closedEdgeX < border_thickness){
            return border_color;
        }else{
            return output;
        }
    }

    float d = distance(float2(closedEdgeX, closedEdgeY), float2(corner_radius,corner_radius));
    if(d<corner_radius){
        if(corner_radius-d < border_thickness){
            return border_color;
        }else{
            return output;
        }
    }
    return float4(0.0,0.0,0.0,0.0);
}