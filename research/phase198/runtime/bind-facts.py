"""Create isolated runtime variants from the authenticated Phase182 source."""
from pathlib import Path


def replace_once(text, before, after):
    assert text.count(before) == 1, before
    return text.replace(before, after)


def variant(text, mode):
    if mode == 'original':
        return text
    assert mode in ('facts', 'split')
    # Programs and their metadata are immutable for the entire bound process.
    # x86 and QBE expose exactly the same runtime ABI. No runtime field moves.
    globals_ = """static uint64_t p198_heap_base;
static uint16_t p198_ctor_info[65536];
#define P198_NO_SEAL 512u
#define HEAP_OFF p198_heap_base"""
    text = replace_once(text, '#define HEAP_OFF (STAT_OFF + PAGE_UP(STAT_LEN))', globals_)
    text = replace_once(text, '  p111_program_active = program;', '''
  p198_heap_base = STAT_OFF + PAGE_UP(program->static_words);
  for (u32 i = 0; i < program->constructor_count; ++i) {
    p198_ctor_info[i] = (uint16_t)(1u + program->cid_arity[i]
      + (((program->capabilities & 8u) && !program->cid_hot[i]) ? P198_NO_SEAL : 0u));
  }
  p111_program_active = program;''')
    before, body = text.split('#define P125_VERIFIED(N)', 1)
    body, after = body.split('P125_VERIFIED(1)', 1)
    body = replace_once(body, 'cid < p111_program_active->constructor_count && N == cid_arity(cid)', '(p198_ctor_info[cid] & 511u) == (N + 1u)')
    body = replace_once(body, '(p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)', 'cid < 65536u && (p198_ctor_info[cid] & P198_NO_SEAL)')
    if mode == 'split':
        # Keep the original slow paths and all sharing/packing and metadata errors.
        # In the raw case fields are read and published in original order.
        body = body.replace('uint64_t p125_rt_ctor##N(', 'static __attribute__((noinline)) uint64_t p198_slow_ctor##N(')
        body = body.replace('uint64_t p125_rt_take##N(', 'static __attribute__((noinline)) uint64_t p198_slow_take##N(')
        add = """
uint64_t p125_rt_ctor##N(P111State *s, uint32_t cid, const uint64_t *fields) {
  Env e = s->e;
  Cls cls = cls_fit(N);
  if (cid < 65536u && (p198_ctor_info[cid] & P198_NO_SEAL) && ALC_AT(e, cls)) {
    Loc at = heap_alloc(e, cls);
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = fields[i];
    return term_ctr(cid, at);
  }
  return p198_slow_ctor##N(s, cid, fields);
}
uint64_t p125_rt_take##N(P111State *s, uint64_t term, uint64_t *out) {
  u32 cid = (u32)term_aux(term);
  if ((term >> 56) == TAG_CTR && (p198_ctor_info[cid] & 511u) == N + 1u) {
    Env e = s->e;
    Loc at = term_loc(term);
    for (u32 i = 0; i < N; ++i) out[i] = e.mem[at + i];
    spare_free(e, cls_fit(N), at);
    return N;
  }
  return p198_slow_take##N(s, term, out);
}"""
        body = body.rstrip() + ' ' + chr(92) + '\n' + (' ' + chr(92) + '\n').join(add.strip().splitlines()) + '\n'
    return before + '#define P125_VERIFIED(N)' + body + 'P125_VERIFIED(1)' + after
