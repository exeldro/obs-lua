uniform float left_side_width = 0.1;
uniform float left_side_size = 0.9;
uniform float left_side_shadow = 0.8;
uniform float left_flip_width = 0.05;
uniform float left_flip_shadow = 0.6;

uniform float right_side_width = 0.1;
uniform float right_side_size = 0.9;
uniform float right_side_shadow = 0.8;
uniform float right_flip_width = 0.05;
uniform float right_flip_shadow = 0.6;

float4 mainImage(VertData v_in) : TARGET
{
    float2 pos=v_in.uv;
    float shadow = 1.0;
    if(pos.x < left_side_width){
        pos.y -= 0.5;
        pos.y /= left_side_size;
        pos.y += 0.5;
        pos.x -= left_side_width + left_flip_width;
        pos.x /= left_side_size;
        pos.x += left_side_width + left_flip_width;
        shadow = left_side_shadow;
    }else if(pos.x < left_side_width + left_flip_width){
        float factor = 1.0 - ((left_side_width + left_flip_width)-pos.x)/left_flip_width*(1.0 - left_side_size);
        pos.y -= 0.5;
        pos.y /= factor;
        pos.y += 0.5;
        pos.x -= left_side_width + left_flip_width;
        pos.x /= factor;
        pos.x += left_side_width + left_flip_width;
        shadow = left_flip_shadow;
    }

    if(1.0 - pos.x < right_side_width){
        pos.y -= 0.5;
        pos.y /= right_side_size;
        pos.y += 0.5;
        pos.x -= 1.0 - (right_side_width + right_flip_width);
        pos.x /= right_side_size;
        pos.x += 1.0 - (right_side_width + right_flip_width);
        shadow = right_side_shadow;
    }else if(1.0 - pos.x < right_side_width + right_flip_width){
        float factor = 1.0 - ((right_side_width + right_flip_width) - (1.0 - pos.x))/right_flip_width*(1.0 - right_side_size);
        pos.y -= 0.5;
        pos.y /= factor;
        pos.y += 0.5;
        pos.x -= 1.0 - (right_side_width + right_flip_width);
        pos.x /= factor;
        pos.x += 1.0 -(right_side_width + right_flip_width);
        shadow = right_flip_shadow;
    }
    float4 p_color = image.Sample(textureSampler, pos);
    p_color.rgb *= shadow;
    return p_color;
}