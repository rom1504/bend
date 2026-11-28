/* Minimal bump-pointer arena shim implementing the subset of <apr_pools.h>
   used by unmodified CLBG binarytrees/2.c (single-threaded). */
#ifndef APR_POOLS_SHIM_H
#define APR_POOLS_SHIM_H

#include <stdlib.h>
#include <string.h>

typedef struct apr_pool_chunk {
  struct apr_pool_chunk *next;
  size_t cap;
  size_t used;
  char data[];
} apr_pool_chunk_t;

typedef struct apr_pool_t {
  apr_pool_chunk_t *head;
  apr_pool_chunk_t *cur;
} apr_pool_t;

static inline void apr_initialize(void) {}
static inline void apr_terminate(void) {}

static inline void apr_pool_create_unmanaged(apr_pool_t **p) {
  apr_pool_t *pool = (apr_pool_t *)malloc(sizeof(apr_pool_t));
  size_t init_cap = 65536;
  apr_pool_chunk_t *c = (apr_pool_chunk_t *)malloc(sizeof(apr_pool_chunk_t) + init_cap);
  c->next = NULL;
  c->cap = init_cap;
  c->used = 0;
  pool->head = c;
  pool->cur = c;
  *p = pool;
}

static inline void apr_pool_clear(apr_pool_t *pool) {
  apr_pool_chunk_t *c = pool->head;
  while (c) {
    c->used = 0;
    c = c->next;
  }
  pool->cur = pool->head;
}

static inline void apr_pool_destroy(apr_pool_t *pool) {
  apr_pool_chunk_t *c = pool->head;
  while (c) {
    apr_pool_chunk_t *n = c->next;
    free(c);
    c = n;
  }
  free(pool);
}

static inline void *apr_pcalloc(apr_pool_t *pool, size_t sz) {
  sz = (sz + 15u) & ~(size_t)15u;
  apr_pool_chunk_t *c = pool->cur;
  while (c->used + sz > c->cap) {
    if (c->next) {
      c = c->next;
      pool->cur = c;
    } else {
      size_t ncap = c->cap * 2;
      if (ncap < sz) ncap = sz;
      apr_pool_chunk_t *nc = (apr_pool_chunk_t *)malloc(sizeof(apr_pool_chunk_t) + ncap);
      nc->next = NULL;
      nc->cap = ncap;
      nc->used = 0;
      c->next = nc;
      c = nc;
      pool->cur = nc;
    }
  }
  void *ptr = c->data + c->used;
  c->used += sz;
  memset(ptr, 0, sz);
  return ptr;
}

#endif
