# bend5k/main.bend — Milestone 4 End-to-End Compiler Driver (-O0 / -O2)
# =====================================================================
# CLI:
#   bend5k [-O0 | -O2 | --opt O0|O2] <src.bend> [<base.bend>] <out.o>
#   bend5k --check-only <src.bend>
type B5kIoRes<-A: Data> is Data:
  B5kErr{msg: String}
  B5kOk{val: A}
def b5k_die(msg: String) -> IO(Unit): IO.bind(Unit, Unit, IO.print_err(msg), u => IO.exit(1))
def b5k_usage() -> IO(Unit): b5k_die("usage: bend5k [-O0|-O2|--opt O0|O2|--check-only] <src.bend> [<base.bend>] <out.o>")
def b5k_close_res(-A: Data, f: File, r: B5kIoRes<A>) -> IO(B5kIoRes<A>): IO.bind(Unit, B5kIoRes<A>, File.close(f), u => IO.pure(B5kIoRes<A>, r))
def b5k_close_got(-A: Data, tag: String, path: String, got: File & Result<&1, &1, U32 & String, A>) -> IO(B5kIoRes<A>):
  match got:
    case (f, Fail{(_, msg)}): b5k_close_res(A, f, B5kErr{tag ++ " failed: " ++ path ++ ": " ++ msg})
    case (f, Done{v}): b5k_close_res(A, f, B5kOk{v})
def b5k_read_sized(path: String, got: File & Result<&1, &1, U32 & String, U32>) -> IO(B5kIoRes<String>):
  match got:
    case (f, Fail{(_, msg)}): b5k_close_res(String, f, B5kErr{"stat failed: " ++ path ++ ": " ++ msg})
    case (f, Done{sz}): IO.bind(File & Result<&1, &1, U32 & String, String>, B5kIoRes<String>, File.read(f, U32.add(sz, 1)), r => b5k_close_got(String, "read", path, r))
def b5k_read_opened(path: String, res: Result<&1, &1, U32 & String, File>) -> IO(B5kIoRes<String>):
  match res:
    case Fail{(_, msg)}: IO.pure(B5kIoRes<String>, B5kErr{"open failed: " ++ path ++ ": " ++ msg})
    case Done{f}: IO.bind(File & Result<&1, &1, U32 & String, U32>, B5kIoRes<String>, File.size(f), r => b5k_read_sized(path, r))
def b5k_read_file(+path: String) -> IO(B5kIoRes<String>): IO.bind(Result<&1, &1, U32 & String, File>, B5kIoRes<String>, File.open(path, "r"), r => b5k_read_opened(path, r))
def b5k_write_opened(path: String, bs: List<&2, U32>, res: Result<&1, &1, U32 & String, File>) -> IO(B5kIoRes<Unit>):
  match res:
    case Fail{(_, msg)}: IO.pure(B5kIoRes<Unit>, B5kErr{"open failed: " ++ path ++ ": " ++ msg})
    case Done{f}: IO.bind(File & Result<&1, &1, U32 & String, Unit>, B5kIoRes<Unit>, File.write_bytes(f, bs), r => b5k_close_got(Unit, "write", path, r))
def b5k_write_file(+path: String, bs: List<&2, U32>) -> IO(B5kIoRes<Unit>): IO.bind(Result<&1, &1, U32 & String, File>, B5kIoRes<Unit>, File.open(path, "w"), r => b5k_write_opened(path, bs, r))
def b5k_compile_lower(is_o2: Bool, lr: LowerRes) -> B5kIoRes<List<&2, U32>>:
  match is_o2 lr:
    case _ LowerRes{False{}, err, _}: B5kErr{err}
    case False{} LowerRes{True{}, _, +prog}: B5kOk{bb_to_bytes(b5k_emit_elf(prog, b5k_codegen(prog)))}
    case True{} LowerRes{True{}, _, prog}:
      +prog2 = b5k_opt(prog)
      B5kOk{bb_to_bytes(b5k_emit_elf(prog2, b5k_peep(b5k_codegen_o2(prog2))))}
