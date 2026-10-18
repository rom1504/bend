/* Each negative case must fail-stop. No Bend computation is implemented here. */
#include "abi.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
  if (argc != 2) return 2;
  NxRt *ctx = nx_rt_open();
  uint64_t empty = nx_rt_zero(ctx, NX_RT_SNIL);
  if (!strcmp(argv[1], "unknown-constructor")) {
    (void)nx_rt_zero(ctx, 99);
  } else if (!strcmp(argv[1], "wrong-arity")) {
    (void)nx_rt_take2(ctx, empty);
  } else if (!strcmp(argv[1], "wrong-field-type")) {
    (void)nx_rt_build2(ctx, NX_RT_CON, empty, empty);
  } else if (!strcmp(argv[1], "invalid-char")) {
    (void)nx_rt_build2(ctx, NX_RT_SCON, 0xd800, empty);
  } else if (!strcmp(argv[1], "duplicate-field")) {
    uint64_t value = nx_rt_build2(ctx, NX_RT_SCON, 'a', empty);
    (void)nx_rt_take2(ctx, value);
    (void)nx_rt_field(ctx, 0);
    (void)nx_rt_field(ctx, 0);
  } else if (!strcmp(argv[1], "pending-take")) {
    uint64_t first = nx_rt_build2(ctx, NX_RT_SCON, 'a', empty);
    uint64_t second = nx_rt_build2(ctx, NX_RT_SCON, 'b', empty);
    (void)nx_rt_take2(ctx, first);
    (void)nx_rt_take2(ctx, second);
  } else if (!strcmp(argv[1], "pending-close")) {
    (void)nx_rt_take2(ctx, nx_rt_build2(ctx, NX_RT_SCON, 'a', empty));
    nx_rt_close(ctx);
  } else if (!strcmp(argv[1], "leaked-owner")) {
    (void)nx_rt_build2(ctx, NX_RT_SCON, 'a', empty);
    nx_rt_close(ctx);
  } else if (!strcmp(argv[1], "invalid-context")) {
    (void)nx_rt_zero(NULL, NX_RT_SNIL);
  } else if (!strcmp(argv[1], "second-context")) {
    (void)nx_rt_open();
  } else if (!strcmp(argv[1], "impossible-branch")) {
    (void)nx_rt_fail(ctx, 1);
  } else if (!strncmp(argv[1], "rebuild-", 8)) {
    int shared = !strcmp(argv[1], "rebuild-shared");
    int stat = !strcmp(argv[1], "rebuild-static");
    int keep_tail = !strcmp(argv[1], "rebuild-keep-tail");
    if (!shared && !stat && !keep_tail && strcmp(argv[1], "rebuild-unique")) return 2;
    uint64_t tail = stat ? nx_rt_static2(ctx, NX_RT_SCON, 'b', empty)
      : nx_rt_build2(ctx, NX_RT_SCON, 'b', empty);
    uint64_t parent = stat ? nx_rt_static2(ctx, NX_RT_SCON, 'a', tail)
      : nx_rt_build2(ctx, NX_RT_SCON, 'a', tail);
    uint64_t alias = parent;
    if (shared) alias = parent = nx_rt_keep(ctx, parent);
    uint64_t other = keep_tail ? nx_rt_zero(ctx, NX_RT_NIL)
      : nx_rt_build2(ctx, NX_RT_SCON, 'z', empty);
    uint64_t result = nx_rt_rebuild2(ctx, parent,
      keep_tail ? NX_RT_CON : NX_RT_SCON, keep_tail ? 1 : 0, other);
    uint64_t remaining = nx_rt_fast_field(ctx, 0);
    if (nx_rt_pending(ctx) != 0) return 4;
    if (keep_tail) {
      if (nx_rt_borrow(ctx, nx_rt_borrow(ctx, result, 0), 0) != 'b' || remaining != 'a') return 5;
    } else {
      if (nx_rt_borrow(ctx, result, 0) != 'a' || nx_rt_borrow(ctx, nx_rt_borrow(ctx, result, 1), 0) != 'z'
          || nx_rt_borrow(ctx, remaining, 0) != 'b') return 6;
    }
    nx_rt_sink(ctx, result);
    nx_rt_sink(ctx, remaining);
    if (shared || stat) {
      if (nx_rt_borrow(ctx, alias, 0) != 'a' || nx_rt_borrow(ctx, nx_rt_borrow(ctx, alias, 1), 0) != 'b') return 7;
      nx_rt_sink(ctx, alias);
    }
    nx_rt_close(ctx);
    puts("rebuild:ok");
    return 0;
  } else if (!strcmp(argv[1], "repeat-context")) {
    nx_rt_close(ctx);
    for (int i = 0; i < 16; ++i) {
      ctx = nx_rt_open();
      uint64_t s = nx_rt_build2(ctx, NX_RT_SCON, 'a', nx_rt_zero(ctx, NX_RT_SNIL));
      (void)nx_rt_sink(ctx, s);
      nx_rt_close(ctx);
    }
    puts("repeat-context:ok");
    return 0;
  } else {
    return 2;
  }
  fputs("negative contract unexpectedly returned\n", stderr);
  return 3;
}
