#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

typedef uint64_t (*CharFn)(void *, uint64_t, uint64_t *);
extern uint64_t p186char_take(void *, uint64_t, uint64_t *);
extern uint64_t p186char_status(void *, uint64_t, uint64_t *);
extern uint64_t p186char_input_alias(void *, uint64_t, uint64_t *);
extern uint64_t p186char_buffer_alias(void *, uint64_t, uint64_t *);
extern uint64_t p186char_ctor(void *, uint64_t, uint64_t *);
extern uint64_t p186char_ctor_alias(void *, uint64_t, uint64_t *);

int main(void) {
  static const uint64_t words[] = {
    0, 1, 65, 0x10ffff, 0x110000, UINT32_MAX, UINT64_C(0x100000000),
    UINT64_C(0x8000000000000000), UINT64_C(0x0102030405060708), UINT64_MAX
  };
  static const CharFn funcs[] = {p186char_take, p186char_status,
    p186char_input_alias, p186char_buffer_alias, p186char_ctor, p186char_ctor_alias};
  const uint64_t guard = UINT64_C(0x6d7e8f9a102345bc);
  unsigned observations = 0;
  for (unsigned f = 0; f < sizeof(funcs) / sizeof(*funcs); ++f) {
    for (unsigned w = 0; w < sizeof(words) / sizeof(*words); ++w) {
      uint64_t state[5] = {guard, guard, guard, guard, guard};
      uint64_t slots[3] = {guard, f >= 4 ? words[w] : ~words[w], guard};
      uint64_t actual = funcs[f](state, words[w], slots + 1);
      uint64_t expected = f == 0 || f >= 4 ? words[w] : 1;
      if (actual != expected || slots[1] != words[w] || slots[0] != guard || slots[2] != guard) {
        fprintf(stderr, "char f=%u word=%016" PRIx64 " got=%016" PRIx64 " want=%016" PRIx64 "\n",
          f, words[w], actual, expected);
        return 1;
      }
      for (unsigned i = 0; i < 5; ++i) if (state[i] != guard) return 2;
      ++observations;
    }
  }
  printf("phase186 char controls pass: %u\n", observations);
  return 0;
}
