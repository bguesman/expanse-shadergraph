#ifndef EXPANSE_SHADERGRAPH_NOISE_INCLUDED
#define EXPANSE_SHADERGRAPH_NOISE_INCLUDED

#include "Utilities.hlsl"
#include "Random.hlsl"

/* Stores both the noise value and an optional associated coordinate. */
struct NoiseResult2D 
{
  float3 value;
  float2 coordinate;
};
struct NoiseResult3D 
{
  float3 value;
  float3 coordinate;
};

/* Specifies noise seed. There are more parameters in here than are necessary
 * to generate certain kinds of noise, but the overhead of passing it around
 * is not signficant enough to warrant the loss of abstraction we get from
 * not standardizing. */
class NoiseSeed 
{
  float3 seedX, seedY, seedZ;

  /* Many different constructors for different noise dimensions. */
  static NoiseSeed MakeNoiseSeed(float seed) 
  {
    NoiseSeed s;
    s.seedX.x = seed;
    return s;
  }

  static NoiseSeed MakeNoiseSeed(float2 seed) 
  {
    NoiseSeed s;
    s.seedX.xy = seed;
    return s;
  }

  static NoiseSeed MakeNoiseSeed(float3 seed) 
  {
    NoiseSeed s;
    s.seedX = seed;
    return s;
  }

  static NoiseSeed MakeNoiseSeed(float2 seedX, float2 seedY) 
  {
    NoiseSeed s;
    s.seedX.xy = seedX;
    s.seedY.xy = seedY;
    return s;
  }

  static NoiseSeed MakeNoiseSeed(float3 seedX, float3 seedY, float3 seedZ) 
  {
    NoiseSeed s;
    s.seedX = seedX;
    s.seedY = seedY;
    s.seedZ = seedZ;
    return s;
  }

  static const NoiseSeed kDefaultNoiseSeed() 
  {
    NoiseSeed s;
    s.seedX = float3(EXPANSE_DEFAULT_SEED_X_1, EXPANSE_DEFAULT_SEED_X_2, EXPANSE_DEFAULT_SEED_X_3);
    s.seedY = float3(EXPANSE_DEFAULT_SEED_Y_1, EXPANSE_DEFAULT_SEED_Y_2, EXPANSE_DEFAULT_SEED_Y_3);
    s.seedZ = float3(EXPANSE_DEFAULT_SEED_Z_1, EXPANSE_DEFAULT_SEED_Z_2, EXPANSE_DEFAULT_SEED_Z_3);
    return s;
  }
};

/* Base noise class and interface for noise generators. This strategy is a
 * little bit of a hack---there is no way in hlsl to declare a partially
 * abstract class that implements some functions and leaves some functions
 * virtual. The solution is to create an interface with all the functions,
 * then a base class that implements all the common functions. */
interface INoise 
{
  /**
   * @brief: generates 2D noise of this type according to seed.
   * */
  NoiseResult2D Generate2DSeeded(float2 uv, float2 cells, NoiseSeed seed);

  /**
   * @brief: generates 2D noise of this type according to default seed.
   * */
  NoiseResult2D Generate2D(float2 uv, float2 cells);

  /**
   * @brief: generates 3D noise of this type according to seed.
   * */
  NoiseResult3D Generate3DSeeded(float3 uv, float3 cells, NoiseSeed seed);

  /**
   * @brief: generates 3D noise of this type according to seed.
   * */
  NoiseResult3D Generate3D(float3 uv, float3 cells);

  /**
   * @brief: generates fbm-layered 2D noise of this type according to seed.
   * */
  NoiseResult2D Generate2DLayeredSeeded(float2 uv, float2 cells, float octaveScale,
    float octaveAmplitude, int octaves, NoiseSeed seed);

  /**
   * @brief: generates fbm-layered 2D noise of this type according to default
   * seed.
   * */
  NoiseResult2D Generate2DLayered(float2 uv, float2 cells, float octaveScale,
    float octaveAmplitude, int octaves);

  /**
   * @brief: generates fbm-layered 3D noise of this type according to seed.
   * */
  NoiseResult3D Generate3DLayeredSeeded(float3 uv, float3 cells, float octaveScale,
    float octaveAmplitude, int octaves, NoiseSeed seed);

