#ifndef NOISE_COMMON
#define NOISE_COMMON

//#include "UnityCG.cginc"
//#include "ShaderVariables.cginc"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShaderVariables.hlsl"

// Referenct: from https://www.shadertoy.com/view/4djSRW
// This set suits the coords of of 0~1 ranges
#define MOD3 float3(443.8975, 397.2973, 491.1871)
#define MOD4 float4(443.897, 441.423, 437.195, 444.129)

float2 _ES_DitherRandomSeed;

float hash11(float p) {
	float3 p3 = frac(p.xxx * MOD3);
	p3 += dot(p3, p3.yzx + 19.19);
	return frac((p3.x + p3.y) * p3.z);
}
float hash12(float2 p) {
	float3 p3 = frac(p.xyx * MOD3);
	p3 += dot(p3, p3.yzx + 19.19);
	return frac((p3.x + p3.y) * p3.z);
}
float3 hash32(float2 p) {
	float3 p3 = frac(p.xyx * MOD3);
	p3 += dot(p3, p3.yxz + 19.19);
	return frac(float3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

float4 hash42(float2 p) {
	float4 p4 = frac(p.xyxy * MOD4);
	p4 += dot(p4, p4.wzxy + 19.19);
	return frac((p4.xxyz + p4.yzzw) * p4.zywx);
}

// Reference: https://www.shadertoy.com/view/MslGR8
float3 DitherRGB(float2 pos, float3 color, float scale) {
	//float2 seed = pos + _ES_DitherRandomSeed;
	//float3 rand = hash32(seed) + hash32(seed + 0.59374) - 0.5; // Use separate rand for rgb
	//color = color + rand / 255.0 * scale;
	return color;
}

float4 DitherRGBA(float2 pos, float4 color, float scale) {
	//float2 seed = pos + _ES_DitherRandomSeed;
	//float4 rand = hash42(seed) + hash42(seed + 0.59374) - 0.5; // Use separate rand for rgba
	//color = color + rand / 255.0 * scale;
	return color;
}

#endif