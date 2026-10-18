#define _GNU_SOURCE
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sched.h>
#include <stdatomic.h>
#include <unistd.h>
#include <signal.h>
#include <sys/mman.h>
#include <time.h>
#include <poll.h>

static _Atomic uint32_t count;
static _Atomic uint64_t tick;
static unsigned initialized;
static void __attribute__((constructor)) initialize(void) { initialized = 17; }
static _Alignas(128) unsigned char aligned_byte;

typedef struct { uint64_t x; uint32_t y; } Pair;
static Pair pair_make(uint64_t x, uint32_t y) { return (Pair){x, y}; }
static uint64_t pair_sum(Pair p) { return p.x + p.y; }

static void *worker(void *arg) {
  (void)arg;
  for (unsigned i = 0; i < 10000; ++i) {
    atomic_fetch_add_explicit(&count, 1, memory_order_relaxed);
    atomic_fetch_add_explicit(&tick, 1, memory_order_release);
  }
  return NULL;
}

int main(void) {
  pthread_t workers[2];
  atomic_store_explicit(&count, 0, memory_order_relaxed);
  atomic_store_explicit(&tick, 0, memory_order_relaxed);
  if (pthread_create(&workers[0], NULL, worker, NULL) ||
      pthread_create(&workers[1], NULL, worker, NULL)) return 1;
  pthread_join(workers[0], NULL);
  pthread_join(workers[1], NULL);
  if (atomic_load_explicit(&count, memory_order_acquire) != 20000 ||
      atomic_load_explicit(&tick, memory_order_acquire) != 20000) return 2;
  uint32_t word = 5, expected = 5;
  if (!__atomic_compare_exchange_n(&word, &expected, 9, false,
      __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE) || word != 9) return 3;
  expected = 5;
  if (__atomic_compare_exchange_n(&word, &expected, 10, false,
      __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE) || expected != 9) return 4;
  if (__atomic_exchange_n(&word, 12, __ATOMIC_ACQUIRE) != 9) return 5;
  if (__atomic_fetch_sub(&word, 2, __ATOMIC_RELEASE) != 12) return 6;
  __atomic_store_n(&word, 7, __ATOMIC_RELEASE);
  if (__atomic_load_n(&word, __ATOMIC_ACQUIRE) != 7) return 7;
  if (__builtin_clz(1u) != 31 || __builtin_clz(0x80000000u) != 0) return 8;
  if (initialized != 17 || ((uintptr_t)&aligned_byte & 127)) return 9;
  if (pair_sum(pair_make(0x100000000ull, 42)) != 0x10000002aull) return 10;
  puts("phase108 cproc headers/atomics/CLZ/constructor/alignment/aggregate PASS");
  return 0;
}
