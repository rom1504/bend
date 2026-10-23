/* Diagnostic native Bend dispatch attribution. Included only by runtime.py.
 * No P111 ABI changes. Counters observe runtime events, not source operations.
 * The TLS getter is signal-safe on this admitted Linux x86-64 static TLS build.
 * The exported global is a sequential-only convenience, never an all-thread
 * logical context. Use the getter for samples from more than one thread. */
#include <errno.h>
#include <inttypes.h>
#include <limits.h>

#if !defined(__linux__) || !defined(__x86_64__) || ATOMIC_INT_LOCK_FREE != 2
#error "Bend diagnostic context requires Linux x86-64 and lock-free uint32 atomics"
#endif
_Static_assert(__atomic_always_lock_free(sizeof(uint64_t), 0),
               "Bend diagnostic counters require lock-free uint64 atomics");

enum {
  BP_DISPATCH, BP_ALLOC, BP_ALLOC_MISS, BP_FREE, BP_ALLOC_WORDS, BP_FREE_WORDS,
  BP_KEEP, BP_SINK, BP_DROP, BP_TAKE, BP_FRAME, BP_FRAME_WORDS, BP_RETURN,
  BP_PRIMITIVE, BP_REG_COPY_WORDS, BP_REG_CLEAR_WORDS, BP_COUNTER_COUNT
};
static const char *const bp_counter_names[BP_COUNTER_COUNT] = {
  "dispatches", "heap_alloc_calls", "heap_alloc_miss_calls", "heap_free_calls",
  "heap_alloc_requested_words", "heap_free_words", "term_keep_calls",
  "term_sink_calls", "term_drop_calls", "ctr_take_calls", "frame_push_calls",
  "frame_capture_words", "return_calls", "primitive_calls",
  "register_words_copy_requested", "register_words_clear_requested"
};

__attribute__((visibility("default")))
_Atomic uint32_t bend_profile_dispatch_id = UINT32_MAX;
static _Thread_local _Atomic uint32_t bp_local_dispatch
  __attribute__((tls_model("initial-exec"))) = UINT32_MAX;
static _Atomic uint64_t *bp_counts;
static _Atomic uint64_t bp_bad_contexts;
static _Atomic unsigned bp_overflow;
static uint32_t bp_segments, bp_rows;
static const P111Segment *bp_functions;
static FILE *bp_output;
static int bp_initialized, bp_counts_enabled;

__attribute__((visibility("default"), noinline))
uint32_t bend_profile_dispatch_get(void) {
  return atomic_load_explicit(&bp_local_dispatch, memory_order_relaxed);
}

static void bp_die(const char *reason) {
  /* Only setup/exit errors write stderr. Successful profiles leave it intact. */
  fprintf(stderr, "bend-profile-runtime: %s\n", reason);
  _exit(125);
}

static inline void bend_profile_count(unsigned event, uint64_t amount) {
  if (!bp_counts_enabled) return;
  uint32_t fid = atomic_load_explicit(&bp_local_dispatch, memory_order_relaxed);
  uint32_t row = fid == UINT32_MAX ? bp_rows - 1 : fid;
  if (event >= BP_COUNTER_COUNT || (row >= bp_rows - 1 && fid != UINT32_MAX)) {
    atomic_fetch_add_explicit(&bp_bad_contexts, 1, memory_order_relaxed);
    return;
  }
  _Atomic uint64_t *cell = bp_counts + (size_t)row * BP_COUNTER_COUNT + event;
  uint64_t previous = atomic_fetch_add_explicit(cell, amount, memory_order_relaxed);
  if (previous > UINT64_MAX - amount)
    atomic_store_explicit(&bp_overflow, 1, memory_order_relaxed);
}

static inline uint32_t bend_profile_dispatch_enter(uint32_t fid) {
  uint32_t prior = atomic_load_explicit(&bp_local_dispatch, memory_order_relaxed);
  atomic_store_explicit(&bp_local_dispatch, fid, memory_order_relaxed);
  atomic_store_explicit(&bend_profile_dispatch_id, fid, memory_order_relaxed);
  bend_profile_count(BP_DISPATCH, 1);
  return prior;
}

static inline void bend_profile_dispatch_leave(uint32_t prior) {
  atomic_store_explicit(&bp_local_dispatch, prior, memory_order_relaxed);
  atomic_store_explicit(&bend_profile_dispatch_id, prior, memory_order_relaxed);
}

