#ifndef P184_MANDELBROT_CORE_H
#define P184_MANDELBROT_CORE_H

#include <stdint.h>

/* Bend's U32 shifts return zero for counts >= 32, never a masked count. */
static inline uint32_t p184_shl(uint32_t value, uint64_t count) {
  return count < 32 ? (uint32_t)(value << count) : UINT32_C(0);
}

static inline uint32_t p184_shr(uint32_t value, uint64_t count) {
  return count < 32 ? value >> count : UINT32_C(0);
}

static inline uint32_t p184_div(uint32_t a, uint32_t b) {
  return b == 0 ? UINT32_C(0) : a / b;
}

/* Unsigned sign extension implements the source's two's-complement asr8.
   It does not rely on implementation-defined signed right shift/conversion. */
static inline uint32_t p184_asr8(uint32_t value) {
  return (value >> 8) | ((UINT32_C(0) - (value >> 31)) & UINT32_C(0xff000000));
}

/* All n rounds execute. After escape, coordinates freeze; there is no break. */
static inline uint32_t p184_mit(uint64_t n, uint32_t cr, uint32_t ci,
                                uint32_t zr, uint32_t zi,
                                uint32_t escaped, uint32_t iterations) {
  while (n != 0) {
    const uint32_t r2 = p184_asr8(zr * zr);
    const uint32_t i2 = p184_asr8(zi * zi);
    const uint32_t magnitude = r2 + i2;
    const uint32_t next_escaped = escaped | (uint32_t)(magnitude > UINT32_C(1024));
    const uint32_t next_zr = r2 - i2 + cr;
    const uint32_t next_zi = p184_asr8(UINT32_C(2) * (zr * zi)) + ci;
    zr = next_escaped == 0 ? next_zr : zr;
    zi = next_escaped == 0 ? next_zi : zi;
    escaped = next_escaped;
    iterations += (uint32_t)(next_escaped == 0);
    --n;
  }
  return iterations;
}

static inline uint32_t p184_pixel(uint32_t id, uint64_t iterations) {
  const uint32_t cr = ((id & UINT32_C(4095)) * UINT32_C(768)) / UINT32_C(4096) - UINT32_C(512);
  const uint32_t ci = ((id >> 12) * UINT32_C(768)) / UINT32_C(4096) - UINT32_C(384);
  return p184_mit(iterations, cr, ci, 0, 0, 0, 0);
}

static inline uint32_t p184_bucket(uint32_t iteration, uint64_t limit) {
  const uint32_t bucket = p184_div(iteration * UINT32_C(8), (uint32_t)limit);
  return bucket > 7 ? UINT32_C(7) : bucket;
}

#endif
