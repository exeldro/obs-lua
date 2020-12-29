uniform int corner_radius;
uniform int border_thickness;
uniform float4 border_color;
uniform float border_alpha_start = 1.0;
uniform float border_alpha_end = 0.0;
uniform float alpha_cut_off = 0.5;

float4 mainImage(VertData v_in) : TARGET
{
    float4 pixel = image.Sample(textureSampler, v_in.uv);
    int closedEdgeX = 0;
    int closedEdgeY = 0;
    if(pixel.a < alpha_cut_off){
        return float4(1.0,0.0,0.0,0.0);
    }
    if(image.Sample(textureSampler, v_in.uv + float2(corner_radius*uv_pixel_interval.x,0)).a < alpha_cut_off){
        closedEdgeX = corner_radius;
    }else if(image.Sample(textureSampler, v_in.uv + float2(-corner_radius*uv_pixel_interval.x,0)).a < alpha_cut_off){
        closedEdgeX = -corner_radius;
    }
    if(image.Sample(textureSampler, v_in.uv + float2(0,corner_radius*uv_pixel_interval.y)).a < alpha_cut_off){
        closedEdgeY = corner_radius;
    }else if(image.Sample(textureSampler, v_in.uv + float2(0,-corner_radius*uv_pixel_interval.y)).a < alpha_cut_off){
        closedEdgeY = -corner_radius;
    }
    if(closedEdgeX == 0 && closedEdgeY == 0){
        return pixel;
    }
    if(closedEdgeX != 0){
        [loop] for(int x = 1;x<corner_radius;x++){
            if(image.Sample(textureSampler, v_in.uv + float2(x*uv_pixel_interval.x, 0)).a < alpha_cut_off){
                closedEdgeX = x;
                break;
            }
            if(image.Sample(textureSampler, v_in.uv + float2(-x*uv_pixel_interval.x, 0)).a < alpha_cut_off){
                closedEdgeX = -x;
                break;
            }
        }
    }
    if(closedEdgeY != 0){
        [loop] for(int y = 1;y<corner_radius;y++){
            if(image.Sample(textureSampler, v_in.uv + float2(0, y*uv_pixel_interval.y)).a < alpha_cut_off){
                closedEdgeY = y;
                break;
            }
            if(image.Sample(textureSampler, v_in.uv + float2(0, -y*uv_pixel_interval.y)).a < alpha_cut_off){
                closedEdgeY = -y;
                break;
            }
        }
    }
    int closedEdgeXabs = closedEdgeX < 0 ? -closedEdgeX : closedEdgeX;
    int closedEdgeYabs = closedEdgeY < 0 ? -closedEdgeY : closedEdgeY;
    if(closedEdgeX == 0){
        if(closedEdgeYabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeYabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    if(closedEdgeY == 0){
        if(closedEdgeXabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeXabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }

    float d = distance(float2(closedEdgeXabs, closedEdgeYabs), float2(corner_radius,corner_radius));
    if(d<corner_radius){
        if(corner_radius-d <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((corner_radius-d)/ (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    return float4(0.0,0.0,0.0,0.0);
}