uniform float inner_radius = 32.0;
uniform float outer_radius = 50.0;
uniform float start_angle = 90.0;

uniform int total = 100;
uniform int part_1 = 50;
uniform float4 color_1;
uniform int part_2 = 25;
uniform float4 color_2;
uniform int part_3 = 10;
uniform float4 color_3;
uniform int part_4 = 5;
uniform float4 color_4;
uniform int part_5 = 3;
uniform float4 color_5;
uniform int part_6 = 2;
uniform float4 color_6;
uniform int part_7 = 1;
uniform float4 color_7;
uniform int part_8 = 1;
uniform float4 color_8;
uniform int part_9 = 1;
uniform float4 color_9;
uniform int part_10 = 0;
uniform float4 color_10;

float4 mainImage(VertData v_in) : TARGET
{
    const float pi = 3.14159265358979323846;
    float parts[] = {part_1, part_2, part_3, part_4, part_5, part_6, part_7, part_8, part_9, part_10};
    float4 colors[] = {color_1, color_2, color_3, color_4, color_5, color_6, color_7, color_8, color_9, color_10};
    float2 center = float2(0.5, 0.5);
    float2 factor;
    if(uv_size.x < uv_size.y){
        factor = float2(1.0, uv_size.y/uv_size.x);
    }else{
        factor = float2(uv_size.x/uv_size.y, 1.0);
    }
    center = center * factor;
    float d = distance(center, v_in.uv * factor);
    if(d > outer_radius/100.0 || d < inner_radius/100.0){
        return image.Sample(textureSampler, v_in.uv);
    }
    float2 toCenter = center - v_in.uv*factor;
    float angle = atan2(toCenter.y ,toCenter.x);
    angle = angle - (start_angle / 180.0 * pi);
    if(angle < 0.0) 
        angle = pi + pi + angle;
    if(angle < 0.0) 
        angle = pi + pi + angle;
    angle = angle / (pi + pi);
    float t = 0.0;
    for(int i = 0; i < 10; i+=1) {
        float part = parts[i]/total;
        if(angle > t && angle <= t+part){
            return colors[i];
        }
        t = t + part;
    }
    return image.Sample(textureSampler, v_in.uv);
}