def b5k_compile_check(is_o2: Bool, check_only: Bool, cr: CheckRes) -> B5kIoRes<List<&2, U32>>:
  match check_only cr:
    case _ CheckRes{False{}, err, _}: B5kErr{err}
    case True{} CheckRes{True{}, _, _}: B5kOk{Nil{}}
    case False{} CheckRes{True{}, _, book}: b5k_compile_lower(is_o2, b5k_lower(book))
def b5k_compile_parse(is_o2: Bool, check_only: Bool, pr: ParseRes) -> B5kIoRes<List<&2, U32>>:
  match pr:
    case ParseRes{False{}, err, _}: B5kErr{err}
    case ParseRes{True{}, _, book}: b5k_compile_check(is_o2, check_only, b5k_check(book))
def b5k_finish_write(res: B5kIoRes<Unit>) -> IO(Unit):
  match res:
    case B5kErr{msg}: b5k_die(msg)
    case B5kOk{_}: IO.pure(Unit, Unit{})
def b5k_run_res(check_only: Bool, out_path: String, res: B5kIoRes<List<&2, U32>>) -> IO(Unit):
  match check_only res:
    case _ B5kErr{msg}: b5k_die(msg)
    case True{} B5kOk{_}: IO.print("CHECK OK (bend5k 1-pass: scope, arity, affine, head-types; no BendTT kernel proof)")
    case False{} B5kOk{bs}: IO.bind(B5kIoRes<Unit>, Unit, b5k_write_file(out_path, bs), r => b5k_finish_write(r))
# Local Relative Multi-File Import Loader (./ and ../)
type ImpReq is Data:
  ImpReq{dir: String, rel: String, alias: String}
type RemapTab is Data:
  RemapTab{syms: SymTab, rmap: RaVec<Maybe<&2, U32>>}
def b5k_drop_to_slash(s: String) -> String:
  match s:
    case SNil{}: SNil{}
    case SCon{Chr{47}, t}: SCon{Chr{47}, t}
    case SCon{_, t}: b5k_drop_to_slash(t)
def b5k_dir_of(path: String) -> String: String.reverse(b5k_drop_to_slash(String.reverse(path)))
def b5k_take_to_slash(s: String, acc: String) -> String:
  match s:
    case SNil{}: acc
    case SCon{Chr{47}, _}: acc
    case SCon{c, t}: b5k_take_to_slash(t, SCon{c, acc})
def b5k_stem_of(rel: String) -> String:
  +base = b5k_take_to_slash(String.reverse(rel), SNil{})
  Bool.pick(String, String.ends_with(base, ".bend"), String.reverse(String.drop(String.reverse(base), 5n)), base)
def b5k_is_ws_ch(+u: U32) -> Bool: Bool.or(Bool.or(U32.is_eq(u, 32), U32.is_eq(u, 9)), Bool.or(U32.is_eq(u, 10), U32.is_eq(u, 13)))
def b5k_take_word(s: String, stop: Bool, prev: Char, +acc: String) -> StrScan:
  match s stop:
    case rest True{}: StrScan{String.reverse(acc), SCon{prev, rest}, True{}}
    case SNil{} False{}: StrScan{String.reverse(acc), SNil{}, True{}}
    case SCon{Chr{+u}, t} False{}:
      +ws = b5k_is_ws_ch(u)
      b5k_take_word(t, ws, Chr{u}, Bool.pick(String, ws, acc, SCon{Chr{u}, acc}))
def b5k_skip_line(s: String) -> String:
  match s:
    case SNil{}: SNil{}
    case SCon{Chr{10}, t}: t
    case SCon{_, t}: b5k_skip_line(t)
def b5k_imp_alias(+dir: String, +rel: String, r2: StrScan, acc: List<&2, ImpReq>) -> List<&2, ImpReq>:
  StrScan{al, _, _} = r2
  Con{ImpReq{dir, rel, al}, acc}
def b5k_imp_line(+dir: String, r1: StrScan, +acc: List<&2, ImpReq>) -> List<&2, ImpReq>:
  StrScan{+rel, +rest, _} = r1
  Bool.pick(List<&2, ImpReq>, String.ends_with(rel, ".bend"),
    Bool.pick(List<&2, ImpReq>, String.starts_with(rest, " as "), b5k_imp_alias(dir, rel, b5k_take_word(String.drop(rest, 4n), False{}, Chr{0}, SNil{}), acc),
      Con{ImpReq{dir, rel, b5k_stem_of(rel)}, acc}), acc)
