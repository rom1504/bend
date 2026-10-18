/* Construction/observation only. The selected native-produced entry owns all
 * function behavior; select its signature with -DP110_CLOSURE_ROOT=0..3. */
#include "abi.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef P110_CLOSURE_ROOT
#error P110_CLOSURE_ROOT must select one frozen root
#endif
#if P110_CLOSURE_ROOT < 0 || P110_CLOSURE_ROOT > 3
#error invalid P110_CLOSURE_ROOT
#endif
#if P110_CLOSURE_ROOT < 2
extern uint64_t nx_entry(NxRt *, uint64_t);
#else
extern uint64_t nx_entry(NxRt *, uint64_t, uint64_t);
#endif
typedef struct { const char *name; uint32_t root, shape; } Case;
typedef struct { uint64_t word; int list; } Owner;
#include "cases.inc.c"
static void require(int ok, const char *message) {
  if (!ok) { fprintf(stderr, "closure-semantics: %s\n", message); exit(2); }
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
  const uint32_t a[] = {97}, unicode[] = {955,128578};
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
  *word = nx_rt_keep(ctx, *word); aliases[(*count)++] = (Owner){*word,list};
}
static void run(const Case *c, int aliases_first) {
  NxRt *ctx = nx_rt_open();
  int empty = c->shape == 0, stat = c->shape == 3, cross = c->shape == 4;
  const uint32_t unicode[] = {0,101,769,128578,1114111}, hs[] = {104,128578}, z[] = {122};
  uint64_t xs, ys = 0, h = 0;
  if (c->root == 1) xs = text(ctx,unicode,empty ? 0 : 5,stat);
  else xs = input(ctx,empty,stat);
  if (c->root == 2) {
    if (cross) {
      uint64_t borrowed = nx_rt_borrow(ctx,xs,0); h = nx_rt_keep(ctx,borrowed);
      require(h == borrowed,"borrowed child lacked sealed handle");
    } else h = text(ctx,hs,empty ? 0 : 2,stat);
  }
  if (c->root == 3) {
    if (cross) { ys = nx_rt_keep(ctx,xs); xs = ys; }
    else ys = empty ? nx_rt_zero(ctx,NX_RT_NIL)
      : node(ctx,NX_RT_CON,text(ctx,z,1,stat),nx_rt_zero(ctx,NX_RT_NIL),stat);
  }
  Owner aliases[3]; uint32_t count = 0;
  if (c->shape >= 2) {
    alias(ctx,&xs,c->root != 1,aliases,&count);
    if (c->root == 2) alias(ctx,&h,0,aliases,&count);
    if (c->root == 3) alias(ctx,&ys,1,aliases,&count);
  }
  uint64_t result;
#if P110_CLOSURE_ROOT < 2
  result = nx_entry(ctx,xs);
#elif P110_CLOSURE_ROOT == 2
  result = nx_entry(ctx,h,xs);
#else
  result = nx_entry(ctx,xs,ys);
#endif
  require(nx_rt_pending(ctx) == 0,"worker left pending fields");
  Owner output = {result,c->root != 1};
  printf("{\"name\":\"%s\",\"dropOrder\":\"%s\",\"result\":",c->name,aliases_first ? "aliases-first" : "result-first");
  observe(ctx,output);
  if (!aliases_first) nx_rt_sink(ctx,result);
  printf(",\"aliases\":[");
  for (uint32_t i = 0; i < count; ++i) {
    if (i) putchar(','); observe(ctx,aliases[i]); nx_rt_sink(ctx,aliases[i].word);
  }
  printf("],\"resultAfterAliasRelease\":");
  if (aliases_first) { observe(ctx,output); nx_rt_sink(ctx,result); }
  else printf("null");
  require(nx_rt_pending(ctx) == 0,"release left pending fields");
  require(nx_rt_live_words(ctx) == 0,"unreleased ownership"); nx_rt_close(ctx);
  puts(",\"released\":true}");
}
int main(int argc, char **argv) {
  uint32_t matched = 0;
  require(argc <= 2,"optional case name only");
  for (uint32_t i = 0; i < sizeof(CASES)/sizeof(CASES[0]); ++i)
    if (CASES[i].root == P110_CLOSURE_ROOT && (argc == 1 || !strcmp(argv[1],CASES[i].name))) {
      run(&CASES[i],0); run(&CASES[i],1); ++matched;
    }
  require(matched != 0,"unknown case for selected root"); return 0;
}
