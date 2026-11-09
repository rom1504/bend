/* Native45 editdist and both dynamic-input variants. See NOTES.md. */
#include "editdist_kernel.h"

static uint32_t ed_pair(uint32_t index) {
  uint32_t a[256] = {0}, b[256] = {0};
  uint32_t rows[2][512] = {{0}};
  uint32_t *prev = rows[0], *cur = rows[1];
  uint32_t seed = (index + 1u) * UINT32_C(2654435761);
  ed_gen(256u, seed, a, 255u);
  ed_gen(256u, seed * UINT32_C(340573321), b, 255u);
  ed_init(257u, prev, 511u);
  for (uint32_t i = 0; i < 256u; ++i) {
    cur[0] = i + 1u;
    ed_row(256u, a[i], b, 255u, prev, cur, 511u);
    uint32_t *swap = prev;
    prev = cur;
    cur = swap;
  }
  return (prev[256] * UINT32_C(2654435761)) ^ (index + 1u);
}

static uint32_t ed_batch(uint32_t depth, uint32_t index) {
  if (depth == 0u)
    return ed_pair(index);
  uint32_t next = depth - 1u;
  /* Base U32.shln is repeated one-bit shifting: >=32 yields zero. */
  uint32_t offset = next < 32u ? UINT32_C(1) << next : 0u;
  uint32_t left = ed_batch(next, index);
  uint32_t right = ed_batch(next, index + offset);
  return left + right;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
  return ed_batch(a, b);
}
