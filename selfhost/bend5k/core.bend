# bend5k/core.bend — Frozen Phase 0 Core Types, Interner, ByteBuf & Helpers
# =========================================================================
# All types are `is Data` (&2) with dense U32 IDs so downstream passes
# (lex, parse, check, lower, opt, regalloc, x64, elf, main) compile cleanly
# under both `bend2 --check-only` and `n9_o2`.

# P111 ABI v11102 Constants
# -------------------------
# sizeof(P111Program) = 192; .data (WA) for p111_cid_hot;
# .rodata (A) for p111_cid_arity / p111_cid_names_*; .text (AX) for code.

def B5K_P111_ABI_VER() -> U32:
  11102
def B5K_P111_DESC_BYTES() -> U32:
  192
def B5K_P111_SEQUENTIAL() -> U32:
  1
def B5K_P111_STOP() -> U32:
  4294967295

# Shared Operator & Condition Codes
# ---------------------------------
# BinOp: 0=ADD 1=SUB 2=MUL 3=DIV 4=MOD 5=AND 6=OR 7=XOR 8=SHL 9=SHR
#        10=FADD 11=FSUB 12=FMUL 13=FDIV
# UnOp:  0=NEG 1=NOT 2=FNEG
# CmpOp: 0=EQ 1=NE 2=LT 3=LE 4=GT 5=GE
# X64CC: 2=B 3=AE 4=E 5=NE 6=BE 7=A 12=L 13=GE 14=LE 15=G

def B5K_OP_ADD() -> U32:
  0
def B5K_OP_SUB() -> U32:
  1
def B5K_OP_MUL() -> U32:
  2
def B5K_OP_DIV() -> U32:
  3
def B5K_OP_MOD() -> U32:
  4
def B5K_OP_AND() -> U32:
  5
def B5K_OP_OR() -> U32:
  6
def B5K_OP_XOR() -> U32:
  7
def B5K_OP_SHL() -> U32:
  8
def B5K_OP_SHR() -> U32:
  9

def B5K_CMP_EQ() -> U32:
  0
def B5K_CMP_NE() -> U32:
  1
def B5K_CMP_LT() -> U32:
  2
def B5K_CMP_LE() -> U32:
  3
def B5K_CMP_GT() -> U32:
  4
def B5K_CMP_GE() -> U32:
  5

# Core Helpers
# ------------

def b5k_str_eq(a: String, b: String) -> Bool:
  String.eq(a, b)

