#include <stdint.h>
#include "mandelbrot-core.h"

uint32_t bench_u32(uint32_t a, uint32_t b) {
  const uint32_t cr = (b & UINT32_C(1023)) - UINT32_C(512);
  const uint32_t ci = ((b >> 10) & UINT32_C(1023)) - UINT32_C(512);
  return p184_mit(a, cr, ci, 0, 0, 0, 0);
}
