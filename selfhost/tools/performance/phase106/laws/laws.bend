import Base
import ./candidate.bend as H
import ./reference.bend as R

# Support: relate the independently written Bool-to-word functions explicitly.
# Their applications can remain neutral until the Bool argument is scrutinized.
law bool_word_exact:
  for value: Bool
  {H.nx_bool32(value) == R.bool_word(value) : U32}

def bool_word_exact(value):
  match value:
    case True{}: {==}
    case False{}: {==}

# The candidate is an exact source extraction, created by prepare.mjs.
# These quantify over every U32 input, not a chosen finite boundary corpus.
law fold_add_exact:
  for +a: U32
  for +b: U32
  {H.nx_fold_bin("add", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}) == H.NxConst{H.NxU32{}, R.evaluate(R.ScalarAdd{}, a, b)} : H.NxExpr}

def fold_add_exact(a, b): {==}

law fold_sub_exact:
  for +a: U32
  for +b: U32
  {H.nx_fold_bin("sub", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}) == H.NxConst{H.NxU32{}, R.evaluate(R.ScalarSub{}, a, b)} : H.NxExpr}

def fold_sub_exact(a, b): {==}

law fold_mul_exact:
  for +a: U32
  for +b: U32
  {H.nx_fold_bin("mul", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}) == H.NxConst{H.NxU32{}, R.evaluate(R.ScalarMul{}, a, b)} : H.NxExpr}

def fold_mul_exact(a, b): {==}

law fold_and_exact:
  for +a: U32
  for +b: U32
  {H.nx_fold_bin("and", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}) == H.NxConst{H.NxU32{}, R.evaluate(R.ScalarAnd{}, a, b)} : H.NxExpr}

def fold_and_exact(a, b): {==}

law fold_or_exact:
  for +a: U32
  for +b: U32
  {H.nx_fold_bin("or", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}) == H.NxConst{H.NxU32{}, R.evaluate(R.ScalarOr{}, a, b)} : H.NxExpr}

def fold_or_exact(a, b): {==}

law fold_xor_exact:
  for +a: U32
  for +b: U32
  {H.nx_fold_bin("xor", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}) == H.NxConst{H.NxU32{}, R.evaluate(R.ScalarXor{}, a, b)} : H.NxExpr}

def fold_xor_exact(a, b): {==}

law fold_eq_exact:
  for +a: U32
  for +b: U32
  {H.nx_fold_bin("eq", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}) == H.NxConst{H.NxU32{}, R.evaluate(R.ScalarEq{}, a, b)} : H.NxExpr}

def fold_eq_exact(a, b):
  Equal.cong(U32, H.NxExpr, value => H.NxConst{H.NxU32{}, value},
    H.nx_bool32(U32.is_eq(a, b)), R.bool_word(U32.is_eq(a, b)),
    bool_word_exact(U32.is_eq(a, b)))

law fold_ult_exact:
  for +a: U32
  for +b: U32
  {H.nx_fold_bin("ult", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}) == H.NxConst{H.NxU32{}, R.evaluate(R.ScalarUlt{}, a, b)} : H.NxExpr}

def fold_ult_exact(a, b):
  Equal.cong(U32, H.NxExpr, value => H.NxConst{H.NxU32{}, value},
    H.nx_bool32(U32.is_lt(a, b)), R.bool_word(U32.is_lt(a, b)),
    bool_word_exact(U32.is_lt(a, b)))

# U64 literals currently hold a U32 payload; preserving their type is essential.
law fold_u64_preserves:
  for +op: String
  for +a: U32
  for +b: U32
  {H.nx_fold_bin(op, H.NxConst{H.NxU64{}, a}, H.NxConst{H.NxU64{}, b}) == H.NxBin{op, H.NxConst{H.NxU64{}, a}, H.NxConst{H.NxU64{}, b}} : H.NxExpr}

def fold_u64_preserves(op, a, b): {==}

law fold_mixed_preserves:
  for +op: String
  for +a: U32
  for +b: U32
  {H.nx_fold_bin(op, H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU64{}, b}) == H.NxBin{op, H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU64{}, b}} : H.NxExpr}

def fold_mixed_preserves(op, a, b): {==}

law fold_unknown_preserves:
  for +a: U32
  for +b: U32
  {H.nx_fold_bin("unknown", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}) == H.NxBin{"unknown", H.NxConst{H.NxU32{}, a}, H.NxConst{H.NxU32{}, b}} : H.NxExpr}

def fold_unknown_preserves(a, b): {==}

law fold_call_preserves:
  for +op: String
  for +name: String
  for +args: List<&2, H.NxExpr>
  for +b: U32
  {H.nx_fold_bin(op, H.NxCall{name, args}, H.NxConst{H.NxU32{}, b}) == H.NxBin{op, H.NxCall{name, args}, H.NxConst{H.NxU32{}, b}} : H.NxExpr}

def fold_call_preserves(op, name, args, b): {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
