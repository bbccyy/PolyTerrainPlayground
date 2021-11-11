Shader "BTSky/AtmosphereLayer" 
{
	Properties 
	{
		[NoScaleOffset] _SkyGradientTex ("Sky Gradient Tex", 2D) = "white" {}
		_StarsTex ("Stars (Alpha)", 2D) = "white" {}
		_StarsColorPalette ("Stars Color Palette", 2D) = "white" {}
		_NoiseTex ("Noise Tex (Alpha)", 2D) = "white" {}
	}

	SubShader 
	{
		Tags { "Queue" = "Transparent-3" "RenderType" = "Transparent"}

		Pass 
		{
			ZWrite Off

			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			#include "DynamicSkyCommon.hlsl"

			sampler2D _StarsTex;
			float4 _StarsTex_ST;
			sampler2D _StarsColorPalette;
			float4 _StarsColorPalette_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			struct a2v 
			{
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			struct v2f 
			{
				float4 pos		: SV_POSITION;
				float4 scrPos	: TEXCOORD0;
				float4 starsUV	: TEXCOORD1;
				float4 noiseUV	: TEXCOORD2;
				float4 viewDir	: TEXCOORD3;	
				float4 color	: TEXCOORD4; 
			};

			v2f vert(a2v v) 
			{
				v2f o = (v2f)0;

				o.pos = SkyDomeObjectToClipPos(v.vertex);
				o.scrPos = ComputeScreenPos(o.pos);
				o.viewDir = GetViewDirInWorld(v.vertex.xyz);

				o.starsUV.xy = v.texcoord0 * _StarsTex_ST.xy + _StarsTex_ST.zw;
				o.starsUV.zw = v.texcoord0 * 20.0;

				//随机闪烁频率
				float2 noiseUV = v.texcoord0 * _NoiseTex_ST.xy;
				o.noiseUV.xy = noiseUV + float2(_Time.y * _ES_StarsScintillation * 0.4, _Time.y * _ES_StarsScintillation * 0.2);
				o.noiseUV.zw = noiseUV * 2 + float2(_Time.y * _ES_StarsScintillation * 0.1, _Time.y * _ES_StarsScintillation * 0.5);

				//计算①大气垂直方向的渐变②地平线光晕
				o.color = RenderAtomosphere(o.viewDir.xyz, o.viewDir.w);

				return o;
			}

			half4 frag(v2f i) :Color
			{
				float2 scrPos = i.scrPos.xy / i.scrPos.w;
				float4 viewDir = float4(normalize(i.viewDir.xyz), i.viewDir.w);
				float viewFade = saturate(viewDir.w * 1.5);
				float3 col = i.color.rgb;

				//太阳光圈
				float3 sunHalo = SunHalo(viewDir.xyz);
				col += sunHalo;

				//月亮光圈
				float4 moonGlow = MoonGlow(viewDir.xyz);
				col += moonGlow.rgb;

				float stars = tex2D(_StarsTex, i.starsUV.xy).a;
				float scintillation = tex2D(_NoiseTex, i.noiseUV.xy).a * tex2D(_NoiseTex, i.noiseUV.zw).a * 3.0;

				float starsNoise = tex2D(_NoiseTex, i.starsUV.zw).a;
				float starsDensity = SetRange(starsNoise, 1.0 - _ES_StarsDensity, 1.0);
				float3 starsColor = tex2D(_StarsColorPalette, float2(starsNoise * _StarsColorPalette_ST.x + _StarsColorPalette_ST.z, 0.5));
				float starsAlpha = stars * scintillation * viewFade * starsDensity;

				//星星颜色
				col += starsColor * _ES_StarsBrightness * starsAlpha * step(moonGlow.a, 0.05);//月亮光圈附近没有星星

				return half4(col,1.0f);
			}

			ENDHLSL
		}
	}
}