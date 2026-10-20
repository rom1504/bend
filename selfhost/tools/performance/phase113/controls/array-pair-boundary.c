/* Independent finite ownership witnesses for profile11301.
 * Baseline Tuple and flat routes are both checked against literal observations.
 * No timing claim or general ownership/leak proof follows from these tests. */
#include "runtime.h"
#include "primitives.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef P113_ARRAY_PAIR_H
uint64_t p113_rt_array_pair(P111State *, uint32_t, const uint64_t *,
                           uint32_t, uint64_t *, uint32_t);
#endif

enum { SNIL, SCON, WNIL, WCON, NIL, CON, TUPLE, UNIT, NONE, SOME,
       FAIL, DONE, EMIT, HALT, TRUE, LT, EQ, GT };
static const char *chosen;
static unsigned checks;
static const uint32_t seed[] = {'s', 0x3bb, 0x1f642};
static const uint32_t replacement[] = {'n', 0x3b2};

static void expect(int condition, const char *message) {
  ++checks;
  if (!condition) {
    fprintf(stderr, "phase113-boundary: %s\n", message);
    exit(2);
  }
}
static uint64_t text(P111State *s, const uint32_t *points, size_t count) {
  uint64_t value = p111_rt_ctor(s, SNIL, NULL, 0);
  while (count) {
    uint64_t fields[] = {points[--count], value};
    value = p111_rt_ctor(s, SCON, fields, 2);
  }
  return value;
}
static void consume(P111State *s, uint64_t value,
                    const uint32_t *points, size_t count) {
  for (size_t i = 0; i < count; ++i) {
    uint64_t fields[2];
    expect(p111_rt_tag(s, value) == SCON, "String constructor");
    p111_rt_take(s, value, fields, 2);
    expect(fields[0] == points[i], "complete Unicode String content");
    value = fields[1];
  }
  expect(p111_rt_tag(s, value) == SNIL, "String ends at expected length");
  p111_rt_sink(s, value);
}
static uint64_t array(P111State *s, uint32_t depth) {
  uint64_t args[] = {depth, text(s, seed, 3)};
  return p111_rt_op(s, P111_OP_ARRAY_NEW, args, 2);
}
/* Input/output overlap is exercised on both paths. The generic route also
 * evaluates its whole call before unboxing; the literal oracle is unchanged. */
