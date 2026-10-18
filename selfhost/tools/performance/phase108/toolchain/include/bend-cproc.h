#ifndef BEND_PHASE108_CPROC_H
#define BEND_PHASE108_CPROC_H
#define BEND_CPROC 1

/* Preinclude before generated C. Scope: host Linux x86-64 runtime. */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
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
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <netinet/in.h>
#include <sys/random.h>
#include <sys/socket.h>
#include <sys/stat.h>

/* Load admitted system headers while glibc suppresses GNU attributes, then
 * restore attribute tokens for provider constructor definitions. The pinned
 * cproc patch emits their .init_array records. Required object alignment uses
 * standard _Alignas in the portable runtime. */
#undef __attribute__

#define __ATOMIC_RELAXED 0
#define __ATOMIC_CONSUME 1
#define __ATOMIC_ACQUIRE 2
#define __ATOMIC_RELEASE 3
#define __ATOMIC_ACQ_REL 4
#define __ATOMIC_SEQ_CST 5

uint32_t bend_qbe_atomic32_sub(uint32_t *, uint32_t, int);
uint32_t bend_qbe_atomic32_exchange(uint32_t *, uint32_t, int);
bool bend_qbe_atomic32_compare_exchange(uint32_t *, uint32_t *, uint32_t,
                                      bool, int, int);
unsigned bend_qbe_clz32(unsigned);

/* All GNU atomic operations in the admitted Bend runtime operate on u32.
 * Pool atomics use the separately typed stdatomic.h adapters. */
#define __atomic_load_n(p, order) bend_qbe_atomic32_load(p, order)
#define __atomic_store_n(p, v, order) bend_qbe_atomic32_store(p, v, order)
#define __atomic_fetch_add(p, v, order) bend_qbe_atomic32_add(p, v, order)
#define __atomic_fetch_sub(p, v, order) bend_qbe_atomic32_sub(p, v, order)
#define __atomic_exchange_n(p, v, order) bend_qbe_atomic32_exchange(p, v, order)
#define __atomic_compare_exchange_n(p, e, v, weak, success, failure) \
  bend_qbe_atomic32_compare_exchange(p, e, v, weak, success, failure)
#define __builtin_clz(v) bend_qbe_clz32(v)

#endif
