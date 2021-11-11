Shader "BTSky/SunLayer" 
{
	Properties 
	{}

	SubShader
	{
		Tags{ "Queue" = "Transparent-2" "RenderType" = "Transparent" }

		Pass 
		{
			Blend One One
			ZWrite Off
			Cull Off

			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			#include "DynamicSkyCommon.hlsl"
		
			struct a2v 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				half4 viewDir : TEXCOORD1;
			};

			v2f vert(a2v v) 
			{
				v2f o;

				o.pos = SkyDomeObjectToClipPos(v.vertex);
				o.uv = v.texcoord * 2.0 - 1.0;
				o.viewDir = GetViewDirInWorld(v.vertex.xyz);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half viewFade = saturate(i.viewDir.w * 100.0);

				half dist = length(i.uv);

				//从中心到边缘根据长度计算衰减系数
				half sunDiskSharpness = smoothstep(0.0, 1.0 - _ES_SunSharpness, 1.0 - dist);
				half3 sunDisk = sunDiskSharpness * _ES_SunColor * _ES_SunBrightness/* * viewFade*/;

				return half4(sunDisk, 1.0);
			}

			ENDHLSL
		}
	}
}