def b5k_list_len_go(-A: Data, xs: List<&2, A>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{_, t}: b5k_list_len_go(A, t, U32.add(acc, 1))

def b5k_list_len(-A: Data, xs: List<&2, A>) -> U32:
  b5k_list_len_go(A, xs, 0)

def b5k_u32_list_len(xs: List<&2, U32>) -> U32:
  b5k_list_len_go(U32, xs, 0)

def b5k_list_rev_go(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: b5k_list_rev_go(A, t, Con{h, acc})

def b5k_list_rev(-A: Data, xs: List<&2, A>) -> List<&2, A>:
  b5k_list_rev_go(A, xs, Nil{})

def b5k_list_app(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:
  b5k_list_rev_go(A, b5k_list_rev_go(A, xs, Nil{}), ys)

def b5k_u32_to_str_go(fuel: Nat, +n: U32, acc: String, z: Bool) -> String:
  match fuel z:
    case 0n _: acc
    case _ True{}: acc
    case 1n+p False{}:
      d = U32.mod(n, 10)
      +q = U32.div(n, 10)
      c = Char.from_u32(U32.add(48, d))
      b5k_u32_to_str_go(p, q, SCon{c, acc}, U32.is_zero(q))

def b5k_u32_to_str_fin(+n: U32, z: Bool) -> String:
  match z:
    case True{}: "0"
    case False{}: b5k_u32_to_str_go(12n, n, "", False{})

def b5k_u32_to_str(+n: U32) -> String:
  b5k_u32_to_str_fin(n, U32.is_zero(n))

# String Interner (SymTab: String <-> U32)
# ----------------------------------------
# Uses Base `Map<&2, U32>` storing `id + 1` (0 = absent) and a 16-level
# binary bit-trie `StrVec` for O(log N) U32 -> String reverse lookup.

type StrVec is Data:
  SVEmpty{}
  SVLeaf{val: String}
  SVNode{lo: StrVec, hi: StrVec}

def strvec_set_go(depth: Nat, +idx: U32, val: String, t: StrVec, is_lo: Bool) -> StrVec:
  match depth t is_lo:
    case 0n _ _: SVLeaf{val}
    case 1n+p SVEmpty{} True{}:
      +nxt = U32.shr(idx)
      SVNode{strvec_set_go(p, nxt, val, SVEmpty{}, U32.is_zero(U32.and(nxt, 1))), SVEmpty{}}
    case 1n+p SVEmpty{} False{}:
      +nxt = U32.shr(idx)
      SVNode{SVEmpty{}, strvec_set_go(p, nxt, val, SVEmpty{}, U32.is_zero(U32.and(nxt, 1)))}
    case 1n+p SVLeaf{_} True{}:
      +nxt = U32.shr(idx)
      SVNode{strvec_set_go(p, nxt, val, SVEmpty{}, U32.is_zero(U32.and(nxt, 1))), SVEmpty{}}
    case 1n+p SVLeaf{_} False{}:
      +nxt = U32.shr(idx)
      SVNode{SVEmpty{}, strvec_set_go(p, nxt, val, SVEmpty{}, U32.is_zero(U32.and(nxt, 1)))}
    case 1n+p SVNode{lo, hi} True{}:
      +nxt = U32.shr(idx)
      SVNode{strvec_set_go(p, nxt, val, lo, U32.is_zero(U32.and(nxt, 1))), hi}
    case 1n+p SVNode{lo, hi} False{}:
      +nxt = U32.shr(idx)
      SVNode{lo, strvec_set_go(p, nxt, val, hi, U32.is_zero(U32.and(nxt, 1)))}

def strvec_get_go(depth: Nat, +idx: U32, t: StrVec, is_lo: Bool) -> String:
  match depth t is_lo:
    case _ SVEmpty{} _: ""
    case _ SVLeaf{v} _: v
    case 0n SVNode{_, _} _: ""
    case 1n+p SVNode{lo, hi} True{}:
      +nxt = U32.shr(idx)
      strvec_get_go(p, nxt, lo, U32.is_zero(U32.and(nxt, 1)))
    case 1n+p SVNode{lo, hi} False{}:
      +nxt = U32.shr(idx)
      strvec_get_go(p, nxt, hi, U32.is_zero(U32.and(nxt, 1)))

type SymTab is Data:
  SymTab{next: U32, by_name: Map<&2, U32>, by_id: StrVec}

type SymRes is Data:
  SymRes{tab: SymTab, id: U32}

def symtab_new() -> SymTab:
  SymTab{0, Map.new(&2, U32), SVEmpty{}}

def symtab_count(st: SymTab) -> U32:
  match st:
    case SymTab{n, _, _}: n

def symtab_name(st: SymTab, +id: U32) -> String:
  match st:
    case SymTab{_, _, by_id}: strvec_get_go(16n, id, by_id, U32.is_zero(U32.and(id, 1)))

def symtab_intern_fin(+next: U32, m1: Map<&2, U32>, by_id: StrVec, +name: String, found: U32, miss: Bool) -> SymRes:
  match miss:
    case True{}:
      m2 = Map.set(&2, U32, m1, name, U32.add(next, 1))
      v2 = strvec_set_go(16n, next, name, by_id, U32.is_zero(U32.and(next, 1)))
      SymRes{SymTab{U32.add(next, 1), m2, v2}, next}
    case False{}:
      SymRes{SymTab{next, m1, by_id}, U32.sub(found, 1)}

def symtab_intern_got(+next: U32, by_id: StrVec, +name: String, got: Map<&2, U32> & U32) -> SymRes:
  (m1, +found) = got
  symtab_intern_fin(next, m1, by_id, name, found, U32.is_zero(found))

def symtab_intern(st: SymTab, +name: String) -> SymRes:
  match st:
    case SymTab{next, by_name, by_id}:
      symtab_intern_got(next, by_id, name, Map.get(U32, 0, by_name, name))

def symtab_lookup_fin(found: U32, miss: Bool) -> Maybe<&2, U32>:
  match miss:
    case True{}: None{}
    case False{}: Some{U32.sub(found, 1)}

def symtab_lookup_got(got: Map<&2, U32> & U32) -> Maybe<&2, U32>:
  (_, +found) = got
  symtab_lookup_fin(found, U32.is_zero(found))

def symtab_lookup(st: SymTab, name: String) -> Maybe<&2, U32>:
  match st:
    case SymTab{_, by_name, _}:
      symtab_lookup_got(Map.get(U32, 0, by_name, name))

# Growable Byte Buffer (ByteBuf)
# ------------------------------
# Stores emitted bytes in reverse for O(1) append; `bb_to_bytes` reverses once.

type ByteBuf is Data:
  ByteBuf{len: U32, rev: List<&2, U32>}

def bb_new() -> ByteBuf:
  ByteBuf{0, Nil{}}

def bb_len(b: ByteBuf) -> U32:
  match b:
    case ByteBuf{n, _}: n

def bb_emit_u8(b: ByteBuf, v: U32) -> ByteBuf:
  match b:
    case ByteBuf{n, rev}: ByteBuf{U32.add(n, 1), Con{U32.and(v, 255), rev}}

def bb_emit_u16(b: ByteBuf, +v: U32) -> ByteBuf:
  bb_emit_u8(bb_emit_u8(b, v), U32.shrn(v, 8n))

def bb_emit_u32(b: ByteBuf, +v: U32) -> ByteBuf:
  b1 = bb_emit_u8(b, v)
  b2 = bb_emit_u8(b1, U32.shrn(v, 8n))
  b3 = bb_emit_u8(b2, U32.shrn(v, 16n))
  bb_emit_u8(b3, U32.shrn(v, 24n))

def bb_emit_u64(b: ByteBuf, lo: U32, hi: U32) -> ByteBuf:
  bb_emit_u32(bb_emit_u32(b, lo), hi)

def bb_emit_str_go(s: String, b: ByteBuf) -> ByteBuf:
  match s:
    case SNil{}: b
    case SCon{c, t}: bb_emit_str_go(t, bb_emit_u8(b, Char.to_u32(c)))

def bb_emit_str(b: ByteBuf, s: String) -> ByteBuf:
  bb_emit_str_go(s, b)

def bb_emit_cstr(b: ByteBuf, s: String) -> ByteBuf:
  bb_emit_u8(bb_emit_str_go(s, b), 0)

def bb_emit_zeros_go(n: Nat, b: ByteBuf) -> ByteBuf:
  match n:
    case 0n: b
    case 1n+p: bb_emit_zeros_go(p, bb_emit_u8(b, 0))

def bb_emit_zeros(b: ByteBuf, n: U32) -> ByteBuf:
  bb_emit_zeros_go(U32.to_nat(n), b)

def bb_append_bytes_go(xs: List<&2, U32>, b: ByteBuf) -> ByteBuf:
  match xs:
    case Nil{}: b
    case Con{h, t}: bb_append_bytes_go(t, bb_emit_u8(b, h))

def bb_append_bytes(b: ByteBuf, xs: List<&2, U32>) -> ByteBuf:
  bb_append_bytes_go(xs, b)

def bb_to_bytes(b: ByteBuf) -> List<&2, U32>:
  match b:
    case ByteBuf{_, rev}: b5k_list_rev(U32, rev)

# Frozen Token & AST ADTs
# -----------------------

type TokKind is Data:
  TkIdent{sym: U32}
  TkNum{val: U32}
  TkFlt{bits: U32}
  TkChr{code: U32}
  TkStr{val: String}
  TkKw{code: U32}
  TkSym{code: U32}
  TkNewline{}
  TkIndent{}
  TkDedent{}
  TkEof{}

type Tok is Data:
  Tok{kind: TokKind, line: U32}

type Pat is Data:
  PVar{sym: U32, dup: Bool}
  PWild{}
  PNum{val: U32}
  PChr{code: U32}
  PCtr{sym: U32, fields: List<&2, Pat>}
  PPair{fst: Pat, snd: Pat}
  PList{elems: List<&2, Pat>}

type Param is Data:
  Param{sym: U32, typ: Maybe<&2, Expr>, erased: Bool, dup: Bool}

type Case is Data:
  Case{pats: List<&2, Pat>, body: Expr}

type Stmt is Data:
  StBind{pat: Pat, val: Expr}
  StLet{pat: Pat, val: Expr}
  StExpr{val: Expr}
  StRet{val: Expr}

type Expr is Data:
  ENum{val: U32}
  EFlt{bits: U32}
  EChr{code: U32}
  EStr{val: String}
  EVar{sym: U32}
  ERef{sym: U32}
  EApp{fun: Expr, args: List<&2, Expr>}
  ELam{params: List<&2, Param>, body: Expr}
  ELet{pat: Pat, val: Expr, body: Expr}
  EMat{scruts: List<&2, Expr>, cases: List<&2, Case>}
  ECtr{sym: U32, fields: List<&2, Expr>}
  EAnn{val: Expr, typ: Expr}
  EAll{param: Param, body: Expr}
  ESet{}
  EEmpty{}
  EUnit{}
  EEq{lhs: Expr, rhs: Expr}
  ERefl{}
  EArrNew{elems: List<&2, Expr>}
  EArrGet{arr: Expr, idx: Expr}
  EArrSet{arr: Expr, idx: Expr, val: Expr}
  EOp{op: U32, lhs: Expr, rhs: Expr}
  EUnOp{op: U32, val: Expr}
  EIf{cond: Expr, then_e: Expr, else_e: Expr}
  EDo{stmts: List<&2, Stmt>}
  EPair{fst: Expr, snd: Expr}
  EList{elems: List<&2, Expr>}
  EHole{}

type CtorDef is Data:
  CtorDef{sym: U32, cid: U32, fields: List<&2, Param>}

type TypeDef is Data:
  TypeDef{sym: U32, params: List<&2, Param>, is_data: Bool, ctors: List<&2, CtorDef>}

type Def is Data:
  Def{sym: U32, params: List<&2, Param>, ret: Maybe<&2, Expr>, body: Expr, is_import: Bool, import_path: String}

type LawDef is Data:
  LawDef{sym: U32, params: List<&2, Param>, ret: Expr}

type Book is Data:
  Book{types: List<&2, TypeDef>, defs: List<&2, Def>, laws: List<&2, LawDef>, syms: SymTab}

# Frozen Direct-First SSA/ANF CFG IR ADTs
# ---------------------------------------

type IrType is Data:
  ITerm{}
  IU32{}
  IF32{}
  IPtr{}

type IrOp is Data:
  IConst{dst: U32, val: U32}
  IFlt{dst: U32, bits: U32}
  ICopy{dst: U32, src: U32}
  IBin{dst: U32, op: U32, lhs: U32, rhs: U32}
  IUn{dst: U32, op: U32, src: U32}
  ICmp{dst: U32, op: U32, lhs: U32, rhs: U32}
  ICallDirect{dst: U32, fid: U32, args: List<&2, U32>}
  ICallClosure{dst: U32, fid: U32, caps: List<&2, U32>}
  IApply{dst: U32, clo: U32, arg: U32}
  ICtor{dst: U32, cid: U32, fields: List<&2, U32>}
  ITake{dsts: List<&2, U32>, src: U32}
  ITag{dst: U32, src: U32}
  IKeep{dst: U32, src: U32}
  ISink{src: U32}
  IReuse{dst: U32, slot: U32, cid: U32, fields: List<&2, U32>}
  IStatic{dst: U32, idx: U32}
  IArrOp{dsts: List<&2, U32>, op: U32, args: List<&2, U32>}
  IAlloca{dst: U32, words: U32}
  ILoad{dst: U32, base: U32, off: U32}
  IStore{base: U32, off: U32, val: U32}
  IFail{code: U32}

type IrSwitchArm is Data:
  IrArm{tag: U32, target: U32}

type IrTerm is Data:
  TJmp{target: U32}
  TBr{cond: U32, then_blk: U32, else_blk: U32}
  TSwitch{scrut: U32, arms: List<&2, IrSwitchArm>, def_blk: U32}
  TRet{val: U32}
  TTailCall{fid: U32, args: List<&2, U32>}
  TFail{code: U32}

type IrBlock is Data:
  IrBlock{id: U32, ops: List<&2, IrOp>, term: IrTerm}

type IrCtor is Data:
  IrCtor{cid: U32, name: String, arity: U32, hot: Bool}

type IrFn is Data:
  IrFn{fid: U32, name: String, arity: U32, nregs: U32, is_escaping: Bool, is_effectful: Bool, is_main: Bool, blocks: List<&2, IrBlock>}

type IrProg is Data:
  IrProg{fns: List<&2, IrFn>, ctors: List<&2, IrCtor>, statics: List<&2, U32>, main_fid: U32, main_pure: Bool, effects: List<&2, String>, show_desc: List<&2, U32>, show_names: List<&2, String>}

# Frozen Typed x86-64 Machine Instruction & ELF Handoff ADTs
# ----------------------------------------------------------
# Reg = U32 (0..15 GPR: RAX=0 RCX=1 RDX=2 RBX=3 RSP=4 RBP=5 RSI=6 RDI=7 R8..R15;
#            0..15 XMM: XMM0..XMM15)

type X64Inst is Data:
  XMovRR{dst: U32, src: U32}
  XMovRI32{dst: U32, imm: U32}
  XMovRI64{dst: U32, lo: U32, hi: U32}
  XLoad{dst: U32, base: U32, disp: U32}
  XStore{base: U32, disp: U32, src: U32}
  XLeaRip{dst: U32, sym: String}
  XAluRR{op: U32, dst: U32, src: U32}
  XAluRI{op: U32, dst: U32, imm: U32}
  XShift{op: U32, dst: U32, amt: U32, by_cl: Bool}
  XMul{dst: U32, src: U32}
  XDiv{src: U32, is_signed: Bool}
  XCmpRR{lhs: U32, rhs: U32}
  XCmpRI{lhs: U32, imm: U32}
  XTestRR{lhs: U32, rhs: U32}
  XSetcc{cc: U32, dst: U32}
  XCmov{cc: U32, dst: U32, src: U32}
  XPush{reg: U32}
  XPop{reg: U32}
  XSubRsp{imm: U32}
  XAddRsp{imm: U32}
  XLabel{id: U32}
  XJmp{target: U32}
  XJcc{cc: U32, target: U32}
  XCallSym{sym: String}
  XCallReg{reg: U32}
  XRet{}
  XXmmRR{op: U32, dst: U32, src: U32}
  XXmmLoad{dst: U32, base: U32, disp: U32}
  XXmmStore{base: U32, disp: U32, src: U32}
  XCvt{op: U32, dst: U32, src: U32}
  XExtReloc{kind: U32, sym: String, addend: U32}

type X64Fn is Data:
  X64Fn{name: String, is_global: Bool, insts: List<&2, X64Inst>}

type ElfReloc is Data:
  ElfReloc{off: U32, sym: String, rtype: U32, addend: U32}