  /**
   * @brief: generates fbm-layered 3D noise of this type according to default
   * seed.
   * */
  NoiseResult3D Generate3DLayered(float3 uv, float3 cells, float octaveScale,
    float octaveAmplitude, int octaves);
};

class BaseNoise : INoise 
{

  /* Dummy Implementation. */
  NoiseResult2D Generate2DSeeded(float2 uv, float2 cells, NoiseSeed seed) {
    NoiseResult2D result;
    result.value = 0;
    result.coordinate = float2(0, 0);
    return result;
  }

  NoiseResult2D Generate2D(float2 uv, float2 cells) {
    return Generate2DSeeded(uv, cells, NoiseSeed::kDefaultNoiseSeed());
  }

  /* Dummy Implementation. */
  NoiseResult3D Generate3DSeeded(float3 uv, float3 cells, NoiseSeed seed) {
    NoiseResult3D result;
    result.value = 0;
    result.coordinate = float3(0, 0, 0);
    return result;
  }

  NoiseResult3D Generate3D(float3 uv, float3 cells) {
    return Generate3DSeeded(uv, cells, NoiseSeed::kDefaultNoiseSeed());
  }

  NoiseResult2D Generate2DLayeredSeeded(float2 uv, float2 cells, float octaveScale,
    float octaveAmplitude, int octaves, NoiseSeed seed) {
    float maxValue = 0.0;
    float amplitude = 1.0;
    NoiseResult2D result;
    result.value = 0.0;
    result.coordinate = 0.0;
    for (int i = 0; i < octaves; i++) {
      NoiseResult2D octaveNoise = Generate2DSeeded(uv, cells, seed);
      result.value += octaveNoise.value * amplitude;
      result.coordinate += octaveNoise.coordinate * amplitude;
      maxValue += amplitude;
      amplitude *= octaveAmplitude;
      cells *= octaveScale;
    }
    result.value /= maxValue;
    result.coordinate /= maxValue;
    return result;
  }

  NoiseResult2D Generate2DLayered(float2 uv, float2 cells, float octaveScale,
    float octaveAmplitude, int octaves) {
    return Generate2DLayeredSeeded(uv, cells, octaveScale, octaveAmplitude,
      octaves, NoiseSeed::kDefaultNoiseSeed());
  }

  NoiseResult3D Generate3DLayeredSeeded(float3 uv, float3 cells, float octaveScale,
    float octaveAmplitude, int octaves, NoiseSeed seed) {
    float maxValue = 0.0;
    float amplitude = 1.0;
    NoiseResult3D result;
    result.value = 0.0;
    result.coordinate = 0.0;
    for (int i = 0; i < octaves; i++) {
      NoiseResult3D octaveNoise = Generate3DSeeded(uv, cells, seed);
      result.value += octaveNoise.value * amplitude;
      result.coordinate += octaveNoise.coordinate * amplitude;
      maxValue += amplitude;
      amplitude *= octaveAmplitude;
      cells *= octaveScale;
    }
    result.value /= maxValue;
    result.coordinate /= maxValue;
    return result;
  }

  NoiseResult3D Generate3DLayered(float3 uv, float3 cells, float octaveScale,
    float octaveAmplitude, int octaves) {
    return Generate3DLayeredSeeded(uv, cells, octaveScale, octaveAmplitude,
      octaves, NoiseSeed::kDefaultNoiseSeed());
  }
};


