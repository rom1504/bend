/* Finite source-audited primitive switch, never a C-program-body parser. */
#include "primitives.h"

static bool p111_native_bool(Term t) {
  return t == 1 || (term_tag(t) == TAG_PAK && term_aux(t) == CID_TRUE);
}

static Term p111_native_word(Env e, u32 x) {
  Term w = term_pak(CID_WNIL, 0);
  for (u32 i = 32; i > 0; i--) {
    Loc p = heap_alloc(e, 1);
    e.mem[p] = (x >> (i - 1)) & 1;
    e.mem[p + 1] = rfc_seal(e, w);
    w = term_ctr(CID_WCON, p);
  }
  return w;
}

static Term p111_tuple(Env e, Term first, Term second) {
  Loc at = heap_alloc(e, cls_fit(2));
  e.mem[at] = rfc_seal(e, first);
  e.mem[at + 1] = rfc_seal(e, second);
  return term_ctr(CID_TUPLE, at);
}

static void p111_primitive_arity(u32 actual, u32 expected) {
  if (actual != expected) err_fail("phase111: primitive arity mismatch");
}

uint64_t p111_rt_op(P111State *state, uint32_t op, const uint64_t *args, uint32_t count) {
  Env e = state->e;
  switch (op) {
    case P111_OP_U32_ADD: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], +, args[1]);
    }
    case P111_OP_U32_SUB: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], -, args[1]);
    }
    case P111_OP_U32_AND: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], &, args[1]);
    }
    case P111_OP_U32_OR: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], |, args[1]);
    }
    case P111_OP_U32_XOR: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], ^, args[1]);
    }
    case P111_OP_U32_MUL: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], *, args[1]);
    }
    case P111_OP_U32_IS_EQ: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], ==, args[1]);
    }
    case P111_OP_U32_IS_NE: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], !=, args[1]);
    }
    case P111_OP_U32_IS_LT: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], <, args[1]);
    }
    case P111_OP_U32_IS_LE: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], <=, args[1]);
    }
    case P111_OP_U32_IS_GT: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], >, args[1]);
    }
    case P111_OP_U32_IS_GE: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], >=, args[1]);
    }
    case P111_OP_U32_INC: {
      p111_primitive_arity(count, 1);
      return U32_BIN(args[0], +, 1);
    }
    case P111_OP_U32_SHL: {
      p111_primitive_arity(count, 1);
      return U32_BIN(args[0], <<, 1);
    }
    case P111_OP_U32_SHR: {
      p111_primitive_arity(count, 1);
      return U32_BIN(args[0], >>, 1);
    }
    case P111_OP_U32_SHLN: {
      p111_primitive_arity(count, 2);
      return (args[1] >= 32 ? 0 : U32_BIN(args[0], <<, args[1]));
    }
    case P111_OP_U32_SHRN: {
      p111_primitive_arity(count, 2);
      return (args[1] >= 32 ? 0 : U32_BIN(args[0], >>, args[1]));
    }
    case P111_OP_U32_DIV: {
      p111_primitive_arity(count, 2);
      return ((u32)(args[1]) == 0 ? 0 : (u64)U32_QUO((u32)(args[0]), (u32)(args[1])));
    }
    case P111_OP_U32_MOD: {
      p111_primitive_arity(count, 2);
      return ((u32)(args[1]) == 0 ? args[0] : U32_BIN(args[0], -, U32_QUO((u32)(args[0]), (u32)(args[1])) * args[1]));
    }
    case P111_OP_U32_NOT: {
      p111_primitive_arity(count, 1);
      return ((u64)~(u32)(args[0]));
    }
    case P111_OP_U32_IS_ZERO: {
      p111_primitive_arity(count, 1);
      return U32_BIN(args[0], ==, 0);
    }
    case P111_OP_U32_CMP: {
      p111_primitive_arity(count, 2);
      Term cmp = (U32_BIN(args[0], >, args[1]) + U32_BIN(args[0], >=, args[1]));
      return term_pak(cmp == 0 ? CID_LT : cmp == 1 ? CID_EQ : CID_GT, 0);
    }
    case P111_OP_U32_TO_F32: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)(u32)(args[0]));
    }
    case P111_OP_U32_TO_NAT: {
      p111_primitive_arity(count, 1);
      return ((u64)args[0]);
    }
    case P111_OP_U32_FROM_NAT: {
      p111_primitive_arity(count, 1);
      return ((u64)(u32)(args[0]));
    }
    case P111_OP_F32_ADD: {
      p111_primitive_arity(count, 2);
      return f32_rewrap(f32_unbox(args[0]) + f32_unbox(args[1]));
    }
    case P111_OP_F32_SUB: {
      p111_primitive_arity(count, 2);
      return f32_rewrap(f32_unbox(args[0]) - f32_unbox(args[1]));
    }
    case P111_OP_F32_MUL: {
      p111_primitive_arity(count, 2);
      return f32_rewrap(f32_unbox(args[0]) * f32_unbox(args[1]));
    }
    case P111_OP_F32_DIV: {
      p111_primitive_arity(count, 2);
      return f32_rewrap(f32_unbox(args[0]) / f32_unbox(args[1]));
    }
    case P111_OP_F32_IS_EQ: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) == f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_NE: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) != f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_LT: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) < f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_LE: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) <= f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_GT: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) > f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_GE: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) >= f32_unbox(args[1])));
    }
    case P111_OP_F32_SQRT: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)sqrt(f32_unbox(args[0])));
    }
    case P111_OP_F32_EXP: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)exp(f32_unbox(args[0])));
    }
    case P111_OP_F32_LOG: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)log(f32_unbox(args[0])));
    }
    case P111_OP_F32_LOG2: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)log2(f32_unbox(args[0])));
    }
    case P111_OP_F32_LOG10: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)log10(f32_unbox(args[0])));
    }
    case P111_OP_F32_SIN: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)sin(f32_unbox(args[0])));
    }
    case P111_OP_F32_COS: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)cos(f32_unbox(args[0])));
    }
    case P111_OP_F32_TAN: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)tan(f32_unbox(args[0])));
    }
    case P111_OP_F32_ASIN: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)asin(f32_unbox(args[0])));
    }
    case P111_OP_F32_ACOS: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)acos(f32_unbox(args[0])));
    }
    case P111_OP_F32_ATAN: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)atan(f32_unbox(args[0])));
    }
    case P111_OP_F32_SINH: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)sinh(f32_unbox(args[0])));
    }
    case P111_OP_F32_COSH: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)cosh(f32_unbox(args[0])));
    }
    case P111_OP_F32_TANH: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)tanh(f32_unbox(args[0])));
    }
    case P111_OP_F32_FLOOR: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)floor(f32_unbox(args[0])));
    }
    case P111_OP_F32_CEIL: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)ceil(f32_unbox(args[0])));
    }
    case P111_OP_F32_TRUNC: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)trunc(f32_unbox(args[0])));
    }
    case P111_OP_F32_ABS: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)fabs(f32_unbox(args[0])));
    }
    case P111_OP_F32_POW: {
      p111_primitive_arity(count, 2);
      return f32_rewrap((f32)pow(f32_unbox(args[0]), f32_unbox(args[1])));
    }
    case P111_OP_F32_ATAN2: {
      p111_primitive_arity(count, 2);
      return f32_rewrap((f32)atan2(f32_unbox(args[0]), f32_unbox(args[1])));
    }
    case P111_OP_F32_MOD: {
      p111_primitive_arity(count, 2);
      return f32_rewrap((f32)fmod(f32_unbox(args[0]), f32_unbox(args[1])));
    }
    case P111_OP_F32_NEG: {
      p111_primitive_arity(count, 1);
      return f32_rewrap(-f32_unbox(args[0]));
    }
    case P111_OP_F32_TO_U32: {
      p111_primitive_arity(count, 1);
      return f32_to_u32(args[0]);
    }
    case P111_OP_F32_BITS: {
      p111_primitive_arity(count, 1);
      return args[0];
    }
    case P111_OP_F32_SHOW: {
      p111_primitive_arity(count, 1);
      return f32_show(e, args[0]);
    }
    case P111_OP_F32_READ: {
      p111_primitive_arity(count, 1);
      return f32_read(e, args[0]);
    }
    case P111_OP_NAT_ADD: {
      p111_primitive_arity(count, 2);
      return nat_chk(e, args[0] + args[1]);
    }
    case P111_OP_NAT_SUB: {
      p111_primitive_arity(count, 2);
      return (args[0] < args[1] ? 0 : args[0] - args[1]);
    }
    case P111_OP_NAT_MUL: {
      p111_primitive_arity(count, 2);
      return nat_mul(e, args[0], args[1]);
    }
    case P111_OP_NAT_DOUBLE: {
      p111_primitive_arity(count, 1);
      return nat_chk(e, args[0] + args[0]);
    }
    case P111_OP_NAT_CMP: {
      p111_primitive_arity(count, 2);
      Term cmp = ((args[0] > args[1]) + (args[0] >= args[1]));
      return term_pak(cmp == 0 ? CID_LT : cmp == 1 ? CID_EQ : CID_GT, 0);
    }
    case P111_OP_NAT_IS_LT: {
      p111_primitive_arity(count, 2);
      return (args[0] < args[1]);
    }
    case P111_OP_BOOL_OR: {
      p111_primitive_arity(count, 2);
      return (p111_native_bool(args[0]) | p111_native_bool(args[1]));
    }
    case P111_OP_BOOL_XOR: {
      p111_primitive_arity(count, 2);
      return (p111_native_bool(args[0]) ^ p111_native_bool(args[1]));
    }
    /* Additional owned results from nc_intrinsic_value/nc_array_value. */
    case P111_OP_NAT_DIVMOD: {
      p111_primitive_arity(count, 2);
      Term a = args[0], b = args[1];
      return p111_tuple(e, b == 0 ? 0 : a / b, b == 0 ? a : a % b);
    }
    case P111_OP_ARRAY_NEW: {
      p111_primitive_arity(count, 2);
      Term init[1] = {args[1]};
      return blk_new(e, !NATIVE_SCALAR_ARRAYS, args[0], 0, 1, init);
    }
    case P111_OP_ARRAY_GET: {
      p111_primitive_arity(count, 2);
      Term got = native_array_get(e, args[0], args[1]);
      return p111_tuple(e, args[0], got);
    }
    case P111_OP_ARRAY_SET: {
      p111_primitive_arity(count, 3);
      native_array_set(e, args[0], args[1], args[2]);
      return args[0];
    }
    case P111_OP_ARRAY_SWAP: {
      p111_primitive_arity(count, 3);
      Term old = native_array_swap(e, args[0], args[1], args[2]);
      return p111_tuple(e, args[0], old);
    }
    case P111_OP_ARRAY_SIZE: {
      p111_primitive_arity(count, 1);
      return p111_tuple(e, args[0], 1ull << blk_cls(args[0]));
    }
    case P111_OP_ARRAY_CLONE: {
      p111_primitive_arity(count, 1);
      Term copy = blk_copy(e, args[0]);
      return p111_tuple(e, args[0], copy);
    }
    case P111_OP_ARRAY_ATOMIC_ADD:
    case P111_OP_ARRAY_ATOMIC_MIN:
    case P111_OP_ARRAY_ATOMIC_MAX:
    case P111_OP_ARRAY_ATOMIC_AND:
    case P111_OP_ARRAY_ATOMIC_OR:
    case P111_OP_ARRAY_ATOMIC_XOR:
    case P111_OP_ARRAY_ATOMIC_EXCH:
    case P111_OP_ARRAY_ATOMIC_CAS:
    case P111_OP_ARRAY_ATOMIC_FADD: {
      p111_primitive_arity(count, op == P111_OP_ARRAY_ATOMIC_CAS ? 4 : 3);
      /* This contiguous catalogue order is exactly nc_atomic's 1..9. */
      u32 atomic_op = op - P111_OP_ARRAY_ATOMIC_ADD + 1;
      Term old = array_atomic(e, args[0], args[1], args[2],
        op == P111_OP_ARRAY_ATOMIC_CAS ? args[3] : 0, atomic_op);
      return p111_tuple(e, args[0], old);
    }
    default:
      err_fail("phase111: unknown primitive ID");
      return 0;
  }
}

