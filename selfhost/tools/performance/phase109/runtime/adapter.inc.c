/* Appended to authenticated, unmodified production core function slices.
 * This file adapts the C ABI; it contains no Bend worker algorithm. */
#include "abi.h"

struct NxRt {
  Env env;
  Term fields[2];
  u32 pending;
  u32 static_words;
};
static NxRt nx_context;
static bool nx_active;

static void nx_require(bool ok, const char *message) {
  if (!ok) err_fail(message);
}
static Env nx_env(NxRt *ctx) {
  nx_require(nx_active && ctx == &nx_context, "nx ABI: invalid context");
  return ctx->env;
}
static u32 nx_id(Env e, Term term) {
  u64 tag = term_tag(term), cid = term_aux(term);
  nx_require(cid < 4, "nx ABI: constructor ID outside descriptor");
  nx_require((cid_arity(cid) == 0 && tag == TAG_PAK && term_loc(term) == 0
      && !term_rfc(term)) || (cid_arity(cid) == 2 && tag == TAG_CTR),
    "nx ABI: constructor representation mismatch");
  if (tag == TAG_CTR) {
    Loc loc = term_peek(e, term);
    nx_require(loc >= STAT_OFF && loc + 1 < HEAP_OFF +
      ((u64)a32_load(a32_at(e.mem, H_BUMP)) << PAGE_BITS),
      "nx ABI: constructor location outside arena");
  }
  return (u32)cid;
}

NxRt *nx_rt_open(void) {
  nx_require(!nx_active, "nx ABI: only one live context admitted");
  memset(&nx_context, 0, sizeof(nx_context));
  memset(ALC, 0, sizeof(ALC));
  KEEP_WORDS = CAP_WORDS;
  bank_lock = 0;
  io_gpu = false;
  CORPUS = corpus_map(1ull << 30);
  corpus_lay(CORPUS, 1ull << 30);
  a32_store(a32_at(CORPUS, H_BUMP), 1);
  nx_context.env = (Env){CORPUS, ALC[0]};
  nx_active = true;
  return &nx_context;
}
uint32_t nx_rt_id(NxRt *ctx, uint64_t term) {
  return nx_id(nx_env(ctx), term);
}
uint64_t nx_rt_fail(NxRt *ctx, uint32_t reason) {
  (void)nx_env(ctx);
  (void)reason;
  err_fail("nx ABI: impossible source branch");
  return 0; /* C ABI has a machine result; err_fail never returns. */
}
uint64_t nx_rt_keep(NxRt *ctx, uint64_t term) {
  Env e = nx_env(ctx);
  if (term_tag(term) == 0) {
    nx_require(term <= 0x10ffff && !(term >= 0xd800 && term <= 0xdfff),
      "nx ABI: invalid immediate Char");
  } else {
    (void)nx_id(e, term);
  }
  return term_keep(e, term);
}
uint32_t nx_rt_sink(NxRt *ctx, uint64_t term) {
  Env e = nx_env(ctx);
  if (term_tag(term) == 0) {
    nx_require(term <= 0x10ffff && !(term >= 0xd800 && term <= 0xdfff),
      "nx ABI: invalid immediate Char");
  } else {
    (void)nx_id(e, term);
  }
  term_sink(e, term);
  return 0;
}
uint64_t nx_rt_zero(NxRt *ctx, uint32_t cid) {
  (void)nx_env(ctx);
  nx_require(cid == NX_RT_NIL || cid == NX_RT_SNIL,
    "nx ABI: zero constructor arity mismatch");
  return term_pak(cid, 0);
}
static void nx_fields(Env e, u32 cid, Term head, Term tail) {
  nx_require(cid == NX_RT_CON || cid == NX_RT_SCON,
    "nx ABI: binary constructor arity mismatch");
  u32 tail_id = nx_id(e, tail);
  nx_require(tail_id == cid || tail_id + 1 == cid,
    "nx ABI: constructor tail type mismatch");
  if (cid == NX_RT_CON) {
    u32 head_id = nx_id(e, head);
    nx_require(head_id == NX_RT_SNIL || head_id == NX_RT_SCON,
      "nx ABI: List head must be String");
  } else {
    nx_require(head <= 0x10ffff && !(head >= 0xd800 && head <= 0xdfff),
      "nx ABI: Char must be a Unicode scalar");
  }
}
static Term nx_construct2(Env e, u32 cid, Term head, Term tail, Loc loc) {
  e.mem[loc] = rfc_seal(e, head);
  e.mem[loc + 1] = rfc_seal(e, tail);
  return term_ctr(cid, loc);
}
uint64_t nx_rt_build2(NxRt *ctx, uint32_t cid, uint64_t head, uint64_t tail) {
  Env e = nx_env(ctx);
  nx_fields(e, cid, head, tail);
  return nx_construct2(e, cid, head, tail, heap_alloc(e, cls_fit(2)));
}
static void nx_take2(NxRt *ctx, Term term) {
  Env e = ctx->env;
  Loc spare = ctr_take(e, term, 2, ctx->fields);
  spare_free(e, cls_fit(2), spare);
  ctx->pending = 3;
}
uint32_t nx_rt_take2(NxRt *ctx, uint64_t term) {
  Env e = nx_env(ctx);
  nx_require(ctx->pending == 0, "nx ABI: untransferred scratch children");
  u32 cid = nx_id(e, term);
  nx_require(cid == NX_RT_CON || cid == NX_RT_SCON,
    "nx ABI: take requires binary constructor");
  nx_take2(ctx, term);
  return 0;
}
static Term nx_field(NxRt *ctx, u32 index) {
  ctx->pending &= ~(1u << index);
  Term result = ctx->fields[index];
  ctx->fields[index] = TERM_HOLE;
  return result;
}
uint64_t nx_rt_field(NxRt *ctx, uint32_t index) {
  (void)nx_env(ctx);
  nx_require(index < 2 && (ctx->pending & (1u << index)),
    "nx ABI: invalid or repeated scratch transfer");
  return nx_field(ctx, index);
}

