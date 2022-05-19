#ifndef EXPANSE_SHADERGRAPH_UTILITIES_INCLUDED
#define EXPANSE_SHADERGRAPH_UTILITIES_INCLUDED

// Disable warnings for releases. In general these should be fixed
// properly, but they are annoying for users.
#pragma warning(disable: 3206) // implicit truncation of vector type
#pragma warning(disable: 3556) // integer divides may be much slower
#pragma warning(disable: 3571) // power not known to be positive
#pragma warning(disable: 4000) // use of potentially uninitialized variable

/**
 * @brief: static utility class for (frankly) utility functions that don't
 * have another logical place.
 * */
class Utilities {

  #define FLT_EPSILON 0.000001

  static float clampAboveZero(float a) {
    return max(1e-9, a);
  }
  static float2 clampAboveZero(float2 a) {
    return max(1e-9, a);
  }
  static float3 clampAboveZero(float3 a) {
    return max(1e-9, a);
  }
  static float clampNonZero(float a) {
    return (a == 0) ? 1e-9 : a;
  }

  static float clampCosine(float c) {
    return clamp(c, -1.0, 1.0);
  }

  /* True if a is greater than b within tolerance FLT_EPSILON, false
   * otherwise. */
  static bool floatGT(float a, float b) {
    return a > b - FLT_EPSILON;
  }
  static bool floatGT(float a, float b, float eps) {
    return a > b - eps;
  }

  /* True if a is less than b within tolerance FLT_EPSILON, false
   * otherwise. */
  static bool floatLT(float a, float b) {
    return a < b + FLT_EPSILON;
  }
  static bool floatLT(float a, float b, float eps) {
    return a < b + eps;
  }

  static float safeSqrt(float x) {
    return sqrt(max(0, x));
  }

  static float average(float3 x) {
    return dot(x, 1.0/3.0);
  }

  /* Returns minimum non-negative number. If both numbers are negative,
   * returns a negative number. */
  static float minNonNegative(float a, float b) {
    return (min(a, b) < 0.0) ? max(a, b) : min(a, b);
  }

  /* Returns whether x is within [bounds.x, bounds.y]. */
  static bool boundsCheck(float x, float2 bounds) {
    return floatGT(x, bounds.x) && floatLT(x, bounds.y);
  }
  static bool boundsCheckEpsilon(float x, float2 bounds, float eps) {
    return (x >= bounds.x - eps) && (x <= bounds.y + eps);
  }
  static bool boundsCheckNoEpsilon(float x, float2 bounds) {
    return (x >= bounds.x) && (x <= bounds.y);
  }

  // Computes whether uv is inside range [0, 1] with specified tolerance
  static bool insideFramebuffer(float2 uv, float2 tolerance) {
    return all(uv >= tolerance) && all(uv <= 1 - tolerance);
  }

  // Computes whether uv is inside range [0, 1]
  static bool insideFramebuffer(float2 uv) {
    return all(uv >= 0) && all(uv <= 1);
  }

  static float erf(float x) {
    float sign_x = sign(x);
    x = abs(x);
    const float p = 0.3275911;
    const float a1 = 0.254829592;
    const float a2 = -0.284496736;
    const float a3 = 1.421413741;
    const float a4 = -1.453152027;
    const float a5 = 1.061405429;
    float t = 1 / (1 + p * x);
    float t2 = t * t;
    float t3 = t * t2;
    float t4 = t2 * t2;
    float t5 = t3 * t2;
    float prefactor = a5 * t5 + a4 * t4 + a3 * t3 + a2 * t2 + a1 * t;
    return sign_x * (1 - prefactor * exp(-(x * x)));
  }

  /**
   * @brief: converts a temperature to its corresponding color on the 
   * blackbody spectrum.
   * 
   * Based on data by Mitchell Charity http://www.vendian.org/mncharity/dir3/blackbody/,
   * to match Unity's solution.
   * */
  static float3 blackbodyTempToColor(float t) {
    float3 result = 1;

    // Red
    result.x = 56100000.0f * pow(t, (-3.0f / 2.0f)) + 148.0f;

    // Green
    result.y = 100.04f * log(t) - 623.6f;
    if (t > 6500.0f)
        result.y = 35200000.0f * pow(t, (-3.0f / 2.0f)) + 184.0f;

    // Blue
    result.z = 194.18f * log(t) - 1448.6f;

    // Normalize and fade out when temperature is low
    return (clamp(result, 0, 255) / 255.0f) * saturate(t / 1000.0f);
  }

};

#endif // EXPANSE_SHADERGRAPH_UTILITIES_INCLUDED
