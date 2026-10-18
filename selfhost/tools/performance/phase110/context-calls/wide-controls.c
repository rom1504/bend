/* Independent synthetic ABI oracle: construct/observe public runtime values;
 * the tested worker consumes eight owners and returns the eighth. */
#include "abi.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern uint64_t nx_wide(NxRt *, uint64_t, uint64_t, uint64_t, uint64_t,
                        uint64_t, uint64_t, uint64_t, uint64_t);
static const char *const values[8] = {
  "alpha", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel"
};
static void require(int ok, const char *message) {
  if (!ok) { fprintf(stderr, "wide ABI: %s\n", message); exit(2); }
}
static uint64_t string(NxRt *ctx, const char *text) {
  uint64_t value = nx_rt_zero(ctx, NX_RT_SNIL);
  for (size_t n = strlen(text); n; --n)
    value = nx_rt_build2(ctx, NX_RT_SCON, (unsigned char)text[n - 1], value);
  return value;
}
static void observe(NxRt *ctx, uint64_t word, const char *expected) {
  size_t n = 0;
  while (nx_rt_id(ctx, word) == NX_RT_SCON) {
    require(expected[n] && nx_rt_borrow(ctx, word, 0) == (unsigned char)expected[n],
      "complete string value differs");
    ++n; word = nx_rt_borrow(ctx, word, 1);
  }
  require(nx_rt_id(ctx, word) == NX_RT_SNIL && !expected[n], "string suffix differs");
}
static void run(int shared, int result_first) {
  NxRt *ctx = nx_rt_open(); uint64_t args[8], aliases[8];
  for (unsigned i = 0; i < 8; ++i) {
    args[i] = string(ctx, values[i]);
    require(!(args[i] >> 63), "unique input is not a raw dynamic root");
    if (shared) {
      args[i] = nx_rt_keep(ctx, args[i]); aliases[i] = args[i];
      require(args[i] >> 63, "shared input did not become a redirect");
    }
  }
  uint64_t result = nx_wide(ctx, args[0], args[1], args[2], args[3],
                           args[4], args[5], args[6], args[7]);
  require(result == args[7], "eighth owning word was not returned intact");
  require(nx_rt_pending(ctx) == 0, "worker left pending scratch");
  observe(ctx, result, values[7]);
  if (shared) {
    for (unsigned i = 0; i < 8; ++i) observe(ctx, aliases[i], values[i]);
    if (result_first) nx_rt_sink(ctx, result);
    for (unsigned i = 0; i < 8; ++i) {
      observe(ctx, aliases[i], values[i]); nx_rt_sink(ctx, aliases[i]);
    }
    if (!result_first) { observe(ctx, result, values[7]); nx_rt_sink(ctx, result); }
  } else {
    /* Inputs were unique at the ABI boundary. Split only the surviving result
     * afterwards so both independent output-drop orders are still exercised. */
    result = nx_rt_keep(ctx, result); uint64_t alias = result;
    nx_rt_sink(ctx, result_first ? result : alias);
    observe(ctx, result_first ? alias : result, values[7]);
    nx_rt_sink(ctx, result_first ? alias : result);
  }
  require(nx_rt_pending(ctx) == 0 && nx_rt_live_words(ctx) == 0, "unreleased ownership");
  nx_rt_close(ctx);
  printf("{\"name\":\"wide-%s\",\"dropOrder\":\"%s\",\"result\":\"hotel\",\"aliases\":%s,\"released\":true}\n",
    shared ? "shared" : "unique", result_first ? "result-first" : "aliases-first",
    shared ? "[\"alpha\",\"bravo\",\"charlie\",\"delta\",\"echo\",\"foxtrot\",\"golf\",\"hotel\"]" : "[\"hotel\"]");
}
int main(void) {
  run(0, 1); run(0, 0); run(1, 1); run(1, 0); return 0;
}
