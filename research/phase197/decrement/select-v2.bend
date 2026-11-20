# Copy + full-width immediate ADD/SUB -> one LEA. No value/memory motion.
# Refuse until a bounded typed-item scan proves every arithmetic flag dead:
# only CMP/ADD/SUB terminate that proof; carry consumers and all unknown items
# are barriers. Partial flag writers (including shifts by zero) only pass through.
# Signed displacement admission uses both immediate words, never just lo.

type X197DHead is Data:
  X197DHead{+item: X187Parsed, +rest: List<&2,X188Seq>}

@unsafe
def x197d_next(todo: List<&2,X188Seq>) -> Maybe<&2,X197DHead>:
  match todo:
    case Nil{}: None{}
    case Con{X188Empty{},rest}: x197d_next(rest)
    case Con{X188Join{left,right},rest}: x197d_next(Con{left,Con{right,rest}})
    case Con{X188One{item},rest}: Some{X197DHead{item,rest}}

@unsafe
def x197d_flag_kill(+op: String) -> Bool:
  String.eq(op,"cmpq") || String.eq(op,"cmpl") || String.eq(op,"addq") ||
    String.eq(op,"addl") || String.eq(op,"subq") || String.eq(op,"subl")

@unsafe
def x197d_flag_pass(+op: String) -> Bool:
  String.eq(op,"movq") || String.eq(op,"movl") || String.eq(op,"movabsq") ||
    String.eq(op,"movzbl") || String.eq(op,"leaq") || String.eq(op,"shrq") ||
    String.eq(op,"shrl") || String.eq(op,"shlq") || String.eq(op,"shll") ||
    String.eq(op,"sarq") || String.eq(op,"sarl") || String.eq(op,"andq") ||
    String.eq(op,"andl") || String.eq(op,"orq") || String.eq(op,"orl") ||
    String.eq(op,"xorq") || String.eq(op,"xorl")

law x197d_flags_dead:
  for todo: List<&2,X188Seq>
  for +budget: U32
  Bool

@unsafe
def x197d_flags_next(next: Maybe<&2,X197DHead>, budget: U32) -> Bool:
  match next:
    case Some{X197DHead{PInst{X187Instruction{+op,[a,b]}},rest}}:
      nt_choose(Bool,x197d_flag_kill(op),u => True{},u =>
        nt_choose(Bool,x197d_flag_pass(op),v => x197d_flags_dead(rest,budget),v => False{}))
    case _: False{}

@unsafe
def x197d_flags_dead(todo,budget):
  nt_choose(Bool,U32.is_gt(budget,0),u => x197d_flags_next(x197d_next(todo),U32.sub(budget,1)),u => False{})

# Both operands must already be valid signed32 machine immediates. Negating
# INT32_MIN cannot fit a LEA displacement and retains the exact original pair.
@unsafe
def x197d_displacement(+op: String, +lo: U32, +hi: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,x187_e_signed32(lo,hi),u =>
    nt_choose(Maybe<&2,U32>,String.eq(op,"addq"),v => Some{lo},v =>
      nt_choose(Maybe<&2,U32>,String.eq(op,"subq") && Bool.not(U32.is_eq(lo,2147483648)),
        w => Some{U32.sub(0,lo)},w => None{})),u => None{})

law x197d_work:
  for todo: List<&2,X188Seq>
  for output: List<&2,X188Seq>
  X188Seq

@unsafe
def x197d_admit(displacement: Maybe<&2,U32>, +source: U32, +destination: U32,
    +after: List<&2,X188Seq>, original: X187Parsed, rest: List<&2,X188Seq>, +output: List<&2,X188Seq>) -> X188Seq:
  match displacement:
    case Some{disp}:
      nt_choose(X188Seq,x197d_flags_dead(after,16),
        u => x197d_work(after,Con{x188_i2("leaq",X187Mem{source,disp},x188_reg(destination,64)),output}),
        u => x197d_work(rest,Con{X188One{original},output}))
    case None{}: x197d_work(rest,Con{X188One{original},output})

@unsafe
def x197d_second(next: Maybe<&2,X197DHead>, source: U32, +destination: U32,
    original: X187Parsed, rest: List<&2,X188Seq>, output: List<&2,X188Seq>) -> X188Seq:
  match next:
    case Some{X197DHead{PInst{X187Instruction{op,[X187Imm{lo,hi},X187Reg{target,64,False{}}]}},after}}:
      x197d_admit(nt_choose(Maybe<&2,U32>,U32.is_eq(target,destination),
        u => x197d_displacement(op,lo,hi),u => None{}),source,destination,after,original,rest,output)
    case _: x197d_work(rest,Con{X188One{original},output})

@unsafe
def x197d_step(+item: X187Parsed, +rest: List<&2,X188Seq>, +output: List<&2,X188Seq>) -> X188Seq:
  match item:
    case PInst{X187Instruction{op,[X187Reg{+source,64,False{}},X187Reg{+destination,64,False{}}]}}:
      nt_choose(X188Seq,String.eq(op,"movq") && x191_ff_register(source) &&
          x191_ff_register(destination) && Bool.not(U32.is_eq(source,destination)),
        u => x197d_second(x197d_next(rest),source,destination,item,rest,output),
        u => x197d_work(rest,Con{X188One{item},output}))
    case _: x197d_work(rest,Con{X188One{item},output})

@unsafe
def x197d_work(todo,output):
  match todo:
    case Nil{}: x188_finish(output)
    case Con{X188Empty{},rest}: x197d_work(rest,output)
    case Con{X188Join{left,right},rest}: x197d_work(Con{left,Con{right,rest}},output)
    case Con{X188One{item},rest}: x197d_step(item,rest,output)

@unsafe
def x197d_select(code: X188Seq) -> X188Seq:
  x197d_work([code],[])
