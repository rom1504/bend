# bend5k/main.bend — Milestone 4 End-to-End Compiler Driver (-O0 / -O2)
# =====================================================================
# CLI: bend5k [-O0 | -O2 | --opt O0|O2 | --check-only] <src.bend> [<base.bend>] <out.o>
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
def b5k_opened(-A: Data, path: String, k: File -> IO(B5kIoRes<A>), res: Result<&1, &1, U32 & String, File>) -> IO(B5kIoRes<A>):
  match res:
    case Fail{(_, msg)}: IO.pure(B5kIoRes<A>, B5kErr{"open failed: " ++ path ++ ": " ++ msg})
    case Done{f}: k(f)
def b5k_read_sized(path: String, got: File & Result<&1, &1, U32 & String, U32>) -> IO(B5kIoRes<String>):
  match got:
    case (f, Fail{(_, msg)}): b5k_close_res(String, f, B5kErr{"stat failed: " ++ path ++ ": " ++ msg})
    case (f, Done{sz}): IO.bind(File & Result<&1, &1, U32 & String, String>, B5kIoRes<String>, File.read(f, U32.add(sz, 1)), r => b5k_close_got(String, "read", path, r))
def b5k_read_file(+path: String) -> IO(B5kIoRes<String>): IO.bind(Result<&1, &1, U32 & String, File>, B5kIoRes<String>, File.open(path, "r"), r => b5k_opened(String, path, f => IO.bind(File & Result<&1, &1, U32 & String, U32>, B5kIoRes<String>, File.size(f), r2 => b5k_read_sized(path, r2)), r))
def b5k_write_file(+path: String, bs: List<&2, U32>) -> IO(B5kIoRes<Unit>): IO.bind(Result<&1, &1, U32 & String, File>, B5kIoRes<Unit>, File.open(path, "w"), r => b5k_opened(Unit, path, f => IO.bind(File & Result<&1, &1, U32 & String, Unit>, B5kIoRes<Unit>, File.write_bytes(f, bs), r2 => b5k_close_got(Unit, "write", path, r2)), r))
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
def b5k_io_bind(-A: Data, res: B5kIoRes<A>, k: A -> IO(Unit)) -> IO(Unit):
  match res:
    case B5kErr{msg}: b5k_die(msg)
    case B5kOk{v}: k(v)
def b5k_if_io(cond: Bool, thn: Unit -> IO(Unit), els: Unit -> IO(Unit)) -> IO(Unit):
  match cond:
    case True{}: thn(Unit{})
    case False{}: els(Unit{})
def b5k_run_res(check_only: Bool, out_path: String, res: B5kIoRes<List<&2, U32>>) -> IO(Unit):
  b5k_io_bind(List<&2, U32>, res, bs => b5k_if_io(check_only,
    _ => IO.print("CHECK OK (bend5k 1-pass: scope, arity, affine, head-types; no BendTT kernel proof)"),
    _ => IO.bind(B5kIoRes<Unit>, Unit, b5k_write_file(out_path, bs), r => b5k_io_bind(Unit, r, _ => IO.pure(Unit, Unit{})))))
# Local Relative Multi-File Import Loader (./ and ../)
type ImpReq is Data:
  ImpReq{dir: String, rel: String, alias: String}
type RemapTab is Data:
  RemapTab{syms: SymTab, rmap: RaVec<Maybe<&2, U32>>}
def b5k_slash(take: Bool, s: String, acc: String) -> String:
  match take s:
    case _ SNil{}: acc
    case False{} SCon{Chr{47}, t}: SCon{Chr{47}, t}
    case True{} SCon{Chr{47}, _}: acc
    case False{} SCon{_, t}: b5k_slash(False{}, t, acc)
    case True{} SCon{c, t}: b5k_slash(True{}, t, SCon{c, acc})
def b5k_dir_of(path: String) -> String: String.reverse(b5k_slash(False{}, String.reverse(path), SNil{}))
def b5k_stem_of(rel: String) -> String:
  +base = b5k_slash(True{}, String.reverse(rel), SNil{})
  Bool.pick(String, String.ends_with(base, ".bend"), String.reverse(String.drop(String.reverse(base), 5n)), base)
