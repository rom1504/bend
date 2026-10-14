/* Diagnostic host-only work counts. Not a runtime optimization. */
#if DEVICE
#error "Phase89 counters support only the serial CPU diagnostic"
#endif
#define P89_FIELDS(X) \
  X(append_chars) X(append_finished) X(append_returns) \
  X(alloc_calls) X(alloc_words) X(alloc_misses) X(alloc_cold) X(alloc_bank) \
  X(alloc_fresh) X(fresh_words) X(free_calls) X(free_words) X(heap_hands) \
  X(drop_calls) X(drop_items) X(drop_fields) X(drop_nodes) \
  X(drop_release) X(drop_shared) X(drop_last) X(wrap_calls) \
  X(retain_calls) X(retain_units) X(fade_calls) X(fade_fields) \
  X(take_calls) X(take_fields) X(take_direct) X(take_last) X(take_shared) \
  X(choose_calls) X(match_joins)
#define P89_ENUM(n) P89_##n,
enum { P89_FIELDS(P89_ENUM) P89_SIZE };
#undef P89_ENUM
#define P89_NAME(n) #n,
static const char* p89_names[] = { P89_FIELDS(P89_NAME) };
#undef P89_NAME
static uint64_t p89_counts[P89_SIZE], p89_saved[16][P89_SIZE], p89_ms[16];
static unsigned p89_marks, p89_overflow;
static _Thread_local unsigned p89_owner;
static _Atomic uint64_t p89_foreign;
#define P89_ADD(n, v) do { \
  if (p89_owner) { p89_counts[P89_##n] += (uint64_t)(v); } \
  else { atomic_fetch_add_explicit(&p89_foreign, 1, memory_order_relaxed); } \
} while (0)
#define P89_INC(n) P89_ADD(n, 1)
static void p89_snapshot(uint64_t ms) {
  if (!p89_owner) {
    atomic_fetch_add_explicit(&p89_foreign, 1, memory_order_relaxed);
    return;
  }
  if (p89_marks >= 16) { p89_overflow++; return; }
  p89_ms[p89_marks] = ms;
  memcpy(p89_saved[p89_marks++], p89_counts, sizeof(p89_counts));
}
static void p89_dump(void) {
  fprintf(stderr, "P89_COUNTS {\"schema\":1,\"marks\":%u,\"overflow\":%u,\"foreignEvents\":%llu}\n",
    p89_marks, p89_overflow, (unsigned long long)atomic_load_explicit(&p89_foreign, memory_order_relaxed));
  for (unsigned m = 0; m <= p89_marks; ++m) {
    fprintf(stderr, "P89_COUNTS {\"mark\":%u,\"final\":%s,\"ms\":%llu,\"counts\":{",
      m, m == p89_marks ? "true" : "false", (unsigned long long)(m == p89_marks ? 0 : p89_ms[m]));
    for (unsigned i = 0; i < P89_SIZE; ++i) {
      fprintf(stderr, "%s\"%s\":%llu", i ? "," : "", p89_names[i],
        (unsigned long long)(m == p89_marks ? p89_counts[i] : p89_saved[m][i]));
    }
    fprintf(stderr, "}}\n");
  }
}
static void __attribute__((constructor(101))) p89_start(void) {
  p89_owner = 1;
  atexit(p89_dump);
}
