/* Harness for unmodified Embench-IoT slre (libslre.c / slre.h) */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define GLOBAL_SCALE_FACTOR 1
#include "../embench-iot/support/beebsc.c"
#include "../embench-iot/src/slre/libslre.c"

int main(void) {
  const uint32_t ROUNDS = 4000;
  int len = (int)strlen(text);
  char work[64];
  memcpy(work, text, (size_t)len + 1);

  uint32_t acc = 2166136261u;
  struct slre_cap cap;
  for (uint32_t r = 0; r < ROUNDS; r++) {
    /* rotate text by 1 char each round so compiler cannot hoist slre_match */
    char first = work[0];
    for (int k = 0; k < len - 1; k++) work[k] = work[k + 1];
    work[len - 1] = first;
    for (int i = 0; i < 4; i++) {
      int m = slre_match(regexes[i], work, len, &cap, 1);
      acc = (acc ^ (uint32_t)m) * 16777619u;
    }
  }
  printf("%u\n", acc);
  return 0;
}