def b5k_take_word(s: String, stop: Bool, prev: Char, +acc: String) -> StrScan:
  match s stop:
    case rest True{}: StrScan{String.reverse(acc), SCon{prev, rest}, True{}}
    case SNil{} False{}: StrScan{String.reverse(acc), SNil{}, True{}}
    case SCon{Chr{+u}, t} False{}:
      +ws = Bool.or(Bool.or(U32.is_eq(u, 32), U32.is_eq(u, 9)), Bool.or(U32.is_eq(u, 10), U32.is_eq(u, 13)))
      b5k_take_word(t, ws, Chr{u}, Bool.pick(String, ws, acc, SCon{Chr{u}, acc}))
def b5k_skip_line(s: String) -> String:
  match s:
    case SNil{}: SNil{}
    case SCon{Chr{10}, t}: t
    case SCon{_, t}: b5k_skip_line(t)
def b5k_scan_fst(r: StrScan) -> String:
  StrScan{a, _, _} = r
  a
def b5k_skip_sp(s: String) -> String:
  match s:
    case SCon{Chr{32}, t}: b5k_skip_sp(t)
    case SCon{Chr{9}, t}: b5k_skip_sp(t)
    case other: other
def b5k_imp_line(+dir: String, r1: StrScan, +acc: List<&2, ImpReq>) -> List<&2, ImpReq>:
  StrScan{+rel, +rest, _} = r1
  is_base = Bool.and(String.eq(rel, "Base"), Bool.not(String.starts_with(rest, " as ")))
  alias = opt_if(String, String.starts_with(rest, " as "), _ => b5k_scan_fst(b5k_take_word(b5k_skip_sp(String.drop(rest, 4n)), False{}, Chr{0}, SNil{})), _ => b5k_stem_of(rel))
  opt_if(List<&2, ImpReq>, is_base, _ => acc, _ => Con{ImpReq{dir, rel, alias}, acc})
def b5k_scan_imp_go(fuel: Nat, +dir: String, +s: String, +acc: List<&2, ImpReq>) -> List<&2, ImpReq>:
  match fuel s:
    case 0n _: b5k_list_rev(ImpReq, acc)
    case _ SNil{}: b5k_list_rev(ImpReq, acc)
    case 1n+p _: b5k_scan_imp_go(p, dir, b5k_skip_line(s), opt_if(List<&2, ImpReq>, String.starts_with(s, "import "), _ => b5k_imp_line(dir, b5k_take_word(b5k_skip_sp(String.drop(s, 7n)), False{}, Chr{0}, SNil{}), acc), _ => acc))
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
def b5k_rm_sym_ub(rmap: RaVec<Maybe<&2, U32>>, bnd: List<&2, U32>, +s: U32) -> U32: Bool.pick(U32, b5k_chk_u32_mem(bnd, s), s, b5k_rm_sym(rmap, s))
def b5k_cons_plist(h: Pat, p: Pat) -> Pat:
  match p:
    case PList{t}: PList{Con{h, t}}
    case _: PList{Con{h, Nil{}}}
def b5k_un_plist(p: Pat) -> List<&2, Pat>:
  match p:
    case PList{ps}: ps
    case _: Nil{}
def b5k_rm_pat(+fuel: Nat, +rmap: RaVec<Maybe<&2, U32>>, p: Pat) -> Pat:
  match fuel p:
    case 0n x: x
    case 1n++f PPair{a, b}: PPair{b5k_rm_pat(f, rmap, a), b5k_rm_pat(f, rmap, b)}
    case 1n++f PCtr{s, fs}: PCtr{b5k_rm_sym(rmap, s), b5k_un_plist(b5k_rm_pat(f, rmap, PList{fs}))}
    case 1n++f PList{Con{h, t}}: b5k_cons_plist(b5k_rm_pat(f, rmap, h), b5k_rm_pat(f, rmap, PList{t}))
    case _ x: x