static u32 p111_special_arity(u32 kind) {
  switch (kind) {
    case P111_SPECIAL_FALSE:
    case P111_SPECIAL_TRUE:
    case P111_SPECIAL_ZERO: return 0;
    case P111_SPECIAL_SUCC:
    case P111_SPECIAL_CHR:
    case P111_SPECIAL_U32:
    case P111_SPECIAL_F32:
    case P111_SPECIAL_ALEAF: return 1;
    case P111_SPECIAL_ANODE: return 2;
    default:
      err_fail("phase111: unknown special constructor ID");
      return 0;
  }
}

uint64_t p111_rt_special_ctor(P111State *state, uint32_t kind,
                             const uint64_t *args, uint32_t count) {
  Env e = state->e;
  p111_primitive_arity(count, p111_special_arity(kind));
  switch (kind) {
    case P111_SPECIAL_FALSE:
    case P111_SPECIAL_ZERO: return 0;
    case P111_SPECIAL_TRUE: return 1;
    case P111_SPECIAL_SUCC: return nat_chk(e, args[0] + 1);
    case P111_SPECIAL_CHR: return args[0];
    case P111_SPECIAL_U32:
    case P111_SPECIAL_F32: return term_word(e, args[0]);
    case P111_SPECIAL_ALEAF: {
      Term init[1] = {args[0]};
      return blk_new(e, !NATIVE_SCALAR_ARRAYS, 0, 0, 1, init);
    }
    case P111_SPECIAL_ANODE: return blk_node(e, args[0], args[1]);
    default:
      err_fail("phase111: unknown special constructor ID");
      return 0;
  }
}

