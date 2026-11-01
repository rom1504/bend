# Diagnostic controls compare complete values; timing checksums only force work.
# Shared loops have identical consumers for either selected dispatch function.
# Input parsing finishes before IO.now. The external guard also charges startup,
# reporting and any remaining reclamation; region_ms is only the local clock.
@unsafe
def p151p_same(a: List<&2,U32>, b: List<&2,U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}:
      p151_choose(Bool,U32.is_eq(x,y),u => p151p_same(xs,ys),u => False{})
    case _ _: False{}

@unsafe
def p151p_expect_roles(+tag: U32, +want: List<&2,U32>) -> Bool:
  p151p_same(p88_roles(tag),want) && p151p_same(p151_roles(tag),want)

@unsafe
def p151p_expect_binary(+id: U32, +want: String) -> Bool:
  String.eq(p112fp_binary(id),want) && String.eq(p151_binary(id),want)

# Independently written finite table expectations check both implementations.
@unsafe
def p151p_tables() -> Bool:
  p151p_expect_roles(0,[]) &&
  p151p_expect_roles(1,[13,14]) &&
  p151p_expect_roles(2,[3,3,1,1,6,8,1,1]) &&
  p151p_expect_roles(3,[3,1,1,6,8,1,1,2]) &&
  p151p_expect_roles(4,[3,1,3,1,1]) &&
  p151p_expect_roles(5,[3,3,1,1,4,4,7,2,2]) &&
  p151p_expect_roles(6,[1,7]) &&
  p151p_expect_roles(7,[1,1,5,5]) &&
  p151p_expect_roles(8,[1,1,1,7,2]) &&
  p151p_expect_roles(9,[1,2]) &&
  p151p_expect_roles(10,[9,7,7,7,7,7,1,1]) &&
  p151p_expect_roles(11,[5,5,1,2]) &&
  p151p_expect_roles(12,[]) && p151p_expect_roles(4294967295,[]) &&
  p151p_expect_binary(26,"add") && p151p_expect_binary(27,"sub") &&
  p151p_expect_binary(28,"mul") && p151p_expect_binary(29,"div") &&
  p151p_expect_binary(30,"ceqs") && p151p_expect_binary(31,"cnes") &&
  p151p_expect_binary(32,"clts") && p151p_expect_binary(33,"cles") &&
  p151p_expect_binary(34,"cgts") && p151p_expect_binary(35,"cges") &&
  p151p_expect_binary(0,"INVALID_P112_FLOAT_OPERATION") &&
  p151p_expect_binary(25,"INVALID_P112_FLOAT_OPERATION") &&
  p151p_expect_binary(36,"INVALID_P112_FLOAT_OPERATION") &&
  p151p_expect_binary(4294967295,"INVALID_P112_FLOAT_OPERATION")

@unsafe
def p151p_comparator_controls() -> Bool:
  p151p_same([],[]) && p151p_same([1,2],[1,2]) &&
  Bool.not(p151p_same([1,2],[1,3])) && Bool.not(p151p_same([1,2],[2,1])) &&
  Bool.not(p151p_same([1,2],[1])) && Bool.not(p151p_same([1],[1,2])) &&
  String.eq("add","add") && Bool.not(String.eq("add","sub")) &&
  Bool.not(String.eq("add","add\0")) && Bool.not(String.eq("","add"))

@unsafe
def p151p_case(+id: U32) -> Bool:
  p151p_same(p88_roles(id),p151_roles(id)) &&
  String.eq(p112fp_binary(id),p151_binary(id)) &&
  p151_choose(Bool,U32.is_gt(id,11),u => p151p_expect_roles(id,[]),u => True{}) &&
  p151_choose(Bool,U32.is_lt(id,26) || U32.is_gt(id,35),
    u => p151p_expect_binary(id,"INVALID_P112_FLOAT_OPERATION"),u => True{})

