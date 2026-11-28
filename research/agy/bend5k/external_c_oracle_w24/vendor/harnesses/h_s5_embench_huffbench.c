/* Harness for unmodified Embench-IoT huffbench (libhuffbench.c) */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define GLOBAL_SCALE_FACTOR 1
#include "../embench-iot/support/beebsc.c"
#include "../embench-iot/src/huffbench/libhuffbench.c"

int main(void) {
  const uint32_t ROUNDS = 80;
  uint32_t acc = 2166136261u;
  for (uint32_t r = 0; r < ROUNDS; r++) {
    init_heap_beebs((void *)heap, HEAP_SIZE);
    memcpy(test_data, orig_data, TEST_SIZE);
    /* vary first byte deterministically */
    test_data[0] = (unsigned char)('a' + (r % 26));
    compdecomp(test_data, TEST_SIZE);
    for (int i = 0; i < TEST_SIZE; i++) {
      acc = (acc ^ (uint32_t)test_data[i]) * 16777619u;
    }
  }
  printf("%u\n", acc);
  return 0;
}
