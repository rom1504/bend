#include <stdint.h>
#include "mandelbrot-core.h"

/* coverage.grid samples cell centers across the whole original viewport.
   This is a separate entry algorithm from the histogram/recolor renderer. */
uint32_t bench_u32(uint32_t a, uint32_t b) {
  const uint64_t depth = a;
  const uint32_t side = p184_shl(1, depth);
  const uint32_t mask = side - UINT32_C(1);
  const uint32_t step = p184_div(4096, side);
  uint32_t remaining = side * side;
  uint32_t index = 0;
  uint32_t accumulated = 0;
  while (remaining != 0) {
    const uint32_t x = (index & mask) * step + step / UINT32_C(2);
    const uint32_t y = p184_shr(index, depth) * step + step / UINT32_C(2);
    const uint32_t at = y * UINT32_C(4096) + x;
    const uint32_t value = p184_pixel(at, b);
    accumulated += value * (at * UINT32_C(2654435761) + UINT32_C(1));
    ++index;
    --remaining;
  }
  return accumulated;
}