def b5k_scan_imp_step(is_rel: Bool, dir: String, s: String, acc: List<&2, ImpReq>) -> List<&2, ImpReq>:
  match is_rel:
    case True{}: b5k_imp_line(dir, b5k_take_word(String.drop(s, 7n), False{}, Chr{0}, SNil{}), acc)
    case False{}: acc
def b5k_scan_imp_go(fuel: Nat, +dir: String, +s: String, acc: List<&2, ImpReq>) -> List<&2, ImpReq>:
  match fuel s:
    case 0n _: b5k_list_rev(ImpReq, acc)
    case _ SNil{}: b5k_list_rev(ImpReq, acc)
    case 1n+p _:
      is_rel = Bool.or(String.starts_with(s, "import ./"), String.starts_with(s, "import ../"))
      acc2 = b5k_scan_imp_step(is_rel, dir, s, acc)
      b5k_scan_imp_go(p, dir, b5k_skip_line(s), acc2)
def b5k_scan_imports(dir: String, src: String) -> List<&2, ImpReq>: b5k_scan_imp_go(U32.to_nat(2048), dir, src, Nil{})
def b5k_rm_add_k(old: U32, rmap: RaVec<Maybe<&2, U32>>, sr: SymRes) -> RemapTab:
  SymRes{syms2, nid} = sr
  RemapTab{syms2, ct_set(U32, rmap, old, nid)}
def b5k_rm_add(rt: RemapTab, +alias: String, +old: U32) -> RemapTab:
  RemapTab{+syms, rmap} = rt
  b5k_rm_add_k(old, rmap, symtab_intern(syms, alias ++ "." ++ symtab_name(syms, old)))
def b5k_rm_ctors(cs: List<&2, CtorDef>, +alias: String, rt: RemapTab) -> RemapTab:
  match cs:
    case Nil{}: rt
    case Con{CtorDef{csym, _, _}, t}: b5k_rm_ctors(t, alias, b5k_rm_add(rt, alias, csym))
def b5k_rm_types(ts: List<&2, TypeDef>, +alias: String, rt: RemapTab) -> RemapTab:
  match ts:
    case Nil{}: rt
    case Con{TypeDef{tsym, _, _, cs}, t}: b5k_rm_types(t, alias, b5k_rm_ctors(cs, alias, b5k_rm_add(rt, alias, tsym)))
def b5k_rm_defs(ds: List<&2, Def>, +alias: String, rt: RemapTab) -> RemapTab:
  match ds:
    case Nil{}: rt
    case Con{Def{dsym, _, _, _, _, _}, t}: b5k_rm_defs(t, alias, b5k_rm_add(rt, alias, dsym))
def b5k_rm_laws(ls: List<&2, LawDef>, +alias: String, rt: RemapTab) -> RemapTab:
  match ls:
    case Nil{}: rt
    case Con{LawDef{lsym, _, _}, t}: b5k_rm_laws(t, alias, b5k_rm_add(rt, alias, lsym))
def b5k_rm_sym(rmap: RaVec<Maybe<&2, U32>>, +s: U32) -> U32: Maybe.default(&2, U32, ct_get(U32, rmap, s), s)
def b5k_rm_sym_ub(rmap: RaVec<Maybe<&2, U32>>, bnd: List<&2, U32>, +s: U32) -> U32:
  Bool.pick(U32, b5k_chk_u32_mem(bnd, s), s, b5k_rm_sym(rmap, s))
def b5k_rm_pat_go(+fuel: Nat, +rmap: RaVec<Maybe<&2, U32>>, p: Pat) -> Pat:
  match fuel p:
    case 0n x: x
    case 1n+f PPair{a, b}: PPair{b5k_rm_pat_go(f, rmap, a), b5k_rm_pat_go(f, rmap, b)}
    case 1n+_ PCtr{s, fs}: PCtr{b5k_rm_sym(rmap, s), fs}
    case _ x: x
