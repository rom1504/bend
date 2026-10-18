/* Graph setup and observation only. Both callbacks execute a generic runtime
 * operation; the IR callback uses the exact candidate template. */
#include "abi.h"
#include "abi-extension.h"
#include "abi-private.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef P110_AUDIT_IR
extern uint64_t nx_ir_probe_c1_k0(NxRt *, uint64_t, uint64_t);
extern uint64_t nx_ir_probe_c1_k1(NxRt *, uint64_t, uint64_t);
extern uint64_t nx_ir_probe_c3_k0(NxRt *, uint64_t, uint64_t);
#endif

typedef struct { uint64_t word; int list; } Owner;
typedef struct {
  uint64_t parent, other;
  uint32_t cid, keep;
  Owner aliases[3];
  uint32_t alias_count;
} Graph;

static void require(int ok, const char *message) {
  if (!ok) { fprintf(stderr, "audit: %s\n", message); exit(2); }
}
static uint64_t str(NxRt *ctx, const char *s, int stat) {
  uint64_t out = nx_rt_zero(ctx, NX_RT_SNIL);
  for (size_t n = strlen(s); n; --n)
    out = stat ? nx_rt_static2(ctx, NX_RT_SCON, (unsigned char)s[n - 1], out)
               : nx_rt_build2(ctx, NX_RT_SCON, (unsigned char)s[n - 1], out);
  return out;
}
static void observe_string(NxRt *ctx, uint64_t value, char *out, size_t cap) {
  size_t n = 0;
  while (nx_rt_id(ctx, value) == NX_RT_SCON) {
    uint64_t c = nx_rt_borrow(ctx, value, 0);
    require(c >= 'a' && c <= 'z' && n + 1 < cap, "unexpected string payload");
    out[n++] = (char)c; value = nx_rt_borrow(ctx, value, 1);
  }
  require(nx_rt_id(ctx, value) == NX_RT_SNIL, "wrong string terminator");
  out[n] = 0;
}
static void observe(NxRt *ctx, Owner owner, char *out, size_t cap) {
  if (owner.list == 2) { snprintf(out, cap, "%" PRIu64, owner.word); return; }
  if (!owner.list) {
    char s[64]; observe_string(ctx, owner.word, s, sizeof(s));
    snprintf(out, cap, "\"%s\"", s); return;
  }
  size_t n = 0; out[n++] = '[';
  uint64_t at = owner.word; unsigned count = 0;
  while (nx_rt_id(ctx, at) == NX_RT_CON) {
    char s[64]; observe_string(ctx, nx_rt_borrow(ctx, at, 0), s, sizeof(s));
    int wrote = snprintf(out + n, cap - n, "%s\"%s\"", count++ ? "," : "", s);
    require(wrote > 0 && (size_t)wrote < cap - n, "list observation overflow");
    n += (size_t)wrote; at = nx_rt_borrow(ctx, at, 1);
  }
  require(nx_rt_id(ctx, at) == NX_RT_NIL && n + 2 <= cap, "wrong list terminator");
  out[n++] = ']'; out[n] = 0;
}
/* Generic Take2 probe: no source algorithm. */
#ifdef P110_AUDIT_IR
extern uint64_t nx_ir_probe_take2(NxRt *, uint64_t);
#endif
int main(int argc, char **argv) {
  require(argc == 3, "expected graph and field0-first/field1-first");
  const char *name = argv[1];
  int first_first = !strcmp(argv[2], "field0-first");
  require(first_first || !strcmp(argv[2], "field1-first"), "bad drop order");
  int list = !strncmp(name, "list-", 5), stat = strstr(name, "static") != NULL;
  int shared = strstr(name, "shared") != NULL;
  int sealed_static = !strcmp(name, "string-sealed-static");
  int last = strstr(name, "last-owner") != NULL;
  int dag = !strcmp(name, "list-dag-shared");
  int empty = !strcmp(name, "string-allocator-empty");
  int handoff = !strcmp(name, "string-allocator-handoff");
  int recognized = !strcmp(name, "list-raw") || !strcmp(name, "list-last-owner") ||
    !strcmp(name, "list-shared") || !strcmp(name, "list-static") ||
    !strcmp(name, "string-raw") || !strcmp(name, "string-last-owner") ||
    !strcmp(name, "string-shared") || !strcmp(name, "string-static") || sealed_static || dag || empty || handoff;
  require(recognized, "unknown take graph");
  NxRt *ctx = nx_rt_open(); Owner aliases[3]; uint32_t count = 0;
  uint64_t nil = nx_rt_zero(ctx, NX_RT_NIL), parent;
  if (dag) {
    uint64_t b = nx_rt_keep(ctx, str(ctx, "b", 0));
    uint64_t tail = nx_rt_build2(ctx, NX_RT_CON, b, nil);
    parent = nx_rt_build2(ctx, NX_RT_CON, b, tail);
    require(nx_rt_borrow(ctx, parent, 0) == nx_rt_borrow(ctx, nx_rt_borrow(ctx, parent, 1), 0), "DAG children do not overlap");
  } else parent = list ? (stat ? nx_rt_static2(ctx, NX_RT_CON, str(ctx, "b", 1), nil)
                               : nx_rt_build2(ctx, NX_RT_CON, str(ctx, "b", 0), nil)) : str(ctx, "ab", stat);
  if (sealed_static) {
    aliases[count++] = (Owner){parent, 0};
    uint64_t holder = nx_rt_build2(ctx, NX_RT_CON, parent, nil);
    nx_rt_take2(ctx, holder); parent = nx_rt_field(ctx, 0); nx_rt_sink(ctx, nx_rt_field(ctx, 1));
    require(parent >> 63, "static object did not acquire heap redirect");
  } else if (shared || stat) {
    parent = nx_rt_keep(ctx, parent); aliases[count++] = (Owner){parent, list};
  } else if (last || handoff) {
    parent = nx_rt_keep(ctx, parent); nx_rt_sink(ctx, parent);
    require(parent >> 63, "missing last-owner redirect");
  }
  uint64_t child = nx_rt_borrow(ctx, parent, list ? 0 : 1);
  uint64_t kept = nx_rt_keep(ctx, child); require(kept == child, "child was not sealed or static");
  aliases[count++] = (Owner){kept, 0};
  uint64_t *alc = (uint64_t *)(uintptr_t)nx_rt_ir_alc(ctx);
  uint64_t pads[32768]; uint32_t pad_count = 0;
  if (empty || handoff) {
    while (handoff ? pad_count < 16384 : alc[1] != 0) {
      require(pad_count < 32768, "class1 preparation exceeded bound");
      pads[pad_count++] = str(ctx, "q", 0);
    }
    if (handoff) while (alc[33] != 32766) {
      require(pad_count > 0, "class1 handoff boundary not reached");
      nx_rt_sink(ctx, pads[--pad_count]);
    }
    require(empty ? alc[1] == 0 && alc[33] == 0 : alc[1] != 0 && alc[33] == 32766, "class1 preparation mismatch");
  }
  NxRtPair pair;
#ifdef P110_AUDIT_IR
  pair.first = nx_ir_probe_take2(ctx, parent);
  require(nx_rt_pending(ctx) == 1, "take probe missing second owner");
  pair.second = nx_rt_fast_field(ctx, 0);
#else
  pair = nx_rt_pair_take2(ctx, parent);
#endif
  require(nx_rt_pending(ctx) == 0, "pending take fields");
  if (empty) require(alc[1] != 0 && alc[33] == 2, "empty class1 free did not push exactly one shell");
  if (handoff) require(alc[1] == 0 && alc[33] == 0 && alc[65] != 0, "class1 handoff missing");
  Owner first = {pair.first, list ? 0 : 2}, second = {pair.second, list ? 1 : 0};
  char first_text[128], second_text[128], survivor[128];
  observe(ctx, first, first_text, sizeof(first_text)); observe(ctx, second, second_text, sizeof(second_text));
  nx_rt_sink(ctx, first_first ? first.word : second.word);
  observe(ctx, first_first ? second : first, survivor, sizeof(survivor));
  require(!strcmp(survivor, first_first ? second_text : first_text), "survivor changed after sibling drop");
  nx_rt_sink(ctx, first_first ? second.word : first.word);
  printf("{\"name\":\"%s\",\"dropOrder\":\"%s\",\"first\":%s,\"second\":%s,\"survivor\":%s,\"aliases\":[", name, argv[2], first_text, second_text, survivor);
  for (uint32_t i = 0; i < count; ++i) {
    char value[128]; observe(ctx, aliases[i], value, sizeof(value)); printf("%s%s", i ? "," : "", value); nx_rt_sink(ctx, aliases[i].word);
  }
  while (pad_count) nx_rt_sink(ctx, pads[--pad_count]);
  require(nx_rt_live_words(ctx) == 0, "take leaked ownership"); nx_rt_close(ctx);
  puts("],\"released\":true}"); return 0;
}
