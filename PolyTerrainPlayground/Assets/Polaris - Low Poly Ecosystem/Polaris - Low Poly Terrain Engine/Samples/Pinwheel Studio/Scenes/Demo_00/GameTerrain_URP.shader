Shader "Custom/GameTerrain"
{
	Properties
	{
		_SplatMap("Splatmap (RGB)", 2D) = "black" {}
		_GroundColor("Color", Color) = (1,1,1,1)
		_TextureA("Texture A", 2D) = "white" {}
		_TextureB("Texture B", 2D) = "white" {}
		_TextureC("Texture C", 2D) = "white" {}
		_TextureD("Texture D", 2D) = "white" {}
		_TextureScale("TextureScale", Range(0.01,10)) = 0.25
		_PrioGround("Prio Ground", Range(0.01, 2.0)) = 1
		_PrioA("Prio A", Range(0.01, 2.0)) = 1
		_PrioB("Prio B", Range(0.01, 2.0)) = 1
		_PrioC("Prio C", Range(0.01, 2.0)) = 1
		_PrioD("Prio D", Range(0.01, 2.0)) = 1
		_Depth("Depth", Range(0.01,1.0)) = 0.2
	}

		SubShader
	{
		// Set Queue to AlphaTest+2 to render the terrain after all other solid geometry.
		// We do this because the terrain shader is expensive and this way we ensure most pixels
		// are already discarded before the fragment shader is executed:
		Tags{ "Queue" = "AlphaTest+2" }
		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
		// Make realtime shadows work
#pragma multi_compile_fwdbase
		// Skip unnessesary shader variants
#pragma skip_variants DIRLIGHTMAP_COMBINED LIGHTPROBE_SH POINT SPOT SHADOWS_DEPTH SHADOWS_CUBE VERTEXLIGHT_ON

#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "AutoLight.cginc"

		sampler2D _SplatMap;
		sampler2D _TextureA;
		sampler2D _TextureB;
		sampler2D _TextureC;
		sampler2D _TextureD;
		half _TextureScale;

		uniform half4 _GroundColor;

		half _PrioGround;
		half _PrioA;
		half _PrioB;
		half _PrioC;
		half _PrioD;

		half _Depth;

	struct a2v
	{
		float4 vertex : POSITION;
		half3 normal : NORMAL;
		half4 color : COLOR;
		float3 uv : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uvSplat : TEXCOORD0;
		float2 uvMaterial : TEXCOORD1;
		half4 materialPrios : TEXCOORD2;
		// put shadows data into TEXCOORD3
		SHADOW_COORDS(3)
		half4 color : COLOR0;
		half3 diff : COLOR1;
		half3 ambient : COLOR2;
	};

	v2f vert(a2v v)
	{
		v2f OUT;
		OUT.pos = UnityObjectToClipPos(v.vertex);
		OUT.uvSplat = v.uv.xy;
		// uvs of the rendered materials are based on world position
		OUT.uvMaterial = mul(unity_ObjectToWorld, v.vertex).xz * _TextureScale;
		OUT.materialPrios = half4(_PrioA, _PrioB, _PrioC, _PrioD);
		OUT.color = v.color;

		// calculate light
		half3 worldNormal = UnityObjectToWorldNormal(v.normal);
		half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
		OUT.diff = nl * _LightColor0.rgb;
		OUT.ambient = ShadeSH9(half4(worldNormal,1));

		// Transfer shadow coordinates:
		TRANSFER_SHADOW(OUT);

		return OUT;
	}

	fixed4 frag(v2f IN) : SV_Target
	{
		half4 groundColor = _GroundColor;
		half4 materialAColor = tex2D(_TextureA, IN.uvMaterial);
		half4 materialBColor = tex2D(_TextureB, IN.uvMaterial);
		half4 materialCColor = tex2D(_TextureC, IN.uvMaterial);
		half4 materialDColor = tex2D(_TextureD, IN.uvMaterial);

	// store heights for all materials on this pixel
	half groundHeight = groundColor.a;
	half4 materialHeights = fixed4(materialAColor.a, materialBColor.a, materialCColor.a, materialDColor.a);
	// avoid black artefacts by division by zero
	materialHeights = max(0.0001, materialHeights);

	// get material amounts from splatmap
	half4 materialAmounts = tex2D(_SplatMap, IN.uvSplat).argb;
	// the ground amount takes up all unused space
	half groundAmount = 1.0 - min(1.0, materialAmounts.r + materialAmounts.g + materialAmounts.b + materialAmounts.a);

	// calculate material strenghts
	half alphaGround = groundAmount * _PrioGround * groundHeight;
	half4 alphaMaterials = materialAmounts * IN.materialPrios * materialHeights;

	// find strongest point of all materials
	half max_01234 = max(alphaGround, alphaMaterials.r);
	max_01234 = max(max_01234, alphaMaterials.g);
	max_01234 = max(max_01234, alphaMaterials.b);
	max_01234 = max(max_01234, alphaMaterials.a);

	//lower threshold
	max_01234 = max(max_01234 - _Depth, 0);

	// mask all materials above threshold
	half b0 = max(alphaGround - max_01234, 0);
	half b1 = max(alphaMaterials.r - max_01234, 0);
	half b2 = max(alphaMaterials.g - max_01234, 0);
	half b3 = max(alphaMaterials.b - max_01234, 0);
	half b4 = max(alphaMaterials.a - max_01234, 0);

	// combine all materials and normalize
	half alphaSum = b0 + b1 + b2 + b3 + b4;
	half4 col2 = (
		groundColor * b0 +
		materialAColor * b1 +
		materialBColor * b2 +
		materialCColor * b3 +
		materialDColor * b4
		) / alphaSum;

	//include vertex colors
	half4 col = col2;
	//col *= IN.color;

	// compute shadow attenuation (1.0 = fully lit, 0.0 = fully shadowed)
	half shadow = SHADOW_ATTENUATION(IN);
	// darken light's illumination with shadow, keep ambient intact
	half3 lighting = IN.diff * shadow + IN.ambient;

	col.rgb *= IN.diff * SHADOW_ATTENUATION(IN) + IN.ambient;

	return col;
	}
		ENDCG
	}

		// shadow casting support
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}