def b5k_rm_pat_list(+fuel: Nat, +rmap: RaVec<Maybe<&2, U32>>, ps: List<&2, Pat>) -> List<&2, Pat>:
  match fuel ps:
    case 0n xs: xs
    case _ Nil{}: Nil{}
    case 1n+f Con{PCtr{s, fs}, t}: Con{PCtr{b5k_rm_sym(rmap, s), b5k_rm_pat_list(f, rmap, fs)}, b5k_rm_pat_list(f, rmap, t)}
    case 1n+f Con{PPair{a, b}, t}: Con{PPair{b5k_rm_pat_go(f, rmap, a), b5k_rm_pat_go(f, rmap, b)}, b5k_rm_pat_list(f, rmap, t)}
    case 1n+f Con{PList{es}, t}: Con{PList{b5k_rm_pat_list(f, rmap, es)}, b5k_rm_pat_list(f, rmap, t)}
    case 1n+f Con{h, t}: Con{h, b5k_rm_pat_list(f, rmap, t)}
def b5k_pat_syms_go(+fuel: Nat, ps: List<&2, Pat>, acc: List<&2, U32>) -> List<&2, U32>:
  match fuel ps:
    case 0n _: acc
    case _ Nil{}: acc
    case 1n+f Con{PVar{s, _}, t}: b5k_pat_syms_go(f, t, Con{s, acc})
    case 1n+f Con{PCtr{_, fs}, t}: b5k_pat_syms_go(f, b5k_list_app(Pat, fs, t), acc)
    case 1n+f Con{PPair{a, b}, t}: b5k_pat_syms_go(f, Con{a, Con{b, t}}, acc)
    case 1n+f Con{PList{es}, t}: b5k_pat_syms_go(f, b5k_list_app(Pat, es, t), acc)
    case 1n+f Con{_, t}: b5k_pat_syms_go(f, t, acc)
def b5k_pm_syms(ps: List<&2, Param>, acc: List<&2, U32>) -> List<&2, U32>:
  match ps:
    case Nil{}: acc
    case Con{Param{s, _, _, _}, t}: Con{s, b5k_pm_syms(t, acc)}
type RmW is Data:
  RWE{bnd: List<&2, U32>, e: Expr}
  RWEs{bnd: List<&2, U32>, es: List<&2, Expr>}
  RWPs{bnd: List<&2, U32>, ps: List<&2, Param>}
  RWCs{bnd: List<&2, U32>, cs: List<&2, Case>}
  RWSs{bnd: List<&2, U32>, ss: List<&2, Stmt>}
  RWME{bnd: List<&2, U32>, m: Maybe<&2, Expr>}
type RmR is Data:
  RRE{e: Expr}
  RREs{es: List<&2, Expr>}
  RRPs{ps: List<&2, Param>}
  RRCs{cs: List<&2, Case>}
  RRSs{ss: List<&2, Stmt>}
  RRME{m: Maybe<&2, Expr>}
def b5k_rr_e(r: RmR) -> Expr:
  match r:
    case RRE{e}: e
    case _: EHole{}
def b5k_rr_es(r: RmR) -> List<&2, Expr>:
  match r:
    case RREs{es}: es
    case _: Nil{}
def b5k_rr_ps(r: RmR) -> List<&2, Param>:
  match r:
    case RRPs{ps}: ps
    case _: Nil{}
def b5k_rr_cs(r: RmR) -> List<&2, Case>:
  match r:
    case RRCs{cs}: cs
    case _: Nil{}
def b5k_rr_ss(r: RmR) -> List<&2, Stmt>:
  match r:
    case RRSs{ss}: ss
    case _: Nil{}
def b5k_rr_me(r: RmR) -> Maybe<&2, Expr>:
  match r:
    case RRME{m}: m
    case _: None{}
