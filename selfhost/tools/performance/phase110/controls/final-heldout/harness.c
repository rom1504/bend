#include "abi.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#ifndef P110_SELECTOR
#define P110_SELECTOR 0
#endif

extern uint64_t nx_list_reverse(NxRt *, uint64_t, uint64_t);
extern uint64_t nx_string_reverse(NxRt *, uint64_t, uint64_t);
#if P110_SELECTOR == 1
extern uint64_t nx_list_tail(NxRt *, uint64_t);
#elif P110_SELECTOR == 2
extern uint64_t nx_list_last(NxRt *, uint64_t, uint64_t);
#elif P110_SELECTOR == 3
extern uint64_t nx_list_append(NxRt *, uint64_t, uint64_t);
#endif
typedef struct {const uint32_t *data; uint32_t count;} Text;
typedef struct {uint32_t from, offset, string_kind;} Alias;
typedef struct {
  const char *name;
  uint32_t string_kind, static_input, repeats;
  const Text *input, *acc;
  uint32_t input_count, acc_count;
  const Alias *aliases;
  uint32_t alias_count;
  Text last_acc;
} Case;
typedef struct {uint64_t count, hash;} Observation;
#include "cases.inc.c"

static void require(int condition, const char *message) {
  if (!condition) {fprintf(stderr, "harness: %s\n", message); exit(2);}
}
static uint64_t make2(NxRt *ctx, uint32_t cid, uint64_t h, uint64_t t, int stat) {
  return stat ? nx_rt_static2(ctx, cid, h, t) : nx_rt_build2(ctx, cid, h, t);
}
static uint64_t text_repeated(NxRt *ctx, Text s, uint32_t repeats, int stat) {
  uint64_t value = nx_rt_zero(ctx, NX_RT_SNIL);
  for (uint32_t rep = 0; rep < repeats; ++rep)
    for (uint32_t i = s.count; i != 0; --i)
      value = make2(ctx, NX_RT_SCON, s.data[i - 1], value, stat);
  return value;
}
static uint64_t text(NxRt *ctx, Text s, int stat) {
  return text_repeated(ctx, s, 1, stat);
}
static uint64_t strings(NxRt *ctx, const Text *xs, uint32_t n, uint32_t repeats, int stat) {
  uint64_t value = nx_rt_zero(ctx, NX_RT_NIL);
  for (uint32_t rep = 0; rep < repeats; ++rep)
    for (uint32_t i = n; i != 0; --i)
      value = make2(ctx, NX_RT_CON, text(ctx, xs[i - 1], stat), value, stat);
  return value;
}
static uint64_t mix(uint64_t hash, uint32_t word) {
  for (uint32_t i = 0; i != 4; ++i) {
    hash ^= (word >> (8 * i)) & 255;
    hash *= UINT64_C(1099511628211);
  }
  return hash;
}
static uint64_t text_count(NxRt *ctx, uint64_t s) {
  uint64_t n = 0;
  while (nx_rt_id(ctx, s) == NX_RT_SCON) {
    ++n; s = nx_rt_borrow(ctx, s, 1);
  }
  require(nx_rt_id(ctx, s) == NX_RT_SNIL, "text ended at wrong constructor");
  return n;
}
static uint64_t text_hash(NxRt *ctx, uint64_t s, uint64_t hash) {
  while (nx_rt_id(ctx, s) == NX_RT_SCON) {
    hash = mix(hash, (uint32_t)nx_rt_borrow(ctx, s, 0));
    s = nx_rt_borrow(ctx, s, 1);
  }
  require(nx_rt_id(ctx, s) == NX_RT_SNIL, "text ended at wrong constructor");
  return hash;
}
static Observation observe(NxRt *ctx, uint64_t value, int string_kind) {
  Observation o = {0, UINT64_C(14695981039346656037)};
  if (string_kind) {
    o.count = text_count(ctx, value);
    o.hash = text_hash(ctx, value, o.hash);
  } else {
    while (nx_rt_id(ctx, value) == NX_RT_CON) {
      uint64_t head = nx_rt_borrow(ctx, value, 0);
      o.hash = mix(o.hash, (uint32_t)text_count(ctx, head));
      o.hash = text_hash(ctx, head, o.hash);
      ++o.count;
      value = nx_rt_borrow(ctx, value, 1);
    }
    require(nx_rt_id(ctx, value) == NX_RT_NIL, "list ended at wrong constructor");
  }
  return o;
}
static double now(void) {
  struct timespec t;
  require(clock_gettime(CLOCK_MONOTONIC, &t) == 0, "clock failed");
  return t.tv_sec + t.tv_nsec * 1e-9;
}
static void run(const Case *c, uint32_t repetitions) {
  double worker_seconds = 0;
  uint64_t max_bump = 0;
  Observation first_result = {0, 0}, first_aliases[8];
  for (uint32_t rep = 0; rep < repetitions; ++rep) {
    NxRt *ctx = nx_rt_open();
    uint64_t input = c->string_kind ? text_repeated(ctx, c->input[0], c->repeats, c->static_input)
      : strings(ctx, c->input, c->input_count, c->repeats, c->static_input);
#if P110_SELECTOR == 1
    uint64_t acc = 0; /* The actual List.tail entry has one live argument. */
#elif P110_SELECTOR == 2
    uint64_t acc = text(ctx, c->last_acc, 0);
#else
    uint64_t acc = c->string_kind ? text(ctx, c->acc[0], 0)
      : strings(ctx, c->acc, c->acc_count, 1, 0);
#endif
    uint64_t aliases[8];
    require(c->alias_count <= 8, "too many fixture aliases");
    for (uint32_t i = 0; i < c->alias_count; ++i) {
      const Alias *a = &c->aliases[i];
      if (a->from == 0) {
        input = nx_rt_keep(ctx, input);
        aliases[i] = input;
      } else {
        uint64_t at = input;
        for (uint32_t j = 0; j < a->offset; ++j) at = nx_rt_borrow(ctx, at, 1);
        if (a->from == 2) at = nx_rt_borrow(ctx, at, 0);
        aliases[i] = nx_rt_keep(ctx, at);
        /* Nontrivial children were sealed by constructor creation, so keep
         * updates that existing redirect; the parent's child word stays valid. */
        require(aliases[i] == at, "fixture borrowed a nonsealed heap child");
      }
    }
    double begin = now();
#if P110_SELECTOR == 1
    uint64_t result = nx_list_tail(ctx, input);
#elif P110_SELECTOR == 2
    uint64_t result = nx_list_last(ctx, input, acc);
#elif P110_SELECTOR == 3
    uint64_t result = nx_list_append(ctx, input, acc);
#else
    uint64_t result = c->string_kind ? nx_string_reverse(ctx, input, acc)
      : nx_list_reverse(ctx, input, acc);
#endif
    worker_seconds += now() - begin;
    require(nx_rt_pending(ctx) == 0, "worker left scratch children");
    Observation got = observe(ctx, result, P110_SELECTOR == 2 ? 1 : c->string_kind);
    nx_rt_sink(ctx, result);
    Observation alias_got[8];
    for (uint32_t i = 0; i < c->alias_count; ++i) {
      /* Observe after dropping result: retained aliases must independently live. */
      alias_got[i] = observe(ctx, aliases[i], c->aliases[i].string_kind);
      nx_rt_sink(ctx, aliases[i]);
    }
    uint64_t bump = nx_rt_bump_words(ctx);
    if (bump > max_bump) max_bump = bump;
    require(nx_rt_live_words(ctx) == 0, "worker leaked ownership");
    nx_rt_close(ctx);
    if (rep == 0) {
      first_result = got;
      for (uint32_t i = 0; i < c->alias_count; ++i) first_aliases[i] = alias_got[i];
    } else {
      require(got.count == first_result.count && got.hash == first_result.hash,
        "worker changed result across repetitions");
      for (uint32_t i = 0; i < c->alias_count; ++i)
        require(alias_got[i].count == first_aliases[i].count && alias_got[i].hash == first_aliases[i].hash,
          "worker changed alias across repetitions");
    }
    if (rep == 0) {
      printf("{\"name\":\"%s\",\"count\":%" PRIu64 ",\"hash\":\"%016" PRIx64 "\",\"aliases\":[", c->name, got.count, got.hash);
      for (uint32_t i = 0; i < c->alias_count; ++i)
        printf("%s{\"count\":%" PRIu64 ",\"hash\":\"%016" PRIx64 "\"}", i ? "," : "", alias_got[i].count, alias_got[i].hash);
      puts("],\"released\":true}");
    }
  }
  fprintf(stderr, "{\"name\":\"%s\",\"repetitions\":%u,\"workerSeconds\":%.9f,\"maxBumpWords\":%" PRIu64 "}\n", c->name, repetitions, worker_seconds, max_bump);
}
int main(int argc, char **argv) {
  const char *selected = argc > 1 ? argv[1] : NULL;
  uint32_t repetitions = argc > 2 ? (uint32_t)strtoul(argv[2], NULL, 10) : 1;
  require(repetitions > 0 && repetitions <= 10000, "repetitions outside 1..10000");
  uint32_t matched = 0;
  for (uint32_t i = 0; i < sizeof(CASES) / sizeof(CASES[0]); ++i)
    if (!selected || strcmp(selected, CASES[i].name) == 0) {
      run(&CASES[i], repetitions); ++matched;
    }
  require(matched != 0, "unknown fixture name");
  return 0;
}
