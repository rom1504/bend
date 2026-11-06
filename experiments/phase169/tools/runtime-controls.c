/* Unit controls for the unchanged take ABI; not compiler implementation.
 * Compile with -I pointing at the frozen private runtime directory. */
#include "runtime.c"
#include <sys/wait.h>

static const uint8_t test_arities[] = {0, 1, 2, 3, 4, 5};
static const uint8_t test_hot[] = {1, 1, 1, 1, 1, 1};
static const P111Program test_program = {
  .constructor_count = 6, .static_words = 128,
  .cid_arity = test_arities, .cid_hot = test_hot, .capabilities = 5,
};

#define CHECK(x) do { if (!(x)) { \
  fprintf(stderr, "control failed at line %d: %s\n", __LINE__, #x); return 2; \
} } while (0)

static uint64_t take_case(P111State *s, Term parent, Term *out, unsigned n,
                          int generic) {
  if (generic) return p111_rt_take(s, parent, out, n);
  switch (n) {
    case 1: return p125_rt_take1(s, parent, out);
    case 2: return p125_rt_take2(s, parent, out);
    case 3: return p125_rt_take3(s, parent, out);
    case 4: return p125_rt_take4(s, parent, out);
    default: return p111_rt_take(s, parent, out, n);
  }
}

int main(int argc, char **argv) {
  CHECK(argc == 2);
  const char *name = argv[1];
  p111_program_active = &test_program;
  KEEP_WORDS = 4096;
  size_t bytes = (HEAP_OFF + 4096) * sizeof(Term);
  Term *H = mmap(NULL, bytes, PROT_READ | PROT_WRITE,
                MAP_SHARED | MAP_ANONYMOUS, -1, 0);
  CHECK(H != MAP_FAILED);
  /* Only a few pages of this sparse runtime address space are resident. */
  Term *out = H + HEAP_OFF + 3000;
  Term *alc = H + HEAP_OFF + 3200;
  P111State state = {.e = {H, alc}};
  Loc parent_at = HEAP_OFF + 32, parent_rfc = HEAP_OFF + 48;
  Loc child_at = HEAP_OFF + 64, child_rfc = HEAP_OFF + 80;
  unsigned n = 2, parent_count = 2, child_count = 7, expected_error = 0;
  unsigned expected_child = 8, expected_parent = 1, generic = 0;
  int raw = 0, static_parent = 0, packed = 0, duplicate = 0;
  int raw_child = 0, raw_child_first = 0, error_arity = 0, wrong_tag = 0;

  if (!strcmp(name, "raw-unique")) {raw = 1; expected_child = 7;}
  else if (!strcmp(name, "static")) {static_parent = 1; expected_child = 7;}
  else if (!strcmp(name, "rfc-unique")) {parent_count = 1; expected_child = 7;}
  else if (!strcmp(name, "packed-one")) {n = 1; packed = 1; expected_child = 7;}
  else if (!strcmp(name, "shared-one")) n = 1;
  else if (!strcmp(name, "shared-two")) n = 2;
  else if (!strcmp(name, "shared-three")) n = 3;
  else if (!strcmp(name, "shared-four")) n = 4;
  else if (!strcmp(name, "shared-five-generic")) {n = 5; generic = 1;}
  else if (!strcmp(name, "shared-two-generic")) generic = 1;
  else if (!strcmp(name, "duplicate-child")) {duplicate = 1; expected_child = 9;}
  else if (!strcmp(name, "parent-maximum")) {
    parent_count = RFC_CNT; expected_parent = RFC_CNT - 1;
  }
  else if (!strcmp(name, "parent-zero-fallback")) {
    parent_count = 0; expected_parent = RFC_CNT;
  }
  else if (!strcmp(name, "child-last-valid")) {
    child_count = RFC_CNT - 2; expected_child = RFC_CNT - 1;
  }
  else if (!strcmp(name, "child-overflow")) {
    child_count = RFC_CNT - 1; expected_child = RFC_CNT;
    expected_parent = 2; expected_error = 1;
  }
  else if (!strcmp(name, "duplicate-overflow")) {
    duplicate = 1; child_count = RFC_CNT - 2; expected_child = RFC_CNT;
    expected_parent = 2; expected_error = 1;
  }
  else if (!strcmp(name, "unsealed-last")) {
    raw_child = 1; expected_parent = 2; expected_error = 1;
  }
  else if (!strcmp(name, "unsealed-first")) {
    raw_child_first = 1; expected_child = 7;
    expected_parent = 2; expected_error = 1;
  }
  else if (!strcmp(name, "raw-unique-unsealed")) {
    raw = 1; raw_child = 1; expected_child = 7;
  }
  else if (!strcmp(name, "wrong-arity")) {
    error_arity = 1; expected_error = 1; expected_parent = 2; expected_child = 7;
  }
  else if (!strcmp(name, "wrong-tag")) {
    wrong_tag = 1; expected_error = 1; expected_parent = 2; expected_child = 7;
  }
  else {fprintf(stderr, "unknown control\n"); return 2;}

  if (static_parent) parent_at = HEAP_OFF - 16;
  H[child_at] = term_pak(0, 42);
  H[child_rfc] = (child_at << 24) | child_count;
  Term child = term_ctr(1, child_rfc) | RFC_BIT;
  Term fields[5] = {child, term_ctr(1, HEAP_OFF - 8),
                    term_pak(0, 17), term_pak(0, 23), term_pak(0, 31)};
  H[HEAP_OFF - 8] = term_pak(0, 99);
  if (static_parent) fields[0] = term_pak(0, 11);
  if (duplicate) fields[1] = child;
  if (raw_child) fields[1] = term_ctr(1, child_at);
  if (raw_child_first) fields[0] = term_ctr(1, child_at);
  for (unsigned i = 0; i < n; ++i) H[parent_at + i] = fields[i];
  H[parent_rfc] = (parent_at << 24) | parent_count;
  Term parent = term_ctr(n, parent_rfc) | RFC_BIT;
  if (raw || static_parent) parent = term_ctr(n, parent_at);
  if (packed) parent = term_pak(1, 123);
  if (error_arity) parent = term_ctr(3, parent_rfc) | RFC_BIT;
  if (wrong_tag) parent = term_clo(2, parent_rfc) | RFC_BIT;

  /* Error cases use the actual runtime fail-stop, not an exception replacement.
   * Shared mappings expose mutations before _exit, so checks cover ordering. */
  pid_t pid = fork();
  CHECK(pid >= 0);
  if (pid == 0) {
    uint64_t result = take_case(&state, parent, out, n, generic);
    out[10] = result;
    _exit(0);
  }
  int status = 0;
  CHECK(waitpid(pid, &status, 0) == pid);
  CHECK(WIFEXITED(status));
  CHECK(WEXITSTATUS(status) == (int)expected_error);
  if (!error_arity && !wrong_tag) {
    for (unsigned i = 0; i < n; ++i) CHECK(out[i] == (packed ? 123 : fields[i]));
  } else {
    for (unsigned i = 0; i < n; ++i) CHECK(out[i] == 0);
  }
  CHECK(out[10] == (expected_error ? 0 : n));
  CHECK((H[child_rfc] & RFC_CNT) == expected_child);
  CHECK((H[child_rfc] >> 24) == child_at);
  CHECK(H[child_at] == term_pak(0, 42));
  CHECK(H[HEAP_OFF - 8] == term_pak(0, 99));
  if (raw) {
    CHECK(ALC_AT(state.e, 1) == parent_at);
    CHECK(ALC_LEN(state.e, 1) == 2);
    CHECK(ALC_AT(state.e, 0) == 0);
    CHECK(H[parent_at] == 0);
  } else if (!packed && !static_parent && parent_count == 1) {
    CHECK(ALC_AT(state.e, 0) == parent_rfc);
    CHECK(ALC_LEN(state.e, 0) == 1);
    CHECK(ALC_AT(state.e, 1) == parent_at);
    CHECK(ALC_LEN(state.e, 1) == 2);
    CHECK(H[parent_rfc] == 0 && H[parent_at] == 0);
  } else {
    for (unsigned i = 0; i < 3 * ALC_WORDS; ++i) CHECK(alc[i] == 0);
    if (!packed && !static_parent) {
      CHECK((H[parent_rfc] & RFC_CNT) == expected_parent);
      if (parent_count != 0) CHECK((H[parent_rfc] >> 24) == parent_at);
    }
    for (unsigned i = 0; i < n; ++i) CHECK(H[parent_at + i] == fields[i]);
  }
  if (!expected_error && !raw && !packed && !static_parent && parent_count == 2) {
    /* Consume the retained original root again. Its fields must still be usable;
     * now it is unique, so this transfer must not increment children again. */
    Term second[5] = {0};
    CHECK(take_case(&state, parent, second, n, generic) == n);
    for (unsigned i = 0; i < n; ++i) CHECK(second[i] == fields[i]);
    CHECK((H[child_rfc] & RFC_CNT) == expected_child);
    if (n == 1) {
      CHECK(ALC_AT(state.e, 0) == parent_at);
      CHECK(ALC_LEN(state.e, 0) == 2);
      CHECK(H[parent_at] == parent_rfc && H[parent_rfc] == 0);
    } else {
      CHECK(ALC_AT(state.e, 0) == parent_rfc);
      CHECK(ALC_LEN(state.e, 0) == 1);
      CHECK(ALC_AT(state.e, cls_fit(n)) == parent_at);
      CHECK(ALC_LEN(state.e, cls_fit(n)) == (1u << cls_fit(n)));
    }
  }
  CHECK(munmap(H, bytes) == 0);
  printf("%s: complete state PASS\n", name);
  return 0;
}