def b5k_rm_w(+fuel: Nat, +rmap: RaVec<Maybe<&2, U32>>, w: RmW) -> RmR:
  match fuel w:
    case 0n RWE{_, x}: RRE{x}
    case 0n RWEs{_, xs}: RREs{xs}
    case 0n RWPs{_, xs}: RRPs{xs}
    case 0n RWCs{_, xs}: RRCs{xs}
    case 0n RWSs{_, xs}: RRSs{xs}
    case 0n RWME{_, m}: RRME{m}
    case 1n+_ RWME{_, None{}}: RRME{None{}}
    case 1n+f RWME{bnd, Some{e}}: RRME{Some{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, e}))}}
    case 1n+_ RWEs{_, Nil{}}: RREs{Nil{}}
    case 1n+f RWEs{+bnd, Con{h, t}}: RREs{Con{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, h})), b5k_rr_es(b5k_rm_w(f, rmap, RWEs{bnd, t}))}}
    case 1n+_ RWPs{_, Nil{}}: RRPs{Nil{}}
    case 1n+f RWPs{+bnd, Con{Param{+s, ty, er, dp}, t}}: RRPs{Con{Param{s, b5k_rr_me(b5k_rm_w(f, rmap, RWME{bnd, ty})), er, dp}, b5k_rr_ps(b5k_rm_w(f, rmap, RWPs{Con{s, bnd}, t}))}}
    case 1n+_ RWCs{_, Nil{}}: RRCs{Nil{}}
    case 1n+f RWCs{+bnd, Con{Case{+pats, body}, t}}: RRCs{Con{Case{b5k_rm_pat_list(16n, rmap, pats), b5k_rr_e(b5k_rm_w(f, rmap, RWE{b5k_pat_syms_go(32n, pats, bnd), body}))}, b5k_rr_cs(b5k_rm_w(f, rmap, RWCs{bnd, t}))}}
    case 1n+_ RWSs{_, Nil{}}: RRSs{Nil{}}
    case 1n+f RWSs{+bnd, Con{StBind{+p, v}, t}}: RRSs{Con{StBind{b5k_rm_pat_go(16n, rmap, p), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, v}))}, b5k_rr_ss(b5k_rm_w(f, rmap, RWSs{b5k_pat_syms_go(32n, [p], bnd), t}))}}
    case 1n+f RWSs{+bnd, Con{StLet{+p, v}, t}}: RRSs{Con{StLet{b5k_rm_pat_go(16n, rmap, p), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, v}))}, b5k_rr_ss(b5k_rm_w(f, rmap, RWSs{b5k_pat_syms_go(32n, [p], bnd), t}))}}
    case 1n+f RWSs{+bnd, Con{StExpr{v}, t}}: RRSs{Con{StExpr{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, v}))}, b5k_rr_ss(b5k_rm_w(f, rmap, RWSs{bnd, t}))}}
    case 1n+f RWSs{+bnd, Con{StRet{v}, t}}: RRSs{Con{StRet{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, v}))}, b5k_rr_ss(b5k_rm_w(f, rmap, RWSs{bnd, t}))}}
    case 1n+_ RWE{bnd, EVar{s}}: RRE{EVar{b5k_rm_sym_ub(rmap, bnd, s)}}
    case 1n+_ RWE{bnd, ERef{s}}: RRE{ERef{b5k_rm_sym_ub(rmap, bnd, s)}}
    case 1n+f RWE{+bnd, EApp{fn, args}}: RRE{EApp{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, fn})), b5k_rr_es(b5k_rm_w(f, rmap, RWEs{bnd, args}))}}
    case 1n+f RWE{+bnd, ELam{+ps, body}}: RRE{ELam{b5k_rr_ps(b5k_rm_w(f, rmap, RWPs{bnd, ps})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{b5k_pm_syms(ps, bnd), body}))}}
    case 1n+f RWE{+bnd, ELet{+pat, val, body}}: RRE{ELet{b5k_rm_pat_go(16n, rmap, pat), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, val})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{b5k_pat_syms_go(32n, [pat], bnd), body}))}}
    case 1n+f RWE{+bnd, EMat{sc, cs}}: RRE{EMat{b5k_rr_es(b5k_rm_w(f, rmap, RWEs{bnd, sc})), b5k_rr_cs(b5k_rm_w(f, rmap, RWCs{bnd, cs}))}}
    case 1n+f RWE{bnd, ECtr{s, fs}}: RRE{ECtr{b5k_rm_sym(rmap, s), b5k_rr_es(b5k_rm_w(f, rmap, RWEs{bnd, fs}))}}
    case 1n+f RWE{+bnd, EAnn{v, ty}}: RRE{EAnn{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, v})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, ty}))}}
    case 1n+f RWE{+bnd, EAll{Param{+s, ty, er, dp}, body}}: RRE{EAll{Param{s, b5k_rr_me(b5k_rm_w(f, rmap, RWME{bnd, ty})), er, dp}, b5k_rr_e(b5k_rm_w(f, rmap, RWE{Con{s, bnd}, body}))}}
    case 1n+f RWE{+bnd, EEq{a, b}}: RRE{EEq{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, a})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, b}))}}
    case 1n+f RWE{bnd, EArrNew{es}}: RRE{EArrNew{b5k_rr_es(b5k_rm_w(f, rmap, RWEs{bnd, es}))}}
    case 1n+f RWE{+bnd, EArrGet{a, i}}: RRE{EArrGet{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, a})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, i}))}}
    case 1n+f RWE{+bnd, EArrSet{a, i, v}}: RRE{EArrSet{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, a})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, i})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, v}))}}
    case 1n+f RWE{+bnd, EOp{op, a, b}}: RRE{EOp{op, b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, a})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, b}))}}
    case 1n+f RWE{bnd, EUnOp{op, a}}: RRE{EUnOp{op, b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, a}))}}
    case 1n+f RWE{+bnd, EIf{c, t, el}}: RRE{EIf{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, c})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, t})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, el}))}}
    case 1n+f RWE{bnd, EDo{ss}}: RRE{EDo{b5k_rr_ss(b5k_rm_w(f, rmap, RWSs{bnd, ss}))}}
    case 1n+f RWE{+bnd, EPair{a, b}}: RRE{EPair{b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, a})), b5k_rr_e(b5k_rm_w(f, rmap, RWE{bnd, b}))}}
    case 1n+f RWE{bnd, EList{es}}: RRE{EList{b5k_rr_es(b5k_rm_w(f, rmap, RWEs{bnd, es}))}}
    case 1n+_ RWE{_, x}: RRE{x}