/* Trusted operations use the exact same allocator/refcount primitives. The
 * structured checker, typed source and entry harness establish their preconditions;
 * public checked operations above remain available for boundary validation. */
uint32_t nx_rt_fast_id(NxRt *ctx, uint64_t term) {
  (void)ctx;
  return (u32)term_aux(term);
}
uint64_t nx_rt_fast_keep(NxRt *ctx, uint64_t term) {
  return term_keep(ctx->env, term);
}
uint32_t nx_rt_fast_sink(NxRt *ctx, uint64_t term) {
  term_sink(ctx->env, term);
  return 0;
}
uint64_t nx_rt_fast_zero(NxRt *ctx, uint32_t cid) {
  (void)ctx;
  return term_pak(cid, 0);
}
uint64_t nx_rt_fast_build2(NxRt *ctx, uint32_t cid, uint64_t head, uint64_t tail) {
  Env e = ctx->env;
  return nx_construct2(e, cid, head, tail, heap_alloc(e, cls_fit(2)));
}
uint32_t nx_rt_fast_take2(NxRt *ctx, uint64_t term) {
  nx_take2(ctx, term);
  return 0;
}
uint64_t nx_rt_fast_field(NxRt *ctx, uint32_t index) {
  return nx_field(ctx, index);
}
uint64_t nx_rt_rebuild2(NxRt *ctx, uint64_t parent, uint32_t cid,
                      uint32_t keep_index, uint64_t other) {
  Env e = ctx->env;
  Term old[2];
  Loc spare = ctr_take(e, parent, 2, old);
  /* A nonzero spare can be immortal static storage: never overwrite it. */
  Loc loc = spare >= HEAP_OFF ? spare : heap_alloc(e, cls_fit(2));
  ctx->fields[0] = old[1u - keep_index];
  ctx->fields[1] = TERM_HOLE;
  ctx->pending = 1;
  return nx_construct2(e, cid, old[keep_index], other, loc);
}
uint64_t nx_rt_borrow(NxRt *ctx, uint64_t term, uint32_t index) {
  Env e = nx_env(ctx);
  nx_require(index < 2 && cid_arity(nx_id(e, term)) == 2,
    "nx ABI: invalid borrowed field");
  return e.mem[term_peek(e, term) + index];
}
uint64_t nx_rt_static2(NxRt *ctx, uint32_t cid, uint64_t head, uint64_t tail) {
  Env e = nx_env(ctx);
  nx_fields(e, cid, head, tail);
  nx_require(term_triv(head) && term_triv(tail),
    "nx ABI: static constructor contains heap child");
  nx_require(ctx->static_words + 2 <= STAT_LEN,
    "nx ABI: fixed static arena exhausted");
  Loc loc = STAT_OFF + ctx->static_words;
  ctx->static_words += 2;
  e.mem[loc] = head;
  e.mem[loc + 1] = tail;
  return term_ctr(cid, loc);
}
uint64_t nx_rt_bump_words(NxRt *ctx) {
  Env e = nx_env(ctx);
  return ((u64)a32_load(a32_at(e.mem, H_BUMP)) - 1) << PAGE_BITS;
}
static u64 nx_chain(Env e, Loc at, Cls cls, u64 bound) {
  u64 count = 0;
  while (at) {
    nx_require(at >= HEAP_OFF && at < HEAP_OFF + bound + PAGE_LEN,
      "nx ABI: free-list address outside heap");
    nx_require(count < bound, "nx ABI: free-list cycle");
    count += 1ull << cls;
    at = e.mem[at];
  }
  return count;
}
uint64_t nx_rt_live_words(NxRt *ctx) {
  Env e = nx_env(ctx);
  u64 allocated = nx_rt_bump_words(ctx), free_words = 0;
  for (Cls cls = 0; cls < NCLS_ALL; ++cls) {
    u64 hot = nx_chain(e, ALC_AT(e, cls), cls, allocated);
    nx_require(hot == ALC_LEN(e, cls), "nx ABI: allocator length mismatch");
    free_words += hot;
    free_words += nx_chain(e, ALC_COLD(e, cls), cls, allocated);
    Bank *bank = bank_at(e.mem, cls);
    nx_require(bank->rd == bank->wr && bank->wr == bank->top,
      "nx ABI: host bank indices mismatch");
    for (u32 i = 0; i < bank->rd; ++i)
      free_words += nx_chain(e, e.mem[bank->off + i], cls, allocated);
  }
  nx_require(free_words <= allocated, "nx ABI: over-released heap");
  return allocated - free_words;
}
uint32_t nx_rt_pending(NxRt *ctx) {
  (void)nx_env(ctx);
  return ctx->pending;
}
void nx_rt_close(NxRt *ctx) {
  (void)nx_env(ctx);
  nx_require(ctx->pending == 0, "nx ABI: unreleased scratch children");
  nx_require(nx_rt_live_words(ctx) == 0, "nx ABI: unreleased heap ownership");
  nx_require(munmap(CORPUS, corpus_size) == 0, "nx ABI: arena unmap failed");
  CORPUS = NULL;
  nx_active = false;
}
