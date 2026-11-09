/* Handwritten translation of native45/fixtures/test-rle-roundtrip.bend.
   Entry corresponds to p93.value: its two runtime words are unused there too. */
#include <stdint.h>
#include <stdlib.h>

typedef struct WordList {
  uint32_t value;
  struct WordList *next;
} WordList;

typedef struct RunList {
  uint32_t count;
  uint32_t value;
  struct RunList *next;
} RunList;

static WordList *word_cons(uint32_t value, WordList *next) {
  WordList *node = malloc(sizeof *node);
  if (!node) abort();
  node->value = value;
  node->next = next;
  return node;
}

static RunList *run_cons(uint32_t count, uint32_t value, RunList *next) {
  RunList *node = malloc(sizeof *node);
  if (!node) abort();
  node->count = count;
  node->value = value;
  node->next = next;
  return node;
}

static RunList *run_reverse(RunList *xs) {
  RunList *acc = NULL;
  while (xs) {
    RunList *next = xs->next;
    xs->next = acc;
    acc = xs;
    xs = next;
  }
  return acc;
}

/* Consume the input list, accumulate complete runs in reverse, then reverse. */
static RunList *encode(WordList *xs) {
  if (!xs) return NULL;
  uint32_t current = xs->value;
  uint32_t count = 1;
  WordList *next = xs->next;
  free(xs);
  xs = next;
  RunList *acc = NULL;
  while (xs) {
    if (xs->value == current) {
      count += UINT32_C(1);
    } else {
      acc = run_cons(count, current, acc);
      current = xs->value;
      count = 1;
    }
    next = xs->next;
    free(xs);
    xs = next;
  }
  return run_reverse(run_cons(count, current, acc));
}

static uint32_t run_length(const RunList *xs) {
  uint32_t result = 0;
  for (; xs; xs = xs->next) result += UINT32_C(1);
  return result;
}

static WordList *repeat(uint32_t count, uint32_t value) {
  WordList *result = NULL;
  while (count) {
    result = word_cons(value, result);
    --count;
  }
  return result;
}

/* Both arguments are uniquely owned; link the consumed first list to second. */
static WordList *concat(WordList *xs, WordList *ys) {
  if (!xs) return ys;
  WordList *last = xs;
  while (last->next) last = last->next;
  last->next = ys;
  return xs;
}

static WordList *expand(const RunList *runs) {
  if (!runs) return NULL;
  WordList *head = repeat(runs->count, runs->value);
  WordList *tail = expand(runs->next);
  return concat(head, tail);
}

static uint32_t digest(WordList *xs) {
  uint32_t result = 0;
  while (xs) {
    result = result * UINT32_C(10) + xs->value;
    WordList *next = xs->next;
    free(xs);
    xs = next;
  }
  return result;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
  (void)a;
  (void)b;
  static const uint32_t input[] = {7, 7, 7, 2, 9, 9};
  WordList *xs = NULL;
  for (size_t i = sizeof input / sizeof input[0]; i; --i)
    xs = word_cons(input[i - 1], xs);
  RunList *code = encode(xs);
  uint32_t count = run_length(code);
  uint32_t sum = digest(expand(code));
  while (code) {
    RunList *next = code->next;
    free(code);
    code = next;
  }
  /* These predicates are the original program's internal observations. */
  return (uint32_t)(count == UINT32_C(3)) * UINT32_C(10)
       + (uint32_t)(sum == UINT32_C(777299));
}
