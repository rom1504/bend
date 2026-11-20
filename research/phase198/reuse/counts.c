#include <inttypes.h>
#include <stdio.h>

uint64_t p198_transpose_counts[2];
__attribute__((destructor)) static void report_events(void) {
    fprintf(stderr, "%" PRIu64 " %" PRIu64 "\n", p198_transpose_counts[0], p198_transpose_counts[1]);
}
