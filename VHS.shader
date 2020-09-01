//based on https://www.shadertoy.com/view/Ms3XWH
uniform float range = 0.05;
uniform float noiseQuality = 250.0;
uniform float noiseIntensity = 0.88;
uniform float offsetIntensity = 0.02;
uniform float colorOffsetIntensity = 1.3;

float rand(float2 co)
{
    return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float uvY, float offset)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, uvY) * offset;
    x -= smoothstep(pos, edge1, uvY) * offset;
    return x;
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 uv = v_in.uv;
    for (float i = 0.0; i < 0.71; i += 0.1313)
    {
        float d = (elapsed_time * i) % 1.7;
        float o = sin(1.0 - tan(elapsed_time * 0.24 * i));
    	o *= offsetIntensity;
        uv.x += verticalBar(d, uv.y, o);
    }
    float uvY = uv.y;
    uvY *= noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);
    float noise = rand(float2(elapsed_time * 0.00001, uvY));
    uv.x += noise * noiseIntensity / 100.0;

    float2 offsetR = float2(0.006 * sin(elapsed_time), 0.0) * colorOffsetIntensity;
    float2 offsetG = float2(0.0073 * (cos(elapsed_time * 0.97)), 0.0) * colorOffsetIntensity;

    float r = image.Sample(textureSampler, uv + offsetR).r;
    float g = image.Sample(textureSampler, uv + offsetG).g;
    float b = image.Sample(textureSampler, uv).b;

    float4 output = float4(r, g, b, 1.0);
    return output;
}