def b5k_rm_ctor_defs(+rmap: RaVec<Maybe<&2, U32>>, +bnd: List<&2, U32>, cs: List<&2, CtorDef>) -> List<&2, CtorDef>:
  match cs:
    case Nil{}: Nil{}
    case Con{CtorDef{s, cid, fs}, t}: Con{CtorDef{b5k_rm_sym(rmap, s), cid, b5k_rr_ps(b5k_rm_w(64n, rmap, RWPs{bnd, fs}))}, b5k_rm_ctor_defs(rmap, bnd, t)}
def b5k_rm_type_defs(+rmap: RaVec<Maybe<&2, U32>>, ts: List<&2, TypeDef>) -> List<&2, TypeDef>:
  match ts:
    case Nil{}: Nil{}
    case Con{TypeDef{s, +ps, is_d, cs}, t}: Con{TypeDef{b5k_rm_sym(rmap, s), b5k_rr_ps(b5k_rm_w(64n, rmap, RWPs{Nil{}, ps})), is_d, b5k_rm_ctor_defs(rmap, b5k_pm_syms(ps, Nil{}), cs)}, b5k_rm_type_defs(rmap, t)}
def b5k_rm_def_list(+rmap: RaVec<Maybe<&2, U32>>, ds: List<&2, Def>) -> List<&2, Def>:
  match ds:
    case Nil{}: Nil{}
    case Con{Def{s, +ps, ret, body, is_i, ip}, t}:
      +bnd = b5k_pm_syms(ps, Nil{})
      Con{Def{b5k_rm_sym(rmap, s), b5k_rr_ps(b5k_rm_w(64n, rmap, RWPs{Nil{}, ps})), b5k_rr_me(b5k_rm_w(64n, rmap, RWME{bnd, ret})), b5k_rr_e(b5k_rm_w(128n, rmap, RWE{bnd, body})), is_i, ip}, b5k_rm_def_list(rmap, t)}
def b5k_rm_law_list(+rmap: RaVec<Maybe<&2, U32>>, ls: List<&2, LawDef>) -> List<&2, LawDef>:
  match ls:
    case Nil{}: Nil{}
    case Con{LawDef{s, +ps, ret}, t}: Con{LawDef{b5k_rm_sym(rmap, s), b5k_rr_ps(b5k_rm_w(64n, rmap, RWPs{Nil{}, ps})), b5k_rr_e(b5k_rm_w(64n, rmap, RWE{b5k_pm_syms(ps, Nil{}), ret}))}, b5k_rm_law_list(rmap, t)}