@unsafe
def p151p_range(+left: U32, +next: U32) -> Bool:
  p151_choose(Bool,U32.is_eq(left,0),u => True{},
    u => p151p_case(next) && p151p_range(U32.sub(left,1),U32.add(next,1)))

# 514 exact paired inputs: every 0..255, 64 low-bit aliases at each of
# bits 8/16/31, 64 inputs spanning U32 wrap, and two preceding boundaries.
@unsafe
def p151p_ranges() -> Bool:
  p151p_range(256,0) && p151p_range(64,256) && p151p_range(64,65536) &&
  p151p_range(64,2147483648) && p151p_range(64,4294967264) &&
  p151p_case(65535) && p151p_case(2147483647)

def p151p_word(value: U32, hash: U32) -> U32:
  U32.mul(U32.xor(hash,value),16777619)

@unsafe
def p151p_words(words: List<&2,U32>, hash: U32) -> U32:
  match words:
    case Nil{}: p151p_word(4294967295,hash)
    case Con{head,rest}: p151p_words(rest,p151p_word(head,hash))

@unsafe
def p151p_text(text: String, hash: U32) -> U32:
  match text:
    case SNil{}: p151p_word(1100000,hash)
    case SCon{head,rest}: p151p_text(rest,p151p_word(Char.to_u32(head),hash))

# Both loops consume every output element and mix the unmasked input as well.
# Roles visit 0..15; binary visits 26..41, including all successes and fallbacks.
# Seed increments with U32 wrap. COUNT controls cost without constructing input.
@unsafe
def p151p_roles_select(candidate: Bool, tag: U32) -> List<&2,U32>:
  match candidate:
    case False{}: p88_roles(tag)
    case True{}: p151_roles(tag)

@unsafe
def p151p_binary_select(candidate: Bool, id: U32) -> String:
  match candidate:
    case False{}: p112fp_binary(id)
    case True{}: p151_binary(id)

@unsafe
def p151p_roles_loop(+candidate: Bool, +left: U32, +next: U32, +hash: U32) -> U32:
  p151_choose(U32,U32.is_eq(left,0),u => hash,
    u => p151p_roles_loop(candidate,U32.sub(left,1),U32.add(next,1),
      p151p_words(p151p_roles_select(candidate,U32.and(next,15)),p151p_word(next,hash))))

@unsafe
def p151p_binary_loop(+candidate: Bool, +left: U32, +next: U32, +hash: U32) -> U32:
  p151_choose(U32,U32.is_eq(left,0),u => hash,
    u => p151p_binary_loop(candidate,U32.sub(left,1),U32.add(next,1),
      p151p_text(p151p_binary_select(candidate,U32.add(U32.and(next,15),26)),p151p_word(next,hash))))

@unsafe
def p151p_roles_reference(count: U32, seed: U32) -> U32:
  p151p_roles_loop(False{},count,seed,2166136261)

@unsafe
def p151p_roles_candidate(count: U32, seed: U32) -> U32:
  p151p_roles_loop(True{},count,seed,2166136261)

@unsafe
def p151p_binary_reference(count: U32, seed: U32) -> U32:
  p151p_binary_loop(False{},count,seed,2166136261)

@unsafe
def p151p_binary_candidate(count: U32, seed: U32) -> U32:
  p151p_binary_loop(True{},count,seed,2166136261)

@unsafe
def p151p_loop_case(+count: U32, +seed: U32) -> Bool:
  U32.is_eq(p151p_roles_reference(count,seed),p151p_roles_candidate(count,seed)) &&
  U32.is_eq(p151p_binary_reference(count,seed),p151p_binary_candidate(count,seed))

@unsafe
def p151p_loop_controls() -> Bool:
  p151p_loop_case(0,0) && p151p_loop_case(1,4294967295) &&
  p151p_loop_case(65,0) && p151p_loop_case(65,2147483648) && p151p_loop_case(65,4294967294)

@unsafe
def p151p_controls() -> Bool:
  p151p_comparator_controls() && p151p_tables() && p151p_ranges() && p151p_loop_controls()

