/* Compile this boundary with GCC, without the cproc adapter include directory.
 * No Bend compiler algorithm or generated program function lives here. */
#include <stdint.h>
#include <stdbool.h>

uint32_t bend_qbe_atomic32_load(const uint32_t *p, int order) {
  return __atomic_load_n(p, order);
}
uint64_t bend_qbe_atomic64_load(const uint64_t *p, int order) {
  return __atomic_load_n(p, order);
}
void bend_qbe_atomic32_store(uint32_t *p, uint32_t v, int order) {
  __atomic_store_n(p, v, order);
}
void bend_qbe_atomic64_store(uint64_t *p, uint64_t v, int order) {
  __atomic_store_n(p, v, order);
}
uint32_t bend_qbe_atomic32_add(uint32_t *p, uint32_t v, int order) {
  return __atomic_fetch_add(p, v, order);
}
uint64_t bend_qbe_atomic64_add(uint64_t *p, uint64_t v, int order) {
  return __atomic_fetch_add(p, v, order);
}
uint32_t bend_qbe_atomic32_sub(uint32_t *p, uint32_t v, int order) {
  return __atomic_fetch_sub(p, v, order);
}
uint32_t bend_qbe_atomic32_exchange(uint32_t *p, uint32_t v, int order) {
  return __atomic_exchange_n(p, v, order);
}
bool bend_qbe_atomic32_compare_exchange(uint32_t *p, uint32_t *expected,
    uint32_t v, bool weak, int success, int failure) {
  return __atomic_compare_exchange_n(p, expected, v, weak, success, failure);
}
unsigned bend_qbe_clz32(unsigned v) {
  return __builtin_clz(v);
}
