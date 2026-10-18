/* Independent finite runtime-ABI witnesses, not a Bend program implementation.
 * Link this small object to the cached Phase111 runtime object. */
#include "runtime.h"
#include "primitives.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { SNIL, SCON, WNIL, WCON, NIL, CON, TUPLE, UNIT, NONE, SOME,
       FAIL, DONE, EMIT, HALT, TRUE, LT, EQ, GT };
static const char *chosen;
static uint32_t checks;

static void expect(int condition, const char *message) {
  ++checks;
  if (!condition) {
    fprintf(stderr, "boundary: %s\n", message);
    exit(2);
  }
}
static uint64_t op1(P111State *s, uint32_t op, uint64_t a) {
  uint64_t args[] = {a}; return p111_rt_op(s, op, args, 1);
}
static uint64_t op2(P111State *s, uint32_t op, uint64_t a, uint64_t b) {
  uint64_t args[] = {a, b}; return p111_rt_op(s, op, args, 2);
}
static uint64_t op3(P111State *s, uint32_t op, uint64_t a, uint64_t b, uint64_t c) {
  uint64_t args[] = {a, b, c}; return p111_rt_op(s, op, args, 3);
}
static void pair(P111State *s, uint64_t term, uint64_t out[2]) {
  expect(p111_rt_tag(s, term) == TUPLE, "Tuple result tag");
  p111_rt_take(s, term, out, 2);
}
static uint64_t string(P111State *s, const char *text) {
  uint64_t out = p111_rt_ctor(s, SNIL, NULL, 0);
  for (size_t i = strlen(text); i > 0; --i) {
    uint64_t fields[] = {(unsigned char)text[i - 1], out};
    out = p111_rt_ctor(s, SCON, fields, 2);
  }
  return out;
}
static void consume_string(P111State *s, uint64_t term, const char *text) {
  for (size_t i = 0; text[i]; ++i) {
    uint64_t fields[2];
    expect(p111_rt_tag(s, term) == SCON, "String cons tag");
    p111_rt_take(s, term, fields, 2);
    expect(fields[0] == (unsigned char)text[i], "String character");
    term = fields[1];
  }
  expect(p111_rt_tag(s, term) == SNIL, "String end tag");
  p111_rt_sink(s, term);
}

static void scalar_controls(P111State *s) {
  expect(op2(s, P111_OP_U32_ADD, UINT32_MAX, 1) == 0, "U32 addition wraps");
  expect(op2(s, P111_OP_U32_SUB, 0, 1) == UINT32_MAX, "U32 subtraction wraps");
  expect(op2(s, P111_OP_U32_MUL, UINT32_MAX, 2) == UINT32_MAX - 1, "U32 multiplication wraps");
  expect(op2(s, P111_OP_U32_DIV, UINT32_MAX, 0) == 0, "U32 division by zero");
  expect(op2(s, P111_OP_U32_MOD, UINT32_MAX, 0) == UINT32_MAX, "U32 modulus by zero");
  expect(op2(s, P111_OP_U32_DIV, UINT32_MAX, 2) == 2147483647, "U32 large division");
  expect(op2(s, P111_OP_U32_MOD, UINT32_MAX, 2) == 1, "U32 large modulus");
  expect(op2(s, P111_OP_U32_SHLN, 1, 31) == UINT64_C(2147483648), "U32 shift by31");
  expect(op2(s, P111_OP_U32_SHLN, 1, 32) == 0, "U32 shift by32");
  expect(op2(s, P111_OP_U32_SHLN, 1, UINT64_C(0xffffffffffff)) == 0, "U32 shift bylargeNat");
  expect(op2(s, P111_OP_U32_SHRN, UINT32_MAX, 31) == 1, "U32 right shift by31");
  expect(op2(s, P111_OP_U32_SHRN, UINT32_MAX, 32) == 0, "U32 right shift by32");
  expect(op1(s, P111_OP_U32_NOT, 0) == UINT32_MAX, "U32 not remains32bits");
  expect(op2(s, P111_OP_NAT_SUB, 2, 9) == 0, "Nat subtraction saturates");
  expect(op2(s, P111_OP_NAT_ADD, UINT64_C(0xfffffffffffe), 1) == UINT64_C(0xffffffffffff), "Nat largest valid add");
  expect(op2(s, P111_OP_NAT_MUL, UINT64_C(0x7fffffffffff), 2) == UINT64_C(0xfffffffffffe), "Nat largest valid multiply");
  uint64_t values[2];
  pair(s, op2(s, P111_OP_NAT_DIVMOD, 29, 0), values);
  expect(values[0] == 0 && values[1] == 29, "Nat divmod byzero pair");
  pair(s, op2(s, P111_OP_NAT_DIVMOD, 29, 6), values);
  expect(values[0] == 4 && values[1] == 5, "Nat divmod pairorder");
  expect(p111_rt_tag(s, op2(s, P111_OP_U32_CMP, 1, 2)) == LT, "Cmp LT tag");
  expect(p111_rt_tag(s, op2(s, P111_OP_U32_CMP, 2, 2)) == EQ, "Cmp EQ tag");
  expect(p111_rt_tag(s, op2(s, P111_OP_NAT_CMP, 3, 2)) == GT, "Cmp GT tag");
  uint64_t tagged_true = p111_rt_ctor(s, TRUE, NULL, 0);
  expect(op2(s, P111_OP_BOOL_OR, tagged_true, 0) == 1, "Bool taggedcompatibility");
  expect(op2(s, P111_OP_BOOL_XOR, tagged_true, 1) == 0, "Bool mixedrepresentation");
}

