/* Generic graph preparation/observation only; algorithms are generated workers. */
#include "abi.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern uint64_t nx_call_identity(NxRt *, uint64_t);
extern uint64_t nx_call_inside_constructor(NxRt *, uint64_t, uint64_t);
extern uint64_t nx_call_twice(NxRt *, uint64_t, uint64_t);
extern uint64_t nx_call_discard(NxRt *, uint64_t, uint64_t);
extern uint64_t nx_call_same(NxRt *, uint64_t);
extern uint64_t nx_reverse_via_call(NxRt *, uint64_t, uint64_t);
typedef struct { const char *name; uint32_t op, shape; } Case;
typedef struct { uint64_t word; int list; } Owner;
#include "cases.inc.c"
static void require(int ok, const char *message) {
  if (!ok) { fprintf(stderr, "call-shapes: %s\n", message); exit(2); }
}
static uint64_t node(NxRt *ctx, uint32_t cid, uint64_t a, uint64_t b, int stat) {
  return stat ? nx_rt_static2(ctx, cid, a, b) : nx_rt_build2(ctx, cid, a, b);
}
static uint64_t text(NxRt *ctx, const uint32_t *cs, uint32_t size, int stat) {
  uint64_t out = nx_rt_zero(ctx, NX_RT_SNIL);
  for (uint32_t i = size; i; --i) out = node(ctx, NX_RT_SCON, cs[i - 1], out, stat);
  return out;
}
static uint64_t input(NxRt *ctx, int empty, int stat) {
  const uint32_t a[] = {97}, unicode[] = {955, 128578};
  uint64_t out = nx_rt_zero(ctx, NX_RT_NIL);
  if (!empty) {
    out = node(ctx, NX_RT_CON, nx_rt_zero(ctx, NX_RT_SNIL), out, stat);
    out = node(ctx, NX_RT_CON, text(ctx, unicode, 2, stat), out, stat);
    out = node(ctx, NX_RT_CON, text(ctx, a, 1, stat), out, stat);
  }
  return out;
}
static void observe_string(NxRt *ctx, uint64_t word) {
  uint32_t count = 0; putchar('[');
  while (nx_rt_id(ctx, word) == NX_RT_SCON) {
    printf("%s%" PRIu64, count++ ? "," : "", nx_rt_borrow(ctx, word, 0));
    word = nx_rt_borrow(ctx, word, 1);
  }
  require(nx_rt_id(ctx, word) == NX_RT_SNIL, "bad string terminator"); putchar(']');
}
static void observe(NxRt *ctx, Owner value) {
  if (!value.list) { observe_string(ctx, value.word); return; }
  uint32_t count = 0; putchar('[');
  while (nx_rt_id(ctx, value.word) == NX_RT_CON) {
    if (count++) putchar(','); observe_string(ctx, nx_rt_borrow(ctx, value.word, 0));
    value.word = nx_rt_borrow(ctx, value.word, 1);
  }
  require(nx_rt_id(ctx, value.word) == NX_RT_NIL, "bad list terminator"); putchar(']');
}
static void alias(NxRt *ctx, uint64_t *word, int list, Owner *aliases, uint32_t *count) {
  *word = nx_rt_keep(ctx, *word); aliases[(*count)++] = (Owner){*word, list};
}
static void run(const Case *c) {
  NxRt *ctx = nx_rt_open();
  int empty = c->shape == 0, stat = c->shape == 3, cross = c->shape == 4;
  int second = c->op == 2 || c->op == 3 || c->op == 5;
  uint64_t xs = input(ctx, empty, stat), ys = 0, h = 0;
  const uint32_t z[] = {122}, hs[] = {104, 128578};
  if (second) {
    if (cross) { ys = nx_rt_keep(ctx, xs); xs = ys; }
    else ys = empty ? nx_rt_zero(ctx, NX_RT_NIL)
      : node(ctx, NX_RT_CON, text(ctx, z, 1, stat), nx_rt_zero(ctx, NX_RT_NIL), stat);
  }
  if (c->op == 1) {
    if (cross) {
      uint64_t borrowed = nx_rt_borrow(ctx, xs, 0); h = nx_rt_keep(ctx, borrowed);
      require(h == borrowed, "borrowed child lacked sealed handle");
    } else h = text(ctx, hs, empty ? 0 : 2, stat);
  }
  Owner aliases[3]; uint32_t count = 0;
  if (c->shape >= 2) {
    alias(ctx, &xs, 1, aliases, &count);
    if (second) alias(ctx, &ys, 1, aliases, &count);
    if (c->op == 1) alias(ctx, &h, 0, aliases, &count);
  }
  uint64_t result;
  switch (c->op) {
    case 0: result = nx_call_identity(ctx, xs); break;
    case 1: result = nx_call_inside_constructor(ctx, h, xs); break;
    case 2: result = nx_call_twice(ctx, xs, ys); break;
    case 3: result = nx_call_discard(ctx, xs, ys); break;
    case 4: result = nx_call_same(ctx, xs); break;
    case 5: result = nx_reverse_via_call(ctx, xs, ys); break;
    default: require(0, "unknown worker"); result = 0;
  }
  require(nx_rt_pending(ctx) == 0, "worker left pending fields");
  printf("{\"name\":\"%s\",\"result\":", c->name); observe(ctx, (Owner){result, 1});
  nx_rt_sink(ctx, result); printf(",\"aliases\":[");
  for (uint32_t i = 0; i < count; ++i) {
    if (i) putchar(','); observe(ctx, aliases[i]); nx_rt_sink(ctx, aliases[i].word);
  }
  require(nx_rt_live_words(ctx) == 0, "unreleased ownership"); nx_rt_close(ctx);
  puts("],\"released\":true}");
}
int main(int argc, char **argv) {
  uint32_t matched = 0;
  for (uint32_t i = 0; i < sizeof(CASES) / sizeof(CASES[0]); ++i)
    if (argc == 1 || (argc == 2 && !strcmp(argv[1], CASES[i].name))) { run(&CASES[i]); ++matched; }
  require(matched != 0, "unknown case"); return 0;
}
