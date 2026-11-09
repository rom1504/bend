// Both native45 variation-ray-active fixtures share coverage.active(count, first).
#include "ray-kernel.h"

uint32_t bench_u32(uint32_t a, uint32_t b) {
  uint32_t acc = 0u;
  uint32_t at = b;
  for (uint32_t remaining = a; remaining != 0u; --remaining) {
    uint32_t value = pixel_render(at % 80u, at / 80u, 40.0f, 32.0f);
    acc = acc * 16777619u + value;
    at += 1u;
  }
  return acc;
}