@unsafe
def p151p_controls_done(good: Bool) -> IO(U32):
  match good:
    case False{}: IO.die(U32,1,"phase151 dispatch control failed")
    case True{}:
      do IO<U32>:
        Unit <- IO.print("phase151 exact_input_pairs 514")
        Unit <- IO.print("phase151 independent_table_cases 28")
        Unit <- IO.print("phase151 comparator_controls 10")
        Unit <- IO.print("phase151 loop_observation_pairs 10")
        Unit <- IO.print("phase151 controls true")
        IO.pure(U32,0)

# The observable zero/nonzero branch demands the final hash before IO.now.
# Its printed label prevents identical-branch elimination from moving the clock.
@unsafe
def p151p_ready(label: String, count: U32, seed: U32, started: Nat, +hash: U32) -> IO(U32):
  p151p_zero(label,count,seed,started,hash,U32.is_eq(hash,0))

@unsafe
def p151p_zero(label: String, count: U32, seed: U32, started: Nat, hash: U32, zero: Bool) -> IO(U32):
  match zero:
    case True{}: p151p_report(label,count,seed,started,hash,"true")
    case False{}: p151p_report(label,count,seed,started,hash,"false")

@unsafe
def p151p_report(label: String, count: U32, seed: U32, started: Nat, hash: U32, zero: String) -> IO(U32):
  do IO<U32>:
    finished : Nat <- IO.now()
    Unit <- IO.print("phase151 mode " ++ label)
    Unit <- IO.print("phase151 region_ms " ++ Nat.show(Nat.sub(finished,started)))
    Unit <- IO.print("phase151 calls " ++ U32.show(count))
    Unit <- IO.print("phase151 seed " ++ U32.show(seed))
    Unit <- IO.print("phase151 hash " ++ U32.show(hash))
    Unit <- IO.print("phase151 hash_zero " ++ zero)
    IO.pure(U32,0)

@unsafe
def p151p_timed(label: String, run: U32 -> U32 -> U32, +count: U32, +seed: U32) -> IO(U32):
  do IO<U32>:
    started : Nat <- IO.now()
    p151p_ready(label,count,seed,started,run(count,seed))

@unsafe
def p151p_mode(+mode: String, +count: U32, +seed: U32) -> IO(U32):
  p151_choose(IO(U32),String.eq(mode,"controls"),u => p151p_controls_done(p151p_controls()),u =>
  p151_choose(IO(U32),String.eq(mode,"reference-roles"),u => p151p_timed(mode,p151p_roles_reference,count,seed),u =>
  p151_choose(IO(U32),String.eq(mode,"candidate-roles"),u => p151p_timed(mode,p151p_roles_candidate,count,seed),u =>
  p151_choose(IO(U32),String.eq(mode,"reference-binary"),u => p151p_timed(mode,p151p_binary_reference,count,seed),u =>
  p151_choose(IO(U32),String.eq(mode,"candidate-binary"),u => p151p_timed(mode,p151p_binary_candidate,count,seed),
    u => IO.die(U32,2,"expected controls, reference-roles, candidate-roles, reference-binary or candidate-binary"))))))

@unsafe
def p151p_parsed(mode: String, count: Maybe<&2,U32>, seed: Maybe<&2,U32>) -> IO(U32):
  match count seed:
    case Some{+n} Some{s}:
      p151_choose(IO(U32),U32.is_le(n,100000000),u => p151p_mode(mode,n,s),u => IO.die(U32,2,"COUNT exceeds 100000000"))
    case _ _: IO.die(U32,2,"expected unsigned COUNT and SEED")

@unsafe
def p151p_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{mode,Con{count,Con{seed,Nil{}}}}}: p151p_parsed(mode,U32.read(count),U32.read(seed))
    case _: IO.die(U32,2,"expected IGNORED MODE COUNT SEED")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p151p_args(args)