static void float_controls(P111State *s) {
  const uint64_t one = UINT64_C(0x3f800000), negzero = UINT64_C(0x80000000);
  const uint64_t nan = UINT64_C(0x7fc01234), inf = UINT64_C(0x7f800000);
  expect(op1(s, P111_OP_F32_BITS, nan) == nan, "F32 bits preservesNaNpayload");
  expect(op1(s, P111_OP_F32_NEG, 0) == negzero, "F32 negativezero bits");
  expect(op1(s, P111_OP_F32_NEG, negzero) == 0, "F32 doublenegativezero");
  expect(op2(s, P111_OP_F32_DIV, negzero, one) == negzero, "F32 signedzero division");
  expect(op2(s, P111_OP_F32_DIV, one, 0) == inf, "F32 division infinity");
  uint64_t zero_nan = op2(s, P111_OP_F32_DIV, 0, 0);
  expect((zero_nan & UINT64_C(0x7f800000)) == UINT64_C(0x7f800000)
    && (zero_nan & UINT64_C(0x007fffff)) != 0, "F32 zero division NaN class");
  expect(op2(s, P111_OP_F32_IS_EQ, nan, nan) == 0, "F32 NaN not equal");
  expect(op2(s, P111_OP_F32_IS_NE, nan, nan) == 1, "F32 NaN unequal");
  expect(op2(s, P111_OP_F32_IS_LT, nan, one) == 0, "F32 NaN unordered");
  expect(op2(s, P111_OP_F32_IS_EQ, 0, negzero) == 1, "F32 zeros equal");
  expect(op1(s, P111_OP_F32_TO_U32, nan) == 0, "F32 NaN toU32");
  expect(op1(s, P111_OP_F32_TO_U32, UINT64_C(0x4f800000)) == 0, "F32 2^32 toU32");
  expect(op2(s, P111_OP_F32_MUL, UINT64_C(0x40000000), UINT64_C(0x3f000000)) == one, "F32 multiplication bits");
  expect(op1(s, P111_OP_U32_TO_F32, 16777217) == UINT64_C(0x4b800000), "F32 conversion roundstoeven");
  consume_string(s, op1(s, P111_OP_F32_SHOW, UINT64_C(0x3fc00000)), "1.5");
  uint64_t parsed = op1(s, P111_OP_F32_READ, string(s, "1.5"));
  expect(p111_rt_tag(s, parsed) == SOME, "F32 read Some tag");
  uint64_t contents[1]; p111_rt_take(s, parsed, contents, 1);
  expect(contents[0] == UINT64_C(0x3fc00000), "F32 read result bits");
  uint64_t rejected = op1(s, P111_OP_F32_READ, string(s, "1.5x"));
  expect(p111_rt_tag(s, rejected) == NONE, "F32 read refuses trailingtext");
  p111_rt_sink(s, rejected);
}