def b5k_merge_imp_k(its: List<&2, TypeDef>, ids: List<&2, Def>, ils: List<&2, LawDef>, mts: List<&2, TypeDef>, mds: List<&2, Def>, mls: List<&2, LawDef>, rt: RemapTab) -> Book:
  RemapTab{syms3, +rmap} = rt
  Book{b5k_list_app(TypeDef, b5k_rm_type_defs(rmap, its), mts), b5k_list_app(Def, b5k_rm_def_list(rmap, ids), mds), b5k_list_app(LawDef, b5k_rm_law_list(rmap, ils), mls), syms3}
def b5k_merge_imp_book(+alias: String, imp_bk: Book, main_bk: Book) -> Book:
  Book{+its, +ids, +ils, syms2} = imp_bk
  Book{mts, mds, mls, _} = main_bk
  b5k_merge_imp_k(its, ids, ils, mts, mds, mls, b5k_rm_laws(ils, alias, b5k_rm_defs(ids, alias, b5k_rm_types(its, alias, RemapTab{syms2, RVEmpty{}}))))
def b5k_book_syms(bk: Book) -> SymTab:
  Book{_, _, _, syms} = bk
  syms
type ImpStepRes is Data:
  ImpErr{msg: String}
  ImpOk{reqs: List<&2, ImpReq>, bk: Book}
def b5k_imp_step_parse(alias: String, sub_reqs: List<&2, ImpReq>, rest: List<&2, ImpReq>, main_bk: Book, pr: ParseRes) -> ImpStepRes:
  match pr:
    case ParseRes{False{}, err, _}: ImpErr{err}
    case ParseRes{True{}, _, imp_bk}: ImpOk{b5k_list_app(ImpReq, sub_reqs, rest), b5k_merge_imp_book(alias, imp_bk, main_bk)}
def b5k_imp_step_read(full: String, alias: String, rest: List<&2, ImpReq>, +bk: Book, loaded: B5kIoRes<String>) -> ImpStepRes:
  match loaded:
    case B5kErr{msg}: ImpErr{msg}
    case B5kOk{src}:
      +src2 = String.reverse(String.reverse(src))
      b5k_imp_step_parse(alias, b5k_scan_imports(b5k_dir_of(full), src2), rest, bk, b5k_parse(src2, b5k_book_syms(bk)))
def b5k_imp_bind_k(res: ImpStepRes, k: List<&2, ImpReq> -> Book -> IO(Unit)) -> IO(Unit):
  match res:
    case ImpErr{msg}: b5k_die(msg)
    case ImpOk{reqs2, bk2}: k(reqs2)(bk2)
def b5k_if_io(cond: Bool, thn: Unit -> IO(Unit), els: Unit -> IO(Unit)) -> IO(Unit):
  match cond:
    case True{}: thn(Unit{})
    case False{}: els(Unit{})
def b5k_load_imports(fuel: Nat, reqs: List<&2, ImpReq>, +seen: List<&2, String>, +bk: Book, +is_o2: Bool, +check_only: Bool, +out_path: String) -> IO(Unit):
  match fuel reqs:
    case 0n _: b5k_run_res(check_only, out_path, b5k_compile_check(is_o2, check_only, b5k_check(bk)))
    case _ Nil{}: b5k_run_res(check_only, out_path, b5k_compile_check(is_o2, check_only, b5k_check(bk)))
    case 1n++p Con{ImpReq{dir, rel, +alias}, +rest}:
      +full = dir ++ rel
      +key = alias ++ ":" ++ full
      b5k_if_io(b5k_chk_str_match(False{}, seen, key),
        _ => b5k_load_imports(p, rest, seen, bk, is_o2, check_only, out_path),
        _ => IO.bind(B5kIoRes<String>, Unit, b5k_read_file(full), r =>
          b5k_imp_bind_k(b5k_imp_step_read(full, alias, rest, bk, r), reqs2 => bk2 => b5k_load_imports(p, reqs2, Con{key, seen}, bk2, is_o2, check_only, out_path))))
