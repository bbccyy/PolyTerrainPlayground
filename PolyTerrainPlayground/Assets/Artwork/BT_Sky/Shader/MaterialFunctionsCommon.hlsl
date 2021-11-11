#ifndef MATERIAL_FUNCTIONS_COMMON
#define MATERIAL_FUNCTIONS_COMMON

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#ifndef PI
#define PI	3.1415626
#endif
#define PI_TWO 6.2831853
#define PI_HALF 1.5707963
#define PI_INV 0.3183099
#define PI_TWO_INV 0.1591549
#define PI_HALF_INV 0.6366198

inline half Pow2(half x) {
	return x * x;
}

inline half3 Pow2(half3 x) {
	return x * x;
}

inline half Pow3(half x) {
	return x * x * x;
}

inline half3 Pow3(half3 x) {
	return x * x * x;
}

//inline half Pow4(half x) {
//	return x * x * x * x;
//}

inline half3 Pow4(half3 x) {
	return x * x * x * x;
}

inline half Pow5(half x) {
	return x * x * x * x * x;
}

inline half3 Pow5(half3 x) {
	return x * x * x * x * x;
}

inline half Pow6(half x) {
	return x * x * x * x * x * x;
}

inline half3 Pow6(half3 x) {
	return x * x * x * x * x * x;
}

inline float2 MirrorUV(float2 uv) {
	float2 t = frac(uv * 0.5) * 2.0;
	float2 l = float2(1.0, 1.0);

	return l - abs(t - l);
}

inline half SetRange(half value, half low, half high) {
	return saturate((value - low) / (high - low));
}

inline half FastPow(half x, half power) {
	half result = saturate(power * x + (1 - power));
	return result * result;
}

inline half ExponentialDensity(half depth, half density) {
	if (depth > 0.0) {
		half d = depth * density;
		return 1.0 / exp(d * d);
		return 1.0 - exp(-abs(depth * density));
	}
	else {
		return 1.0;
	}
}

/// centerPosition: default is (0.5, 0.5), radius: default is 0.5, density: default is 2.333
inline half RadialGradientExponential(half2 uv, half2 centerPosition, half radius, half density) {
	half2 offset = uv - centerPosition;
	half dist = sqrt(dot(offset, offset));

	return 1.0 - ExponentialDensity(1 - dist / radius, density);
}

inline half3 SubUV(sampler2D tex, float2 uv, float2 subImages, float frame) {
	float2 invSubImages = 1.0 / subImages;

	float fracOfFrame = frac(frame);
	float intOfFrame = frame - fracOfFrame;

	float2 uv1 = invSubImages * (float2(fmod(intOfFrame, subImages.x), floor(intOfFrame * invSubImages.x)) + uv);
	float2 uv2 = invSubImages * (float2(fmod((intOfFrame + 1.0), subImages.x), floor((intOfFrame + 1.0) * invSubImages.x)) + uv);

	half3 col1 = tex2D(tex, uv1).rgb;
	half3 col2 = tex2D(tex, uv2).rgb;

	return lerp(col1, col2, fracOfFrame);
}

inline half ScaleRadialGradientAroundWhite(half newScale, half value) {
	return saturate(saturate(value + newScale - 1.0) / max(newScale, 0.00001));
}

inline half SphereMask(half a, half b, half radius) {
	half distance = length(a - b);
	half invRadius = 1.0 / max(radius, 0.00001);
	half normalizeDistance = distance * invRadius;
	half negNormalizedDistance = 1.0 - normalizeDistance;
	return saturate(negNormalizedDistance);
}

inline float2 Rotator(float2 uv, float angle) {
	float cosVal = cos(angle);
	float sinVal = sin(angle);
	float2 rowX = float2(cosVal, -sinVal);
	float2 rowY = float2(sinVal, cosVal);

	float arg1 = dot(rowX, uv);
	float arg2 = dot(rowY, uv);

	return float2(arg1, arg2);
}

