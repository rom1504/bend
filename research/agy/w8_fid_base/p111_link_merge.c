/* Wave 8 link-time segment table merge stub for separately-compiled `x86-module` `.o` files.
 *
 * Each module `m` compiled with `x86-module ... FID_BASE <m>` exports:
 *   - p111_mod_<m>_fid_base : uint64_t
 *   - p111_mod_<m>_program  : P111Program (ABI11102, 192 bytes; shifted main_fid + module tables)
 *
 * Define W8_MODULES(X) with the module list and W8_ENTRY_MOD with the entry module name, e.g.:
 *   gcc -O2 -c p111_link_merge.c -DW8_ENTRY_MOD=m1 \
 *       -DW8_MODULES='X(m0) X(m1)' -o merge.o
 *   gcc merge.o m0.o m1.o runtime-agy.o -o app -lm -lpthread
 */
#include <stdint.h>
#include <string.h>

typedef struct {
  uint64_t abi, size, segment_count, constructor_count, main_fid, main_pure;
  uint64_t reg_width, result_width, static_words, show_words, show_names_count, capabilities;
  void **segments;
  uint8_t *fid_arity, *fid_flags, *fid_results;
  uint8_t *cid_arity, *cid_hot;
  char **cid_names;
  uint64_t *static_image;
  uint32_t *show_desc;
  char **show_names;
  uint64_t effect_count;
  char **effects;
} P111Program;

extern int p111_rt_main(int argc, char **argv, const P111Program *prog);

#ifndef W8_MODULES
#define W8_MODULES(X) X(m0) X(m1)
#endif
#ifndef W8_ENTRY_MOD
#define W8_ENTRY_MOD m1
#endif

#define W8_DECL(M) \
  extern const P111Program p111_mod_##M##_program; \
  extern const uint64_t    p111_mod_##M##_fid_base;
W8_MODULES(W8_DECL)

/* Satisfies all RIP-relative `p111_program` loads across all linked module `.o` files. */
P111Program p111_program;

static void   *w8_merged_segments[65532];
static uint8_t w8_merged_fid_arity[65532];
static uint8_t w8_merged_fid_flags[65532];
static uint8_t w8_merged_fid_results[65532];

static void w8_unused_seg(void) {}

#define W8_ENTRY_PROG_2(M) (&p111_mod_##M##_program)
#define W8_ENTRY_PROG(M)   W8_ENTRY_PROG_2(M)

int main(int argc, char **argv) {
  const P111Program *mods[] = {
#define W8_PROG(M) &p111_mod_##M##_program,
    W8_MODULES(W8_PROG)
  };
  const uint64_t bases[] = {
#define W8_BASE(M) p111_mod_##M##_fid_base,
    W8_MODULES(W8_BASE)
  };
  const uint64_t nmods = (uint64_t)(sizeof(mods) / sizeof(mods[0]));
  p111_program = *mods[0]; /* inherit shared CID/show/effects/capabilities from root module */
  uint64_t total = 0;
  for (uint64_t i = 0; i < nmods; i++) {
    uint64_t b = bases[i], n = mods[i]->segment_count;
    if (b + n > 65532) return 2;
    if (b + n > total) total = b + n;
  }
  /* Fill reserved inter-module FID gaps with a valid non-NULL sentinel so modules
   * can grow/shrink within their reserved FID range without shifting downstream fid_base. */
  for (uint64_t j = 0; j < total; j++) {
    w8_merged_segments[j] = (void *)&w8_unused_seg;
    w8_merged_fid_arity[j] = 0;
    w8_merged_fid_flags[j] = 0;
    w8_merged_fid_results[j] = 0;
  }
  for (uint64_t i = 0; i < nmods; i++) {
    uint64_t b = bases[i], n = mods[i]->segment_count;
    memcpy(w8_merged_segments + b,    mods[i]->segments,    n * sizeof(void *));
    memcpy(w8_merged_fid_arity + b,   mods[i]->fid_arity,   n);
    memcpy(w8_merged_fid_flags + b,   mods[i]->fid_flags,   n);
    memcpy(w8_merged_fid_results + b, mods[i]->fid_results, n);
    if (mods[i]->reg_width > p111_program.reg_width) p111_program.reg_width = mods[i]->reg_width;
    if (mods[i]->result_width > p111_program.result_width) p111_program.result_width = mods[i]->result_width;
  }
  p111_program.segment_count = total;
  p111_program.main_fid      = W8_ENTRY_PROG(W8_ENTRY_MOD)->main_fid;
  p111_program.segments      = w8_merged_segments;
  p111_program.fid_arity     = w8_merged_fid_arity;
  p111_program.fid_flags     = w8_merged_fid_flags;
  p111_program.fid_results   = w8_merged_fid_results;
  return p111_rt_main(argc, argv, &p111_program);
}
