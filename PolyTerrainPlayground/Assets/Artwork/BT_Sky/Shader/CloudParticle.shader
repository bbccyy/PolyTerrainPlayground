Shader "BTSky/CloudParticle"
{
	Properties
	{
		[Header(Cloud Maps)]
		[NoScaleOffset] _SkyGradientTex("Sky Gradient Tex", 2D) = "white" {}
		[NoScaleOffset] _CloudParticleAtlas("Cloud Particle Atlas", 2D) = "white" {}

		[Header(Cloud Curl)]
		[NoScaleOffset] _CloudCurlTex("Cloud Curl Tex", 2D) = "white" {}
		_CloudCurlTiling("Cloud Curl Tiling", Range(0.0, 30.0)) = 10.0
		_CloudCurlAmplitude("Cloud Curl Amplitude", Range(0.0, 0.02)) = 0.01
		_CloudCurlSpeed("Cloud Curl Speed", Range(0.0, 50.0)) = 20

		[Header(Debug)]
		[Toggle(FIXED_SPRITE_ID)] _UseFixedSpriteId("Fixed Sprite ID?", Float) = 0
		_FixedSpriteId("Sprite ID", Int) = 0
		[Toggle(FIXED_EDGE_SMOOTHNESS)] _UseFixedEdgeSmoothness("Fixed Edge Smoothness?", Float) = 0
		_FixedEdgeSmoothness("Fixed Edge Smoothness", Range(0.0, 1.0)) = 0.1
		[Toggle(FIXED_RIMLIGHT_WIDTH)] _UseFixedRimLightWidth("Fixed Rimlight Width?", Float) = 0
		_FixedRimLightWidth("Fixed Rimlight Width", Range(0.0, 1.0)) = 0.1
	}

	SubShader
	{
		Tags { "Queue" = "Transparent-1" "RenderType" = "Transparent" }

		Pass
		{
			Tags{"LightMode" = "UniversalForward"}

			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off

			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile __ FIXED_SPRITE_ID
			#pragma multi_compile __ FIXED_EDGE_SMOOTHNESS
			#pragma multi_compile __ FIXED_RIMLIGHT_WIDTH

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			#include "DynamicSkyCommon.hlsl"

			sampler2D _CloudParticleAtlas;
			
			//云贴图对应的横向和纵向个数(2,4)
			float2 _AtlasTiles;

			sampler2D _CloudCurlTex;
			float _CloudCurlTiling;
			float _CloudCurlAmplitude;
			float _CloudCurlSpeed;

			int _FixedSpriteId;
			half _FixedEdgeSmoothness;
			half _FixedRimLightWidth;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord0 : TEXCOORD0; // xy: uv0, zw: uv1  两套uv相同
				float4 texcoord1 : TEXCOORD1; // xy: 云的总时间和剩余时间, zw: 云生长和消亡所占的比例
				half4 color : COLOR;		  // y: id in [0, 1], z: 边缘平滑度, w: 边缘光宽度
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				half4 viewDir : TEXCOORD2;
				half4 middleware : TEXCOORD3;
				half3 backgroundColor : TEXCOORD4;
				half3 lightColor : TEXCOORD5;
				half3 rimLightColor : TEXCOORD6;
				half3 cloudLightColor : TEXCOORD7;
				half3 cloudDarkColor : TEXCOORD8;
			};

			v2f vert(a2v v)
			{
				v2f o = (v2f)0;

				o.pos = SkyDomeObjectToClipPos(v.vertex);
				o.scrPos = ComputeScreenPos(o.pos);

				//id：计算当前使用的基于粒子云纹理的云的索引(取整0~7，左下角是0) 
				int id = floor(v.color.y * (_AtlasTiles.x * _AtlasTiles.y - 1) + 0.5);
#if defined (FIXED_SPRITE_ID)
				id = _FixedSpriteId;
#endif
				//根据模型uv计算对应在粒子云纹理上的uv
				o.uv.xy = (v.texcoord0.xy + float2(id % _AtlasTiles.x, floor(id / _AtlasTiles.x))) / _AtlasTiles;
				//计算采样噪声图的uv
				o.uv.zw = v.texcoord0.xy * _CloudCurlTiling + _ES_CloudElapsedTime * float2(1.2, 0.8) * _CloudCurlSpeed;

				//w分量(重点),viewDir和天空球向上方向的垂直比例(水平为1，垂直为0)
				o.viewDir = GetViewDirInWorld(v.vertex.xyz);

				// Middleware
				//太阳和月亮对云的影响强度
				half sunLdV = dot(o.viewDir.xyz, _ES_SunDirection);
				half sunMask = SunMask(sunLdV);
				half moonLdV = dot(o.viewDir.xyz, _ES_MoonDirection);
				half moonMask = SunMask(moonLdV);
				//太阳对云整体的影响强度
				o.middleware.x = sunMask * _ES_CloudSunBrightenIntensity;				
				//云边缘的光滑度(使用顶点色的z值，也可以在材质属性中设置固定值)
				o.middleware.y = v.color.z;
#if defined (FIXED_EDGE_SMOOTHNESS)
				o.middleware.y = _FixedEdgeSmoothness;
#endif
				//云的边缘光范围(使用顶点色的w值，也可以在材质属性中设置固定值)
				o.middleware.z = v.color.w;
#if defined (FIXED_RIMLIGHT_WIDTH)
				o.middleware.z = _FixedRimLightWidth;
#endif
				//middleware.w 计算云的消隐的当前状态
				half agePercent = v.texcoord1.y / max(v.texcoord1.x, 0.00001);
				agePercent = agePercent * _ES_CloudAgePercent;
				o.middleware.w = 1.0 - smoothstep(0.0, v.texcoord1.b, agePercent) * (1.0 - smoothstep(v.texcoord1.a, 1.0, agePercent));

				// Background color  和天空球做一次混合
				o.backgroundColor = RenderAtomosphere(o.viewDir.xyz, o.viewDir.w) + SunHalo(o.viewDir.xyz);

				//计算云整体的梯度变化
				half coverage = _ES_CloudCoverage;
				half coverageFade = smoothstep(0.3, 0.7, 1.0 - coverage); //coverage[0.3,0.7]反向映射到coverageFade[0,1],

				//月亮和太阳附近云的梯度变化越明显
				o.lightColor = (MoonPhase(o.viewDir.xyz) + SunPhase(o.viewDir.xyz)) * coverageFade;

				//rimLightColor边缘高光，根据太阳和月亮的位置还有边缘光的范围共同影响边缘光位置，边缘光强度由太阳亮度或月亮亮度，
				//边缘光颜色由太阳光圈和月亮颜色的决定，整体的梯度变化coverage也会影响最后的边缘光颜色
				half rimLightGradientSunShine = smoothstep(_ES_SunRimLightRadius, 1.0, sunMask) * _ES_SunBrightness * 0.125;
				half rimLightGradientMoonShine = smoothstep(_ES_SunRimLightRadius, 1.0, moonMask) * _ES_MoonBrightness * 0.1;
				o.rimLightColor = (_ES_SunHaloColor * Pow2(rimLightGradientSunShine) + _ES_MoonColor * Pow2(rimLightGradientMoonShine)) * coverageFade;

				// Clouds colors 两次混合
				half frontAndBackFadeRatio = GetFrontAndBackFadeRatio(sunLdV, _ES_CloudFrontAndBackBlendFactor);
				o.cloudLightColor = lerp(_ES_CloudLightBackColor, _ES_CloudLightFrontColor, frontAndBackFadeRatio);
				o.cloudDarkColor = lerp(_ES_CloudDarkBackColor, _ES_CloudDarkFrontColor, frontAndBackFadeRatio);

				return o;
			}

			half4 frag(v2f i) :Color
			{
				float2 scrPos = i.scrPos.xy / i.scrPos.w;
				float3 curlNoise = tex2D(_CloudCurlTex, i.uv.zw).rgb;
				float2 curlOffset = (curlNoise.xy - 0.5) * curlNoise.z * _CloudCurlAmplitude;

				half4 texCol = tex2D(_CloudParticleAtlas, i.uv.xy + curlOffset);
				//half4 texCol = tex2D(_CloudParticleAtlas, i.uv.xy);

				half globalLightingGradient = i.middleware.x;
				half edgeSmoothness = i.middleware.y;
				half rimlightWidth = i.middleware.z;
				half fadeRatio = i.middleware.w;		//当前消亡状态
				//half fadeRatio = 0.9f;

				half4 cloudCol;

				// alpha
				half cloudAlphaDistMin = max(fadeRatio - edgeSmoothness, 0.0);
				half cloudAlphaDistMax = min(fadeRatio + edgeSmoothness, 1.0);
				//根据粒子云b通道计算透明度，做Alpha Test
				cloudCol.a = texCol.a * smoothstep(cloudAlphaDistMin, cloudAlphaDistMax, texCol.b) * smoothstep(-0.1, 0.1, i.viewDir.w);	
				clip(cloudCol.a - 0.01);

				//color：主体颜色+边缘光
				half3 blendLightAndDarkCloudColors = lerp(i.cloudDarkColor, i.cloudLightColor, texCol.r);		//插值混合
				half3 rimLightShineEdges = i.rimLightColor * lerp(texCol.g, (1.0 - smoothstep(cloudAlphaDistMin, min(fadeRatio + rimlightWidth, 1.0), texCol.b)) * 4.0, fadeRatio);

				cloudCol.rgb = blendLightAndDarkCloudColors + rimLightShineEdges/* + 0.4 * i.cloudLightColor * _ES_CloudCoverage*/;
				//cloudCol.rgb += i.lightColor * texCol.r;
				cloudCol.rgb *= (globalLightingGradient + 1.0);		//云整体的梯度系数

				half horizonFade = saturate(smoothstep(0.0, 0.1, i.viewDir.w));
				cloudCol.rgb = lerp(i.backgroundColor, cloudCol.rgb, lerp(horizonFade, 1.0, smoothstep(0.4, 0.7, _ES_CloudCoverage)));	//混合天空的颜色(不是混合操作)

				cloudCol.a = saturate(cloudCol.a);
				return cloudCol;

			}

			ENDHLSL
		}
	}
}