/* Generates classic value noise. */
class ValueNoise : BaseNoise {
  NoiseResult2D Generate2DSeeded(float2 uv, float2 cells, NoiseSeed seed) {
    /* Final result. */
    NoiseResult2D result;

    /* Point on our grid. */
    float2 p = uv * cells;

    /* Generate the top left point of the cell. */
    float2 tl = floor(uv * cells);

    /* Grid points. */
    float2 grid_00 = tl;
    float2 grid_01 = tl + float2(0, 1);
    float2 grid_10 = tl + float2(1, 0);
    float2 grid_11 = tl + float2(1, 1);

    /* Wraparound. */
    grid_00 -= cells * floor(grid_00 / cells);
    grid_01 -= cells * floor(grid_01 / cells);
    grid_10 -= cells * floor(grid_10 / cells);
    grid_11 -= cells * floor(grid_11 / cells);

    /* Noise values. */
    float noise_00 = Random::random_2_1_seeded(grid_00, seed.seedX.xy);
    float noise_01 = Random::random_2_1_seeded(grid_01, seed.seedX.xy);
    float noise_10 = Random::random_2_1_seeded(grid_10, seed.seedX.xy);
    float noise_11 = Random::random_2_1_seeded(grid_11, seed.seedX.xy);

    /* Lerp. */
    float2 a = frac(p);
    float noise_0 = lerp(noise_00, noise_01, smoothstep(0, 1, a.y));
    float noise_1 = lerp(noise_10, noise_11, smoothstep(0, 1, a.y));
    float noise = lerp(noise_0, noise_1, smoothstep(0, 1, a.x));

    result.value = noise;
    result.coordinate = p;
    return result;
  }

  NoiseResult3D Generate3DSeeded(float3 uv, float3 cells, NoiseSeed seed) {
    /* Final result. */
    NoiseResult3D result;

    /* Point on our grid. */
    float3 p = uv * cells;

    /* Generate the top left point of the cell. */
    float3 tl = floor(uv * cells);

    /* Grid points. */
    float3 grid_000 = tl;
    float3 grid_001 = tl + float3(0, 0, 1);
    float3 grid_010 = tl + float3(0, 1, 0);
    float3 grid_011 = tl + float3(0, 1, 1);
    float3 grid_100 = tl + float3(1, 0, 0);
    float3 grid_101 = tl + float3(1, 0, 1);
    float3 grid_110 = tl + float3(1, 1, 0);
    float3 grid_111 = tl + float3(1, 1, 1);

    /* Wraparound. */
    grid_000 -= cells * floor(grid_000 / cells);
    grid_001 -= cells * floor(grid_001 / cells);
    grid_010 -= cells * floor(grid_010 / cells);
    grid_011 -= cells * floor(grid_011 / cells);
    grid_100 -= cells * floor(grid_100 / cells);
    grid_101 -= cells * floor(grid_101 / cells);
    grid_110 -= cells * floor(grid_110 / cells);
    grid_111 -= cells * floor(grid_111 / cells);


    /* Noise values. */
    float noise_000 = Random::random_3_1_seeded(grid_000, seed.seedX);
    float noise_001 = Random::random_3_1_seeded(grid_001, seed.seedX);
    float noise_010 = Random::random_3_1_seeded(grid_010, seed.seedX);
    float noise_011 = Random::random_3_1_seeded(grid_011, seed.seedX);
    float noise_100 = Random::random_3_1_seeded(grid_100, seed.seedX);
    float noise_101 = Random::random_3_1_seeded(grid_101, seed.seedX);
    float noise_110 = Random::random_3_1_seeded(grid_110, seed.seedX);
    float noise_111 = Random::random_3_1_seeded(grid_111, seed.seedX);

    /* Lerp. */
    float3 a = frac(p);
    /* z. */
    float noise_00 = lerp(noise_000, noise_001, smoothstep(0, 1, a.z));
    float noise_01 = lerp(noise_010, noise_011, smoothstep(0, 1, a.z));
    float noise_10 = lerp(noise_100, noise_101, smoothstep(0, 1, a.z));
    float noise_11 = lerp(noise_110, noise_111, smoothstep(0, 1, a.z));
    /* y. */
    float noise_0 = lerp(noise_00, noise_01, smoothstep(0, 1, a.y));
    float noise_1 = lerp(noise_10, noise_11, smoothstep(0, 1, a.y));
    /* x. */
    float noise = lerp(noise_0, noise_1, smoothstep(0, 1, a.x));

    result.value = noise;
    result.coordinate = p;
    return result;
  }
};


