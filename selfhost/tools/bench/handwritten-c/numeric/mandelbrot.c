/* Catalog mandelbrot.bend: two full pixel passes and pairwise reductions.
   Structural reference: bench/runtime/mandelbrot/main.c. */
#include <stdint.h>
#include "mandelbrot-core.h"

typedef struct {
  uint32_t h0, h1, h2, h3, h4, h5, h6, h7;
} Histogram;

typedef struct {
  uint32_t k0, k1, k2, k3, k4, k5, k6, k7;
} Lut;

static Histogram hchunk(uint32_t first, uint64_t iterations) {
  Histogram h = {0, 0, 0, 0, 0, 0, 0, 0};
  uint32_t remaining = 64;
  while (remaining != 0) {
    --remaining;
    const uint32_t bucket = p184_bucket(p184_pixel(first + remaining, iterations), iterations);
    h.h0 += (uint32_t)(bucket == 0);
    h.h1 += (uint32_t)(bucket == 1);
    h.h2 += (uint32_t)(bucket == 2);
    h.h3 += (uint32_t)(bucket == 3);
    h.h4 += (uint32_t)(bucket == 4);
    h.h5 += (uint32_t)(bucket == 5);
    h.h6 += (uint32_t)(bucket == 6);
    h.h7 += (uint32_t)(bucket == 7);
  }
  return h;
}

static Histogram hzip(Histogram a, Histogram b) {
  return (Histogram){a.h0 + b.h0, a.h1 + b.h1, a.h2 + b.h2, a.h3 + b.h3,
                     a.h4 + b.h4, a.h5 + b.h5, a.h6 + b.h6, a.h7 + b.h7};
}

static Histogram hfold(uint64_t depth, uint32_t first, uint64_t iterations) {
  if (depth == 0) return hchunk(first, iterations);
  const uint64_t previous = depth - 1;
  const Histogram left = hfold(previous, first, iterations);
  const Histogram right = hfold(previous, first + p184_shl(64, previous), iterations);
  return hzip(left, right);
}

static Lut cdf(Histogram h) {
  const uint32_t c0 = h.h0;
  const uint32_t c1 = c0 + h.h1;
  const uint32_t c2 = c1 + h.h2;
  const uint32_t c3 = c2 + h.h3;
  const uint32_t c4 = c3 + h.h4;
  const uint32_t c5 = c4 + h.h5;
  const uint32_t c6 = c5 + h.h6;
  const uint32_t c7 = c6 + h.h7;
  return (Lut){p184_div(c0 * UINT32_C(255), c7), p184_div(c1 * UINT32_C(255), c7),
               p184_div(c2 * UINT32_C(255), c7), p184_div(c3 * UINT32_C(255), c7),
               p184_div(c4 * UINT32_C(255), c7), p184_div(c5 * UINT32_C(255), c7),
               p184_div(c6 * UINT32_C(255), c7), p184_div(c7 * UINT32_C(255), c7)};
}

static uint32_t recolor_pixel(uint32_t id, uint64_t limit, Lut lut) {
  const uint32_t iteration = p184_pixel(id, limit);
  const uint32_t bucket = p184_bucket(iteration, limit);
  const uint32_t color = (uint32_t)(bucket == 0) * lut.k0
                       + (uint32_t)(bucket == 1) * lut.k1
                       + (uint32_t)(bucket == 2) * lut.k2
                       + (uint32_t)(bucket == 3) * lut.k3
                       + (uint32_t)(bucket == 4) * lut.k4
                       + (uint32_t)(bucket == 5) * lut.k5
                       + (uint32_t)(bucket == 6) * lut.k6
                       + (uint32_t)(bucket == 7) * lut.k7;
  return color * (id * UINT32_C(2654435761) + UINT32_C(1)) + iteration;
}

static uint32_t rcol(uint64_t depth, uint32_t first, uint64_t iterations, Lut lut) {
  if (depth == 0) return recolor_pixel(first, iterations, lut);
  const uint64_t previous = depth - 1;
  const uint32_t left = rcol(previous, first, iterations, lut);
  const uint32_t right = rcol(previous, first + p184_shl(1, previous), iterations, lut);
  return left + right;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
  /* The fixture's bench ignores seed and always uses seven iterations. */
  (void)b;
  const uint64_t depth = a;
  const uint64_t iterations = 7;
  const Lut lut = cdf(hfold(depth, 0, iterations));
  uint32_t mix = lut.k0 * UINT32_C(2654435761) + lut.k1;
  mix = mix * UINT32_C(2654435761) + lut.k2;
  mix = mix * UINT32_C(2654435761) + lut.k3;
  mix = mix * UINT32_C(2654435761) + lut.k4;
  mix = mix * UINT32_C(2654435761) + lut.k5;
  mix = mix * UINT32_C(2654435761) + lut.k6;
  mix = mix * UINT32_C(2654435761) + lut.k7;
  const uint32_t recolored = rcol(depth + UINT64_C(6), 0, iterations, lut);
  return mix * UINT32_C(2654435761) + recolored;
}
