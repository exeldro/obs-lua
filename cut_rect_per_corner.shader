uniform int corner_tl;
uniform int corner_tr;
uniform int corner_br;
uniform int corner_bl;
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
    int corner_top = corner_tl>corner_tr?corner_tl:corner_tr;
    int corner_right = corner_tr>corner_br?corner_tr:corner_br;
    int corner_bottom = corner_bl>corner_br?corner_bl:corner_br;
    int corner_left = corner_tl>corner_bl?corner_tl:corner_bl;
    
    if(image.Sample(textureSampler, v_in.uv + float2(corner_right*uv_pixel_interval.x,0)).a < alpha_cut_off){
        closedEdgeX = corner_right;
    }else if(image.Sample(textureSampler, v_in.uv + float2(-corner_left*uv_pixel_interval.x,0)).a < alpha_cut_off){
        closedEdgeX = -corner_left;
    }
    if(image.Sample(textureSampler, v_in.uv + float2(0,corner_bottom*uv_pixel_interval.y)).a < alpha_cut_off){
        closedEdgeY = corner_bottom;
    }else if(image.Sample(textureSampler, v_in.uv + float2(0,-corner_top*uv_pixel_interval.y)).a < alpha_cut_off){
        closedEdgeY = -corner_top;
    }
    if(closedEdgeX == 0 && closedEdgeY == 0){
        return pixel;
    }
    if(closedEdgeX != 0){
        [loop] for(int x = 1;x<corner_right;x++){
            if(image.Sample(textureSampler, v_in.uv + float2(x*uv_pixel_interval.x, 0)).a < alpha_cut_off){
                closedEdgeX = x;
                break;
            }
        }
        [loop] for(int x = 1;x<corner_left;x++){
            if(image.Sample(textureSampler, v_in.uv + float2(-x*uv_pixel_interval.x, 0)).a < alpha_cut_off){
                closedEdgeX = -x;
                break;
            }
        }
    }
    if(closedEdgeY != 0){
        [loop] for(int y = 1;y<corner_bottom;y++){
            if(image.Sample(textureSampler, v_in.uv + float2(0, y*uv_pixel_interval.y)).a < alpha_cut_off){
                closedEdgeY = y;
                break;
            }
        }
        [loop] for(int y = 1;y<corner_top;y++){
            if(image.Sample(textureSampler, v_in.uv + float2(0, -y*uv_pixel_interval.y)).a < alpha_cut_off){
                closedEdgeY = -y;
                break;
            }
        }
    }
    int closedEdgeXabs = closedEdgeX < 0 ? -closedEdgeX : closedEdgeX;
    int closedEdgeYabs = closedEdgeY < 0 ? -closedEdgeY : closedEdgeY;
    int corner_radius = 0;
    if(closedEdgeX < 0 && closedEdgeY < 0){
        corner_radius = corner_tl;
    }else if(closedEdgeX > 0 && closedEdgeY < 0){
        corner_radius = corner_tr;
    }else if(closedEdgeX > 0 && closedEdgeY > 0){
        corner_radius = corner_br;
    }else if(closedEdgeX < 0 && closedEdgeY > 0){
        corner_radius = corner_bl;
    }
    if(closedEdgeXabs > corner_radius && closedEdgeYabs > corner_radius){
        return pixel;
    }
    if(closedEdgeXabs == 0){
        if(closedEdgeYabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeYabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    if(closedEdgeYabs == 0){
        if(closedEdgeXabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeXabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    if(closedEdgeXabs > corner_radius){
        if(closedEdgeYabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeYabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    if(closedEdgeYabs > corner_radius){
        if(closedEdgeXabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeXabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    float d = closedEdgeXabs+closedEdgeYabs;
    if(d>corner_radius){
        if(d-corner_radius <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((d-corner_radius)/ (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    return float4(0.0,0.0,0.0,0.0);
}