/* Generates classic perlin noise. */
class PerlinNoise : BaseNoise {
  NoiseResult2D Generate2DSeeded(float2 uv, float2 cells, NoiseSeed seed) {
    /* Final result. */
    NoiseResult2D result;

    /* Point on our grid. */
    float2 p = uv * cells;

    /* Generate the top left point of the cell. */
    float2 tl = floor(p);

    /* Grid points. */
    float2 grid_00 = tl;
    float2 grid_01 = tl + float2(0, 1);
    float2 grid_10 = tl + float2(1, 0);
    float2 grid_11 = tl + float2(1, 1);

    /* Offset vectors---important to compute before wraparound. */
    float2 offset_00 = (grid_00 - p);
    float2 offset_01 = (grid_01 - p);
    float2 offset_10 = (grid_10 - p);
    float2 offset_11 = (grid_11 - p);

    /* Wraparound. */
    grid_00 -= cells * floor(grid_00 / cells);
    grid_01 -= cells * floor(grid_01 / cells);
    grid_10 -= cells * floor(grid_10 / cells);
    grid_11 -= cells * floor(grid_11 / cells);

    /* Gradient vectors. */
    float2 gradient_00 = normalize(Random::random_2_2_seeded(grid_00, seed.seedX.xy, seed.seedY.xy) * 2 - 1);
    float2 gradient_01 = normalize(Random::random_2_2_seeded(grid_01, seed.seedX.xy, seed.seedY.xy) * 2 - 1);
    float2 gradient_10 = normalize(Random::random_2_2_seeded(grid_10, seed.seedX.xy, seed.seedY.xy) * 2 - 1);
    float2 gradient_11 = normalize(Random::random_2_2_seeded(grid_11, seed.seedX.xy, seed.seedY.xy) * 2 - 1);

    /* Noise values. */
    float noise_00 = dot(gradient_00, offset_00);
    float noise_01 = dot(gradient_01, offset_01);
    float noise_10 = dot(gradient_10, offset_10);
    float noise_11 = dot(gradient_11, offset_11);

    /* Lerp. */
    float2 a = smoothstep(0, 1, saturate(frac(p)));
    /* y. */
    float noise_0 = lerp(noise_00, noise_01, a.y);
    float noise_1 = lerp(noise_10, noise_11, a.y);
    /* x. */
    float noise = lerp(noise_0, noise_1, a.x);

    result.value = (noise+1)/2;
    result.coordinate = p;
    return result;
  }

