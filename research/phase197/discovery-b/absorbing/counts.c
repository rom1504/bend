#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

uint64_t p197_calls, p197_steps, p197_leaf;
__attribute__((destructor)) static void counts(void) {
    fprintf(stderr, "calls=%" PRIu64 " steps=%" PRIu64 " leaves=%" PRIu64 "\n",
            p197_calls, p197_steps, p197_leaf);
}
