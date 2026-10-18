/* ABI v2 operator controls, independent of emitted source workers. Run each
 * mode/layout/ownership combination in a fresh process. Checked public APIs
 * construct inputs and observe/drop every owner after result release. */
#include "abi.h"
#include "abi-extension.h"
#include <stdio.h>
#include <string.h>

static uint64_t make2(NxRt *ctx, int stat, uint32_t cid, uint64_t a, uint64_t b) {
  return stat ? nx_rt_static2(ctx,cid,a,b) : nx_rt_build2(ctx,cid,a,b);
}

int main(int argc, char **argv) {
  if (argc != 4) return 2;
  int pair = !strcmp(argv[1],"pair");
  if (!pair && strcmp(argv[1],"specialized")) return 2;
  int list = !strcmp(argv[2],"c1-k0");
  int tail = !strcmp(argv[2],"c1-k1");
  if (!list && !tail && strcmp(argv[2],"c3-k0")) return 2;
  int shared = !strcmp(argv[3],"shared");
  int stat = !strcmp(argv[3],"static");
  if (!shared && !stat && strcmp(argv[3],"unique")) return 2;
  NxRt *ctx = nx_rt_open();
  uint64_t snil = nx_rt_zero(ctx,NX_RT_SNIL), nil = nx_rt_zero(ctx,NX_RT_NIL);
  uint64_t old_tail = make2(ctx,stat,NX_RT_SCON,'b',snil);
  uint64_t parent = list ? make2(ctx,stat,NX_RT_CON,old_tail,nil)
                        : make2(ctx,stat,NX_RT_SCON,'a',old_tail);
  uint64_t alias = parent;
  if (shared) alias = parent = nx_rt_keep(ctx,parent);
  uint64_t other = list || tail ? nil : nx_rt_build2(ctx,NX_RT_SCON,'z',snil);
  uint64_t result, remaining;
  if (pair) {
    NxRtPair out = list ? nx_rt_pair_rebuild2_c1_k0(ctx,parent,other)
                       : tail ? nx_rt_pair_rebuild2_c1_k1(ctx,parent,other)
                              : nx_rt_pair_rebuild2_c3_k0(ctx,parent,other);
    result = out.first; remaining = out.second;
  } else {
    result = list ? nx_rt_rebuild2_c1_k0(ctx,parent,other)
                  : tail ? nx_rt_rebuild2_c1_k1(ctx,parent,other)
                         : nx_rt_rebuild2_c3_k0(ctx,parent,other);
    if (nx_rt_pending(ctx) != 1) return 4;
    remaining = nx_rt_fast_field(ctx,0);
  }
  if (nx_rt_pending(ctx) != 0) return 5;
  if (list || tail) {
    if (nx_rt_id(ctx,result) != NX_RT_CON ||
        nx_rt_borrow(ctx,nx_rt_borrow(ctx,result,0),0) != 'b' ||
        nx_rt_id(ctx,nx_rt_borrow(ctx,result,1)) != NX_RT_NIL) return 6;
    if (list ? nx_rt_id(ctx,remaining) != NX_RT_NIL : remaining != 'a') return 7;
  } else {
    if (nx_rt_borrow(ctx,result,0) != 'a' ||
        nx_rt_borrow(ctx,nx_rt_borrow(ctx,result,1),0) != 'z' ||
        nx_rt_borrow(ctx,remaining,0) != 'b') return 8;
  }
  nx_rt_sink(ctx,result);
  nx_rt_sink(ctx,remaining);
  if (shared || stat) {
    if (list) {
      if (nx_rt_borrow(ctx,nx_rt_borrow(ctx,alias,0),0) != 'b' ||
          nx_rt_id(ctx,nx_rt_borrow(ctx,alias,1)) != NX_RT_NIL) return 9;
    } else {
      if (nx_rt_borrow(ctx,alias,0) != 'a' ||
          nx_rt_borrow(ctx,nx_rt_borrow(ctx,alias,1),0) != 'b') return 10;
    }
    nx_rt_sink(ctx,alias);
  }
  nx_rt_close(ctx);
  puts("rebuild-v2:ok");
  return 0;
}