static void array_controls(P111State *s) {
  uint64_t fields[2];
  uint64_t a = op2(s, P111_OP_ARRAY_NEW, 1, string(s, "a"));
  pair(s, op1(s, P111_OP_ARRAY_CLONE, a), fields);
  a = fields[0]; uint64_t b = fields[1];
  pair(s, op2(s, P111_OP_ARRAY_GET, a, 0), fields);
  a = fields[0]; uint64_t observed = fields[1];
  a = op3(s, P111_OP_ARRAY_SET, a, 0, string(s, "b"));
  consume_string(s, observed, "a"); /* retained get survives replacement */
  pair(s, op2(s, P111_OP_ARRAY_GET, b, 0), fields);
  b = fields[0]; consume_string(s, fields[1], "a");
  pair(s, op3(s, P111_OP_ARRAY_SWAP, a, 1, string(s, "c")), fields);
  a = fields[0]; consume_string(s, fields[1], "a");
  p111_rt_sink(s, a); /* clone remains alive after original release */
  pair(s, op2(s, P111_OP_ARRAY_GET, b, 1), fields);
  b = fields[0]; consume_string(s, fields[1], "a");
  pair(s, op1(s, P111_OP_ARRAY_SIZE, b), fields);
  b = fields[0]; expect(fields[1] == 2, "Array size preserveshandle");
  p111_rt_sink(s, b);

  a = op2(s, P111_OP_ARRAY_NEW, 0, 7);
  pair(s, op3(s, P111_OP_ARRAY_ATOMIC_ADD, a, 0, 5), fields);
  a = fields[0]; expect(fields[1] == 7, "AtomicAdd returnsold");
  uint64_t cas[] = {a, 0, 12, 19};
  pair(s, p111_rt_op(s, P111_OP_ARRAY_ATOMIC_CAS, cas, 4), fields);
  a = fields[0]; expect(fields[1] == 12, "AtomicCAS hit returnsold");
  cas[0] = a; cas[2] = 12; cas[3] = 99;
  pair(s, p111_rt_op(s, P111_OP_ARRAY_ATOMIC_CAS, cas, 4), fields);
  a = fields[0]; expect(fields[1] == 19, "AtomicCAS miss returnsold");
  pair(s, op2(s, P111_OP_ARRAY_GET, a, 0), fields);
  a = fields[0]; expect(fields[1] == 19, "AtomicCAS miss preservesvalue");
  p111_rt_sink(s, a);

  a = op2(s, P111_OP_ARRAY_NEW, 0, UINT64_C(0x3f800000));
  pair(s, op3(s, P111_OP_ARRAY_ATOMIC_FADD, a, 0, UINT64_C(0x3f000000)), fields);
  a = fields[0]; expect(fields[1] == UINT64_C(0x3f800000), "AtomicFADD returnsoldbits");
  pair(s, op2(s, P111_OP_ARRAY_GET, a, 0), fields);
  a = fields[0]; expect(fields[1] == UINT64_C(0x3fc00000), "AtomicFADD newbits");
  p111_rt_sink(s, a);
}

