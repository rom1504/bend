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
static Graph make_graph(NxRt *ctx, const char *name) {
  uint64_t nil = nx_rt_zero(ctx, NX_RT_NIL);
  Graph g = {0}; g.cid = NX_RT_SCON;
  if (!strcmp(name, "remaining-is-other")) {
    uint64_t b = nx_rt_keep(ctx, str(ctx, "b", 0)); /* two owned claims */
    g.parent = nx_rt_build2(ctx, NX_RT_SCON, 'a', b); g.other = b;
    require(nx_rt_borrow(ctx, g.parent, 1) == g.other, "remaining/other are not physically aliased");
    g.aliases[g.alias_count++] = (Owner){nx_rt_keep(ctx, b), 0};
  } else if (!strcmp(name, "retained-in-other") || !strcmp(name, "cross-layout-overlap")) {
    uint64_t b = nx_rt_keep(ctx, str(ctx, "b", 0));
    g.keep = !strcmp(name, "cross-layout-overlap"); g.cid = NX_RT_CON;
    g.parent = g.keep ? nx_rt_build2(ctx, NX_RT_SCON, 'a', b)
                      : nx_rt_build2(ctx, NX_RT_CON, b, nil);
    g.other = nx_rt_build2(ctx, NX_RT_CON, b, nil);
    require(nx_rt_borrow(ctx, g.parent, g.keep) == nx_rt_borrow(ctx, g.other, 0),
      "retained/other-head are not physically aliased");
    g.parent = nx_rt_keep(ctx, g.parent);
    g.aliases[g.alias_count++] = (Owner){g.parent, !g.keep};
    g.aliases[g.alias_count++] = (Owner){nx_rt_keep(ctx, b), 0};
  } else if (!strcmp(name, "sealed-static-parent")) {
    uint64_t stat = str(ctx, "ab", 1);
    g.aliases[g.alias_count++] = (Owner){stat, 0};
    uint64_t holder = nx_rt_build2(ctx, NX_RT_CON, stat, nil);
    nx_rt_take2(ctx, holder);
    g.parent = nx_rt_field(ctx, 0); nx_rt_sink(ctx, nx_rt_field(ctx, 1));
    require(g.parent >> 63, "static constructor was not sealed by dynamic holder");
    g.other = str(ctx, "z", 0);
  } else if (!strcmp(name, "last-owner-redirect") || !strcmp(name, "allocator-empty") || !strcmp(name, "allocator-handoff")) {
    g.parent = str(ctx, "ab", 0);
    if (strcmp(name, "allocator-empty")) {
      g.parent = nx_rt_keep(ctx, g.parent); nx_rt_sink(ctx, g.parent);
      require(g.parent >> 63, "expected a last-owner redirect");
    }
    g.other = !strcmp(name, "allocator-handoff") ? nx_rt_zero(ctx, NX_RT_SNIL) : str(ctx, "z", 0);
    g.aliases[g.alias_count++] = (Owner){nx_rt_keep(ctx, nx_rt_borrow(ctx, g.parent, 1)), 0};
  } else { require(0, "unknown graph"); }
  return g;
}
static NxRtPair rebuild(NxRt *ctx, Graph g) {
#ifdef P110_AUDIT_IR
  uint64_t built = g.cid == NX_RT_SCON ? nx_ir_probe_c3_k0(ctx, g.parent, g.other)
    : g.keep ? nx_ir_probe_c1_k1(ctx, g.parent, g.other)
             : nx_ir_probe_c1_k0(ctx, g.parent, g.other);
  require(nx_rt_pending(ctx) == 1, "IR probe did not transfer remaining child");
  NxRtPair out = {built, nx_rt_fast_field(ctx, 0)}; return out;
#else
  return g.cid == NX_RT_SCON ? nx_rt_pair_rebuild2_c3_k0(ctx, g.parent, g.other)
    : g.keep ? nx_rt_pair_rebuild2_c1_k1(ctx, g.parent, g.other)
             : nx_rt_pair_rebuild2_c1_k0(ctx, g.parent, g.other);
#endif
}
int main(int argc, char **argv) {
  require(argc == 3, "expected graph and result-first/remaining-first");
  const char *name = argv[1]; int result_first = !strcmp(argv[2], "result-first");
  require(result_first || !strcmp(argv[2], "remaining-first"), "invalid drop order");
  NxRt *ctx = nx_rt_open(); Graph g = make_graph(ctx, name);
  uint64_t *alc = (uint64_t *)(uintptr_t)nx_rt_ir_alc(ctx);
  uint64_t pads[65536]; uint32_t pad_count = 0;
  int empty = !strcmp(name, "allocator-empty"), handoff = !strcmp(name, "allocator-handoff");
  if (empty || handoff) {
    while (handoff ? pad_count < 32768 : alc[0] != 0) {
      require(pad_count < 65536, "allocator preparation exceeded bound");
      pads[pad_count] = nx_rt_keep(ctx, str(ctx, "q", 0));
      nx_rt_sink(ctx, pads[pad_count++]); /* retain exactly one redirect owner */
    }
    if (handoff) while (alc[32] != 32767) {
      require(pad_count > 0, "could not reach class0 handoff boundary");
      nx_rt_sink(ctx, pads[--pad_count]);
    }
    require(empty ? alc[0] == 0 && alc[32] == 0 : alc[0] != 0 && alc[32] == 32767,
      "allocator precondition differs");
  }
  NxRtPair pair = rebuild(ctx, g);
  require(nx_rt_pending(ctx) == 0, "pending children after reconstruction");
  if (handoff) require(alc[0] == 0 && alc[32] == 0 && alc[64] != 0, "missed exact class0 handoff");
  if (empty) require(alc[0] != 0 && alc[32] > 0, "empty hot-list allocation failed to refill");
  Owner result = {pair.first, g.cid == NX_RT_CON};
  Owner remaining = {pair.second, g.cid == NX_RT_CON ? (g.keep ? 2 : 1) : 0};
  char result_text[128], remaining_text[128], survivor[128];
  observe(ctx, result, result_text, sizeof(result_text));
  observe(ctx, remaining, remaining_text, sizeof(remaining_text));
  nx_rt_sink(ctx, result_first ? result.word : remaining.word);
  observe(ctx, result_first ? remaining : result, survivor, sizeof(survivor));
  require(!strcmp(survivor, result_first ? remaining_text : result_text), "survivor changed after first owner drop");
  nx_rt_sink(ctx, result_first ? remaining.word : result.word);
  printf("{\"name\":\"%s\",\"dropOrder\":\"%s\",\"result\":%s,\"remaining\":%s,\"survivor\":%s,\"aliases\":[", name, argv[2], result_text, remaining_text, survivor);
  for (uint32_t i = 0; i < g.alias_count; ++i) {
    char value[128]; observe(ctx, g.aliases[i], value, sizeof(value));
    printf("%s%s", i ? "," : "", value); nx_rt_sink(ctx, g.aliases[i].word);
  }
  while (pad_count) nx_rt_sink(ctx, pads[--pad_count]);
  require(nx_rt_live_words(ctx) == 0, "unreleased ownership");
  nx_rt_close(ctx); puts("],\"released\":true}"); return 0;
}
