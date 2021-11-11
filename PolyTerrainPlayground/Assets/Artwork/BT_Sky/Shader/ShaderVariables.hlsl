#ifndef DYNAMICSKY_SHADER_VARIABLES
#define DYNAMICSKY_SHADER_VARIABLES

half3 _ES_MainLightColor;

float3 _ES_SkyCenterWorldPos;
half3 _ES_SkyWorldUpDir;

half3 _ES_LightDirection;
half3 _ES_LightColor;
half _ES_LightIntensity;

half4 _ES_TopFrontColor;
half4 _ES_TopBackColor;
half4 _ES_BottomFrontColor;
half4 _ES_BottomBackColor;
half _ES_SkyFrontAndBackBlendFactor;
half4 _ES_SkyGradientBlendFactor;
half _ES_BottomColorHeight;
half3 _ES_HorizonHaloColor;
half _ES_HorizonHaloIntensity;
half4 _ES_HorizonHaloBlendFactor;
half _ES_HorizonHaloHeight;

half3 _ES_SunDirection;	// World space
half3 _ES_SunColor;
half _ES_SunBrightness;
half _ES_SunSharpness;
half _ES_SunSize;
half _ES_SunRimLightRadius;

half _ES_SunHaloSize;
half3 _ES_SunHaloColor;
half _ES_SunHaloIntensity;

half3 _ES_MoonDirection;
half _ES_MoonSize;
half3 _ES_MoonColor;
half _ES_MoonBrightness;
half _ES_MoonGlowIntensity;
half _ES_MoonLunarPhase;

float _ES_CloudElapsedTime;
float2 _ES_CloudDirection;	// x: sin(angle), y: cos(angle)
half3 _ES_CloudLightFrontColor;
half3 _ES_CloudLightBackColor;
half3 _ES_CloudDarkFrontColor;
half3 _ES_CloudDarkBackColor;
half _ES_CloudFrontAndBackBlendFactor;
half _ES_CloudHeight;
float _ES_CloudTiling;
half _ES_CloudCoverage;
float _ES_CloudAgePercent;
half _ES_CloudOpacity;
half2 _ES_CloudSmoothness;
half _ES_CloudSunBrightenIntensity;
half _ES_CloudLightingIntensity;

float _ES_CloudWispsElapsedTime;
half _ES_CloudWispsCoverage;
half _ES_CloudWispsOpacity;

float _ES_StarsScintillation;
half _ES_StarsBrightness;
half _ES_StarsDensity;

float _ES_AuroraElapsedTime;
half _ES_AuroraBlurAmount;
half _ES_AuroraBrightness;

float _ES_GalaxyFadeValue;
half3 _ES_GalaxyLightColor;
half3 _ES_GalaxyBGColor;
half3 _ES_GalaxyDarkColor;

sampler2D _ES_WeatherMap;

#endif