def b5k_pat_syms(+fuel: Nat, ps: List<&2, Pat>, acc: List<&2, U32>) -> List<&2, U32>:
  match fuel ps:
    case 0n _: acc
    case _ Nil{}: acc
    case 1n+f Con{PVar{s, _}, t}: b5k_pat_syms(f, t, Con{s, acc})
    case 1n+f Con{PCtr{_, fs}, t}: b5k_pat_syms(f, b5k_list_app(Pat, fs, t), acc)
    case 1n+f Con{PPair{a, b}, t}: b5k_pat_syms(f, Con{a, Con{b, t}}, acc)
    case 1n+f Con{PList{es}, t}: b5k_pat_syms(f, b5k_list_app(Pat, es, t), acc)
    case 1n+f Con{_, t}: b5k_pat_syms(f, t, acc)
def b5k_pm_syms(ps: List<&2, Param>, acc: List<&2, U32>) -> List<&2, U32>:
  match ps:
    case Nil{}: acc
    case Con{Param{s, _, _, _}, t}: Con{s, b5k_pm_syms(t, acc)}
def b5k_cons_list(h: Expr, e: Expr) -> Expr:
  match e:
    case EList{t}: EList{Con{h, t}}
    case _: EList{Con{h, Nil{}}}
def b5k_un_list(e: Expr) -> List<&2, Expr>:
  match e:
    case EList{es}: es
    case _: Nil{}
def b5k_cons_lam(p: Param, e: Expr) -> Expr:
  match e:
    case ELam{ps, b}: ELam{Con{p, ps}, b}
    case b: ELam{Con{p, Nil{}}, b}
def b5k_un_lam(e: Expr) -> List<&2, Param>:
  match e:
    case ELam{ps, _}: ps
    case _: Nil{}
def b5k_cons_mat(c: Case, e: Expr) -> Expr:
  match e:
    case EMat{sc, cs}: EMat{sc, Con{c, cs}}
    case _: EMat{Nil{}, Con{c, Nil{}}}
def b5k_cons_do(s: Stmt, e: Expr) -> Expr:
  match e:
    case EDo{ss}: EDo{Con{s, ss}}
    case _: EDo{Con{s, Nil{}}}
