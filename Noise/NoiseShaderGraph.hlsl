#ifndef EXPANSE_SHADERGRAPH_NOISE_SHADERGRAPH_INCLUDED
#define EXPANSE_SHADERGRAPH_NOISE_SHADERGRAPH_INCLUDED

#include "Noise.hlsl"

float amplitudeNormalization(int octaves, float octaveMultiplier)
{
    return (1 - pow(octaveMultiplier, octaves)) / (1 - octaveMultiplier);
}

// Value noise
void ValueNoise_float(
    in float3 uv,
    in float3 scale,
    in float octaves,
    in float octaveScale,
    in float octaveMultiplier,
    out float3 noise,
    out float3 coordinate)
{
    ValueNoise n;
    noise = 0;
    coordinate = 0;
    float amplitude = rcp(amplitudeNormalization(octaves, octaveMultiplier));
    for (int i = 0; i < octaves; i++)
    {
        NoiseResult3D result = n.Generate3D(uv, scale);
        noise += amplitude * result.value;
        coordinate += amplitude * result.coordinate;
        amplitude *= octaveMultiplier;
        scale *= octaveScale;
    }
}
void ValueNoise_half(
    in half3 uv,
    in half3 scale,
    in half octaves,
    in half octaveScale,
    in half octaveMultiplier,
    out half3 noise,
    out half3 coordinate)
{
    ValueNoise_float(
        uv, 
        scale,
        octaves, 
        octaveScale,
        octaveMultiplier,
        noise, 
        coordinate);
}

// Perlin noise
void PerlinNoise_float(
    in float3 uv,
    in float3 scale,
    in float octaves,
    in float octaveScale,
    in float octaveMultiplier,
    out float3 noise,
    out float3 coordinate)
{
    PerlinNoise n;
    noise = 0;
    coordinate = 0;
    float amplitude = rcp(amplitudeNormalization(octaves, octaveMultiplier));
    for (int i = 0; i < octaves; i++)
    {
        NoiseResult3D result = n.Generate3D(uv, scale);
        noise += amplitude * result.value;
        coordinate += amplitude * result.coordinate;
        amplitude *= octaveMultiplier;
        scale *= octaveScale;
    }
}
void PerlinNoise_half(
    in half3 uv,
    in half3 scale,
    in half octaves,
    in half octaveScale,
    in half octaveMultiplier,
    out half3 noise,
    out half3 coordinate)
{
    PerlinNoise_float(
        uv, 
        scale,
        octaves, 
        octaveScale,
        octaveMultiplier,
        noise,
        coordinate);
}

// Worley noise
void WorleyNoise_float(
    in float3 uv,
    in float3 scale,
    in float octaves,
    in float octaveScale,
    in float octaveMultiplier,
    out float3 noise,
    out float3 coordinate)
{
    WorleyNoise n;
    noise = 0;
    coordinate = 0;
    float amplitude = rcp(amplitudeNormalization(octaves, octaveMultiplier));
    for (int i = 0; i < octaves; i++)
    {
        NoiseResult3D result = n.Generate3D(uv, scale);
        noise += amplitude * result.value;
        coordinate += amplitude * result.coordinate;
        amplitude *= octaveMultiplier;
        scale *= octaveScale;
    }
}
void WorleyNoise_half(
    in half3 uv,
    in half3 scale,
    in half octaves,
    in half octaveScale,
    in half octaveMultiplier,
    out half3 noise,
    out half3 coordinate)
{
    WorleyNoise_float(
        uv,
        scale,
        octaves, 
        octaveScale,
        octaveMultiplier,
        noise,
        coordinate);
}

// Curl noise
void CurlNoise_float(
    in float3 uv,
    in float3 scale,
    in float octaves,
    in float octaveScale,
    in float octaveMultiplier,
    out float3 noise,
    out float3 coordinate)
{
    CurlNoise n;
    noise = 0;
    coordinate = 0;
    float amplitude = rcp(amplitudeNormalization(octaves, octaveMultiplier));
    for (int i = 0; i < octaves; i++)
    {
        NoiseResult3D result = n.Generate3D(uv, scale);
        noise += amplitude * result.value;
        coordinate += amplitude * result.coordinate;
        amplitude *= octaveMultiplier;
        scale *= octaveScale;
    }
}
void CurlNoise_half(
    in half3 uv,
    in half3 scale,
    in half octaves,
    in half octaveScale,
    in half octaveMultiplier,
    out half3 noise,
    out half3 coordinate)
{
    CurlNoise_float(
        uv,
        scale,
        octaves, 
        octaveScale,
        octaveMultiplier,
        noise,
        coordinate);
}

#endif  // EXPANSE_SHADERGRAPH_NOISE_SHADERGRAPH_INCLUDED
