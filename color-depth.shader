//based on https://www.shadertoy.com/view/tscfWM
uniform float colorDepth = 5.0;

float4 mainImage(VertData v_in) : TARGET
{
    // Change these to change results
    float2 size = float2(256, 256);
    float2 uv = v_in.uv;
    // Maps UV onto grid of variable size to pixilate the image
    uv = round(uv*size)/size;
    float4 col = image.Sample(textureSampler, uv);
    // Maps color onto the specified color depth
    return float4(round(col.r * colorDepth) / colorDepth, 
                    round(col.g * colorDepth) / colorDepth,
                    round(col.b * colorDepth) / colorDepth, 1.0);
}