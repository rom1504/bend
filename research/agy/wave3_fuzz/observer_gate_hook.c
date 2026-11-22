/* Live-Metadata Observer Hook for Wave 2 Fast Paths.
 * Link with: -Wl,--wrap=p111_rt_main -Wl,--wrap=p125_rt_take1 -Wl,--wrap=p125_rt_take2
 *            -Wl,--wrap=p125_rt_take3 -Wl,--wrap=p125_rt_take4
 *
 * Env vars:
 *   OBS_MODE=normal   : unchanged descriptor
 *   OBS_MODE=cap-no8  : clears capability bit 3 (0x8) in p111_program before boot
 *   OBS_MODE=all-hot  : sets cid_hot[i]=1 for all constructors in p111_program before boot
 *   OBS_MODE=hot-name : sets cid_hot[i]=1 for constructor matching OBS_CTOR_NAME
 *
 * In non-normal modes, every p125_rt_take{1..4} on a heap constructor (tag 0x02 or 0x82)
 * whose cid is hot or when !(capabilities & 8) verifies that every heap-constructor child
 * (tag&0x7f == 2, loc >= HEAP_OFF) has the RFC seal bit (bit 63) set!
 */
#include "runtime.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int __real_p111_rt_main(int argc, char **argv, const P111Program *program);
#define DECL_WRAP(N) \
  extern uint64_t __real_p125_rt_take##N(P111State *, uint64_t, uint64_t *); \
  uint64_t __wrap_p125_rt_take##N(P111State *s, uint64_t term, uint64_t *out);
DECL_WRAP(1) DECL_WRAP(2) DECL_WRAP(3) DECL_WRAP(4)

static const P111Program *g_prog = NULL;
static int g_check_seal = 0;
static uint64_t g_heap_off = 0;
static unsigned long g_takes_checked = 0;
static unsigned long g_unsealed_violations = 0;
static uint32_t g_first_bad_parent_cid = 0;
static uint32_t g_first_bad_child_cid = 0;

static void check_take_children(uint64_t parent, uint64_t *out, uint32_t n) {
  if (!g_check_seal || !g_prog) return;
  uint64_t ptag = (parent >> 56) & 0x7fu;
  if (ptag != 2u) return;
  uint64_t ploc = parent & UINT64_C(0xffffffffff);
  /* Skip static image terms (already immutable in .rodata/static image) */
  if ((parent >> 63) == 0 && ploc < g_heap_off) return;
  uint32_t pcid = (uint32_t)((parent >> 40) & 0xffffu);
  if (pcid >= g_prog->constructor_count) return;
  int must_seal = (!(g_prog->capabilities & UINT64_C(8))) || (g_prog->cid_hot[pcid] != 0);
  if (!must_seal) return;
  g_takes_checked++;
  for (uint32_t i = 0; i < n; i++) {
    uint64_t child = out[i];
    uint64_t ctag = (child >> 56) & 0x7fu;
    if (ctag == 2u) {
      uint64_t cloc = child & UINT64_C(0xffffffffff);
      /* Heap constructor child MUST be sealed (bit 63 == 1) when parent is hot/cap-no8! */
      if ((child >> 63) == 0 && cloc >= g_heap_off) {
        if (g_unsealed_violations == 0) {
          g_first_bad_parent_cid = pcid;
          g_first_bad_child_cid = (uint32_t)((child >> 40) & 0xffffu);
        }
        g_unsealed_violations++;
      }
    }
  }
}

#define DEF_WRAP(N) \
  uint64_t __wrap_p125_rt_take##N(P111State *s, uint64_t term, uint64_t *out) { \
    uint64_t r = __real_p125_rt_take##N(s, term, out); \
    if (r == N) check_take_children(term, out, N); \
    return r; \
  }
DEF_WRAP(1) DEF_WRAP(2) DEF_WRAP(3) DEF_WRAP(4)

static void report_at_exit(void) {
  if (g_unsealed_violations > 0) {
    const char *pname = (g_prog && g_first_bad_parent_cid < g_prog->constructor_count)
      ? g_prog->cid_names[g_first_bad_parent_cid] : "?";
    const char *cname = (g_prog && g_first_bad_child_cid < g_prog->constructor_count)
      ? g_prog->cid_names[g_first_bad_child_cid] : "?";
    fprintf(stderr, "OBSERVER_VIOLATION: %lu unsealed heap child(ren) in hot/cap-no8 parent (first: parent=%s[%u] child=%s[%u], checked=%lu)\n",
            g_unsealed_violations, pname, g_first_bad_parent_cid, cname, g_first_bad_child_cid, g_takes_checked);
  }
}

int __wrap_p111_rt_main(int argc, char **argv, const P111Program *program) {
  P111Program *mut = (P111Program *)program;
  g_prog = program;
  g_heap_off = ((program->static_words + 127u) & ~UINT64_C(127)) + UINT64_C(51413504);
  const char *mode = getenv("OBS_MODE");
  if (mode && strcmp(mode, "cap-no8") == 0) {
    mut->capabilities &= ~UINT64_C(8);
    g_check_seal = 1;
  } else if (mode && strcmp(mode, "all-hot") == 0) {
    uint8_t *hot = (uint8_t *)mut->cid_hot;
    for (uint64_t i = 0; i < mut->constructor_count; i++) {
      hot[i] = 1;
    }
    g_check_seal = 1;
  } else if (mode && strcmp(mode, "hot-name") == 0) {
    const char *target = getenv("OBS_CTOR_NAME");
    uint8_t *hot = (uint8_t *)mut->cid_hot;
    for (uint64_t i = 0; i < mut->constructor_count; i++) {
      if (target && mut->cid_names[i] && strcmp(mut->cid_names[i], target) == 0) {
        hot[i] = 1;
      }
    }
    g_check_seal = 1;
  }
  atexit(report_at_exit);
  return __real_p111_rt_main(argc, argv, program);
}