def b5k_rm_e(+fuel: Nat, +rmap: RaVec<Maybe<&2, U32>>, +bnd: List<&2, U32>, e: Expr) -> Expr:
  match fuel e:
    case 0n x: x
    case 1n+_ EVar{s}: EVar{b5k_rm_sym_ub(rmap, bnd, s)}
    case 1n+_ ERef{s}: ERef{b5k_rm_sym_ub(rmap, bnd, s)}
    case 1n++f EApp{fn, args}: EApp{b5k_rm_e(f, rmap, bnd, fn), b5k_un_list(b5k_rm_e(f, rmap, bnd, EList{args}))}
    case 1n++f ELam{Nil{}, body}: ELam{Nil{}, b5k_rm_e(f, rmap, bnd, body)}
    case 1n++f ELam{Con{Param{+s, ty, er, dp}, ps}, body}: b5k_cons_lam(Param{s, opt_maybe(Expr, Maybe<&2, Expr>, ty, _ => None{}, x => Some{b5k_rm_e(f, rmap, bnd, x)}), er, dp}, b5k_rm_e(f, rmap, Con{s, bnd}, ELam{ps, body}))
    case 1n++f ELet{+pat, val, body}: ELet{b5k_rm_pat(64n, rmap, pat), b5k_rm_e(f, rmap, bnd, val), b5k_rm_e(f, rmap, b5k_pat_syms(32n, [pat], bnd), body)}
    case 1n++f EMat{sc, Nil{}}: EMat{b5k_un_list(b5k_rm_e(f, rmap, bnd, EList{sc})), Nil{}}
    case 1n++f EMat{sc, Con{Case{+pats, body}, cs}}: b5k_cons_mat(Case{b5k_un_plist(b5k_rm_pat(64n, rmap, PList{pats})), b5k_rm_e(f, rmap, b5k_pat_syms(32n, pats, bnd), body)}, b5k_rm_e(f, rmap, bnd, EMat{sc, cs}))
    case 1n++f ECtr{s, fs}: ECtr{b5k_rm_sym(rmap, s), b5k_un_list(b5k_rm_e(f, rmap, bnd, EList{fs}))}
    case 1n++f EAnn{v, ty}: EAnn{b5k_rm_e(f, rmap, bnd, v), b5k_rm_e(f, rmap, bnd, ty)}
    case 1n++f EAll{Param{+s, ty, er, dp}, body}: EAll{Param{s, opt_maybe(Expr, Maybe<&2, Expr>, ty, _ => None{}, x => Some{b5k_rm_e(f, rmap, bnd, x)}), er, dp}, b5k_rm_e(f, rmap, Con{s, bnd}, body)}
    case 1n++f EEq{a, b}: EEq{b5k_rm_e(f, rmap, bnd, a), b5k_rm_e(f, rmap, bnd, b)}
    case 1n++f EArrNew{es}: EArrNew{b5k_un_list(b5k_rm_e(f, rmap, bnd, EList{es}))}
    case 1n++f EArrGet{a, i}: EArrGet{b5k_rm_e(f, rmap, bnd, a), b5k_rm_e(f, rmap, bnd, i)}
    case 1n++f EArrSet{a, i, v}: EArrSet{b5k_rm_e(f, rmap, bnd, a), b5k_rm_e(f, rmap, bnd, i), b5k_rm_e(f, rmap, bnd, v)}
    case 1n++f EOp{op, a, b}: EOp{op, b5k_rm_e(f, rmap, bnd, a), b5k_rm_e(f, rmap, bnd, b)}
    case 1n++f EUnOp{op, a}: EUnOp{op, b5k_rm_e(f, rmap, bnd, a)}
    case 1n++f EIf{c, t, el}: EIf{b5k_rm_e(f, rmap, bnd, c), b5k_rm_e(f, rmap, bnd, t), b5k_rm_e(f, rmap, bnd, el)}
    case 1n++f EDo{Con{StBind{+p, v}, ss}}: b5k_cons_do(StBind{b5k_rm_pat(64n, rmap, p), b5k_rm_e(f, rmap, bnd, v)}, b5k_rm_e(f, rmap, b5k_pat_syms(32n, [p], bnd), EDo{ss}))
    case 1n++f EDo{Con{StLet{+p, v}, ss}}: b5k_cons_do(StLet{b5k_rm_pat(64n, rmap, p), b5k_rm_e(f, rmap, bnd, v)}, b5k_rm_e(f, rmap, b5k_pat_syms(32n, [p], bnd), EDo{ss}))
    case 1n++f EDo{Con{StExpr{v}, ss}}: b5k_cons_do(StExpr{b5k_rm_e(f, rmap, bnd, v)}, b5k_rm_e(f, rmap, bnd, EDo{ss}))
    case 1n++f EDo{Con{StRet{v}, ss}}: b5k_cons_do(StRet{b5k_rm_e(f, rmap, bnd, v)}, b5k_rm_e(f, rmap, bnd, EDo{ss}))
    case 1n++f EPair{a, b}: EPair{b5k_rm_e(f, rmap, bnd, a), b5k_rm_e(f, rmap, bnd, b)}
    case 1n++f EList{Con{h, t}}: b5k_cons_list(b5k_rm_e(f, rmap, bnd, h), b5k_rm_e(f, rmap, bnd, EList{t}))
    case 1n+_ x: x
def b5k_rm_ctor_defs(+rmap: RaVec<Maybe<&2, U32>>, +bnd: List<&2, U32>, cs: List<&2, CtorDef>) -> List<&2, CtorDef>:
  match cs:
    case Nil{}: Nil{}
    case Con{CtorDef{s, cid, fs}, t}: Con{CtorDef{b5k_rm_sym(rmap, s), cid, b5k_un_lam(b5k_rm_e(128n, rmap, bnd, ELam{fs, EHole{}}))}, b5k_rm_ctor_defs(rmap, bnd, t)}
