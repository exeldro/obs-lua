//based on https://www.shadertoy.com/view/WsdyRN

//Higher values = less distortion
uniform float distortion = 75.;
//Higher values = tighter distortion
uniform float amplitude = 10.;
//Higher values = more color distortion
uniform float chroma = .5;

float2 zoomUv(float2 uv, float zoom) {
    float2 uv1 = uv;
    uv1 += .5;
    uv1 += zoom/2.-1.;
    uv1 /= zoom;
    return uv1;
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 uvt = v_in.uv;
    
    float2 uvtR = uvt;
    float2 uvtG = uvt;
    float2 uvtB = uvt;
    
    //Uncomment the following line to get varying chroma distortion
    //chroma = sin(elapsed_time)/2.+.5;
    
    uvtR += float2(sin(uvt.y*amplitude+elapsed_time)/distortion, cos(uvt.x*amplitude+elapsed_time)/distortion);
    uvtG += float2(sin(uvt.y*amplitude+elapsed_time+chroma)/distortion, cos(uvt.x*amplitude+elapsed_time+chroma)/distortion);
    uvtB += float2(sin(uvt.y*amplitude+elapsed_time+(chroma*2.))/distortion, cos(uvt.x*amplitude+elapsed_time+(chroma*2.))/distortion);
    
    float2 uvR = zoomUv(uvtR, 1.1);
    float2 uvG = zoomUv(uvtG, 1.1);
    float2 uvB = zoomUv(uvtB, 1.1);
    
    float colR = image.Sample(textureSampler, uvR).r;
    float colG = image.Sample(textureSampler, uvG).g;
    float colB = image.Sample(textureSampler, uvB).b;

    return float4(colR, colG, colB, 1.0);
}