static void pair(P111State *s, int flat, uint32_t op,
                 uint64_t *args, uint32_t argc, uint64_t *out) {
  if (flat) {
    expect(p113_rt_array_pair(s, op, args, argc, out, 2) == 0,
           "flat helper returns success zero");
  } else {
    uint64_t boxed = p111_rt_op(s, op, args, argc);
    expect(p111_rt_tag(s, boxed) == TUPLE, "generic result is Tuple");
    p111_rt_take(s, boxed, out, 2);
  }
}
static uint64_t get(P111State *s, int flat, uint64_t a, uint32_t index,
                    const uint32_t *points, size_t count) {
  uint64_t args[] = {a, index}, out[2];
  pair(s, flat, P111_OP_ARRAY_GET, args, 2, out);
  consume(s, out[1], points, count);
  return out[0];
}
static void get_release(P111State *s, int flat, int array_first) {
  uint64_t args[] = {array(s, 1), 1}, out[2];
  pair(s, flat, P111_OP_ARRAY_GET, args, 2, out);
  if (array_first) {
    p111_rt_sink(s, out[0]);
    consume(s, out[1], seed, 3);
  } else {
    consume(s, out[1], seed, 3);
    uint64_t a = get(s, flat, out[0], 1, seed, 3);
    p111_rt_sink(s, a);
  }
}
static void swap_release(P111State *s, int flat, int shared) {
  uint64_t original = array(s, 1), alias = 0;
  if (shared) {
    uint64_t args[] = {original}, out[2];
    pair(s, flat, P111_OP_ARRAY_CLONE, args, 1, out);
    original = out[0]; alias = out[1];
  }
  uint64_t args[] = {original, 1, text(s, replacement, 2)}, out[2];
  pair(s, flat, P111_OP_ARRAY_SWAP, args, 3, out);
  original = get(s, flat, out[0], 1, replacement, 2);
  p111_rt_sink(s, original);
  consume(s, out[1], seed, 3); /* returned cell outlives its array */
  if (shared) {
    alias = get(s, flat, alias, 0, seed, 3);
    alias = get(s, flat, alias, 1, seed, 3);
    p111_rt_sink(s, alias);
  }
}
static void clone_release(P111State *s, int flat, int original_first) {
  uint64_t args[] = {array(s, 1)}, out[2];
  pair(s, flat, P111_OP_ARRAY_CLONE, args, 1, out);
  uint64_t original = out[0], copy = out[1];
  uint64_t set[] = {copy, 0, text(s, replacement, 2)};
  copy = p111_rt_op(s, P111_OP_ARRAY_SET, set, 3);
  if (original_first) {
    original = get(s, flat, original, 0, seed, 3);
    p111_rt_sink(s, original);
    copy = get(s, flat, copy, 0, replacement, 2);
    copy = get(s, flat, copy, 1, seed, 3);
    p111_rt_sink(s, copy);
  } else {
    copy = get(s, flat, copy, 0, replacement, 2);
    p111_rt_sink(s, copy);
    original = get(s, flat, original, 0, seed, 3);
    original = get(s, flat, original, 1, seed, 3);
    p111_rt_sink(s, original);
  }
}
static void overlap(P111State *s, int flat, int offset) {
  uint64_t buffer[5] = {array(s, 1), 1, text(s, replacement, 2), 0, 0};
  uint64_t *out = buffer + offset;
  pair(s, flat, P111_OP_ARRAY_SWAP, buffer, 3, out);
  uint64_t a = out[0], prior = out[1];
  a = get(s, flat, a, 1, replacement, 2);
  p111_rt_sink(s, a);
  consume(s, prior, seed, 3);
}
static void size_cases(P111State *s, int flat) {
  for (uint32_t depth = 0; depth <= 2; ++depth) {
    uint64_t args[] = {array(s, depth)}, out[2];
    pair(s, flat, P111_OP_ARRAY_SIZE, args, 1, out);
    expect(out[1] == (UINT64_C(1) << depth), "array size scalar");
    uint64_t a = get(s, flat, out[0], (1u << depth) - 1, seed, 3);
    p111_rt_sink(s, a);
  }
}
static void positives(P111State *s, int flat) {
  if (!strcmp(chosen, "get-array-first")) get_release(s, flat, 1);
  else if (!strcmp(chosen, "get-value-first")) get_release(s, flat, 0);
  else if (!strcmp(chosen, "swap-unique")) swap_release(s, flat, 0);
  else if (!strcmp(chosen, "swap-shared")) swap_release(s, flat, 1);
  else if (!strcmp(chosen, "clone-original-first")) clone_release(s, flat, 1);
  else if (!strcmp(chosen, "clone-copy-first")) clone_release(s, flat, 0);
  else if (!strcmp(chosen, "overlap-exact")) overlap(s, flat, 0);
  else if (!strcmp(chosen, "overlap-forward")) overlap(s, flat, 1);
  else if (!strcmp(chosen, "sizes")) size_cases(s, flat);
  else if (!strcmp(chosen, "repeat-ownership")) {
    for (unsigned i = 0; i < 64; ++i) {
      clone_release(s, flat, i & 1);
      swap_release(s, flat, 1);
    }
  } else {
    fputs("phase113-boundary: unknown case\n", stderr);
    exit(2);
  }
}
static uint64_t boundary_segment(P111State *s) {
  /* Invalid metadata deliberately uses null buffers. Required rejection occurs
   * before reading or consuming any Term. A wrong implementation may crash. */
  uint64_t out[2], args[3] = {0, 0, 0};
  if (!strcmp(chosen, "reject-operation"))
    p113_rt_array_pair(NULL, P111_OP_ARRAY_SET, NULL, 3, NULL, 2);
  else if (!strcmp(chosen, "reject-argument-count"))
    p113_rt_array_pair(NULL, P111_OP_ARRAY_GET, NULL, 1, NULL, 2);
  else if (!strcmp(chosen, "reject-output-count"))
    p113_rt_array_pair(NULL, P111_OP_ARRAY_GET, NULL, 2, NULL, 1);
  else if (!strcmp(chosen, "reject-null-state"))
    p113_rt_array_pair(NULL, P111_OP_ARRAY_GET, args, 2, out, 2);
  else if (!strcmp(chosen, "reject-null-input"))
    p113_rt_array_pair(s, P111_OP_ARRAY_GET, NULL, 2, out, 2);
  else if (!strcmp(chosen, "reject-null-output"))
    p113_rt_array_pair(s, P111_OP_ARRAY_GET, args, 2, NULL, 2);
  else {
    positives(s, 0);
    positives(s, 1);
  }
  if (!checks) {
    fputs("phase113-boundary: rejection unexpectedly returned\n", stderr);
    exit(3);
  }
  printf("%s:ok\n", chosen);
  uint64_t zero = 0;
  return p111_rt_return(s, &zero, 1);
}

static const P111Segment segments[] = {boundary_segment};
static const uint8_t arity[] = {0}, flags[] = {2}, results[] = {0};
static const uint8_t ctor_arity[] = {0,2,0,2,0,2,2,0,0,1,1,1,1,2,0,0,0,0};
static const uint8_t ctor_hot[] = {0,1,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,0};
static const char *const ctor_names[] = {
  "SNil","SCon","WNil","WCon","Nil","Con","Tuple","Unit",
  "None","Some","Fail","Done","Emit","Halt","True","LT","EQ","GT"};
static const uint64_t static_image[] = {0};
static const uint32_t show[] = {0};
static const char *const show_names[] = {"U32"};
static const P111Program program = {
  P111_ABI_VERSION,sizeof(P111Program),1,18,0,1,2,1,0,1,1,P111_SEQUENTIAL,
  segments,arity,flags,results,ctor_arity,ctor_hot,ctor_names,static_image,
  show,show_names,0,NULL
};
int main(int argc, char **argv) {
  if (argc != 2) {
    fputs("usage: array-pair-boundary CASE\n", stderr);
    return 2;
  }
  chosen = argv[1];
  char *runtime_argv[] = {argv[0], "--threads", "1", "--gpu", "off", NULL};
  return p111_rt_main(5, runtime_argv, &program);
}
