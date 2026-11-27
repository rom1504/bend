# bend5k/core.bend — Frozen Phase 0 Core Types, Interner, ByteBuf & Helpers
# Shared Operator & Condition Codes
# BinOp: 0=ADD 1=SUB 2=MUL 3=DIV 4=MOD 5=AND 6=OR 7=XOR 8=SHL 9=SHR 10=FADD 11=FSUB 12=FMUL 13=FDIV
# UnOp:  0=NEG 1=NOT 2=FNEG | CmpOp: 0=EQ 1=NE 2=LT 3=LE 4=GT 5=GE
# X64CC: 2=B 3=AE 4=E 5=NE 6=BE 7=A 12=L 13=GE 14=LE 15=G
def B5K_OP_ADD() -> U32: 0
def B5K_OP_SUB() -> U32: 1
def B5K_OP_MUL() -> U32: 2
def B5K_OP_DIV() -> U32: 3
def B5K_OP_MOD() -> U32: 4
def B5K_OP_AND() -> U32: 5
def B5K_OP_OR() -> U32: 6
def B5K_OP_XOR() -> U32: 7
def B5K_OP_SHL() -> U32: 8
def B5K_OP_SHR() -> U32: 9
def B5K_CMP_EQ() -> U32: 0
def B5K_CMP_NE() -> U32: 1
def B5K_CMP_LT() -> U32: 2
def B5K_CMP_LE() -> U32: 3
def B5K_CMP_GT() -> U32: 4
def B5K_CMP_GE() -> U32: 5
# Core Helpers
def b5k_str_eq(a: String, b: String) -> Bool: String.eq(a, b)
def b5k_list_len_go(-A: Data, xs: List<&2, A>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{_, t}: b5k_list_len_go(A, t, U32.add(acc, 1))
def b5k_list_len(-A: Data, xs: List<&2, A>) -> U32: b5k_list_len_go(A, xs, 0)
def b5k_u32_list_len(xs: List<&2, U32>) -> U32: b5k_list_len_go(U32, xs, 0)
def b5k_list_rev_go(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: b5k_list_rev_go(A, t, Con{h, acc})
def b5k_list_rev(-A: Data, xs: List<&2, A>) -> List<&2, A>: b5k_list_rev_go(A, xs, Nil{})
def b5k_list_app(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>: b5k_list_rev_go(A, b5k_list_rev_go(A, xs, Nil{}), ys)
def b5k_u32_to_str_go(fuel: Nat, +n: U32, acc: String, z: Bool) -> String:
  match fuel z:
    case 1n+p False{}:
      +q = U32.div(n, 10)
      b5k_u32_to_str_go(p, q, SCon{Char.from_u32(U32.add(48, U32.mod(n, 10))), acc}, U32.is_zero(q))
    case _ _: acc
def b5k_u32_to_str(+n: U32) -> String: Bool.pick(String, U32.is_zero(n), "0", b5k_u32_to_str_go(12n, n, "", False{}))
# Shared Dense 4-Way U32 Bit-Trie (Depth 8 = 65,536 entries)
type RaVec<-A: Data> is Data:
  RVEmpty{}
  RVLeaf{val: A}
  RVNode{c0: RaVec<A>, c1: RaVec<A>, c2: RaVec<A>, c3: RaVec<A>}
def ra_vec_set_q(-A: Data, d: Nat, +idx: U32, val: A, t: RaVec<A>, q: U32) -> RaVec<A>:
  match d t q:
    case 0n _ _: RVLeaf{val}
    case 1n+p RVNode{c0, c1, c2, c3} 0: RVNode{ra_vec_set_q(A, p, U32.shrn(idx, 2n), val, c0, U32.and(U32.shrn(idx, 2n), 3)), c1, c2, c3}
    case 1n+p RVNode{c0, c1, c2, c3} 1: RVNode{c0, ra_vec_set_q(A, p, U32.shrn(idx, 2n), val, c1, U32.and(U32.shrn(idx, 2n), 3)), c2, c3}
    case 1n+p RVNode{c0, c1, c2, c3} 2: RVNode{c0, c1, ra_vec_set_q(A, p, U32.shrn(idx, 2n), val, c2, U32.and(U32.shrn(idx, 2n), 3)), c3}
    case 1n+p RVNode{c0, c1, c2, c3} _: RVNode{c0, c1, c2, ra_vec_set_q(A, p, U32.shrn(idx, 2n), val, c3, U32.and(U32.shrn(idx, 2n), 3))}
    case 1n+p _ 0: RVNode{ra_vec_set_q(A, p, U32.shrn(idx, 2n), val, RVEmpty{}, U32.and(U32.shrn(idx, 2n), 3)), RVEmpty{}, RVEmpty{}, RVEmpty{}}
    case 1n+p _ 1: RVNode{RVEmpty{}, ra_vec_set_q(A, p, U32.shrn(idx, 2n), val, RVEmpty{}, U32.and(U32.shrn(idx, 2n), 3)), RVEmpty{}, RVEmpty{}}
    case 1n+p _ 2: RVNode{RVEmpty{}, RVEmpty{}, ra_vec_set_q(A, p, U32.shrn(idx, 2n), val, RVEmpty{}, U32.and(U32.shrn(idx, 2n), 3)), RVEmpty{}}
    case 1n+p _ _: RVNode{RVEmpty{}, RVEmpty{}, RVEmpty{}, ra_vec_set_q(A, p, U32.shrn(idx, 2n), val, RVEmpty{}, U32.and(U32.shrn(idx, 2n), 3))}
def ra_vec_set(-A: Data, d: Nat, +idx: U32, val: A, t: RaVec<A>) -> RaVec<A>: ra_vec_set_q(A, d, idx, val, t, U32.and(idx, 3))
def ra_vec_get_q(-A: Data, d: Nat, +idx: U32, defv: A, t: RaVec<A>, q: U32) -> A:
  match d t q:
    case _ RVEmpty{} _: defv
    case _ RVLeaf{v} _: v
    case 0n RVNode{_, _, _, _} _: defv
    case 1n+p RVNode{c0, _, _, _} 0: ra_vec_get_q(A, p, U32.shrn(idx, 2n), defv, c0, U32.and(U32.shrn(idx, 2n), 3))
    case 1n+p RVNode{_, c1, _, _} 1: ra_vec_get_q(A, p, U32.shrn(idx, 2n), defv, c1, U32.and(U32.shrn(idx, 2n), 3))
    case 1n+p RVNode{_, _, c2, _} 2: ra_vec_get_q(A, p, U32.shrn(idx, 2n), defv, c2, U32.and(U32.shrn(idx, 2n), 3))
    case 1n+p RVNode{_, _, _, c3} _: ra_vec_get_q(A, p, U32.shrn(idx, 2n), defv, c3, U32.and(U32.shrn(idx, 2n), 3))
def ra_vec_get(-A: Data, d: Nat, defv: A, +idx: U32, t: RaVec<A>) -> A: ra_vec_get_q(A, d, idx, defv, t, U32.and(idx, 3))
# String Interner (SymTab: String <-> U32)
type SymTab is Data:
  SymTab{next: U32, by_name: Map<&2, U32>, by_id: RaVec<String>}
type SymRes is Data:
  SymRes{tab: SymTab, id: U32}
def symtab_new() -> SymTab: SymTab{0, Map.new(&2, U32), RVEmpty{}}
def symtab_name(st: SymTab, +id: U32) -> String:
  SymTab{_, _, by_id} = st
  ra_vec_get(String, 8n, "", id, by_id)
def symtab_intern_got(+next: U32, by_id: RaVec<String>, +name: String, got: Map<&2, U32> & U32) -> SymRes:
  (m1, found) = got
  match found:
    case 0: SymRes{SymTab{U32.add(next, 1), Map.set(&2, U32, m1, name, U32.add(next, 1)), ra_vec_set(String, 8n, next, name, by_id)}, next}
    case f: SymRes{SymTab{next, m1, by_id}, U32.sub(f, 1)}
def symtab_intern(st: SymTab, +name: String) -> SymRes:
  SymTab{next, by_name, by_id} = st
  symtab_intern_got(next, by_id, name, Map.get(U32, 0, by_name, name))
def symtab_lookup_got(got: Map<&2, U32> & U32) -> Maybe<&2, U32>:
  (_, +found) = got
  Bool.pick(Maybe<&2, U32>, U32.is_zero(found), None{}, Some{U32.sub(found, 1)})
def symtab_lookup(st: SymTab, name: String) -> Maybe<&2, U32>:
  SymTab{_, by_name, _} = st
  symtab_lookup_got(Map.get(U32, 0, by_name, name))
# Growable Byte Buffer (ByteBuf)
type ByteBuf is Data:
  ByteBuf{len: U32, rev: List<&2, U32>}
def bb_new() -> ByteBuf: ByteBuf{0, Nil{}}
def bb_len(b: ByteBuf) -> U32:
  ByteBuf{n, _} = b
  n
def bb_emit_u8(b: ByteBuf, v: U32) -> ByteBuf:
  ByteBuf{n, rev} = b
  ByteBuf{U32.add(n, 1), Con{U32.and(v, 255), rev}}
def bb_emit_u16(b: ByteBuf, +v: U32) -> ByteBuf: bb_emit_u8(bb_emit_u8(b, v), U32.shrn(v, 8n))
def bb_emit_u32(b: ByteBuf, +v: U32) -> ByteBuf: bb_emit_u16(bb_emit_u16(b, v), U32.shrn(v, 16n))
def bb_emit_u64(b: ByteBuf, lo: U32, hi: U32) -> ByteBuf: bb_emit_u32(bb_emit_u32(b, lo), hi)
def bb_emit_str_go(s: String, b: ByteBuf) -> ByteBuf:
  match s:
    case SNil{}: b
    case SCon{c, t}: bb_emit_str_go(t, bb_emit_u8(b, Char.to_u32(c)))
def bb_emit_cstr(b: ByteBuf, s: String) -> ByteBuf: bb_emit_u8(bb_emit_str_go(s, b), 0)
def bb_emit_zeros_go(n: Nat, b: ByteBuf) -> ByteBuf:
  match n:
    case 0n: b
    case 1n+p: bb_emit_zeros_go(p, bb_emit_u8(b, 0))
def bb_emit_zeros(b: ByteBuf, n: U32) -> ByteBuf: bb_emit_zeros_go(U32.to_nat(n), b)
def bb_to_bytes(b: ByteBuf) -> List<&2, U32>:
  ByteBuf{_, rev} = b
  b5k_list_rev(U32, rev)

# Frozen Token & AST ADTs
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
  IMutField{obj: U32, idx: U32, val: U32}
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
# Reg = U32 (0..15 GPR: RAX=0 RCX=1 RDX=2 RBX=3 RSP=4 RBP=5 RSI=6 RDI=7 R8..R15; 0..15 XMM)
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
