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
#define SPARE_LOC_MASK ((UINT64_C(1) << 40) - 1)
static Graph spare_graph(NxRt *ctx, const char *name) {
  Graph g = {0}; g.cid = NX_RT_SCON;
  int shared_parent = !strcmp(name, "shared-parent-raw-other");
  int rfc_one = !strcmp(name, "rfc-other-one");
  int rfc_shared = !strcmp(name, "rfc-other-shared");
  int static_other = !strcmp(name, "raw-static-other") || !strcmp(name, "handoff-raw-static-other");
  int known = shared_parent || rfc_one || rfc_shared || static_other ||
    !strcmp(name, "raw-dynamic-other") || !strcmp(name, "handoff-raw-dynamic-other");
  require(known, "unknown wrapper-spare graph");
  g.parent = nx_rt_keep(ctx, str(ctx, "ab", 0));
  if (shared_parent) g.aliases[g.alias_count++] = (Owner){g.parent, 0};
  else nx_rt_sink(ctx, g.parent); /* exactly one parent redirect owner */
  g.aliases[g.alias_count++] = (Owner){nx_rt_keep(ctx, nx_rt_borrow(ctx, g.parent, 1)), 0};
  g.other = str(ctx, "z", static_other);
  if (rfc_one || rfc_shared) {
    g.other = nx_rt_keep(ctx, g.other);
    if (rfc_one) nx_rt_sink(ctx, g.other);
    else g.aliases[g.alias_count++] = (Owner){g.other, 0};
  }
  require(g.parent >> 63, "parent is not a redirect");
  require((g.other >> 63) == (uint64_t)(rfc_one || rfc_shared), "wrong other representation");
  return g;
}
static NxRtPair spare_rebuild(NxRt *ctx, Graph g) {
#ifdef P110_AUDIT_IR
  uint64_t built = nx_ir_probe_c3_k0(ctx, g.parent, g.other);
  require(nx_rt_pending(ctx) == 1, "IR probe did not transfer remaining child");
  NxRtPair pair = {built, nx_rt_fast_field(ctx, 0)}; return pair;
#else
  return nx_rt_pair_rebuild2_c3_k0(ctx, g.parent, g.other);
#endif
}
int main(int argc, char **argv) {
  require(argc == 3, "expected graph and result-first/remaining-first");
  const char *name = argv[1]; int result_first = !strcmp(argv[2], "result-first");
  require(result_first || !strcmp(argv[2], "remaining-first"), "invalid drop order");
  NxRt *ctx = nx_rt_open(); Graph g = spare_graph(ctx, name);
  uint64_t *alc = (uint64_t *)(uintptr_t)nx_rt_ir_alc(ctx);
  uint64_t pads[65536]; uint32_t pad_count = 0;
  int handoff = !strncmp(name, "handoff-", 8);
  if (handoff) {
    while (pad_count < 32768) {
      pads[pad_count] = nx_rt_keep(ctx, str(ctx, "q", 0));
      nx_rt_sink(ctx, pads[pad_count++]);
    }
    while (alc[32] != 32767) {
      require(pad_count > 0, "could not reach class0 handoff boundary");
      nx_rt_sink(ctx, pads[--pad_count]);
    }
    require(alc[0] && alc[32] == 32767, "wrong handoff precondition");
  }
  uint64_t wrapper = g.parent & SPARE_LOC_MASK;
  uint64_t parent_cell = nx_rt_ir_view(ctx, wrapper);
  uint64_t old_hot = alc[0], old_len = alc[32], old_cold = alc[64];
  int shared_parent = !strcmp(name, "shared-parent-raw-other");
  int raw_other = !(g.other >> 63);
  require((parent_cell & UINT64_C(16777215)) == (uint64_t)(shared_parent ? 2 : 1), "wrong parent count");
  require((parent_cell >> 24) >= UINT64_C(51413376), "parent target is not dynamic");
  NxRtPair pair = spare_rebuild(ctx, g);
  require(nx_rt_pending(ctx) == 0, "pending children after reconstruction");
#ifdef P110_AUDIT_SPARE
  uint64_t stored_other = nx_rt_borrow(ctx, pair.first, 1);
  if (!shared_parent && raw_other) {
    require((stored_other >> 63) && (stored_other & SPARE_LOC_MASK) == wrapper, "consumed wrapper was not transferred to other");
    uint64_t cell = nx_rt_ir_view(ctx, wrapper);
    require((cell & UINT64_C(16777215)) == 1 && (cell >> 24) == (g.other & SPARE_LOC_MASK), "spare wrapper did not encode exactly one other owner");
    require(alc[0] == old_hot && alc[32] == old_len && alc[64] == old_cold, "eligible spare changed class0 allocator state");
  } else if (shared_parent) {
    require((stored_other & SPARE_LOC_MASK) != wrapper, "shared parent wrapper was repurposed");
    uint64_t cell = nx_rt_ir_view(ctx, wrapper);
    require((cell & UINT64_C(16777215)) == 1 && (cell >> 24) == (parent_cell >> 24), "shared parent alias target/count changed");
  } else {
    require(stored_other == g.other, "existing other redirect was changed");
    if (old_len < 32767) require(alc[0] == wrapper && alc[32] == old_len + 1, "ineligible other did not free parent wrapper normally");
    else require(alc[0] == 0 && alc[32] == 0 && alc[64], "ineligible other missed normal handoff");
  }
#endif
  Owner result = {pair.first, 0}, remaining = {pair.second, 0};
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
