#include "abi.h"
#include "abi-extension.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
  if (argc != 3) return 2;
  int list = !strcmp(argv[1],"list");
  if (!list && strcmp(argv[1],"string")) return 2;
  int shared = !strcmp(argv[2],"shared"), stat = !strcmp(argv[2],"static");
  if (!shared && !stat && strcmp(argv[2],"unique")) return 2;
  NxRt *ctx = nx_rt_open();
  uint64_t snil = nx_rt_zero(ctx,NX_RT_SNIL), nil = nx_rt_zero(ctx,NX_RT_NIL);
  uint64_t str = stat ? nx_rt_static2(ctx,NX_RT_SCON,'x',snil)
                      : nx_rt_build2(ctx,NX_RT_SCON,'x',snil);
  uint64_t parent = list ? (stat ? nx_rt_static2(ctx,NX_RT_CON,str,nil)
                                : nx_rt_build2(ctx,NX_RT_CON,str,nil)) : str;
  uint64_t alias = parent;
  if (shared) alias = parent = nx_rt_keep(ctx,parent);
  NxRtPair out = nx_rt_pair_take2(ctx,parent);
  if (nx_rt_pending(ctx) != 0) return 3;
  if (list) {
    if (nx_rt_borrow(ctx,out.first,0) != 'x' || nx_rt_id(ctx,out.second) != NX_RT_NIL) return 4;
  } else {
    if (out.first != 'x' || nx_rt_id(ctx,out.second) != NX_RT_SNIL) return 5;
  }
  nx_rt_sink(ctx,out.first);
  nx_rt_sink(ctx,out.second);
  if (shared || stat) {
    if (list ? nx_rt_borrow(ctx,nx_rt_borrow(ctx,alias,0),0) != 'x'
             : nx_rt_borrow(ctx,alias,0) != 'x') return 6;
    nx_rt_sink(ctx,alias);
  }
  nx_rt_close(ctx);
  puts("take-v3:ok");
  return 0;
}
