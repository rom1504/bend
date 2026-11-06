/* Diagnostic only: link --wrap=p118_rt_borrow_scalar_safe with the unchanged
 * program object/runtime. The actual guard receives identical arguments and
 * its result is returned unchanged. No Bend heap reads/writes occur here.
 * Addresses refer to this diagnostic binary, never to the clean timed binary.
 */
#include <inttypes.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

enum { SLOTS = 1024 };
typedef struct {
  _Atomic uintptr_t address;
  _Atomic uint64_t calls, passed, unexpected;
} Site;
static Site sites[SLOTS];
static _Atomic uint64_t unrecorded;

extern uint64_t __real_p118_rt_borrow_scalar_safe(void *, uint64_t,
                                                uint64_t, uint32_t);

__attribute__((noinline))
uint64_t __wrap_p118_rt_borrow_scalar_safe(void *state, uint64_t first,
                                         uint64_t second, uint32_t count) {
  uintptr_t address = (uintptr_t)__builtin_extract_return_addr(
      __builtin_return_address(0));
  uint64_t result = __real_p118_rt_borrow_scalar_safe(state, first, second, count);
  size_t at = (address >> 3) & (SLOTS - 1);
  for (size_t tries = 0; tries < SLOTS; ++tries, at = (at + 1) & (SLOTS - 1)) {
    uintptr_t key = atomic_load_explicit(&sites[at].address, memory_order_relaxed);
    if (key == 0) {
      uintptr_t empty = 0;
      atomic_compare_exchange_strong_explicit(&sites[at].address, &empty,
          address, memory_order_relaxed, memory_order_relaxed);
      key = atomic_load_explicit(&sites[at].address, memory_order_relaxed);
    }
    if (key == address) {
      atomic_fetch_add_explicit(&sites[at].calls, 1, memory_order_relaxed);
      atomic_fetch_add_explicit(&sites[at].passed, result == 1, memory_order_relaxed);
      atomic_fetch_add_explicit(&sites[at].unexpected, result > 1, memory_order_relaxed);
      return result;
    }
  }
  atomic_fetch_add_explicit(&unrecorded, 1, memory_order_relaxed);
  return result;
}

__attribute__((destructor))
static void report(void) {
  const char *path = getenv("P171_GUARD_REPORT");
  FILE *out = path ? fopen(path, "wx") : NULL;
  if (!out) {
    fputs("P171 guard diagnostic: missing or nonfresh sidecar path\n", stderr);
    return;
  }
  fprintf(out, "{\"kind\":\"phase171-guard-calls\",\"unrecorded\":%" PRIu64
      ",\"sites\":[", atomic_load(&unrecorded));
  int separator = 0;
  for (size_t i = 0; i < SLOTS; ++i) {
    uintptr_t address = atomic_load(&sites[i].address);
    if (!address) continue;
    fprintf(out, "%s{\"returnAddress\":\"0x%" PRIxPTR
        "\",\"calls\":%" PRIu64 ",\"passed\":%" PRIu64
        ",\"unexpected\":%" PRIu64 "}", separator++ ? "," : "",
        address, atomic_load(&sites[i].calls), atomic_load(&sites[i].passed),
        atomic_load(&sites[i].unexpected));
  }
  fputs("]}\n", out);
  if (fclose(out)) fputs("P171 guard diagnostic: sidecar close failed\n", stderr);
}
