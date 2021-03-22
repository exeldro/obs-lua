float4 mainImage(VertData v_in) : TARGET
{
    float2 center_pos = float2(0.5,0.5);
    float d = distance(v_in.uv, center_pos);
    if(d>0.5)
        return float4(0.0,0.0,0.0,0.0);
    return image.Sample(textureSampler, v_in.uv);
}