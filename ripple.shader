uniform float distance_factor = 12.0;
uniform float time_factor = 2.0;
uniform float power_factor = 3.0;
uniform float center_pos_x = 0.0;
uniform float center_pos_y = 0.0;

float4 mainImage(VertData v_in) : TARGET
{
    float2 cPos = (v_in.uv * 2 ) -1;
    float2 center_pos = float2(center_pos_x, center_pos_y);
    float cLength = distance(cPos, center_pos);
	float2 uv = v_in.uv+(cPos/cLength)*cos(cLength*distance_factor-elapsed_time*time_factor) * power_factor / 100.0;
    return image.Sample(textureSampler, uv);
}