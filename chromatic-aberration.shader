//based on https://www.shadertoy.com/view/XssGz8
uniform float power = 0.01;
uniform float gamma = 2.2;
uniform int num_iter = 7;
uniform bool distort_radial = false;
uniform bool distort_barrel = false;
uniform bool offset_spectrum_ycgco = false;
uniform bool offset_spectrum_yuv = false;
uniform bool use_random = true;

float remap( float t, float a, float b ) {
	return clamp( (t - a) / (b - a), 0.0, 1.0 );
}

float2 remap( float2 t, float2 a, float2 b ) {
	return clamp( (t - a) / (b - a), 0.0, 1.0 );
}

float3 spectrum_offset_rgb( float t )
{
    float t0 = 3.0 * t - 1.5;
	float3 ret = clamp( float3( -t0, 1.0-abs(t0), t0), 0.0, 1.0);
    return ret;
}


float3 lin2srgb( float3 c )
{
    return pow( c, float3(gamma, gamma, gamma) );
}
float3 srgb2lin( float3 c )
{
    return pow( c, float3(1.0/gamma, 1.0/gamma, 1.0/gamma));
}

float3 yCgCo2rgb(float3 ycc)
{
    float R = ycc.x - ycc.y + ycc.z;
	float G = ycc.x + ycc.y;
	float B = ycc.x - ycc.y - ycc.z;
    return float3(R,G,B);
}

float3 spectrum_offset_ycgco( float t )
{
	//float3 ygo = float3( 1.0, 1.5*t, 0.0 ); //green-pink
    //float3 ygo = float3( 1.0, -1.5*t, 0.0 ); //green-purple
    float3 ygo = float3( 1.0, 0.0, -1.25*t ); //cyan-orange
    //float3 ygo = float3( 1.0, 0.0, 1.5*t ); //brownyello-blue
    return yCgCo2rgb( ygo );
}

float3 yuv2rgb( float3 yuv )
{
    float3 rgb;
    rgb.r = yuv.x + yuv.z * 1.13983;
    rgb.g = yuv.x + dot( float2(-0.39465, -0.58060), yuv.yz );
    rgb.b = yuv.x + yuv.y * 2.03211;
    return rgb;
}

float2 radialdistort(float2 coord, float2 amt)
{
	float2 cc = coord - 0.5;
	return coord + 2.0 * cc * amt;
}

float2 barrelDistortion( float2 p, float2 amt )
{
    p = 2.0 * p - 1.0;

    /*
    const float maxBarrelPower = 5.0;
	//note: http://glsl.heroku.com/e#3290.7 , copied from Little Grasshopper
    float theta  = atan(p.y, p.x);
    float2 radius = float2( length(p) );
    radius = pow(radius, 1.0 + maxBarrelPower * amt);
    p.x = radius.x * cos(theta);
    p.y = radius.y * sin(theta);

	/*/
    // much faster version
    //const float maxBarrelPower = 5.0;
    //float radius = length(p);
    float maxBarrelPower = sqrt(5.0);
    float radius = dot(p,p); //faster but doesn't match above accurately
    p *= pow(float2(radius, radius), maxBarrelPower * amt);
	/* */

    return p * 0.5 + 0.5;
}

float2 brownConradyDistortion(float2 uv, float dist)
{
    uv = uv * 2.0 - 1.0;
    // positive values of K1 give barrel distortion, negative give pincushion
    float barrelDistortion1 = 0.1 * dist; // K1 in text books
    float barrelDistortion2 = -0.025 * dist; // K2 in text books

    float r2 = dot(uv,uv);
    uv *= 1.0 + barrelDistortion1 * r2 + barrelDistortion2 * r2 * r2;
    //uv *= 1.0 + barrelDistortion1 * r2;
    
    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here
    return uv * 0.5 + 0.5;
}

float2 distort( float2 uv, float t, float2 min_distort, float2 max_distort )
{
    float2 dist = float2(min_distort.x * (1.0-t) +max_distort.x * t, min_distort.y * (1.0-t) +max_distort.y * t);
    //float2 dist = mix( min_distort, max_distort, t );
    if (distort_radial)
        return radialdistort( uv, 2.0 * dist );
       
    if(distort_barrel)
        return barrelDistortion( uv, 1.75 * dist ); //distortion at center
    return brownConradyDistortion( uv, 75.0 * dist.x );
}

// ====

float3 spectrum_offset_yuv( float t )
{
	//float3 yuv = float3( 1.0, 3.0*t, 0.0 ); //purple-green
    //float3 yuv = float3( 1.0, 0.0, 2.0*t ); //purple-green
    float3 yuv = float3( 1.0, 0.0, -1.0*t ); //cyan-orange
    //float3 yuv = float3( 1.0, -0.75*t, 0.0 ); //brownyello-blue
    return yuv2rgb( yuv );
}

float3 spectrum_offset( float t )
{
    if(offset_spectrum_ycgco)
        return spectrum_offset_ycgco( t );
    if(offset_spectrum_yuv)
        return spectrum_offset_yuv( t );
  	return spectrum_offset_rgb( t );
   	//return srgb2lin( spectrum_offset_rgb( t ) );
    //return lin2srgb( spectrum_offset_rgb( t ) );
}

float4 mainImage(VertData v_in) : TARGET
{
	float2 max_distort = float2(power, power);
    float2 min_distort = 0.5 * max_distort;

    float2 oversiz = distort(float2(1.0, 1.0), 1.0, min_distort, max_distort);

    float2 uv = remap( v_in.uv, 1.0-oversiz, oversiz );
    
    //debug oversiz
    //float2 distuv = distort( uv, 1.0, max_distort );
    //if ( abs(distuv.x-0.5)>0.5 || abs(distuv.y-0.5)>0.5)
    //{
    //    fragColor = float4( 1.0, 0.0, 0.0, 1.0 ); return;
    //}
   
    
    const float stepsiz = 1.0 / (float(num_iter)-1.0);
    float rnd = 0.0;
    if(use_random)
        rnd = rand_f;
    
    float t = rnd * stepsiz;

    float3 sumcol = float3(0.0, 0.0, 0.0);
	float3 sumw = float3(0.0, 0.0, 0.0);
    
	for ( int i=0; i<num_iter; ++i )
	{
		float3 w = spectrum_offset( t );
		sumw += w;
        float2 uvd = distort(v_in.uv, t, min_distort, max_distort ); //TODO: move out of loop
		sumcol += w * srgb2lin(image.Sample(textureSampler, uvd).rgb );
        t += stepsiz;
	}
    
    sumcol.rgb /= sumw;
    
    float3 outcol = sumcol.rgb;
    outcol = lin2srgb( outcol );
    outcol += rnd/255.0;
    
	return float4( outcol, 1.0); 
    return image.Sample(textureSampler, v_in.uv);
}