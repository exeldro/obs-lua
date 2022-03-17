float4 mainImage(VertData v_in) : TARGET
{
	float4 base = image.Sample(textureSampler, v_in.uv);
	return float4(1.0-base.r, 1.0-base.g, 1.0-base.b, base.a);
}
