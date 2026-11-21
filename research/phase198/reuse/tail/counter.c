#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

uint64_t p198_public_tail_counts[128];

__attribute__((destructor)) static void p198_print_tail_counts(void) {
  uint64_t total = 0;
  for (unsigned i = 0; i < 128; ++i) total += p198_public_tail_counts[i];
  fprintf(stderr, "public-tail=%" PRIu64 "\n", total);
  for (unsigned i = 0; i < 128; ++i) {
    if (p198_public_tail_counts[i]) {
      fprintf(stderr, "target %u=%" PRIu64 "\n", i, p198_public_tail_counts[i]);
    }
  }
}