uint64_t p111_rt_special_test(P111State *state, uint32_t kind, uint64_t term) {
  (void)state;
  switch (kind) {
    case P111_SPECIAL_FALSE: return !p111_native_bool(term);
    case P111_SPECIAL_TRUE: return p111_native_bool(term);
    case P111_SPECIAL_ZERO: return term == 0;
    case P111_SPECIAL_SUCC: return term != 0;
    case P111_SPECIAL_CHR:
    case P111_SPECIAL_U32:
    case P111_SPECIAL_F32: return 1;
    case P111_SPECIAL_ALEAF: return blk_cls(term) == 0;
    case P111_SPECIAL_ANODE: return blk_cls(term) != 0;
    default:
      err_fail("phase111: unknown special constructor ID");
      return 0;
  }
}

uint64_t p111_rt_special_take(P111State *state, uint32_t kind, uint64_t term,
                             uint64_t *out, uint32_t count) {
  Env e = state->e;
  p111_primitive_arity(count, p111_special_arity(kind));
  switch (kind) {
    case P111_SPECIAL_FALSE:
    case P111_SPECIAL_TRUE:
    case P111_SPECIAL_ZERO: break;
    case P111_SPECIAL_SUCC: out[0] = term - 1; break;
    case P111_SPECIAL_CHR: out[0] = term; break;
    case P111_SPECIAL_U32:
    case P111_SPECIAL_F32: out[0] = p111_native_word(e, (u32)term); break;
    case P111_SPECIAL_ALEAF:
      out[0] = blk_leaf(e, term);
      blk_free(e, term);
      break;
    case P111_SPECIAL_ANODE:
      /* The low half borrows the parent; the high half releases its shell. */
      out[0] = blk_half(e, term, 0);
      out[1] = blk_half(e, term, 1);
      break;
    default:
      err_fail("phase111: unknown special constructor ID");
      return 0;
  }
  return count;
}