def b5k_rm_type_defs(+rmap: RaVec<Maybe<&2, U32>>, ts: List<&2, TypeDef>) -> List<&2, TypeDef>:
  match ts:
    case Nil{}: Nil{}
    case Con{TypeDef{s, +ps, is_d, cs}, t}: Con{TypeDef{b5k_rm_sym(rmap, s), b5k_un_lam(b5k_rm_e(128n, rmap, Nil{}, ELam{ps, EHole{}})), is_d, b5k_rm_ctor_defs(rmap, b5k_pm_syms(ps, Nil{}), cs)}, b5k_rm_type_defs(rmap, t)}
def b5k_rm_def_list(+rmap: RaVec<Maybe<&2, U32>>, ds: List<&2, Def>) -> List<&2, Def>:
  match ds:
    case Nil{}: Nil{}
    case Con{Def{s, +ps, ret, body, is_i, ip}, t}:
      +bnd = b5k_pm_syms(ps, Nil{})
      Con{Def{b5k_rm_sym(rmap, s), b5k_un_lam(b5k_rm_e(128n, rmap, Nil{}, ELam{ps, EHole{}})), opt_maybe(Expr, Maybe<&2, Expr>, ret, _ => None{}, x => Some{b5k_rm_e(128n, rmap, bnd, x)}), b5k_rm_e(U32.to_nat(512), rmap, bnd, body), is_i, ip}, b5k_rm_def_list(rmap, t)}
def b5k_rm_law_list(+rmap: RaVec<Maybe<&2, U32>>, ls: List<&2, LawDef>) -> List<&2, LawDef>:
  match ls:
    case Nil{}: Nil{}
    case Con{LawDef{s, +ps, ret}, t}: Con{LawDef{b5k_rm_sym(rmap, s), b5k_un_lam(b5k_rm_e(128n, rmap, Nil{}, ELam{ps, EHole{}})), b5k_rm_e(128n, rmap, b5k_pm_syms(ps, Nil{}), ret)}, b5k_rm_law_list(rmap, t)}
def b5k_merge_imp_k(its: List<&2, TypeDef>, ids: List<&2, Def>, ils: List<&2, LawDef>, mts: List<&2, TypeDef>, mds: List<&2, Def>, mls: List<&2, LawDef>, rt: RemapTab) -> Book:
  RemapTab{syms3, +rmap} = rt
  Book{b5k_list_app(TypeDef, b5k_rm_type_defs(rmap, its), mts), b5k_list_app(Def, b5k_rm_def_list(rmap, ids), mds), b5k_list_app(LawDef, b5k_rm_law_list(rmap, ils), mls), syms3}
def b5k_merge_imp_book(+alias: String, imp_bk: Book, main_bk: Book) -> Book:
  Book{+its, +ids, +ils, syms2} = imp_bk
  Book{mts, mds, mls, _} = main_bk
  b5k_merge_imp_k(its, ids, ils, mts, mds, mls, b5k_rm_laws(ils, alias, b5k_rm_defs(ids, alias, b5k_rm_types(its, alias, RemapTab{syms2, RVEmpty{}}))))
def b5k_parse_bind(pr: ParseRes, k: Book -> IO(Unit)) -> IO(Unit):
  match pr:
    case ParseRes{False{}, err, _}: b5k_die(err)
    case ParseRes{True{}, _, bk}: k(bk)
def b5k_book_syms(bk: Book) -> SymTab:
  Book{_, _, _, syms} = bk
  syms
def b5k_alias_is_base(+alias: String) -> Bool:
  b5k_chk_str_match(False{}, ["Base", "Empty", "Unit", "Bool", "Cmp", "Either", "Sigma", "Pair", "Nat", "Maybe", "Result", "Poll", "List", "Word", "U32", "F32", "Char", "String", "Array", "Map", "IO", "File", "Equal"], alias)
def b5k_types_has_pre(+syms: SymTab, ts: List<&2, TypeDef>, +pre: String) -> Bool:
  match ts:
    case Nil{}: False{}
    case Con{TypeDef{s, _, _, _}, t}: Bool.or(String.starts_with(symtab_name(syms, s), pre), b5k_types_has_pre(syms, t, pre))
