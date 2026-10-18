/* Generic String graph construction and observation. nx_entry is the actual
 * Base String.append emitted by the admitted native closed-entry factory. */
#include "abi.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern uint64_t nx_entry(NxRt *, uint64_t, uint64_t);
typedef struct {
  const char *name;
  const uint32_t *left, *right;
  uint32_t left_size, right_size, left_repeats, right_repeats;
  uint32_t stat, aliases, overlap, suffix;
} Case;
#include "cases.inc.c"
static void require(int ok, const char *message) {
  if (!ok) { fprintf(stderr,"base-string-append: %s\n",message); exit(2); }
}
static uint64_t text(NxRt *ctx, const uint32_t *chars, uint32_t size, uint32_t repeats, int stat) {
  uint64_t out = nx_rt_zero(ctx,NX_RT_SNIL);
  for (uint32_t repeat = 0; repeat < repeats; ++repeat)
    for (uint32_t i = size; i; --i)
      out = stat ? nx_rt_static2(ctx,NX_RT_SCON,chars[i-1],out) : nx_rt_build2(ctx,NX_RT_SCON,chars[i-1],out);
  return out;
}
static void observe(NxRt *ctx, uint64_t word) {
  uint32_t count=0; putchar('[');
  while (nx_rt_id(ctx,word)==NX_RT_SCON) {
    printf("%s%" PRIu64,count++ ? "," : "",nx_rt_borrow(ctx,word,0));
    word=nx_rt_borrow(ctx,word,1);
  }
  require(nx_rt_id(ctx,word)==NX_RT_SNIL,"bad String terminator");putchar(']');
}
static void run(const Case *c, int aliases_first) {
  NxRt *ctx=nx_rt_open();
  uint64_t left=text(ctx,c->left,c->left_size,c->left_repeats,c->stat),right;
  if (c->overlap==1) { right=nx_rt_keep(ctx,left);left=right; }
  else if (c->overlap==2) {
    uint64_t borrowed=left;
    for (uint32_t i=0;i<c->suffix;++i) borrowed=nx_rt_borrow(ctx,borrowed,1);
    right=nx_rt_keep(ctx,borrowed);require(right==borrowed,"suffix was not sealed");
  } else right=text(ctx,c->right,c->right_size,c->right_repeats,c->stat);
  uint64_t aliases[2];uint32_t count=0;
  if (c->aliases&1) { left=nx_rt_keep(ctx,left);aliases[count++]=left; }
  if (c->aliases&2) { right=nx_rt_keep(ctx,right);aliases[count++]=right; }
  uint64_t result=nx_entry(ctx,left,right);
  require(nx_rt_pending(ctx)==0,"worker left pending fields");
  printf("{\"name\":\"%s\",\"dropOrder\":\"%s\",\"result\":",c->name,aliases_first ? "aliases-first" : "result-first");
  observe(ctx,result);if (!aliases_first) nx_rt_sink(ctx,result);
  printf(",\"aliases\":[");
  for (uint32_t i=0;i<count;++i) { if (i) putchar(',');observe(ctx,aliases[i]);nx_rt_sink(ctx,aliases[i]); }
  printf("],\"resultAfterAliasRelease\":");
  if (aliases_first) { observe(ctx,result);nx_rt_sink(ctx,result); } else printf("null");
  require(nx_rt_pending(ctx)==0,"release left pending fields");
  require(nx_rt_live_words(ctx)==0,"unreleased ownership");nx_rt_close(ctx);
  puts(",\"released\":true}");
}
int main(int argc,char **argv) {
  uint32_t matched=0;require(argc<=2,"optional case only");
  for (uint32_t i=0;i<sizeof(CASES)/sizeof(CASES[0]);++i)
    if (argc==1 || !strcmp(argv[1],CASES[i].name)) { run(&CASES[i],0);run(&CASES[i],1);++matched; }
  require(matched!=0,"unknown case");return 0;
}
