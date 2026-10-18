/* Experimental object ABI, independent of the production Bend runtime. */
#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern uint32_t phase106_entry(const uint64_t *args);
extern const uint32_t phase106_arity;

int main(int argc, char **argv) {
  int first = 1;
  uint32_t repetitions = 1;
  uint32_t expected = 0;
  int have_repeat = 0, have_expected = 0;
  while (first < argc && strncmp(argv[first], "--", 2) == 0) {
    int repeat_option = strcmp(argv[first], "--repeat") == 0;
    int expect_option = strcmp(argv[first], "--expect") == 0;
    if ((!repeat_option && !expect_option) ||
        (repeat_option && have_repeat) || (expect_option && have_expected)) return 2;
    char *end = NULL;
    if (first + 1 >= argc || !argv[first + 1][0] || argv[first + 1][0] == '-') return 2;
    errno = 0;
    unsigned long long parsed = strtoull(argv[first + 1], &end, 10);
    if (errno || !end || *end || parsed > UINT32_MAX) return 2;
    if (repeat_option) {
      repetitions = (uint32_t)parsed;
      have_repeat = 1;
    } else {
      expected = (uint32_t)parsed;
      have_expected = 1;
    }
    first += 2;
  }
  if ((uint32_t)(argc - first) != phase106_arity) {
    fprintf(stderr, "expected %" PRIu32 " unsigned arguments\n", phase106_arity);
    return 2;
  }
  uint64_t *args = calloc(phase106_arity ? phase106_arity : 1, sizeof *args);
  if (!args) return 2;
  for (int i = first; i < argc; ++i) {
    char *end = NULL;
    errno = 0;
    if (!argv[i][0] || argv[i][0] == '-') { free(args); return 2; }
    args[i - first] = strtoull(argv[i], &end, 10);
    if (errno || !end || *end) { free(args); return 2; }
  }
  uint32_t result = 0;
  for (uint32_t i = 0; i < repetitions; ++i) {
    uint32_t value = phase106_entry(args);
    if (have_expected && value != expected) {
      fprintf(stderr, "iteration %" PRIu32 ": expected %" PRIu32 ", got %" PRIu32 "\n",
              i, expected, value);
      free(args);
      return 1;
    }
    result += value;
  }
  printf("%" PRIu32 "\n", result);
  free(args);
  return 0;
}