def b5k_defs_has_pre(+syms: SymTab, ds: List<&2, Def>, +pre: String) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{Def{s, _, _, _, _, _}, t}: Bool.or(String.starts_with(symtab_name(syms, s), pre), b5k_defs_has_pre(syms, t, pre))
def b5k_laws_has_pre(+syms: SymTab, ls: List<&2, LawDef>, +pre: String) -> Bool:
  match ls:
    case Nil{}: False{}
    case Con{LawDef{s, _, _}, t}: Bool.or(String.starts_with(symtab_name(syms, s), pre), b5k_laws_has_pre(syms, t, pre))
def b5k_bk_has_prefix(bk: Book, +pre: String) -> Bool:
  Book{ts, ds, ls, +syms} = bk
  t_hit = b5k_types_has_pre(syms, ts, pre)
  d_hit = b5k_defs_has_pre(syms, ds, pre)
  l_hit = b5k_laws_has_pre(syms, ls, pre)
  Bool.or(t_hit, Bool.or(d_hit, l_hit))
def b5k_imp_full(+dir: String, +rel: String) -> String:
  Bool.pick(String, String.starts_with(rel, "/"), rel, dir ++ rel)
def b5k_check_top_imps(reqs: List<&2, ImpReq>, +seen_al: List<&2, String>, +bk: Book) -> String:
  match reqs:
    case Nil{}: ""
    case Con{ImpReq{_, +rel, +alias}, rest}:
      bad_ext = Bool.not(String.ends_with(rel, ".bend"))
      bad_dup = b5k_chk_str_match(False{}, seen_al, alias)
      bad_col = b5k_bk_has_prefix(bk, alias ++ ".")
      Bool.pick(String, bad_ext, "import: expected a .bend file: " ++ rel,
      Bool.pick(String, bad_dup, "import: duplicate alias: " ++ alias,
      Bool.pick(String, bad_col, "import: declaration collides with alias: " ++ alias,
        b5k_check_top_imps(rest, Con{alias, seen_al}, bk))))
def b5k_load_imports(fuel: Nat, reqs: List<&2, ImpReq>, +seen: List<&2, String>, +bk: Book, +is_o2: Bool, +check_only: Bool, +out_path: String) -> IO(Unit):
  match fuel reqs:
    case 0n _: b5k_run_res(check_only, out_path, b5k_compile_check(is_o2, check_only, b5k_check(bk)))
    case _ Nil{}: b5k_run_res(check_only, out_path, b5k_compile_check(is_o2, check_only, b5k_check(bk)))
    case 1n++p Con{ImpReq{dir, +rel, +alias}, +rest}:
      +full = b5k_imp_full(dir, rel)
      b5k_if_io(Bool.not(String.ends_with(rel, ".bend")),
        _ => b5k_die("import: expected a .bend file: " ++ rel),
        _ => b5k_if_io(b5k_chk_str_match(False{}, seen, alias),
          _ => b5k_load_imports(p, rest, seen, bk, is_o2, check_only, out_path),
          _ => IO.bind(B5kIoRes<String>, Unit, b5k_read_file(full), r => b5k_io_bind(String, r, +src =>
            b5k_parse_bind(b5k_parse(String.reverse(String.reverse(src)), b5k_book_syms(bk)), imp_bk =>
              b5k_load_imports(p, b5k_list_app(ImpReq, b5k_scan_imp_go(U32.to_nat(2048), b5k_dir_of(full), String.reverse(String.reverse(src)), Nil{}), rest), Con{alias, seen}, b5k_merge_imp_book(alias, imp_bk, bk), is_o2, check_only, out_path))))))
def b5k_check_base_shadow_defs(+syms: SymTab, +ts: List<&2, TypeDef>, ds: List<&2, Def>) -> String:
  match ds:
    case Nil{}: ""
    case Con{Def{s, _, _, _, _, _}, t}:
      +nm = symtab_name(syms, s)
      bad = b5k_chk_is_reserved_def(syms, ts, nm)
      Bool.pick(String, bad, "check: duplicate declaration: " ++ nm, b5k_check_base_shadow_defs(syms, ts, t))
