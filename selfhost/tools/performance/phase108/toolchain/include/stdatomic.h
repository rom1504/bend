#ifndef BEND_PHASE108_STDATOMIC_H
#define BEND_PHASE108_STDATOMIC_H

/* Narrow adapter for the generated Bend host runtime, not a general C11
 * stdatomic implementation. Atomic storage has its x86-64 natural size and
 * alignment; every access crosses an out-of-line, GCC-compiled atomic shim. */
#include <stdint.h>
#define _Atomic

typedef enum {
  memory_order_relaxed = 0,
  memory_order_consume = 1,
  memory_order_acquire = 2,
  memory_order_release = 3,
  memory_order_acq_rel = 4,
  memory_order_seq_cst = 5
} memory_order;

uint32_t bend_qbe_atomic32_load(const uint32_t *, int);
uint64_t bend_qbe_atomic64_load(const uint64_t *, int);
void bend_qbe_atomic32_store(uint32_t *, uint32_t, int);
void bend_qbe_atomic64_store(uint64_t *, uint64_t, int);
uint32_t bend_qbe_atomic32_add(uint32_t *, uint32_t, int);
uint64_t bend_qbe_atomic64_add(uint64_t *, uint64_t, int);

#define BEND_QBE_ATOMIC_FN(p, op) _Generic(*(p), \
  uint32_t: bend_qbe_atomic32_##op, uint64_t: bend_qbe_atomic64_##op)
#define atomic_load_explicit(p, order) BEND_QBE_ATOMIC_FN(p, load)(p, order)
#define atomic_store_explicit(p, v, order) BEND_QBE_ATOMIC_FN(p, store)(p, v, order)
#define atomic_fetch_add_explicit(p, v, order) BEND_QBE_ATOMIC_FN(p, add)(p, v, order)

#endif
