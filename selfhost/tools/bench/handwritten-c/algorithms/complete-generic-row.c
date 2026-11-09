/* Complete row.probe state, including every unused zero-filled cell. */
#include "editdist_kernel.h"
#include <inttypes.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct RowWord {
  uint32_t value;
  struct RowWord *next;
} RowWord;

static RowWord *row_to_list(const uint32_t *array) {
  RowWord *list = NULL;
  for (uint32_t i = 128u; i != 0u; --i) {
    RowWord *node = malloc(sizeof(*node));
    if (!node)
      abort();
    *node = (RowWord){array[i - 1u], list};
    list = node;
  }
  return list;
}

char *bench_text(uint32_t a, uint32_t b) {
  uint32_t arrays[4][128] = {{0}};
  ed_gen(a, b, arrays[0], 127u);
  ed_gen(a, b * UINT32_C(340573321), arrays[1], 127u);
  ed_init(a + 1u, arrays[2], 127u);
  /* row.probe supplies a zero cur[0], unlike the ordinary DP prologue. */
  ed_row(a, b & 3u, arrays[1], 127u, arrays[2], arrays[3], 127u);
  const uint32_t *ordered[4] = {arrays[0], arrays[1], arrays[3], arrays[2]};
  /* 512 words at <=10 decimal digits each, separators, brackets, and NUL. */
  size_t capacity = 4u * 128u * 11u + 16u;
  char *result = malloc(capacity);
  if (!result)
    abort();
  size_t used = 0;
  result[used++] = '[';
  for (unsigned k = 0; k < 4u; ++k) {
    if (k != 0u)
      result[used++] = ',';
    result[used++] = '[';
    RowWord *list = row_to_list(ordered[k]);
    while (list) {
      int count = snprintf(result + used, capacity - used, "%" PRIu32, list->value);
      if (count < 0 || (size_t)count >= capacity - used)
        abort();
      used += (size_t)count;
      RowWord *tail = list->next;
      free(list);
      list = tail;
      if (list)
        result[used++] = ',';
    }
    result[used++] = ']';
  }
  result[used++] = ']';
  result[used] = '\0';
  return result;
}