  NoiseResult3D Generate3DSeeded(float3 uv, float3 cells, NoiseSeed seed) {
    /* Final result. */
    NoiseResult3D result;

    /* Point on our grid. */
    float3 p = uv * cells;

    /* Generate the top left point of the cell. */
    float3 tl = max(0, min(cells, floor(uv * cells)));

    /* Grid points. */
    float3 grid_000 = tl;
    float3 grid_001 = tl + float3(0, 0, 1);
    float3 grid_010 = tl + float3(0, 1, 0);
    float3 grid_011 = tl + float3(0, 1, 1);
    float3 grid_100 = tl + float3(1, 0, 0);
    float3 grid_101 = tl + float3(1, 0, 1);
    float3 grid_110 = tl + float3(1, 1, 0);
    float3 grid_111 = tl + float3(1, 1, 1);

    /* Offset vectors---important to compute before wraparound. */
    float3 offset_000 = (grid_000 - p);
    float3 offset_001 = (grid_001 - p);
    float3 offset_010 = (grid_010 - p);
    float3 offset_011 = (grid_011 - p);
    float3 offset_100 = (grid_100 - p);
    float3 offset_101 = (grid_101 - p);
    float3 offset_110 = (grid_110 - p);
    float3 offset_111 = (grid_111 - p);

    /* Wraparound. */
    grid_000 -= cells * floor(grid_000 / cells);
    grid_001 -= cells * floor(grid_001 / cells);
    grid_010 -= cells * floor(grid_010 / cells);
    grid_011 -= cells * floor(grid_011 / cells);
    grid_100 -= cells * floor(grid_100 / cells);
    grid_101 -= cells * floor(grid_101 / cells);
    grid_110 -= cells * floor(grid_110 / cells);
    grid_111 -= cells * floor(grid_111 / cells);


    /* Gradient vectors. */
    float3 gradient_000 = normalize(Random::random_3_3_seeded(grid_000, seed.seedX, seed.seedY, seed.seedZ) * 2 - 1);
    float3 gradient_001 = normalize(Random::random_3_3_seeded(grid_001, seed.seedX, seed.seedY, seed.seedZ) * 2 - 1);
    float3 gradient_010 = normalize(Random::random_3_3_seeded(grid_010, seed.seedX, seed.seedY, seed.seedZ) * 2 - 1);
    float3 gradient_011 = normalize(Random::random_3_3_seeded(grid_011, seed.seedX, seed.seedY, seed.seedZ) * 2 - 1);
    float3 gradient_100 = normalize(Random::random_3_3_seeded(grid_100, seed.seedX, seed.seedY, seed.seedZ) * 2 - 1);
    float3 gradient_101 = normalize(Random::random_3_3_seeded(grid_101, seed.seedX, seed.seedY, seed.seedZ) * 2 - 1);
    float3 gradient_110 = normalize(Random::random_3_3_seeded(grid_110, seed.seedX, seed.seedY, seed.seedZ) * 2 - 1);
    float3 gradient_111 = normalize(Random::random_3_3_seeded(grid_111, seed.seedX, seed.seedY, seed.seedZ) * 2 - 1);

    /* Noise values. */
    float noise_000 = dot(gradient_000, offset_000);
    float noise_001 = dot(gradient_001, offset_001);
    float noise_010 = dot(gradient_010, offset_010);
    float noise_011 = dot(gradient_011, offset_011);
    float noise_100 = dot(gradient_100, offset_100);
    float noise_101 = dot(gradient_101, offset_101);
    float noise_110 = dot(gradient_110, offset_110);
    float noise_111 = dot(gradient_111, offset_111);

    /* Lerp. */
    float3 a = smoothstep(0, 1, saturate(frac(p)));
    /* z. */
    float noise_00 = lerp(noise_000, noise_001, a.z);
    float noise_01 = lerp(noise_010, noise_011, a.z);
    float noise_10 = lerp(noise_100, noise_101, a.z);
    float noise_11 = lerp(noise_110, noise_111, a.z);
    /* y. */
    float noise_0 = lerp(noise_00, noise_01, a.y);
    float noise_1 = lerp(noise_10, noise_11, a.y);
    /* x. */
    float noise = lerp(noise_0, noise_1, a.x);

    result.value = (noise+1)/2;
    result.coordinate = p;
    return result;
  }
};


/* Generates worley (cell) noise. */
class WorleyNoise : BaseNoise {
  NoiseResult2D Generate2DSeeded(float2 uv, float2 cells, NoiseSeed seed) {
    /* Final result. */
    NoiseResult2D result;

    /* Point on our grid. */
    float2 p = uv * cells;

    /* Generate the cell point. */
    float2 tl = floor(p);
    float2 o = tl + Random::random_2_2_seeded(tl, seed.seedX.xy, seed.seedY.xy);

    /* Compute distance from p to the cell point. */
    float minD = min(1, length(p - o));
    float2 minPoint = tl;

    /* Compute the distance to the points in the neighboring cells. */
    for (int x = -1; x < 2; x++) {
      for  (int y = -1; y < 2; y++) {
        if (!(x == 0 && y == 0)) {
          float2 offset = float2(x, y);
          float2 tl_neighbor = tl + offset;
          /* Wraparound to make tileable. */
          float2 tl_neighbor_wrapped = tl_neighbor - cells * floor(tl_neighbor / cells);
          float2 o_neighbor = tl_neighbor + Random::random_2_2_seeded(tl_neighbor_wrapped, seed.seedX.xy, seed.seedY.xy);
          float d_neighbor = length(p - o_neighbor);
          if (d_neighbor < minD) {
            minD = d_neighbor;
            minPoint = tl_neighbor;
          }
        }
      }
    }

    result.value = minD;
    result.coordinate = p;
    return result;
  }