def b5k_check_base_shadow(has_base: Bool, bk: Book) -> String:
  Book{ts, ds, _, syms} = bk
  Bool.pick(String, has_base, b5k_check_base_shadow_defs(syms, ts, ds), "")
def b5k_run_src_k(is_o2: Bool, check_only: Bool, src_path: String, out_path: String, +src2: String, +bk: Book) -> IO(Unit):
  +reqs = b5k_scan_imp_go(U32.to_nat(2048), b5k_dir_of(src_path), src2, Nil{})
  +berr = b5k_check_base_shadow(String.contains(src2, "import Base"), bk)
  +ierr = Bool.pick(String, String.is_empty(berr), b5k_check_top_imps(reqs, Nil{}, bk), berr)
  b5k_if_io(String.is_empty(ierr),
    _ => b5k_load_imports(32n, reqs, Nil{}, bk, is_o2, check_only, out_path),
    _ => b5k_die(ierr))
def b5k_run_src(is_o2: Bool, check_only: Bool, src_path: String, out_path: String, +src2: String) -> IO(Unit):
  b5k_parse_bind(b5k_parse(src2, symtab_new()), bk => b5k_run_src_k(is_o2, check_only, src_path, out_path, src2, bk))
def b5k_run_driver(is_o2: Bool, +check_only: Bool, +src_path: String, out_path: String) -> IO(Unit):
  IO.bind(B5kIoRes<String>, Unit, b5k_read_file(src_path), r => b5k_io_bind(String, r, src => b5k_run_src(is_o2, check_only, src_path, out_path, String.reverse(String.reverse(src)))))
def b5k_dispatch_pos(is_o2: Bool, check_only: Bool, a1: String, rest: List<&2, String>) -> IO(Unit):
  match check_only rest:
    case True{} Nil{}: b5k_run_driver(is_o2, True{}, a1, "")
    case False{} Con{a2, Nil{}}: b5k_run_driver(is_o2, False{}, a1, String.reverse(String.reverse(a2)))
    case False{} Con{_, Con{a3, Nil{}}}: b5k_run_driver(is_o2, False{}, a1, String.reverse(String.reverse(a3)))
    case _ _: b5k_usage()
def b5k_parse_flags(fuel: Nat, +is_o2: Bool, +chk: Bool, args: List<&2, String>) -> IO(Unit):
  match fuel args:
    case 1n++p Con{+s1, Con{+s2, +more}}:
      b5k_if_io(b5k_str_eq(s1, "-O2"), _ => b5k_parse_flags(p, True{}, chk, Con{s2, more}),
      _ => b5k_if_io(b5k_str_eq(s1, "-O0"), _ => b5k_parse_flags(p, False{}, chk, Con{s2, more}),
      _ => b5k_if_io(b5k_str_eq(s1, "--check-only"), _ => b5k_parse_flags(p, is_o2, True{}, Con{s2, more}),
      _ => b5k_if_io(b5k_str_eq(s1, "--opt"), _ => b5k_parse_flags(p, b5k_str_eq(s2, "O2"), chk, more),
      _ => b5k_dispatch_pos(is_o2, chk, s1, Con{s2, more})))))
    case 1n+_ Con{a1, Nil{}}: b5k_dispatch_pos(is_o2, chk, a1, Nil{})
    case _ _: b5k_usage()
def b5k_clone_args(xs: List<String>) -> List<&2, String>:
  match xs:
    case Nil{}: Nil{}
    case Con{s, t}: Con{String.reverse(String.reverse(s)), b5k_clone_args(t)}
def b5k_main_args(argv: List<String>) -> IO(Unit):
  match argv:
    case Nil{}: b5k_usage()
    case Con{_, rest}: b5k_parse_flags(16n, False{}, False{}, b5k_clone_args(rest))
def main() -> IO(Unit): IO.bind(List<String>, Unit, IO.args(), argv => b5k_main_args(argv))
