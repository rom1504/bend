#ifndef NATIVE45_EDITDIST_KERNEL_H
#define NATIVE45_EDITDIST_KERNEL_H

#include <stdint.h>

/* U32 words and power-of-two array wrapping match the Bend fixtures. */
static inline uint32_t ed_prng(uint32_t x) {
  uint32_t b = x ^ (x << 13u);
  uint32_t d = b ^ (b >> 17u);
  return d ^ (d << 5u);
}

static inline uint32_t ed_min(uint32_t x, uint32_t y) {
  return x < y ? x : y;
}

static inline void ed_gen(uint32_t count, uint32_t seed, uint32_t *array,
                          uint32_t mask) {
  for (uint32_t k = 0; k < count; ++k) {
    seed = ed_prng(seed);
    array[k & mask] = seed & 3u;
  }
}

static inline void ed_init(uint32_t count, uint32_t *array, uint32_t mask) {
  for (uint32_t k = 0; k < count; ++k)
    array[k & mask] = k;
}

/* The caller performs row's final prev/cur swap, including for zero cells. */
static inline void ed_row(uint32_t count, uint32_t ai, const uint32_t *b,
                          uint32_t b_mask, const uint32_t *prev,
                          uint32_t *cur, uint32_t row_mask) {
  for (uint32_t j = 0; j < count; ++j) {
    uint32_t cost = ai != b[j & b_mask] ? 1u : 0u;
    uint32_t diag = prev[j & row_mask];
    uint32_t up = prev[(j + 1u) & row_mask];
    uint32_t left = cur[j & row_mask];
    cur[(j + 1u) & row_mask] = ed_min(ed_min(up + 1u, left + 1u), diag + cost);
  }
}

#endif
