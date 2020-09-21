//based on https://www.shadertoy.com/view/MtXBDs
//inputs
uniform float AMT = 0.2; //0 - 1 glitch amount
uniform float SPEED = 0.6; //0 - 1 speed

//2D (returns 0 - 1)
float random2d(float2 n) { 
    return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
}

float randomRange (in float2 seed, in float min, in float max) {
		return min + random2d(seed) * (max - min);
}

// return 1 if v inside 1d range
float insideRange(float v, float bottom, float top) {
   return step(bottom, v) - step(top, v);
}


   
float4 mainImage(VertData v_in) : TARGET
{
    
    float time = floor(elapsed_time * SPEED * 60.0);    
	float2 uv = v_in.uv;
    
    //copy orig
    float4 outCol = image.Sample(textureSampler, uv);
    
    //randomly offset slices horizontally
    float maxOffset = AMT/2.0;
    for (float i = 0.0; i < 10.0 * AMT; i += 1.0) {
        float sliceY = random2d(float2(time , 2345.0 + float(i)));
        float sliceH = random2d(float2(time , 9035.0 + float(i))) * 0.25;
        float hOffset = randomRange(float2(time , 9625.0 + float(i)), -maxOffset, maxOffset);
        float2 uvOff = uv;
        uvOff.x += hOffset;
        if (insideRange(uv.y, sliceY, frac(sliceY+sliceH)) == 1.0 ){
        	outCol = image.Sample(textureSampler, uvOff);
        }
    }
    
    //do slight offset on one entire channel
    float maxColOffset = AMT/6.0;
    float rnd = random2d(float2(time , 9545.0));
    float2 colOffset = float2(randomRange(float2(time , 9545.0),-maxColOffset,maxColOffset), 
                       randomRange(float2(time , 7205.0),-maxColOffset,maxColOffset));
    if (rnd < 0.33){
        outCol.r = image.Sample(textureSampler, uv + colOffset).r;
        
    }else if (rnd < 0.66){
        outCol.g = image.Sample(textureSampler, uv + colOffset).g;
        
    } else{
        outCol.b = image.Sample(textureSampler, uv + colOffset).b;  
    }
       
	return outCol;
}