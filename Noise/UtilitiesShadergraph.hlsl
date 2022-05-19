#ifndef EXPANSE_SHADERGRAPH_UTILITIES_SHADERGRAPH_INCLUDED
#define EXPANSE_SHADERGRAPH_UTILITIES_SHADERGRAPH_INCLUDED

// Cubemap face + UV => direction
void CubemapDirection_float(
    in float2 uv,
    in float face,
    out float3 direction)
{
    float3 uvw = float3(uv, face);
    // Use side to decompose primary dimension and negativity
    int side = uvw.z;
    int xMost = side < 2;
    int yMost = side >= 2 && side < 4;
    int zMost = side >= 4;
    int wasNegative = side & 1;

    // Insert a constant plane value for the dominant dimension in here
    uvw.z = 1;

    // Depending on the side we swizzle components back (NOTE: uvw.z is 1)
    float3 useComponents = float3(0, 0, 0);
    if (xMost) useComponents = uvw.zxy;
    if (yMost) useComponents = uvw.xzy;
    if (zMost) useComponents = uvw.xyz;

    // Transform components from [0,1] to [-1,1]
    useComponents = useComponents * 2 - float3(1, 1, 1);
    useComponents *= 1 - 2 * wasNegative;

    direction = normalize(useComponents);
}
void CubemapDirection_half(
    in half2 uv,
    in half face,
    out half3 direction)
{
    CubemapDirection_float(uv, face, direction);
}

#endif  // EXPANSE_SHADERGRAPH_UTILITIES_SHADERGRAPH_INCLUDED
