#include <stdint.h>
#include <stdlib.h>

uint32_t bench_u32(uint32_t a, uint32_t b) {
  /* The source array capacity is fixed at 128 even when a is much larger.
     Base Array.get and Array.swap wrap every index with capacity - 1. */
  uint32_t *cells = malloc(128 * sizeof(*cells));
  if (cells == NULL) abort();
  for (uint32_t i = 0; i < 128; ++i) cells[i] = b;
  uint32_t accumulated = 0;
  uint32_t index = 0;
  uint32_t remaining = a;
  while (remaining != 0) {
    const uint32_t slot = index & UINT32_C(127);
    const uint32_t value = cells[slot];
    const uint32_t next = accumulated + value;
    cells[slot] = next ^ index;
    accumulated = next;
    ++index;
    --remaining;
  }
  free(cells);
  return accumulated;
}