static void representation_controls(P111State *s) {
  uint64_t field[2], args[2];
  args[0] = string(s, "leaf");
  uint64_t leaf = p111_rt_special_ctor(s, P111_SPECIAL_ALEAF, args, 1);
  leaf = p111_rt_keep(s, leaf); uint64_t alias = leaf;
  expect(p111_rt_special_test(s, P111_SPECIAL_ALEAF, leaf) == 1, "ALeaf match");
  p111_rt_special_take(s, P111_SPECIAL_ALEAF, leaf, field, 1);
  p111_rt_sink(s, alias); /* extracted child must survive both parent owners */
  consume_string(s, field[0], "leaf");

  args[0] = string(s, "left");
  uint64_t left = p111_rt_special_ctor(s, P111_SPECIAL_ALEAF, args, 1);
  args[0] = string(s, "right");
  uint64_t right = p111_rt_special_ctor(s, P111_SPECIAL_ALEAF, args, 1);
  args[0] = left; args[1] = right;
  uint64_t node = p111_rt_special_ctor(s, P111_SPECIAL_ANODE, args, 2);
  node = p111_rt_keep(s, node); alias = node;
  expect(p111_rt_special_test(s, P111_SPECIAL_ANODE, node) == 1, "ANode match");
  p111_rt_special_take(s, P111_SPECIAL_ANODE, node, field, 2);
  left = field[0]; right = field[1];
  p111_rt_sink(s, alias);
  p111_rt_special_take(s, P111_SPECIAL_ALEAF, left, field, 1);
  consume_string(s, field[0], "left");
  p111_rt_special_take(s, P111_SPECIAL_ALEAF, right, field, 1);
  consume_string(s, field[0], "right");

  p111_rt_special_take(s, P111_SPECIAL_U32, UINT32_C(0xa5a55a5a), field, 1);
  expect(p111_rt_special_ctor(s, P111_SPECIAL_U32, field, 1) == UINT32_C(0xa5a55a5a), "U32 Word roundtrip");
  p111_rt_special_take(s, P111_SPECIAL_F32, UINT32_C(0x80000000), field, 1);
  expect(p111_rt_special_ctor(s, P111_SPECIAL_F32, field, 1) == UINT32_C(0x80000000), "F32 Word preservesnegativezero");
}

static uint64_t boundary_segment(P111State *state) {
  if (!strcmp(chosen, "scalars")) scalar_controls(state);
  else if (!strcmp(chosen, "floats")) float_controls(state);
  else if (!strcmp(chosen, "arrays")) array_controls(state);
  else if (!strcmp(chosen, "representations")) representation_controls(state);
  else if (!strcmp(chosen, "nat-add-overflow")) (void)op2(state, P111_OP_NAT_ADD, UINT64_C(0xffffffffffff), 1);
  else if (!strcmp(chosen, "nat-mul-overflow")) (void)op2(state, P111_OP_NAT_MUL, UINT64_C(0x800000000000), 2);
  else if (!strcmp(chosen, "nat-double-overflow")) (void)op1(state, P111_OP_NAT_DOUBLE, UINT64_C(0xffffffffffff));
  else if (!strcmp(chosen, "succ-overflow")) {
    uint64_t value = UINT64_C(0xffffffffffff);
    (void)p111_rt_special_ctor(state, P111_SPECIAL_SUCC, &value, 1);
  } else if (!strcmp(chosen, "wrong-primitive-arity")) {
    (void)p111_rt_op(state, P111_OP_U32_ADD, NULL, 0);
  } else if (!strcmp(chosen, "unknown-primitive")) {
    (void)p111_rt_op(state, P111_OP_LIMIT, NULL, 0);
  } else { fputs("boundary: unknown case\n", stderr); exit(2); }
  if (checks == 0) { fputs("boundary: rejection unexpectedly returned\n", stderr); exit(3); }
  printf("%s:ok\n", chosen);
  uint64_t zero = 0;
  return p111_rt_return(state, &zero, 1);
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
  if (argc != 2) { fputs("usage: boundary-controls CASE\n", stderr); return 2; }
  chosen = argv[1];
  char *runtime_argv[] = {argv[0], "--threads", "1", "--gpu", "off", NULL};
  return p111_rt_main(5, runtime_argv, &program);
}
