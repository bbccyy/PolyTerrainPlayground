#ifndef DYNAMIC_SKY_COMMON
#define DYNAMIC_SKY_COMMON

//#include "UnityCG.cginc"
#include "ShaderVariables.hlsl"
#include "MaterialFunctionsCommon.hlsl"

sampler2D _SkyGradientTex;

struct OutPutMrt
{
	float4 col			: SV_Target0;
	float4 history		: SV_Target1;
};

inline float4 SkyDomeObjectToClipPos(float4 pos) 
{
	float4 clipPos = TransformObjectToHClip(pos.xyz);
#if defined(UNITY_REVERSED_Z)
	clipPos.z = 0.0;
#else
	clipPos.z = clipPos.w;
#endif
	return clipPos;
}

inline half4 GetViewDirInWorld(float3 localPos) 
{
	float3 worldPos = mul(unity_ObjectToWorld, float4(localPos, 1.0)).xyz;
	half3 viewDir = normalize(worldPos - _ES_SkyCenterWorldPos);
	half up = dot(_ES_SkyWorldUpDir.xyz, viewDir.xyz);

	//up的含义是viewDir在_ES_SkyWorldUpDir上投影的高度，asin(up)是viewDir与水平方向的夹角，
	//PI_HALF_INV的含义是1/（PI/2),asin(up) * PI_HALF_INV表示垂直方向的比例
	return half4(viewDir, asin(up) * PI_HALF_INV);		//取arcsin而不取arccos是取导(方向越接近水平值越大)
	//return half4(viewDir, pow(sin(up),20));
}

// Cancel out glow when less of moon is lit
inline float MoonLunarCancel() 
{
	return 1.0 - abs(_ES_MoonLunarPhase - 0.5) * 2.0;
}

inline half SunMask(half ldv) 
{
	return ldv * 0.5 + 0.5;
}

inline half3 SunPhase(float3 viewDir) 
{
	half ldv = saturate(dot(_ES_SunDirection, viewDir) * 0.5 + 0.5);

    half vertical = dot(viewDir, _ES_SkyWorldUpDir);
	half horizon = abs(vertical);
	half haloInfluence = saturate(pow(ldv, _ES_SunHaloSize * 0.5 * horizon) * vertical);

	half3 sunHalo = haloInfluence * _ES_SunHaloIntensity * _ES_SunColor;

	return sunHalo;
}

inline half3 MoonPhase(float3 viewDir) 
{
	half ldv = saturate(dot(_ES_MoonDirection, viewDir));

	half moonIntensity = clamp(_ES_MoonBrightness, 0.0, 0.8);
	half moonLunarCancel = MoonLunarCancel();
	half3 moonGradientColor = smoothstep(0.5, 1.0, Pow5(ldv)) * _ES_MoonGlowIntensity * moonLunarCancel * _ES_MoonColor * moonIntensity;

	return moonGradientColor;
}

inline half MoonMask(half ldv) 
{
	float moonIntensity = clamp(_ES_MoonBrightness, 0.0, 0.5);
	float moonLunarCancel = MoonLunarCancel();

	return moonLunarCancel * moonIntensity * smoothstep(0.9, 1.0, ldv);
}

inline half GetFrontAndBackFadeRatio(half ldv, half ratio) 
{
	//这里的意思是ldv和ratio按一定比例混合
	half frontAndBackFadeRatio = max(ldv * ratio + (1.0 - ratio), 0.0);
	frontAndBackFadeRatio = Pow3(frontAndBackFadeRatio);

	return frontAndBackFadeRatio;
}

//计算太阳的光圈
inline float3 SunHalo(float3 viewDir) 
{
	float ldv = saturate(dot(_ES_SunDirection, viewDir) * 0.5 + 0.5);

	half vertical = dot(viewDir, _ES_SkyWorldUpDir);
	half horizon = abs(vertical);
	float haloInfluence = saturate(pow(ldv, _ES_SunHaloSize * horizon));
	haloInfluence += saturate(pow(ldv, _ES_SunHaloSize * 0.1 * horizon)) * 0.12;
	haloInfluence += saturate(pow(ldv, _ES_SunHaloSize * 0.01 * horizon)) * 0.03;

	float sunFade = max(dot(_ES_SunDirection, viewDir) * 0.5 + 0.5, 0.0);
	float3 sunHalo = haloInfluence * _ES_SunHaloIntensity * _ES_SunHaloColor * smoothstep(0.5, 1.0, sunFade);

	return sunHalo;
}

//计算月亮光圈颜色
inline float4 MoonGlow(float3 viewDir) 
{
	float ldv = saturate(dot(_ES_MoonDirection, viewDir));

	float moonIntensity = saturate(_ES_MoonBrightness);
	float moonLunarCancel = MoonLunarCancel();
	float moonGradient = SphereMask(ldv, 1.0, _ES_MoonSize * 0.1);
	moonGradient = Pow6(moonGradient);
	moonGradient *= _ES_MoonGlowIntensity * moonLunarCancel;
	float3 moonGradientColor = moonGradient * _ES_MoonColor * moonIntensity;

	return float4(moonGradientColor, moonGradient);
}

inline half3 SkyGradient(half height, half frontAndBackFadeRatio) 
{
	half blendFactor = tex2Dlod(_SkyGradientTex, half4(abs(height) / max(_ES_BottomColorHeight, 0.0001), 0.5, 0.0, 0.0)).r;

	// Front and back gradient
	half3 topColor = lerp(_ES_TopBackColor, _ES_TopFrontColor, frontAndBackFadeRatio).rgb;
	half3 bottomColor = lerp(_ES_BottomBackColor, _ES_BottomFrontColor, frontAndBackFadeRatio).rgb;

	half3 skyGradient = lerp(topColor, bottomColor, blendFactor);

	return skyGradient;
}

inline half3 HorizonHalo(half height, half frontAndBackFadeRatio) 
{
	half blendFactor = tex2Dlod(_SkyGradientTex, half4(abs(height) / max(_ES_HorizonHaloHeight, 0.0001), 0.5, 0.0, 0.0)).g;

	half3 horizonHalo = _ES_HorizonHaloColor * _ES_HorizonHaloIntensity * blendFactor;

	return horizonHalo;
}

inline half Intensity(half3 color) 
{
	return dot(color, half3(0.2127, 0.7152, 0.0721));
}

inline half4 RenderAtomosphere(half3 viewDir, half verticalBlend) 
{
	half ldv = dot(_ES_SunDirection, viewDir.xyz);
	half sunFade = max(ldv * 0.5 + 0.5, 0.0);
	//这里计算的是视线方向与阳光方向夹角决定的向光颜色与背光颜色的混合系数
	half frontAndBackFadeRatio = GetFrontAndBackFadeRatio(ldv, _ES_SkyFrontAndBackBlendFactor);

	half3 atomosphere = 0;

	//根据梯度计算大气颜色
	half3 skyGradient = SkyGradient(verticalBlend, frontAndBackFadeRatio);
	atomosphere += skyGradient;	// Additive blend

	//水平光圈颜色
	half3 horizonHalo = HorizonHalo(verticalBlend, frontAndBackFadeRatio);
	atomosphere += horizonHalo * lerp(smoothstep(0.3, 1.0, sunFade), 1.0, smoothstep(0.2, 0.5, abs(_ES_SunDirection.y))) /* * (1.0 - Intensity(atomosphere))*/;	// Additive blend

	return half4(atomosphere, frontAndBackFadeRatio);
}

#endif