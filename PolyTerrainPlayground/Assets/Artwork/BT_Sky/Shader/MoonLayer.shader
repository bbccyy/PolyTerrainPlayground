Shader "BTSky/MoonLayer" {
	Properties {
		_MoonTex ("Moon Tex (Alpha)", 2D) = "white" {}
		//_MoonBumpTex ("Moon Bump", 2D) = "white" {}
	}

	SubShader{
		Tags{ "Queue" = "Transparent-2" "RenderType" = "Transparent" }

		Pass 
		{
			Blend One One		//混合：月相，月亮边缘
			ZWrite Off
			Cull Back

			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			#include "DynamicSkyCommon.hlsl"

			sampler2D _MoonTex;
			//sampler2D _MoonBumpTex;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				half4 tangentLightDir : TEXCOORD2;
			};

			v2f vert (a2v v) {
				v2f o;
				o.pos = SkyDomeObjectToClipPos(v.vertex);
				o.uv = v.texcoord;

				half2 rotatedLight = CustomRotator(half2(-1,0), half2(0,0), _ES_MoonLunarPhase + 0.25f);
				half2 rotatedLight2 = CustomRotator(half2(rotatedLight.x, 0), half2(0, 0), 0.1);//_ES_MoonLunarPhase
				half3 localLightDir = normalize(float3(rotatedLight2.x, rotatedLight2.y, rotatedLight.y));//定义平行光旋转，UE4中自定义旋转函数CustomRotator()

				half3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				half3x3 rotation = half3x3(v.tangent.xyz, binormal, v.normal);
				o.tangentLightDir.xyz = mul(rotation, localLightDir).xyz;

				//
				half3 localViewDir = normalize(TransformWorldToObject(GetCameraPositionWS()) - v.vertex);
				o.tangentLightDir.w = 1.0 - ExponentialDensity(saturate(dot(localViewDir, v.normal)), 3.0);//指数式衰减系数：中心到边缘

				return o;
			}
			

			//_ES_SkyCenterWorldPos,_ES_BottomFrontColor,_ES_BottomBackColor,_ES_SkyFrontAndBackBlendFactor
			//_ES_SunDirection,_ES_MoonColor,_ES_MoonBrightness
			half4 frag(v2f i):SV_TARGET
			{
				half3 tangentLightDir = normalize(i.tangentLightDir.xyz);

				//half3 tangentNormal = UnpackNormal(tex2D(_MoonBumpTex, i.uv));
				half3 tangentNormal = normalize(half3(0, 0, 1));
				half light = saturate(dot(tangentLightDir, tangentNormal));

				half moon = tex2D(_MoonTex, i.uv).a;
				half fade = i.tangentLightDir.w;

				half3 moonCol = moon * _ES_MoonColor.rgb * _ES_MoonBrightness * light * fade;

				//half4 output;
				half4 output = half4(moonCol, 1.0);
				
				return output;
			}

			ENDHLSL
		}
	}
}
