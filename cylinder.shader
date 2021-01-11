uniform float cylinder_factor = 0.2;
uniform float background_cut = 0.1;

float4 mainImage(VertData v_in) : TARGET
{
    float2 uv = v_in.uv;
    uv.x -= 0.5;
    float bend = sqrt(1.0 - uv.x*uv.x*4);
    uv.y = uv.y/(1.0 - cylinder_factor)-bend*cylinder_factor;
    uv.y-=cylinder_factor/2;
    uv.x /= 2;
    uv.x += 0.5;
    float4 front_color = image.Sample(textureSampler, uv);
    front_color.rgb *= bend/2+0.5;
    if(front_color.a >= 1.0)
        return front_color;
    
    uv = v_in.uv;
    uv.x -= 0.5;
    if(abs(uv.x) < background_cut)
        return front_color;
    uv.y = uv.y/(1.0 - cylinder_factor)+bend*cylinder_factor;
    uv.y-=cylinder_factor/2;
    uv.x /= 2;
    if(uv.x > 0){
        uv.x = 1.0 - uv.x;
    }else{
        uv.x = 0 - uv.x;
    }

    float4 back_color = image.Sample(textureSampler, uv);
    back_color.rgb *=  0.5-bend/2;
    front_color.rgb *= front_color.a;
    front_color.rgb += back_color.rgb * (1.0 - front_color.a) * back_color.a;
    front_color.a = back_color.a * (1.0 - front_color.a) + front_color.a;
    return front_color;
}