  NoiseResult3D Generate3DSeeded(float3 uv, float3 cells, NoiseSeed seed) {
    /* Final result. */
    NoiseResult3D result;

    /* Point on our grid. */
    float3 p = uv * cells;

    /* Generate the cell point. */
    float3 tl = floor(uv * cells);
    float3 o = tl + Random::random_3_3_seeded(tl, seed.seedX, seed.seedY, seed.seedZ);

    /* Compute distance from p to the cell point. */
    float minD = min(1, length(p - o));
    float3 minPoint = tl;

    /* Compute the distance to the points in the neighboring cells. */
    for (int x = -1; x < 2; x++) {
      for  (int y = -1; y < 2; y++) {
        for  (int z = -1; z < 2; z++) {
          if (!(x == 0 && y == 0 && z == 0)) {
            float3 offset = float3(x, y, z);
            float3 tl_neighbor = tl + offset;
            /* Wraparound to make tileable. */
            float3 tl_neighbor_wrapped = tl_neighbor - cells * floor(tl_neighbor / cells);
            float3 o_neighbor = tl_neighbor + Random::random_3_3_seeded(tl_neighbor_wrapped, seed.seedX, seed.seedY, seed.seedZ);
            float d_neighbor = length(p - o_neighbor);
            if (d_neighbor < minD) {
              minD = d_neighbor;
              minPoint = tl_neighbor;
            }
          }
        }
      }
    }

    result.value = minD;
    result.coordinate = minPoint;
    return result;
  }
};

/* Generates inverse worley (cell) noise. */
class InverseWorleyNoise : BaseNoise {
  WorleyNoise m_worleyNoise;

  NoiseResult2D Generate2DSeeded(float2 uv, float2 cells, NoiseSeed seed) {
    NoiseResult2D result = m_worleyNoise.Generate2DSeeded(uv, cells, seed);
    result.value = 1-result.value;
    return result;
  }

  NoiseResult3D Generate3DSeeded(float3 uv, float3 cells, NoiseSeed seed) {
    NoiseResult3D result = m_worleyNoise.Generate3DSeeded(uv, cells, seed);
    result.value = 1-result.value;
    return result;
  }
};

/* Generates curl noise. Unfortunately taking advantage of the base
 * class requires what the compiler interprets as a "recursive call",
 * and so we have to re-implement the base class u */
class CurlNoise : INoise {
  PerlinNoise m_perlinNoise;
  static const float kOctaveScale = 2;
  static const float kOctaveAmplitude = 0.5;
  static const int kOctaves = 3;