static void bend_profile_finish(void) {
  if (!bp_output) return;
  unsigned overflow = atomic_load_explicit(&bp_overflow, memory_order_relaxed);
  uint64_t bad = atomic_load_explicit(&bp_bad_contexts, memory_order_relaxed);
  fprintf(bp_output,
    "{\n\"schema\":\"bend-native-dispatch-events-v1\",\n"
    "\"complete\":%s,\"segment_count\":%" PRIu32 ","
    "\"runtime_segment_count\":4,\"unknown_fid\":4294967295,\n"
    "\"context_kind\":\"active-dispatch-not-logical-ancestry\",\n"
    "\"global_context_scope\":\"one-active-dispatch-thread-only\",\n"
    "\"counts_enabled\":%s,\"counter_bytes\":%zu,"
    "\"counter_overflow\":%s,\"invalid_context_events\":%" PRIu64 ",\n"
    "\"counter_names\":[",
    overflow || bad ? "false" : "true", bp_segments,
    bp_counts_enabled ? "true" : "false",
    bp_counts_enabled ? (size_t)bp_rows * BP_COUNTER_COUNT * sizeof(*bp_counts) : 0,
    overflow ? "true" : "false", bad);
  for (unsigned i = 0; i < BP_COUNTER_COUNT; ++i)
    fprintf(bp_output, "%s\"%s\"", i ? "," : "", bp_counter_names[i]);
  fprintf(bp_output, "],\n\"rows\":[\n");
  unsigned emitted = 0;
  if (bp_counts_enabled) for (uint32_t row = 0; row < bp_rows; ++row) {
    uint64_t values[BP_COUNTER_COUNT];
    unsigned nonzero = 0;
    for (unsigned i = 0; i < BP_COUNTER_COUNT; ++i) {
      values[i] = atomic_load_explicit(
        bp_counts + (size_t)row * BP_COUNTER_COUNT + i, memory_order_relaxed);
      nonzero |= values[i] != 0;
    }
    if (!nonzero) continue;
    uint32_t fid = row == bp_rows - 1 ? UINT32_MAX : row;
    uintptr_t address = row < bp_segments ? (uintptr_t)bp_functions[row] : 0;
    fprintf(bp_output, "%s{\"fid\":%" PRIu32 ",\"segment_address\":\"0x%" PRIxPTR
      "\",\"counts\":[", emitted++ ? ",\n" : "", fid, address);
    for (unsigned i = 0; i < BP_COUNTER_COUNT; ++i)
      fprintf(bp_output, "%s%" PRIu64, i ? "," : "", values[i]);
    fputs("]}", bp_output);
  }
  fputs("\n],\n\"limitations\":["
    "\"Counts are diagnostic runtime events; generated inline operations may bypass them.\","
    "\"heap_alloc_miss is a lane refill and may reuse memory; it is not fresh allocation.\","
    "\"Ownership counts identify execution sites, not allocation origins or logical ancestors.\","
    "\"term_drop_calls counts entries, not traversed nodes; heap_free_calls counts reclamation calls.\","
    "\"Private synchronous calls retain their outer dispatch ID.\","
    "\"Counters change execution cost; use an uninstrumented executable for performance claims.\","
    "\"Completion does not establish target program correctness.\""
    "]\n}\n", bp_output);
  int failed = ferror(bp_output);
  if (fclose(bp_output)) failed = 1;
  bp_output = NULL;
  if (failed) bp_die("event output could not be completed");
}

static void bend_profile_initialize(uint32_t segments, const P111Segment *functions) {
  if (bp_initialized || !segments || segments > 65532 || !functions)
    bp_die("unsupported or repeated program binding");
  bp_initialized = 1;
  bp_segments = segments;
  bp_rows = segments + 5; /* four runtime segments, then outside/unknown */
  bp_functions = functions;
  const char *path = getenv("BEND_PROFILE_EVENTS_OUT");
  const char *mode = getenv("BEND_PROFILE_COUNTERS");
  if (mode && strcmp(mode, "0") && strcmp(mode, "1"))
    bp_die("BEND_PROFILE_COUNTERS must be 0 or 1");
  bp_counts_enabled = path && *path && (!mode || strcmp(mode, "0"));
  if (mode && !strcmp(mode, "1") && (!path || !*path))
    bp_die("counter collection requires BEND_PROFILE_EVENTS_OUT");
  if (!path || !*path) return; /* context-only: no event allocation or output */
  bp_output = fopen(path, "wx");
  if (!bp_output) bp_die("event path must be fresh and writable");
  if (bp_counts_enabled) {
    if (bp_rows > SIZE_MAX / BP_COUNTER_COUNT / sizeof(*bp_counts))
      bp_die("counter capacity overflow");
    size_t cells = (size_t)bp_rows * BP_COUNTER_COUNT;
    bp_counts = calloc(cells, sizeof(*bp_counts));
    if (!bp_counts) bp_die("counter allocation failed");
    for (size_t i = 0; i < cells; ++i) atomic_init(bp_counts + i, 0);
  }
  if (atexit(bend_profile_finish)) bp_die("could not register event output");
}
