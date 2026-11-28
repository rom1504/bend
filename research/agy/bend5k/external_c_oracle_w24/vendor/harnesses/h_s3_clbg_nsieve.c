/* Harness for unmodified CLBG nsieve (bench/algorithm/nsieve/1.c) */
#include <stdint.h>
#include <stdio.h>

static uint32_t g_acc = 2166136261u;
static void record_nsieve(const char *fmt, unsigned int m, unsigned int count) {
  (void)fmt;
  g_acc = (g_acc ^ m) * 16777619u;
  g_acc = (g_acc ^ count) * 16777619u;
}
#define printf record_nsieve
#define main clbg_nsieve_orig_main
#include "../clbg/bench/algorithm/nsieve/1.c"
#undef printf
#undef main

int main(void) {
  /* m = 7 -> sieves 1,280,000; 640,000; 320,000 */
  char *fake_argv[2] = { "nsieve", "7" };
  clbg_nsieve_orig_main(2, fake_argv);
  printf("%u\n", g_acc);
  return 0;
}