/// The Rotator expression outputs UV texture coordinates in the form of a two-channel vector value that can be used to create rotating textures.
/// uv: Takes in base UV texture coordinates the expression can then modify.
/// center: Specifies the coordinates to use as the center of the rotation.
/// speed: Specifies the speed to rotate the coordinates clockwise.
/// time: Takes in a value used to determine the current rotation position.
inline float2 Rotator(float2 uv, float2 center, float speed, float time) {
	float2 offset = uv - center;

	float cosVal = cos(time * speed);
	float sinVal = sin(time * speed);
	float2 rowX = float2(cosVal, -sinVal);
	float2 rowY = float2(sinVal, cosVal);
	
	float arg1 = dot(rowX, offset);
	float arg2 = dot(rowY, offset);

	return float2(arg1, arg2) + center;
}

/// Rotator with rotation center exposed and a rotation angle on 0-1 scale. A rotation angle value of 1 is equal to one full rotation.
/// uv: Takes in base UV texture coordinates the expression can then modify.
/// center: Specifies the coordinates to use as the center of the rotation.
/// angle: 0-1 values for rotation. A value of 1 is equal to a 360 degree turn.
inline float2 CustomRotator(float2 uv, float2 center, float angle) {
	angle *= PI_TWO;	// Convert to radian

	float2 offset = uv - center;

	float sinVal = sin(angle);
	float cosVal = cos(angle);
	float2 rowX = float2(cosVal, -sinVal);
	float2 rowY = float2(sinVal, cosVal);

	float arg1 = dot(rowX, offset);
	float arg2 = dot(rowY, offset);

	return float2(arg1, arg2) + center;
}

inline float3 RotateAboutAxis(float3 normalizedRotationAxis, float rotationAngle, float3 pivotPoint, float3 position) {
	position -= pivotPoint;

	float3 parallelVector = dot(position, normalizedRotationAxis) * normalizedRotationAxis;
	float3 perpendicularVector = position - parallelVector;
	float3 w = cross(normalizedRotationAxis, perpendicularVector);
	float3 rotatedPerpendicularVector = cos(rotationAngle) * perpendicularVector + sin(rotationAngle) * w;
	position = rotatedPerpendicularVector + parallelVector;

	position += pivotPoint;

	return position;
}

/// Rotating the sun vector to align with the UV space
inline float3 RotateVector(float3 vectorToRotate, float3 lookAtVector, float3 restingVector) {
	lookAtVector = normalize(lookAtVector);
	float angle = acos(dot(restingVector, lookAtVector)) * 57.29 / 360.0 * PI_TWO;

	return RotateAboutAxis(cross(restingVector, lookAtVector), angle, 0, vectorToRotate) + vectorToRotate;
}

inline float2 Panner(float2 uv, float time, float2 speed) {
	return uv + speed * time;
}

/// The DepthFade expression is used to hide unsightly seams that take place when translucent objects intersect with opaque ones.
/// opacity: Takes in the existing opacity for the object prior to the depth fade
/// fadeDistance: World space distance over which the fade should take place.
inline float DepthFade(float sceneDepth, float pixelDepth, float opacity, float fadeDistance) {
	// Scales Opacity by a Linear fade based on SceneDepth, from 0 at PixelDepth to 1 at FadeDistance
	// Result = Opacity * saturate((SceneDepth - PixelDepth) / max(FadeDistance, DELTA))
	float fade = saturate((sceneDepth - pixelDepth) / fadeDistance);
	return opacity * fade;
}

inline float2 ScaleUVsByCenter(float2 uv, float2 scale) {
	return (uv - 0.5) / scale + 0.5;
}

inline float2 RotateUVsByCenter(float2 uv, float2 angles) {
	float2 offset = uv - 0.5;

	float2 rowX = float2(angles.y, -angles.x);
	float2 rowY = float2(angles.x, angles.y);

	float arg1 = dot(rowX, offset);
	float arg2 = dot(rowY, offset);

	return float2(arg1, arg2) + 0.5;
}

#endif