  NoiseResult2D Generate2DSeeded(float2 uv, float2 cells, NoiseSeed seed) {
    /* Final result. */
    NoiseResult2D result;

    float epsilon = 0.5/cells.x;

    /* Compute offset uv coordinates, taking into account wraparound. */
    float2 uvx0 = float2(uv.x - epsilon - floor(uv.x - epsilon), uv.y);
    float2 uvxf = float2(uv.x + epsilon - floor(uv.x + epsilon), uv.y);
    float2 uvy0 = float2(uv.x, uv.y - epsilon - floor(uv.y - epsilon));
    float2 uvyf = float2(uv.x, uv.y + epsilon - floor(uv.y + epsilon));

    /* Compute noise values for finite differencing. */
    //
    float x0 = m_perlinNoise.Generate2DLayeredSeeded(uvx0, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;
    float xf = m_perlinNoise.Generate2DLayeredSeeded(uvxf, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;
    float yf = m_perlinNoise.Generate2DLayeredSeeded(uvyf, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;
    float y0 = m_perlinNoise.Generate2DLayeredSeeded(uvy0, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;

    /* Compute the derivatives via finite differencing. */
    float dx = (xf - x0) / (2 * epsilon);
    float dy = (yf - y0) / (2 * epsilon);

    /* Return the curl. */
    result.value = float3(-dy, dx, 0);
    result.coordinate = float2(uvx0.x, uvy0.y);
    return result;
  }

  NoiseResult2D Generate2D(float2 uv, float2 cells) {
    return Generate2DSeeded(uv, cells, NoiseSeed::kDefaultNoiseSeed());
  }

  NoiseResult3D Generate3DSeeded(float3 uv, float3 cells, NoiseSeed seed) {
    /* Final result. */
    NoiseResult3D result;

    float epsilon = 0.5/cells.x;

    /* Compute offset uv coordinates, taking into account wraparound. */
    float3 uvx0 = float3(uv.x - epsilon - floor(uv.x - epsilon), uv.y, uv.z);
    float3 uvxf = float3(uv.x + epsilon - floor(uv.x + epsilon), uv.y, uv.z);
    float3 uvy0 = float3(uv.x, uv.y - epsilon - floor(uv.y - epsilon), uv.z);
    float3 uvyf = float3(uv.x, uv.y + epsilon - floor(uv.y + epsilon), uv.z);
    float3 uvz0 = float3(uv.x, uv.y, uv.z - epsilon - floor(uv.z - epsilon));
    float3 uvzf = float3(uv.x, uv.y, uv.z + epsilon - floor(uv.z + epsilon));

    /* Compute noise values for finite differencing. */
    //
    float x0 = m_perlinNoise.Generate3DLayeredSeeded(uvx0, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;
    float xf = m_perlinNoise.Generate3DLayeredSeeded(uvxf, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;
    float y0 = m_perlinNoise.Generate3DLayeredSeeded(uvy0, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;
    float yf = m_perlinNoise.Generate3DLayeredSeeded(uvyf, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;
    float z0 = m_perlinNoise.Generate3DLayeredSeeded(uvz0, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;
    float zf = m_perlinNoise.Generate3DLayeredSeeded(uvzf, cells, kOctaveScale, kOctaveAmplitude, kOctaves, seed).value.x;

    /* Compute the derivatives via finite differencing. */
    float dx = (xf - x0) / (2 * epsilon);
    float dy = (yf - y0) / (2 * epsilon);
    float dz = (zf - z0) / (2 * epsilon);

    /* Return the curl. */
    result.value = float3(dz - dy, dx - dz, dy - dx);
    result.coordinate = float3(uvx0.x, uvy0.y, uvz0.z);
    return result;
  }

  NoiseResult3D Generate3D(float3 uv, float3 cells) {
    return Generate3DSeeded(uv, cells, NoiseSeed::kDefaultNoiseSeed());
  }

  NoiseResult2D Generate2DLayeredSeeded(float2 uv, float2 cells, float octaveScale,
    float octaveAmplitude, int octaves, NoiseSeed seed) {
    float maxValue = 0.0;
    float amplitude = 1.0;
    NoiseResult2D result;
    result.value = 0.0;
    result.coordinate = 0.0;
    for (int i = 0; i < octaves; i++) {
      NoiseResult2D octaveNoise = Generate2DSeeded(uv, cells, seed);
      result.value += octaveNoise.value * amplitude;
      result.coordinate += octaveNoise.coordinate * amplitude;
      maxValue += amplitude;
      amplitude *= octaveAmplitude;
      cells *= octaveScale;
    }
    result.value /= maxValue;
    result.coordinate /= maxValue;
    return result;
  }

  NoiseResult2D Generate2DLayered(float2 uv, float2 cells, float octaveScale,
    float octaveAmplitude, int octaves) {
    return Generate2DLayeredSeeded(uv, cells, octaveScale, octaveAmplitude,
      octaves, NoiseSeed::kDefaultNoiseSeed());
  }

  NoiseResult3D Generate3DLayeredSeeded(float3 uv, float3 cells, float octaveScale,
    float octaveAmplitude, int octaves, NoiseSeed seed) {
    float maxValue = 0.0;
    float amplitude = 1.0;
    NoiseResult3D result;
    result.value = 0.0;
    result.coordinate = 0.0;
    for (int i = 0; i < octaves; i++) {
      NoiseResult3D octaveNoise = Generate3DSeeded(uv, cells, seed);
      result.value += octaveNoise.value * amplitude;
      result.coordinate += octaveNoise.coordinate * amplitude;
      maxValue += amplitude;
      amplitude *= octaveAmplitude;
      cells *= octaveScale;
    }
    result.value /= maxValue;
    result.coordinate /= maxValue;
    return result;
  }

  NoiseResult3D Generate3DLayered(float3 uv, float3 cells, float octaveScale,
    float octaveAmplitude, int octaves) {
    return Generate3DLayeredSeeded(uv, cells, octaveScale, octaveAmplitude,
      octaves, NoiseSeed::kDefaultNoiseSeed());
  }
};

#endif  // EXPANSE_SHADERGRAPH_NOISE_INCLUDED