def b5k_run_parsed(is_o2: Bool, check_only: Bool, out_path: String, reqs: List<&2, ImpReq>, pr: ParseRes) -> IO(Unit):
  match pr:
    case ParseRes{False{}, err, _}: b5k_die(err)
    case ParseRes{True{}, _, bk}: b5k_load_imports(32n, reqs, Nil{}, bk, is_o2, check_only, out_path)
def b5k_run_loaded(is_o2: Bool, +check_only: Bool, src_path: String, out_path: String, loaded: B5kIoRes<String>) -> IO(Unit):
  match loaded:
    case B5kErr{msg}: b5k_die(msg)
    case B5kOk{src}:
      +src2 = String.reverse(String.reverse(src))
      b5k_run_parsed(is_o2, check_only, out_path, b5k_scan_imports(b5k_dir_of(src_path), src2), b5k_parse(src2, symtab_new()))
def b5k_run_driver(is_o2: Bool, check_only: Bool, +src_path: String, out_path: String) -> IO(Unit): IO.bind(B5kIoRes<String>, Unit, b5k_read_file(src_path), r => b5k_run_loaded(is_o2, check_only, src_path, out_path, r))
def b5k_dispatch_pos(is_o2: Bool, check_only: Bool, a1: String, rest: List<String>) -> IO(Unit):
  match check_only rest:
    case True{} Nil{}: b5k_run_driver(is_o2, True{}, a1, "")
    case False{} Con{a2, Nil{}}: b5k_run_driver(is_o2, False{}, a1, String.reverse(String.reverse(a2)))
    case False{} Con{_, Con{a3, Nil{}}}: b5k_run_driver(is_o2, False{}, a1, String.reverse(String.reverse(a3)))
    case _ _: b5k_usage()
type B5kFlagStep is Type:
  FlagErr{}
  FlagCont{is_o2: Bool, check_only: Bool, rest: List<String>}
  FlagDone{is_o2: Bool, check_only: Bool, a1: String, rest: List<String>}
def b5k_flag_kind(+s: String) -> U32: Bool.pick(U32, b5k_str_eq(s, "-O2"), 1, Bool.pick(U32, b5k_str_eq(s, "-O0"), 2, Bool.pick(U32, b5k_str_eq(s, "--check-only"), 3, Bool.pick(U32, b5k_str_eq(s, "--opt"), 4, 0))))
def b5k_step_k(k: U32, is_o2: Bool, check_only: Bool, s1: String, rest: List<String>) -> B5kFlagStep:
  match k rest:
    case 1 _: FlagCont{True{}, check_only, rest}
    case 2 _: FlagCont{False{}, check_only, rest}
    case 3 _: FlagCont{is_o2, True{}, rest}
    case 4 Nil{}: FlagErr{}
    case 4 Con{lvl, more}: FlagCont{b5k_str_eq(String.reverse(String.reverse(lvl)), "O2"), check_only, more}
    case _ _: FlagDone{is_o2, check_only, s1, rest}
def b5k_parse_flags(fuel: Nat, st: B5kFlagStep) -> IO(Unit):
  match fuel st:
    case 1n+p FlagCont{is_o2, check_only, Con{a1, rest}}:
      +s1 = String.reverse(String.reverse(a1))
      b5k_parse_flags(p, b5k_step_k(b5k_flag_kind(s1), is_o2, check_only, s1, rest))
    case _ FlagDone{is_o2, check_only, a1, rest}: b5k_dispatch_pos(is_o2, check_only, a1, rest)
    case _ _: b5k_usage()
def b5k_clone_args(xs: List<String>) -> List<String>:
  match xs:
    case Nil{}: Nil{}
    case Con{s, t}: Con{String.reverse(String.reverse(s)), b5k_clone_args(t)}
def b5k_main_args(argv: List<String>) -> IO(Unit):
  match argv:
    case Nil{}: b5k_usage()
    case Con{_, rest}: b5k_parse_flags(16n, FlagCont{False{}, False{}, b5k_clone_args(rest)})
def main() -> IO(Unit): IO.bind(List<String>, Unit, IO.args(), argv => b5k_main_args(argv))
