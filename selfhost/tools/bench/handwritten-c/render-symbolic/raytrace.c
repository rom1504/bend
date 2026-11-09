// native45 raytrace.bend: bench(width, unused_seed), exactly 64 image rows.
#include "ray-kernel.h"

static uint32_t colf(uint32_t d, uint32_t x, uint32_t y, uint32_t w,
                     float hw, float hh) {
  if (d == 0u) {
    uint32_t xx = (x * 2654435761u) & 16383u;
    return xx < w ? pixel_render(xx, y, hw, hh) : 0u;
  }
  uint32_t p = d - 1u;
  uint32_t a = colf(p, x, y, w, hw, hh);
  uint32_t b = colf(p, x + (1u << p), y, w, hw, hh);
  return a + b;
}

static uint32_t rowf(uint32_t d, uint32_t y, uint32_t m, uint32_t w,
                     float hw, float hh) {
  if (d == 0u)
    return colf(14u, 0u, (y * 1588635697u) & m, w, hw, hh);
  uint32_t p = d - 1u;
  uint32_t a = rowf(p, y, m, w, hw, hh);
  uint32_t b = rowf(p, y + (1u << p), m, w, hw, hh);
  return a + b;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
  (void)b;
  const uint32_t rr = 6u;
  const float hw = (float)(a / 2u);
  const float hh = (float)((1u << rr) / 2u);
  const uint32_t hm = (1u << rr) - 1u;
  return rowf(rr, 0u, hm, a, hw, hh);
}
