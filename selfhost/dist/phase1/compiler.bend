import Base

# Generated source assembly. Edit the individual src modules.

# Module: src/core/term.bend:20
type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>}

# Module: src/core/term.bend:23
type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}

# Module: src/core/normalize.bend:405
type KNormFrame is Data:
  KNormFrame{+parent: KTerm, +done: List<&2, KTerm>, +todo: List<&2, KTerm>}

# Module: src/core/normalize.bend:573
type KNormCmp is Data:
  KNormCmp{+a: KTerm, +b: KTerm, +le: Bool, +fresh: U32}

# Module: src/core/normalize.bend:576
type KNormAlt is Data:
  KNormAlt{+todo: List<&2, KNormCmp>}

# Module: src/core/graph.bend:6
type GHeap is Data:
  GEmpty{}
  GNode{+value: KTerm, +left: GHeap, +right: GHeap}

# Module: src/core/graph.bend:10
type GState is Data:
  GState{+heap: GHeap, +next: U32}

# Module: src/core/graph.bend:13
type GResult is Data:
  GResult{+state: GState, +term: KTerm}

# Module: src/core/graph.bend:16
type GTerms is Data:
  GTerms{+state: GState, +terms: List<&2, KTerm>}

# Module: src/core/graph.bend:19
type GFrame is Data:
  GFill{+id: U32, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm}
  GMatch{+arm: KTerm, +raw: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm}
  GMinA{+other: KTerm, +args: List<&2, KTerm>}
  GMinB{+other: KTerm, +args: List<&2, KTerm>}
  GRewrite{+original: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm}

# Module: src/core/pretty.bend:3
type KPName is Data:
  KPName{name: String, id: U32, depth: U32}

# Module: src/core/pretty.bend:6
type KPChain is Data:
  KPChain{items: List<&2, KTerm>, tail: KTerm}

# Module: src/check/kernel.bend:4
type KChecked is Data:
  KChecked{+term: KTerm, +typ: KTerm, +uses: List<&2, KTerm>, +error: String}

# Module: src/check/kernel.bend:7
type KEnv is Data:
  KEnv{+book: List<&2, KDef>, +name: String, +lhs: KTerm, +pending: U32, +quantities: List<&2, KTerm>, +unsafe: Bool}

# Module: src/check/specialize.bend:5
type KSpecialized is Data:
  KSpecialized{+book: List<&2, KDef>, +error: String}

# Module: src/check/specialize.bend:8
type KSpecMemo is Data:
  KSpecMemo{+template: String, +key: String, +name: String, +active: Bool}

# Module: src/check/specialize.bend:11
type KSpecState is Data:
  KSpecState{+book: List<&2, KDef>, +memo: List<&2, KSpecMemo>, +serial: U32, +fresh: U32, +error: String, +templates: List<&2, KDef>}

# Module: src/check/specialize.bend:14
type KSpecTerm is Data:
  KSpecTerm{+state: KSpecState, +term: KTerm}

# Module: src/check/specialize.bend:17
type KSpecTerms is Data:
  KSpecTerms{+state: KSpecState, +terms: List<&2, KTerm>}

# Module: src/front/lexer.bend:2
type FToken is Data:
  FToken{+text: String, f_line: U32, f_col: U32, f_kind: U32}

# Module: src/front/lexer.bend:5
type FScanned is Data:
  FScanned{+word: String, +rest: String, size: U32}

# Module: src/front/parser.bend:3
type FParsed is Data:
  FParsed{+term: KTerm, +rest: List<&2, FToken>}

# Module: src/front/declarations.bend:2
type FResult is Data:
  FResult{+book: List<&2, KDef>, +error: String, +imports: List<&2, KTerm>}

# Module: src/front/flatten.bend:4
type FFlatten is Data:
  FFlatten{+term: KTerm, next: U32}

# Module: src/front/flatten.bend:7
type FFields is Data:
  FFields{+fields: List<&2, KTerm>, next: U32}

# Module: src/front/unicode.bend:2
type FDecoded is Data:
  FDecoded{code: U32, +rest: String, +error: String}

# Module: src/front/fresh_work.bend:3
type FFFrame is Data:
  FFAllA{+term: KTerm, +env: List<&2,KTerm>, +id: U32}
  FFAllB{+term: KTerm, +id: U32, +typ: KTerm}
  FFLambda{+term: KTerm, +id: U32}
  FFKids{+term: KTerm, +env: List<&2,KTerm>, +pending: List<&2,KTerm>, +built: List<&2,KTerm>}
  FFLetValue{+env: List<&2,KTerm>, +bodyenv: List<&2,KTerm>, +id: U32, +binding: KTerm, +pending: List<&2,KTerm>, +built: List<&2,KTerm>}
  FFLetBody{+built: List<&2,KTerm>}

# Module: src/front/fresh_work.bend:131
type FFDefFrame is Data:
  FFDefFrame{+definition: KDef, +pending: List<&2,KDef>, +built: List<&2,KDef>, +typ: KTerm, +value: KTerm}

# Module: src/front/freshen.bend:2
type FFresh is Data:
  FFresh{+term: KTerm, next: U32}

# Module: src/front/freshen.bend:5
type FFreshTerms is Data:
  FFreshTerms{+terms: List<&2, KTerm>, next: U32}

# Module: src/front/freshen.bend:8
type FFreshDefs is Data:
  FFreshDefs{+defs: List<&2, KDef>, next: U32}

# Module: src/load/graph.bend:4
type FGraph is Data:
  FGraph{+book: List<&2, KDef>, +error: String, +done: List<&2, KTerm>}

# Module: src/load/seed.bend:6
type FSeed is Data:
  FSeed{+path: String, +book: List<&2, KDef>}

# Module: src/load/modules.bend:3
type FSource is Data:
  FSource{+name: String, +path: String, +text: String}
  FParsedSource{+name: String, +path: String, +text: String, +parsed: FResult}

# Module: src/load/modules.bend:7
type FLoaded is Data:
  FLoaded{+book: List<&2, KDef>, +error: String, +seen: List<&2, String>}

# Module: src/diagnostic/model.bend:4
type DExpr is Data:
  DText{+text: String}
  DTerm{+term: KTerm}

# Module: src/diagnostic/model.bend:8
type DSpan is Data:
  DNoSpan{}
  DSpan{+source: String, begin: U32, end: U32}

# Module: src/diagnostic/model.bend:12
type DOrigin is Data:
  DOrigin{+definition: String, +term: KTerm, +source: String, begin: U32, end: U32, +path: List<&2, U32>}

# Module: src/diagnostic/model.bend:15
type DDiagnostic is Data:
  DDiagnostic{+expected: DExpr, +observed: DExpr, has_observed: Bool, +context: List<&2, KTerm>, +definition: String, +span: DSpan, +note: String, +trail: List<&2, KTerm>}

# Module: src/diagnostic/model.bend:18
type DResult is Data:
  DResult{+error: String, +book: List<&2, KDef>, +diagnostic: DDiagnostic}

# Module: src/diagnostic/frontend.bend:5
type FProvenance is Data:
  FProvenance{+result: FResult, +origins: List<&2,DOrigin>}

# Module: src/diagnostic/frontend.bend:8
type FPSource is Data:
  FPSource{+source: String, +tokens: List<&2,FToken>}

# Module: src/back/native/ir.bend:3
type N_WordKind is Data:
  N_W32{}
  N_W64{}
  N_Box{}

# Module: src/back/native/ir.bend:8
type N_Field is Data:
  N_Field{+offset: U32, +words: List<&2, N_WordKind>}

# Module: src/back/native/ir.bend:11
type N_Arm is Data:
  N_Arm{+name: String, +fields: List<&2, N_Field>}

# Module: src/back/native/ir.bend:14
type N_Layout is Data:
  N_Layout{+words: List<&2, N_WordKind>, +arms: List<&2, N_Arm>}

# Module: src/back/native/ir.bend:17
type N_Value is Data:
  N_Value{+words: List<&2, String>, +layout: N_Layout, +static: Bool}

# Module: src/back/native/ir.bend:20
type N_Param is Data:
  N_Param{+name: String, +kind: N_WordKind}

# Module: src/back/native/ir.bend:23
type N_Frame is Data:
  N_Direct{}
  N_Frame{+pop: U32, +slots: List<&2, String>}

# Module: src/back/native/ir.bend:27
type N_Segment is Data:
  N_Segment{+name: String, +params: List<&2, N_Param>, +result: U32, +frame: N_Frame, +body: String, +refs: List<&2, String>, +host: Bool, +spin: Bool, +fork: Bool, +bang: Bool}

# Module: src/back/native/ir.bend:30
type N_Constructor is Data:
  N_Constructor{+name: String, +arity: U32, +hot: Bool}

# Module: src/back/native/ir.bend:33
type N_Program is Data:
  N_Program{+segments: List<&2, N_Segment>, +constructors: List<&2, N_Constructor>, +image: List<&2, String>, +requests: String, +declarations: String, +show: String, +pure: Bool}

# Module: src/back/native/ir.bend:36
type N_Emitted is Data:
  N_Emitted{+code: String, +value: String, +fresh: U32}

# Module: src/back/native/intrinsic.bend:1
type ni_Op is Data:
  ni_Op{+name: String, +template: String}

# Module: src/back/native/bridge.bend:5
type NC_Literal is Data:
  NC_Literal{+valid: Bool, +value: U32}

# Module: src/back/native/bridge.bend:8
type NC_Binding is Data:
  NC_Binding{+id: U32, +word: String}

# Module: src/back/native/bridge.bend:11
type NC_Code is Data:
  NC_Code{+body: String, +segments: List<&2, N_Segment>, +fresh: U32, +error: String}

# Module: src/back/native/pattern.bend:4
type NPLevel is Data:
  NPLevel{+zero: KTerm, +successor: KTerm, +fallback: KTerm, +hasZero: Bool, +hasSucc: Bool, +valid: Bool}

# Module: src/back/native/pattern.bend:7
type NPRow is Data:
  NPRow{+index: U32, +body: KTerm, +residual: U32, +apply: Bool, +last: Bool}

# Module: src/back/native/show.bend:3
type NC_Desc is Data:
  NC_Desc{+cells: List<&2, String>, +types: List<&2, KTerm>, +error: String}

# Module: src/back/native/show.bend:6
type NC_Show is Data:
  NC_Show{+source: String, +error: String}

# Module: src/back/native/book.bend:1
type NC_Result is Data:
  NC_Result{+source: String, +error: String}

# Module: src/back/native/book.bend:4
type NC_Book is Data:
  NC_Book{+segments: List<&2, N_Segment>, +fresh: U32, +error: String}

# Module: src/core/term.bend:3
law kc:
  for -A: Type
  for +b: Bool
  for yes: Unit -> A
  for no: Unit -> A
  A

# Module: src/core/term.bend:26
law kt:
  for +tag: String
  for +name: String
  for +id: U32
  for +quant: U32
  for +kids: List<&2, KTerm>
  KTerm

# Module: src/core/term.bend:38
law atom:
  for +tag: String
  KTerm

# Module: src/core/term.bend:46
law tg:
  for +t: KTerm
  String

# Module: src/core/term.bend:56
law nm:
  for +t: KTerm
  String

# Module: src/core/term.bend:66
law ix:
  for +t: KTerm
  U32

# Module: src/core/term.bend:76
law qt:
  for +t: KTerm
  U32

# Module: src/core/term.bend:86
law ks:
  for +t: KTerm
  List<&2, KTerm>

# Module: src/core/term.bend:96
law rm:
  for +t: KTerm
  List<&2, String>

# Module: src/core/term.bend:106
law terms_at:
  for +ts: List<&2, KTerm>
  for +n: U32
  KTerm

# Module: src/core/term.bend:119
law kid:
  for +t: KTerm
  for +n: U32
  KTerm

# Module: src/core/term.bend:128
law var:
  for +name: String
  for +id: U32
  KTerm

# Module: src/core/term.bend:137
law ref:
  for +name: String
  KTerm

# Module: src/core/term.bend:145
law qua:
  for +q: U32
  KTerm

# Module: src/core/term.bend:153
law typ:
  for +q: U32
  KTerm

# Module: src/core/term.bend:161
law app:
  for +f: KTerm
  for +x: KTerm
  KTerm

# Module: src/core/term.bend:170
law all:
  for +q: U32
  for +name: String
  for +id: U32
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/term.bend:182
law dn:
  for +d: KDef
  String

# Module: src/core/term.bend:192
law dk:
  for +d: KDef
  String

# Module: src/core/term.bend:202
law da:
  for +d: KDef
  U32

# Module: src/core/term.bend:212
law dx:
  for +d: KDef
  U32

# Module: src/core/term.bend:222
law dt:
  for +d: KDef
  KTerm

# Module: src/core/term.bend:232
law dv:
  for +d: KDef
  KTerm

# Module: src/core/term.bend:242
law dc:
  for +d: KDef
  List<&2, KDef>

# Module: src/core/term.bend:252
law db:
  for +d: KDef
  Bool

# Module: src/core/term.bend:262
law du:
  for +d: KDef
  Bool

# Module: src/core/term.bend:272
law missing:
  KDef

# Module: src/core/term.bend:279
law lookup:
  for +book: List<&2, KDef>
  for +name: String
  KDef

# Module: src/core/term.bend:292
law terms_len:
  for +ts: List<&2, KTerm>
  U32

# Module: src/core/term.bend:304
law has_name:
  for +ns: List<&2, String>
  for +name: String
  Bool

# Module: src/core/term.bend:317
law subst_terms:
  for +ts: List<&2, KTerm>
  for +id: U32
  for +v: KTerm
  List<&2, KTerm>

# Module: src/core/term.bend:323
law core_force:
  for +t: KTerm
  KTerm

# Module: src/core/term.bend:327
law core_rebuild:
  for +t: KTerm
  KTerm

# Module: src/core/term.bend:331
law core_apply:
  for +f: KTerm
  for +x: KTerm
  KTerm

# Module: src/core/term.bend:336
law subst_node:
  for +t: KTerm
  for +id: U32
  for +v: KTerm
  KTerm

# Module: src/core/term.bend:342
law subst:
  for +t: KTerm
  for +id: U32
  for +v: KTerm
  KTerm

# Module: src/core/term.bend:380
law core_beta:
  for +t: KTerm
  KTerm

# Module: src/core/index.bend:4
law index_hash:
  for +name: String
  for +acc: U32
  U32

# Module: src/core/index.bend:9
law index_child:
  for +tree: KDef
  for +right: Bool
  KDef

# Module: src/core/index.bend:14
law index_child_list:
  for +ds: List<&2, KDef>
  for +right: Bool
  KDef

# Module: src/core/index.bend:19
law index_first:
  for +ds: List<&2, KDef>
  KDef

# Module: src/core/index.bend:23
law index_find:
  for +tree: KDef
  for +name: String
  for +hash: U32
  for +bits: U32
  KDef

# Module: src/core/index.bend:30
law index_bucket:
  for +ds: List<&2, KDef>
  for +name: String
  KDef

# Module: src/core/index.bend:35
law index_remove:
  for +ds: List<&2, KDef>
  for +name: String
  List<&2, KDef>

# Module: src/core/index.bend:40
law index_set:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +bits: U32
  KDef

# Module: src/core/index.bend:47
law index_set_node:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +bits: U32
  for +right: Bool
  KDef

# Module: src/core/index.bend:55
law index_build:
  for +book: List<&2, KDef>
  KDef

# Module: src/core/index.bend:59
law index_lookup:
  for +cache: KDef
  for +name: String
  KDef

# Module: src/core/index.bend:64
law book_cached:
  for +book: List<&2, KDef>
  for +bound: U32
  List<&2, KDef>

# Module: src/core/index.bend:69
law book_put:
  for +book: List<&2, KDef>
  for +d: KDef
  List<&2, KDef>

# Module: src/core/index.bend:157
law book_context:
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/core/normalize.bend:5
law norm_join:
  for +a: List<&2, KTerm>
  for +b: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/core/normalize.bend:18
law norm_apply:
  for +t: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/core/normalize.bend:31
law wnf:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/core/normalize.bend:40
law norm_eval:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:48
law norm_eval_node:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:59
law norm_ref:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +d: KDef
  KTerm

# Module: src/core/normalize.bend:69
law norm_args:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:84
law norm_dec:
  for +n: U32
  U32

# Module: src/core/normalize.bend:91
law norm_match:
  for +book: List<&2, KDef>
  for +arm: KTerm
  for +original: KTerm
  for +raw: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:105
law norm_stuck:
  for +t: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:116
law norm_min:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:126
law norm_min_left:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:135
law norm_min_right:
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:143
law strong:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/core/normalize.bend:152
law norm_strong:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/core/normalize.bend:163
law norm_strongs:
  for +book: List<&2, KDef>
  for +ts: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/core/normalize.bend:176
law norm_max:
  for +a: U32
  for +b: U32
  U32

# Module: src/core/normalize.bend:184
law norm_max_term:
  for +t: KTerm
  U32

# Module: src/core/normalize.bend:192
law norm_max_terms:
  for +ts: List<&2, KTerm>
  U32

# Module: src/core/normalize.bend:200
law norm_max_book:
  for +book: List<&2, KDef>
  U32

# Module: src/core/normalize.bend:208
law compare:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  Bool

# Module: src/core/normalize.bend:219
law norm_compare:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:231
law norm_compare_heads:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:242
law norm_compare_same:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:253
law norm_compare_plain:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:263
law norm_compare_terms:
  for +book: List<&2, KDef>
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:286
law norm_subset:
  for +as: List<&2, String>
  for +bs: List<&2, String>
  Bool

# Module: src/core/normalize.bend:299
law norm_removed:
  for +as: List<&2, String>
  for +bs: List<&2, String>
  for +le: Bool
  Bool

# Module: src/core/normalize.bend:308
law norm_kind:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +g: KTerm
  for +h: KTerm
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:320
law norm_let:
  for +ts: List<&2, KTerm>
  KTerm

# Module: src/core/normalize.bend:332
law norm_let_tail:
  for +h: KTerm
  for +rest: List<&2, KTerm>
  KTerm

# Module: src/core/normalize.bend:350
law norm_var:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +values: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:367
law norm_names_len:
  for +names: List<&2, String>
  U32

# Module: src/core/normalize.bend:381
law norm_book_bound:
  for +book: List<&2, KDef>
  U32

# Module: src/core/normalize.bend:385
law norm_bound_found:
  for +book: List<&2, KDef>
  for +stamp: KDef
  U32

# Module: src/core/normalize.bend:408
law norm_max_walk:
  for +todo: List<&2, KTerm>
  for +bound: U32
  U32

# Module: src/core/normalize.bend:413
law norm_max_defs:
  for +todo: List<&2, KDef>
  for +bound: U32
  U32

# Module: src/core/normalize.bend:418
law norm_defs_join:
  for +a: List<&2, KDef>
  for +b: List<&2, KDef>
  List<&2, KDef>

# Module: src/core/normalize.bend:423
law norm_snf_go:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/normalize.bend:430
law norm_snf_head:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/normalize.bend:437
law norm_rebind:
  for +t: KTerm
  for +fresh: U32
  KTerm

# Module: src/core/normalize.bend:442
law norm_snf_open:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/normalize.bend:449
law norm_snf_children:
  for +book: List<&2, KDef>
  for +parent: KTerm
  for +done: List<&2, KTerm>
  for +todo: List<&2, KTerm>
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/normalize.bend:458
law norm_snf_return:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/normalize.bend:523
law norm_exact:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:528
law norm_exact_lists:
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  Bool

# Module: src/core/normalize.bend:533
law norm_exact_head:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:538
law norm_exact_names:
  for +as: List<&2, String>
  for +bs: List<&2, String>
  Bool

# Module: src/core/normalize.bend:578
law norm_cmp_loop:
  for +book: List<&2, KDef>
  for +todo: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:584
law norm_cmp_quick:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:589
law norm_cmp_fail:
  for +book: List<&2, KDef>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:594
law norm_cmp_test:
  for +book: List<&2, KDef>
  for +yes: Bool
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:601
law norm_cmp_heads:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:611
law norm_cmp_same:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:621
law norm_cmp_plain:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:630
law norm_cmp_fields:
  for +book: List<&2, KDef>
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:639
law norm_cmp_zip:
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  List<&2, KNormCmp>

# Module: src/core/normalize.bend:646
law norm_cmp_kind:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +g: KTerm
  for +h: KTerm
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/graph.bend:26
law g_heap:
  for +st: GState
  GHeap

# Module: src/core/graph.bend:30
law g_next:
  for +st: GState
  U32

# Module: src/core/graph.bend:34
law g_state:
  for +r: GResult
  GState

# Module: src/core/graph.bend:38
law g_term:
  for +r: GResult
  KTerm

# Module: src/core/graph.bend:42
law g_states:
  for +r: GTerms
  GState

# Module: src/core/graph.bend:46
law g_terms:
  for +r: GTerms
  List<&2, KTerm>

# Module: src/core/graph.bend:50
law g_get:
  for +heap: GHeap
  for +id: U32
  KTerm

# Module: src/core/graph.bend:55
law g_put:
  for +heap: GHeap
  for +id: U32
  for +value: KTerm
  GHeap

# Module: src/core/graph.bend:61
law g_put_node:
  for +old: KTerm
  for +left: GHeap
  for +right: GHeap
  for +id: U32
  for +value: KTerm
  GHeap

# Module: src/core/graph.bend:69
law g_share:
  for +st: GState
  for +t: KTerm
  GResult

# Module: src/core/graph.bend:74
law g_share_terms:
  for +st: GState
  for +ts: List<&2, KTerm>
  for +done: List<&2, KTerm>
  GTerms

# Module: src/core/graph.bend:80
law g_shared_term:
  for +rest: List<&2, KTerm>
  for +done: List<&2, KTerm>
  for +r: GResult
  GTerms

# Module: src/core/graph.bend:86
law g_share_head:
  for +st: GState
  for +t: KTerm
  GResult

# Module: src/core/graph.bend:91
law g_shared_head:
  for +t: KTerm
  for +r: GTerms
  GResult

# Module: src/core/graph.bend:96
law g_cache:
  for +st: GState
  for +id: U32
  for +t: KTerm
  GState

# Module: src/core/graph.bend:102
law g_wnf:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  GResult

# Module: src/core/graph.bend:108
law g_eval:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:118
law g_cell:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +cell: KTerm
  GResult

# Module: src/core/graph.bend:129
law g_app:
  for +book: List<&2, KDef>
  for +fn: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:139
law g_ref:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +stack: List<&2, GFrame>
  for +d: KDef
  GResult

# Module: src/core/graph.bend:148
law g_args:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:158
law g_return:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:165
law g_resume:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +frame: GFrame
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:173
law g_filled:
  for +book: List<&2, KDef>
  for +id: U32
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:183
law g_min_left:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +args: List<&2, KTerm>
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:192
law g_match:
  for +book: List<&2, KDef>
  for +st: GState
  for +arm: KTerm
  for +original: KTerm
  for +raw: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:205
law g_let:
  for +book: List<&2, KDef>
  for +st: GState
  for +ts: List<&2, KTerm>
  for +bindings: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:216
law g_let_shared:
  for +book: List<&2, KDef>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +bindings: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:228
law g_let_sub:
  for +t: KTerm
  for +bindings: List<&2, KTerm>
  KTerm

# Module: src/core/graph.bend:233
law graph_strong:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/core/graph.bend:238
law g_snf_go:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/graph.bend:246
law g_snf_head:
  for +book: List<&2, KDef>
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  for +r: GResult
  KTerm

# Module: src/core/graph.bend:253
law g_snf_open:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/graph.bend:261
law g_snf_children:
  for +book: List<&2, KDef>
  for +st: GState
  for +parent: KTerm
  for +done: List<&2, KTerm>
  for +todo: List<&2, KTerm>
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/graph.bend:271
law g_snf_return:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/graph.bend:495
law g_start:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +bound: U32
  KTerm

# Module: src/core/reach.bend:7
law reach_book:
  for +book: List<&2, KDef>
  for +roots: List<&2, String>
  for +stops: List<&2, String>
  List<&2, KDef>

# Module: src/core/reach.bend:13
law kr_filter:
  for book: List<&2, KDef>
  for +live: List<&2, String>
  List<&2, KDef>

# Module: src/core/reach.bend:18
law kr_visit:
  for +book: List<&2, KDef>
  for todo: List<&2, String>
  for +seen: List<&2, String>
  for +stops: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:25
law kr_visit_def:
  for +book: List<&2, KDef>
  for +todo: List<&2, String>
  for +seen: List<&2, String>
  for +stops: List<&2, String>
  for +d: KDef
  List<&2, String>

# Module: src/core/reach.bend:33
law kr_resolve:
  for +book: List<&2, KDef>
  for +name: String
  KDef

# Module: src/core/reach.bend:38
law kr_resolve_head:
  for +book: List<&2, KDef>
  for +name: String
  for +d: KDef
  KDef

# Module: src/core/reach.bend:44
law kr_parent:
  for book: List<&2, KDef>
  for +name: String
  KDef

# Module: src/core/reach.bend:49
law kr_dependencies:
  for +d: KDef
  for +stops: List<&2, String>
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:55
law kr_ctor_refs:
  for ctors: List<&2, KDef>
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:60
law kr_refs:
  for +t: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:65
law kr_refs_list:
  for terms: List<&2, KTerm>
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:70
law kr_push:
  for +name: String
  for +names: List<&2, String>
  List<&2, String>

# Module: src/core/pretty.bend:9
law kp_eq:
  for +a: String
  for +b: String
  Bool

# Module: src/core/pretty.bend:14
law kp_is:
  for +t: KTerm
  for +tag: String
  for +name: String
  Bool

# Module: src/core/pretty.bend:20
law kp_quant:
  for +q: U32
  String

# Module: src/core/pretty.bend:24
law kp_join:
  for xs: List<&2, String>
  for +sep: String
  String

# Module: src/core/pretty.bend:29
law kp_par:
  for +s: String
  for +yes: Bool
  String

# Module: src/core/pretty.bend:34
law kp_show:
  for +t: KTerm
  String

# Module: src/core/pretty.bend:38
law kp_scope:
  for env: List<&2, KPName>
  for +id: U32
  for +name: String
  String

# Module: src/core/pretty.bend:44
law kp_index:
  for env: List<&2, KPName>
  for +id: U32
  U32

# Module: src/core/pretty.bend:49
law kp_depth:
  for env: List<&2, KPName>
  U32

# Module: src/core/pretty.bend:53
law kp_bound:
  for env: List<&2, KPName>
  for +name: String
  Bool

# Module: src/core/pretty.bend:58
law kp_bind:
  for +env: List<&2, KPName>
  for +t: KTerm
  List<&2, KPName>

# Module: src/core/pretty.bend:63
law kp_each:
  for ts: List<&2, KTerm>
  for +p: U32
  for +env: List<&2, KPName>
  List<&2, String>

# Module: src/core/pretty.bend:69
law kp_chain:
  for +t: KTerm
  for +name: String
  for +arity: U32
  for +acc: List<&2, KTerm>
  KPChain

# Module: src/core/pretty.bend:76
law kp_spine:
  for +t: KTerm
  for +acc: List<&2, KTerm>
  KPChain

# Module: src/core/pretty.bend:81
law kp_application:
  for s: KPChain
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:87
law kp_removed:
  for xs: List<&2, String>
  String

# Module: src/core/pretty.bend:91
law kp_adt:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:97
law kp_has_removed:
  for xs: List<&2, String>
  Bool

# Module: src/core/pretty.bend:101
law kp_word:
  for +t: KTerm
  for +bit: U32
  for +left: U32
  for +acc: U32
  Maybe<&2, U32>

# Module: src/core/pretty.bend:108
law kp_number:
  for +t: KTerm
  Maybe<&2, U32>

# Module: src/core/pretty.bend:112
law kp_float:
  for n: U32
  F32

# Module: src/core/pretty.bend:116
law kp_float_show:
  for +n: U32
  String

# Module: src/core/pretty.bend:120
law kp_float_text:
  for +s: String
  String

# Module: src/core/pretty.bend:124
law kp_hex:
  for +n: U32
  String

# Module: src/core/pretty.bend:128
law kp_digit:
  for +n: U32
  String

# Module: src/core/pretty.bend:132
law kp_escape:
  for +n: U32
  for +quote: U32
  String

# Module: src/core/pretty.bend:137
law kp_char:
  for +t: KTerm
  for +quote: U32
  Maybe<&2, String>

# Module: src/core/pretty.bend:142
law kp_char_num:
  for n: Maybe<&2, U32>
  for +quote: U32
  Maybe<&2, String>

# Module: src/core/pretty.bend:147
law kp_string:
  for +t: KTerm
  Maybe<&2, String>

# Module: src/core/pretty.bend:151
law kp_append:
  for a: Maybe<&2, String>
  for b: Maybe<&2, String>
  Maybe<&2, String>

# Module: src/core/pretty.bend:156
law kp_list:
  for chain: KPChain
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:162
law kp_tuple:
  for chain: KPChain
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:167
law kp_nat:
  for +t: KTerm
  for +n: Nat
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:174
law kp_array:
  for +t: KTerm
  Maybe<&2, List<&2, KTerm>>

# Module: src/core/pretty.bend:178
law kp_array_join:
  for a: Maybe<&2, List<&2, KTerm>>
  for b: Maybe<&2, List<&2, KTerm>>
  Maybe<&2, List<&2, KTerm>>

# Module: src/core/pretty.bend:183
law kp_ctor:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:189
law kp_ctor_number:
  for n: Maybe<&2, U32>
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:196
law kp_ctor_other:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:202
law kp_ctor_char:
  for c: Maybe<&2, String>
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:209
law kp_ctor_string:
  for s: Maybe<&2, String>
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:216
law kp_ctor_array:
  for a: Maybe<&2, List<&2, KTerm>>
  for +t: KTerm
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:222
law kp_matches:
  for +t: KTerm
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:227
law kp_go:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:233
law kp_go_tail:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:239
law kp_go_last:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:245
law kp_float_point:
  for s: String
  String

# Module: src/core/pretty.bend:249
law kp_exists:
  for +A: KTerm
  for +b: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:256
law kp_rewrite:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:262
law kp_rewrite_motive:
  for +e: KTerm
  for +m: KTerm
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:268
law kp_let:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:274
law kp_let_names:
  for ts: List<&2, KTerm>
  String

# Module: src/core/pretty.bend:278
law kp_let_vals:
  for ts: List<&2, KTerm>
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:283
law kp_let_body:
  for ts: List<&2, KTerm>
  for +env: List<&2, KPName>
  String

# Module: src/check/quantity.bend:4
law qadd:
  for +a: U32
  for +b: U32
  U32

# Module: src/check/quantity.bend:9
law qjoin:
  for +a: U32
  for +b: U32
  U32

# Module: src/check/quantity.bend:14
law qdem:
  for +q: U32
  for +d: U32
  U32

# Module: src/check/quantity.bend:19
law uses_get:
  for +xs: List<&2, KTerm>
  for +id: U32
  U32

# Module: src/check/quantity.bend:24
law uses_del:
  for +xs: List<&2, KTerm>
  for +id: U32
  List<&2, KTerm>

# Module: src/check/quantity.bend:29
law uses_merge:
  for +a: List<&2, KTerm>
  for +b: List<&2, KTerm>
  for +join: Bool
  List<&2, KTerm>

# Module: src/check/quantity.bend:35
law strip:
  for +t: KTerm
  KTerm

# Module: src/check/quantity.bend:39
law descend:
  for +q: U32
  for +a: KTerm
  for +p: KTerm
  U32

# Module: src/check/quantity.bend:45
law descend_go:
  for +a: KTerm
  for +p: KTerm
  U32

# Module: src/check/quantity.bend:50
law descend_fields:
  for +a: List<&2, KTerm>
  for +p: List<&2, KTerm>
  for +ord: U32
  U32

# Module: src/check/quantity.bend:56
law terms_tail:
  for +ts: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/quantity.bend:60
law descend_ctr:
  for +a: KTerm
  for +p: KTerm
  for +ord: U32
  U32

# Module: src/check/quantity.bend:66
law descend_sub:
  for +a: KTerm
  for +ps: List<&2, KTerm>
  U32

# Module: src/check/quantity.bend:71
law descend_spine:
  for +qs: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +cols: List<&2, KTerm>
  Bool

# Module: src/check/quantity.bend:77
law descend_step:
  for +ord: U32
  for +qs: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +cols: List<&2, KTerm>
  Bool

# Module: src/check/kernel.bend:10
law cb:
  for +e: KEnv
  List<&2, KDef>

# Module: src/check/kernel.bend:14
law cn:
  for +e: KEnv
  String

# Module: src/check/kernel.bend:18
law cl:
  for +e: KEnv
  KTerm

# Module: src/check/kernel.bend:22
law cp:
  for +e: KEnv
  U32

# Module: src/check/kernel.bend:26
law cq:
  for +e: KEnv
  List<&2, KTerm>

# Module: src/check/kernel.bend:30
law cu:
  for +e: KEnv
  Bool

# Module: src/check/kernel.bend:34
law ct:
  for +r: KChecked
  KTerm

# Module: src/check/kernel.bend:38
law cy:
  for +r: KChecked
  KTerm

# Module: src/check/kernel.bend:42
law cs:
  for +r: KChecked
  List<&2, KTerm>

# Module: src/check/kernel.bend:46
law ce:
  for +r: KChecked
  String

# Module: src/check/kernel.bend:50
law ok:
  for +t: KTerm
  for +ty: KTerm
  for +us: List<&2, KTerm>
  KChecked

# Module: src/check/kernel.bend:56
law bad:
  for +msg: String
  KChecked

# Module: src/check/kernel.bend:60
law good:
  for +r: KChecked
  Bool

# Module: src/check/kernel.bend:64
law checked:
  for +r: KChecked
  for +t: KTerm
  for +ty: KTerm
  KChecked

# Module: src/check/kernel.bend:70
law both:
  for +a: KChecked
  for +b: KChecked
  for +t: KTerm
  for +ty: KTerm
  for +join: Bool
  KChecked

# Module: src/check/kernel.bend:78
law ctx_get:
  for +ctx: List<&2, KTerm>
  for +id: U32
  KTerm

# Module: src/check/kernel.bend:83
law ctx_bind:
  for +ctx: List<&2, KTerm>
  for +id: U32
  for +q: U32
  for +name: String
  for +ty: KTerm
  List<&2, KTerm>

# Module: src/check/kernel.bend:91
law kindq:
  for +e: KEnv
  for +q: U32
  U32

# Module: src/check/kernel.bend:96
law kapply:
  for +fn: KTerm
  for +x: KTerm
  KTerm

# Module: src/check/kernel.bend:101
law lhs_step:
  for +e: KEnv
  for +x: KTerm
  KEnv

# Module: src/check/kernel.bend:106
law unargs:
  for +t: KTerm
  for +acc: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/kernel.bend:111
law infer:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  KChecked

# Module: src/check/kernel.bend:119
law infer_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  KChecked

# Module: src/check/kernel.bend:127
law infer_var:
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  KChecked

# Module: src/check/kernel.bend:133
law infer_ref:
  for +e: KEnv
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  for +d: KDef
  KChecked

# Module: src/check/kernel.bend:141
law infer_app:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +r: KChecked
  KChecked

# Module: src/check/kernel.bend:149
law infer_app_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +r: KChecked
  for +ty: KTerm
  KChecked

# Module: src/check/kernel.bend:158
law infer_adt:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +d: KDef
  KChecked

# Module: src/check/kernel.bend:166
law infer_adt_done:
  for +t: KTerm
  for +r: KChecked
  KChecked

# Module: src/check/kernel.bend:171
law tele_check:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  for +dem: U32
  KChecked

# Module: src/check/kernel.bend:179
law tele_check_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  KChecked

# Module: src/check/kernel.bend:188
law tele_check_done:
  for +a: KChecked
  for +b: KChecked
  KChecked

# Module: src/check/kernel.bend:193
law tele_fill:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:199
law tele_fill_head:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:206
law check:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecked

# Module: src/check/kernel.bend:214
law check_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecked

# Module: src/check/kernel.bend:222
law check_fits:
  for +e: KEnv
  for +r: KChecked
  for +ty: KTerm
  KChecked

# Module: src/check/kernel.bend:228
law check_lam:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecked

# Module: src/check/kernel.bend:236
law check_lam_q:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +q: U32
  KChecked

# Module: src/check/kernel.bend:245
law check_lam_done:
  for +t: KTerm
  for +ty: KTerm
  for +q: U32
  for +r: KChecked
  KChecked

# Module: src/check/kernel.bend:252
law check_ctr:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecked

# Module: src/check/kernel.bend:260
law check_ctr_found:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +ctr: KDef
  KChecked

# Module: src/check/kernel.bend:269
law check_rfl:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  KChecked

# Module: src/check/kernel.bend:275
law check_let:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +dem: U32
  for +ty: KTerm
  for +bindings: List<&2, KTerm>
  for +us: List<&2, KTerm>
  KChecked

# Module: src/check/kernel.bend:286
law check_let_value:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  for +ty: KTerm
  for +bindings: List<&2, KTerm>
  for +us: List<&2, KTerm>
  for +r: KChecked
  KChecked

# Module: src/check/kernel.bend:299
law check_let_kind:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  for +ty: KTerm
  for +bindings: List<&2, KTerm>
  for +us: List<&2, KTerm>
  for +r: KChecked
  for +k: KChecked
  KChecked

# Module: src/check/kernel.bend:313
law let_cells:
  for +body: KTerm
  for +bs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:318
law check_let_done:
  for +r: KChecked
  for +bs: List<&2, KTerm>
  for +us: List<&2, KTerm>
  KChecked

# Module: src/check/kernel.bend:324
law remaining:
  for +cs: List<&2, KDef>
  for +removed: List<&2, String>
  List<&2, KDef>

# Module: src/check/kernel.bend:329
law defs_empty:
  for +ds: List<&2, KDef>
  Bool

# Module: src/check/kernel.bend:333
law ctx_dead:
  for +book: List<&2, KDef>
  for +ctx: List<&2, KTerm>
  Bool

# Module: src/check/kernel.bend:338
law dead_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/check/kernel.bend:343
law check_mat:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecked

# Module: src/check/kernel.bend:351
law check_mat_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +a: KTerm
  KChecked

# Module: src/check/kernel.bend:360
law check_mat_ctr:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +a: KTerm
  for +ctr: KDef
  KChecked

# Module: src/check/kernel.bend:370
law mat_goal:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:379
law mat_goal_head:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:388
law lhs_ext:
  for +lhs: KTerm
  for +name: String
  for +tel: KTerm
  for +n: U32
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:396
law mat_lhs:
  for +e: KEnv
  for +name: String
  for +tel: KTerm
  for +n: U32
  KEnv

# Module: src/check/kernel.bend:403
law check_rwt:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +r: KChecked
  KChecked

# Module: src/check/kernel.bend:412
law check_rwt_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +r: KChecked
  for +eq: KTerm
  KChecked

# Module: src/check/kernel.bend:422
law check_rwt_goal:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +r: KChecked
  for +eq: KTerm
  for +fresh: U32
  KChecked

# Module: src/check/kernel.bend:433
law tele_quantities:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +n: U32
  List<&2, KTerm>

# Module: src/check/kernel.bend:439
law tele_quantities_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +n: U32
  List<&2, KTerm>

# Module: src/check/kernel.bend:445
law declared:
  for +d: KDef
  KDef

# Module: src/check/kernel.bend:449
law book_without:
  for +book: List<&2, KDef>
  for +name: String
  List<&2, KDef>

# Module: src/check/kernel.bend:454
law check_book:
  for +book: List<&2, KDef>
  String

# Module: src/check/kernel.bend:458
law check_events:
  for +todo: List<&2, KDef>
  for +done: List<&2, KDef>
  String

# Module: src/check/kernel.bend:463
law check_open:
  for +book: List<&2, KDef>
  String

# Module: src/check/kernel.bend:467
law count_open:
  for +book: List<&2, KDef>
  U32

# Module: src/check/kernel.bend:471
law check_open_message:
  for +n: U32
  String

# Module: src/check/kernel.bend:475
law check_event_guard:
  for +rest: List<&2, KDef>
  for +done: List<&2, KDef>
  for +d: KDef
  for +err: String
  String

# Module: src/check/kernel.bend:482
law signature_mode:
  for +d: KDef
  for +later: List<&2, KDef>
  KDef

# Module: src/check/kernel.bend:487
law signature_fill_mode:
  for +d: KDef
  for +fill: KDef
  KDef

# Module: src/check/kernel.bend:492
law event_error:
  for +done: List<&2, KDef>
  for +d: KDef
  for +old: KDef
  String

# Module: src/check/kernel.bend:498
law constructor_exists:
  for +ds: List<&2, KDef>
  for +name: String
  Bool

# Module: src/check/kernel.bend:503
law constructor_names:
  for +done: List<&2, KDef>
  for +ctrs: List<&2, KDef>
  for +names: List<&2, String>
  String

# Module: src/check/kernel.bend:509
law check_event_done:
  for +rest: List<&2, KDef>
  for +done: List<&2, KDef>
  for +d: KDef
  for +err: String
  String

# Module: src/check/kernel.bend:516
law check_definition:
  for +book: List<&2, KDef>
  for +d: KDef
  String

# Module: src/check/kernel.bend:521
law check_definition_type:
  for +book: List<&2, KDef>
  for +d: KDef
  for +e: KEnv
  for +r: KChecked
  String

# Module: src/check/kernel.bend:528
law foreign_tip:
  for +t: KTerm
  KTerm

# Module: src/check/kernel.bend:532
law foreign_head:
  for +t: KTerm
  KTerm

# Module: src/check/kernel.bend:536
law check_foreign:
  for +book: List<&2, KDef>
  for +d: KDef
  String

# Module: src/check/kernel.bend:541
law tele_tip:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/check/kernel.bend:546
law tele_tip_head:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/check/kernel.bend:551
law check_adt_declaration:
  for +e: KEnv
  for +d: KDef
  String

# Module: src/check/kernel.bend:556
law check_ctors:
  for +e: KEnv
  for +d: KDef
  for +ctrs: List<&2, KDef>
  for +kind: KTerm
  String

# Module: src/check/kernel.bend:563
law check_ctors_next:
  for +e: KEnv
  for +d: KDef
  for +rest: List<&2, KDef>
  for +kind: KTerm
  for +err: String
  String

# Module: src/check/kernel.bend:571
law check_ctor_tel:
  for +e: KEnv
  for +d: KDef
  for +tel: KTerm
  for +kind: KTerm
  for +params: U32
  for +fields: U32
  for +ctx: List<&2, KTerm>
  for +args: List<&2, KTerm>
  String

# Module: src/check/kernel.bend:582
law check_ctor_head:
  for +e: KEnv
  for +d: KDef
  for +tel: KTerm
  for +kind: KTerm
  for +params: U32
  for +fields: U32
  for +ctx: List<&2, KTerm>
  for +args: List<&2, KTerm>
  String

# Module: src/check/kernel.bend:593
law check_ctor_domain:
  for +e: KEnv
  for +d: KDef
  for +tel: KTerm
  for +kind: KTerm
  for +params: U32
  for +fields: U32
  for +ctx: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +r: KChecked
  String

# Module: src/check/kernel.bend:605
law infer_template:
  for +e: KEnv
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  for +d: KDef
  KChecked

# Module: src/check/kernel.bend:613
law template_args:
  for +e: KEnv
  for +ty: KTerm
  for +sp: List<&2, KTerm>
  for +n: U32
  KChecked

# Module: src/check/kernel.bend:620
law template_arg_head:
  for +e: KEnv
  for +ty: KTerm
  for +sp: List<&2, KTerm>
  for +n: U32
  KChecked

# Module: src/check/kernel.bend:627
law template_arg_done:
  for +e: KEnv
  for +ty: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +n: U32
  for +r: KChecked
  KChecked

# Module: src/check/kernel.bend:636
law self_pending:
  for +d: KDef
  for +body: KTerm
  U32

# Module: src/check/kernel.bend:641
law contains_self:
  for +todo: List<&2, KTerm>
  for +name: String
  Bool

# Module: src/check/kernel.bend:646
law check_template_definition:
  for +book: List<&2, KDef>
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  String

# Module: src/check/kernel.bend:655
law check_template_binder:
  for +book: List<&2, KDef>
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  String

# Module: src/check/kernel.bend:664
law check_template_open:
  for +book: List<&2, KDef>
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  for +name: String
  String

# Module: src/check/specialize.bend:20
law specialized_book:
  for +r: KSpecialized
  List<&2, KDef>

# Module: src/check/specialize.bend:24
law specialized_error:
  for +r: KSpecialized
  String

# Module: src/check/specialize.bend:28
law sp_book:
  for +st: KSpecState
  List<&2, KDef>

# Module: src/check/specialize.bend:32
law sp_memo:
  for +st: KSpecState
  List<&2, KSpecMemo>

# Module: src/check/specialize.bend:36
law sp_serial:
  for +st: KSpecState
  U32

# Module: src/check/specialize.bend:40
law sp_fresh:
  for +st: KSpecState
  U32

# Module: src/check/specialize.bend:44
law sp_error:
  for +st: KSpecState
  String

# Module: src/check/specialize.bend:48
law sp_state:
  for +r: KSpecTerm
  KSpecState

# Module: src/check/specialize.bend:52
law sp_value:
  for +r: KSpecTerm
  KTerm

# Module: src/check/specialize.bend:56
law sp_states:
  for +r: KSpecTerms
  KSpecState

# Module: src/check/specialize.bend:60
law sp_values:
  for +r: KSpecTerms
  List<&2, KTerm>

# Module: src/check/specialize.bend:64
law sp_mtemplate:
  for +m: KSpecMemo
  String

# Module: src/check/specialize.bend:68
law sp_mkey:
  for +m: KSpecMemo
  String

# Module: src/check/specialize.bend:72
law sp_mname:
  for +m: KSpecMemo
  String

# Module: src/check/specialize.bend:76
law sp_active:
  for +m: KSpecMemo
  Bool

# Module: src/check/specialize.bend:80
law sp_fail:
  for +st: KSpecState
  for +err: String
  KSpecState

# Module: src/check/specialize.bend:85
law sp_put:
  for +st: KSpecState
  for +d: KDef
  KSpecState

# Module: src/check/specialize.bend:90
law sp_canonical:
  for +book: List<&2, KDef>
  for +done: List<&2, KDef>
  List<&2, KDef>

# Module: src/check/specialize.bend:95
law specialize_book:
  for +book: List<&2, KDef>
  KSpecialized

# Module: src/check/specialize.bend:99
law sp_finish:
  for +st: KSpecState
  KSpecialized

# Module: src/check/specialize.bend:103
law sp_definitions:
  for +todo: List<&2, KDef>
  for +st: KSpecState
  KSpecState

# Module: src/check/specialize.bend:108
law sp_definition_next:
  for +rest: List<&2, KDef>
  for +st: KSpecState
  for +d: KDef
  KSpecState

# Module: src/check/specialize.bend:114
law sp_definition_done:
  for +rest: List<&2, KDef>
  for +d: KDef
  for +r: KSpecTerm
  KSpecState

# Module: src/check/specialize.bend:120
law sp_len:
  for +s: String
  U32

# Module: src/check/specialize.bend:124
law sp_key_string:
  for +s: String
  String

# Module: src/check/specialize.bend:128
law term_key:
  for +t: KTerm
  String

# Module: src/check/specialize.bend:132
law sp_keys:
  for +ts: List<&2, KTerm>
  String

# Module: src/check/specialize.bend:136
law sp_name_keys:
  for +ns: List<&2, String>
  String

# Module: src/check/specialize.bend:140
law sp_find:
  for +ms: List<&2, KSpecMemo>
  for +name: String
  for +key: String
  KSpecMemo

# Module: src/check/specialize.bend:146
law sp_done_memo:
  for +ms: List<&2, KSpecMemo>
  for +name: String
  List<&2, KSpecMemo>

# Module: src/check/specialize.bend:151
law sp_take:
  for +ts: List<&2, KTerm>
  for +n: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:156
law sp_take_next:
  for +ts: List<&2, KTerm>
  for +n: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:161
law sp_drop:
  for +ts: List<&2, KTerm>
  for +n: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:166
law sp_drop_next:
  for +ts: List<&2, KTerm>
  for +n: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:171
law sp_shift:
  for +t: KTerm
  for +offset: U32
  KTerm

# Module: src/check/specialize.bend:176
law sp_shifts:
  for +ts: List<&2, KTerm>
  for +offset: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:181
law sp_type:
  for +st: KSpecState
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +owner: String
  KTerm

# Module: src/check/specialize.bend:188
law sp_term:
  for +st: KSpecState
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  KSpecTerm

# Module: src/check/specialize.bend:197
law sp_annotation:
  for +t: KTerm
  for +r: KSpecTerm
  KSpecTerm

# Module: src/check/specialize.bend:202
law sp_lambda:
  for +st: KSpecState
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  KSpecTerm

# Module: src/check/specialize.bend:211
law sp_single:
  for +t: KTerm
  for +r: KSpecTerm
  KSpecTerm

# Module: src/check/specialize.bend:216
law sp_constructor:
  for +st: KSpecState
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  KSpecTerm

# Module: src/check/specialize.bend:225
law sp_ctor_done:
  for +t: KTerm
  for +r: KSpecTerms
  KSpecTerm

# Module: src/check/specialize.bend:230
law sp_args:
  for +st: KSpecState
  for +xs: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +ty: KTerm
  for +owner: String
  for +depth: U32
  KSpecTerms

# Module: src/check/specialize.bend:239
law sp_arg_head:
  for +st: KSpecState
  for +x: KTerm
  for +rest: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +ty: KTerm
  for +owner: String
  for +depth: U32
  KSpecTerms

# Module: src/check/specialize.bend:249
law sp_arg_done:
  for +raw: KTerm
  for +rest: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +ty: KTerm
  for +owner: String
  for +depth: U32
  for +r: KSpecTerm
  KSpecTerms

# Module: src/check/specialize.bend:259
law sp_cons:
  for +h: KTerm
  for +r: KSpecTerms
  KSpecTerms

# Module: src/check/specialize.bend:264
law sp_spine:
  for +st: KSpecState
  for +t: KTerm
  for +xs: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  KSpecTerm

# Module: src/check/specialize.bend:273
law sp_head:
  for +st: KSpecState
  for +head: KTerm
  for +xs: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  for +d: KDef
  KSpecTerm

# Module: src/check/specialize.bend:283
law sp_regular_head:
  for +st: KSpecState
  for +head: KTerm
  for +xs: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  KSpecTerm

# Module: src/check/specialize.bend:292
law sp_regular_done:
  for +xs: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  for +ty: KTerm
  for +r: KSpecTerm
  KSpecTerm

# Module: src/check/specialize.bend:301
law sp_apply_result:
  for +head: KTerm
  for +r: KSpecTerms
  KSpecTerm

# Module: src/check/specialize.bend:306
law sp_template:
  for +st: KSpecState
  for +d: KDef
  for +xs: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  KSpecTerm

# Module: src/check/specialize.bend:315
law sp_template_args:
  for +st: KSpecState
  for +d: KDef
  for +closed: List<&2, KTerm>
  for +rest: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  KSpecTerm

# Module: src/check/specialize.bend:325
law sp_template_checked:
  for +st: KSpecState
  for +d: KDef
  for +closed: List<&2, KTerm>
  for +rest: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  for +checked: KChecked
  KSpecTerm

# Module: src/check/specialize.bend:336
law sp_template_key:
  for +st: KSpecState
  for +d: KDef
  for +closed: List<&2, KTerm>
  for +rest: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  for +key: String
  KSpecTerm

# Module: src/check/specialize.bend:347
law sp_template_inst:
  for +rest: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  for +r: KSpecTerm
  KSpecTerm

# Module: src/check/specialize.bend:355
law sp_instance:
  for +st: KSpecState
  for +d: KDef
  for +xs: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  for +key: String
  for +memo: KSpecMemo
  KSpecTerm

# Module: src/check/specialize.bend:365
law sp_mint:
  for +st: KSpecState
  for +d: KDef
  for +xs: List<&2, KTerm>
  for +depth: U32
  for +key: String
  for +name: String
  KSpecTerm

# Module: src/check/specialize.bend:374
law sp_apply_template:
  for +body: KTerm
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/specialize.bend:379
law sp_mint_type:
  for +st: KSpecState
  for +d: KDef
  for +xs: List<&2, KTerm>
  for +depth: U32
  for +key: String
  for +name: String
  for +ty: KTerm
  for +body: KTerm
  KSpecTerm

# Module: src/check/specialize.bend:390
law sp_mint_body:
  for +d: KDef
  for +name: String
  for +ty: KTerm
  for +r: KSpecTerm
  KSpecTerm

# Module: src/check/specialize.bend:397
law sp_validate:
  for +st: KSpecState
  for +d: KDef
  KSpecTerm

# Module: src/check/specialize.bend:402
law sp_validate_done:
  for +st: KSpecState
  for +d: KDef
  for +error: String
  KSpecTerm

# Module: src/check/specialize.bend:408
law sp_match:
  for +st: KSpecState
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  KSpecTerm

# Module: src/check/specialize.bend:417
law sp_match_type:
  for +st: KSpecState
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  for +a: KTerm
  KSpecTerm

# Module: src/check/specialize.bend:427
law sp_match_ctor:
  for +st: KSpecState
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  for +a: KTerm
  for +ctr: KDef
  KSpecTerm

# Module: src/check/specialize.bend:438
law sp_match_hit:
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  for +a: KTerm
  for +r: KSpecTerm
  KSpecTerm

# Module: src/check/specialize.bend:448
law sp_pair:
  for +t: KTerm
  for +h: KTerm
  for +r: KSpecTerm
  KSpecTerm

# Module: src/check/specialize.bend:454
law sp_let:
  for +st: KSpecState
  for +xs: List<&2, KTerm>
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  KSpecTerms

# Module: src/check/specialize.bend:464
law sp_let_binding:
  for +st: KSpecState
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  for +ty: KTerm
  KSpecTerms

# Module: src/check/specialize.bend:476
law sp_let_bound:
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +goal: KTerm
  for +owner: String
  for +depth: U32
  for +ty: KTerm
  for +r: KSpecTerm
  KSpecTerms

# Module: src/check/specialize.bend:488
law sp_let_body:
  for +r: KSpecTerm
  KSpecTerms

# Module: src/check/specialize.bend:492
law sp_let_result:
  for +t: KTerm
  for +r: KSpecTerms
  KSpecTerm

# Module: src/check/specialize.bend:497
law sp_rewrite:
  for +st: KSpecState
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  KSpecTerm

# Module: src/check/specialize.bend:505
law sp_rewrite_type:
  for +st: KSpecState
  for +t: KTerm
  for +ctx: List<&2, KTerm>
  for +owner: String
  for +depth: U32
  for +eq: KTerm
  KSpecTerm

# Module: src/check/specialize.bend:514
law sp_rewrite_done:
  for +t: KTerm
  for +r: KSpecTerm
  KSpecTerm

# Module: src/check/specialize.bend:916
law sp_initial:
  for +book: List<&2, KDef>
  for +bound: U32
  KSpecState

# Module: src/check/specialize.bend:921
law sp_stamp:
  for +book: List<&2, KDef>
  for +bound: U32
  List<&2, KDef>

# Module: src/check/specialize.bend:926
law sp_needed:
  for +book: List<&2, KDef>
  for +t: KTerm
  Bool

# Module: src/check/specialize.bend:931
law sp_neededs:
  for +book: List<&2, KDef>
  for +ts: List<&2, KTerm>
  Bool

# Module: src/check/specialize.bend:956
law sp_templates:
  for +st: KSpecState
  List<&2, KDef>

# Module: src/check/specialize.bend:960
law sp_template_book:
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/check/prefix.bend:4
law exact_names:
  for +a: List<&2, String>
  for +b: List<&2, String>
  Bool

# Module: src/check/prefix.bend:9
law exact_names_empty:
  for +b: List<&2, String>
  Bool

# Module: src/check/prefix.bend:13
law exact_names_head:
  for +h: String
  for +rest: List<&2, String>
  for +b: List<&2, String>
  Bool

# Module: src/check/prefix.bend:19
law exact_term:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/check/prefix.bend:24
law exact_terms:
  for +a: List<&2, KTerm>
  for +b: List<&2, KTerm>
  Bool

# Module: src/check/prefix.bend:29
law exact_terms_head:
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +b: List<&2, KTerm>
  Bool

# Module: src/check/prefix.bend:35
law exact_def:
  for +a: KDef
  for +b: KDef
  Bool

# Module: src/check/prefix.bend:40
law exact_defs:
  for +a: List<&2, KDef>
  for +b: List<&2, KDef>
  Bool

# Module: src/check/prefix.bend:45
law exact_defs_head:
  for +h: KDef
  for +rest: List<&2, KDef>
  for +b: List<&2, KDef>
  Bool

# Module: src/check/prefix.bend:51
law exact_prefix:
  for +book: List<&2, KDef>
  for +prefix: List<&2, KDef>
  Bool

# Module: src/check/prefix.bend:56
law exact_prefix_head:
  for +book: List<&2, KDef>
  for +h: KDef
  for +rest: List<&2, KDef>
  Bool

# Module: src/check/prefix.bend:62
law check_from_exact_prefix:
  for +book: List<&2, KDef>
  for +validated: List<&2, KDef>
  String

# Module: src/check/prefix.bend:67
law check_prefix_seed:
  for +book: List<&2, KDef>
  for +validated: List<&2, KDef>
  for +done: List<&2, KDef>
  String

# Module: src/check/prefix.bend:73
law check_prefix_step:
  for +book: List<&2, KDef>
  for +h: KDef
  for +rest: List<&2, KDef>
  for +done: List<&2, KDef>
  String

# Module: src/check/annotate.bend:5
law ka_wrap:
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:10
law annotate_book:
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/check/annotate.bend:14
law annotate_except:
  for +book: List<&2, KDef>
  for +stops: List<&2, String>
  List<&2, KDef>

# Module: src/check/annotate.bend:19
law annotate_selected:
  for +book: List<&2, KDef>
  for +selected: List<&2, KDef>
  for +stops: List<&2, String>
  List<&2, KDef>

# Module: src/check/annotate.bend:25
law ka_defs_except:
  for +book: List<&2, KDef>
  for +ds: List<&2, KDef>
  for +stops: List<&2, String>
  List<&2, KDef>

# Module: src/check/annotate.bend:31
law ka_defs:
  for +book: List<&2, KDef>
  for +ds: List<&2, KDef>
  List<&2, KDef>

# Module: src/check/annotate.bend:36
law ka_def:
  for +book: List<&2, KDef>
  for +d: KDef
  KDef

# Module: src/check/annotate.bend:41
law annotate:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:48
law ka_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:55
law ka_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:61
law ka_type_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:67
law ka_type_app:
  for +e: KEnv
  for +t: KTerm
  for +fty: KTerm
  KTerm

# Module: src/check/annotate.bend:73
law ka_lam:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:80
law ka_app:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +fty: KTerm
  KTerm

# Module: src/check/annotate.bend:87
law ka_args:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/annotate.bend:94
law ka_args_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/annotate.bend:102
law ka_mat:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +a: KTerm
  KTerm

# Module: src/check/annotate.bend:110
law ka_mat_ctr:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +a: KTerm
  for +c: KDef
  KTerm

# Module: src/check/annotate.bend:119
law ka_let:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +ty: KTerm
  List<&2, KTerm>

# Module: src/check/annotate.bend:127
law ka_let_head:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +ty: KTerm
  for +vty: KTerm
  List<&2, KTerm>

# Module: src/check/annotate.bend:137
law ka_rwt:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +eq: KTerm
  KTerm

# Module: src/front/lexer.bend:8
law f_choose:
  for -A: Type
  for +b: Bool
  for yes: Unit -> A
  for no: Unit -> A
  A

# Module: src/front/lexer.bend:15
law f_eq:
  for +a: String
  for +b: String
  Bool

# Module: src/front/lexer.bend:20
law f_tx:
  for +ts: List<&2, FToken>
  String

# Module: src/front/lexer.bend:24
law f_tl:
  for +ts: List<&2, FToken>
  List<&2, FToken>

# Module: src/front/lexer.bend:28
law f_line:
  for +ts: List<&2, FToken>
  U32

# Module: src/front/lexer.bend:32
law f_col:
  for +ts: List<&2, FToken>
  U32

# Module: src/front/lexer.bend:36
law f_kind:
  for +ts: List<&2, FToken>
  U32

# Module: src/front/lexer.bend:40
law f_skip:
  for +ts: List<&2, FToken>
  List<&2, FToken>

# Module: src/front/lexer.bend:44
law f_head:
  for +s: String
  Char

# Module: src/front/lexer.bend:48
law f_tail:
  for +s: String
  String

# Module: src/front/lexer.bend:52
law f_ident:
  for +c: Char
  Bool

# Module: src/front/lexer.bend:56
law f_scan_word:
  for +s: String
  for +acc: String
  for +n: U32
  FScanned

# Module: src/front/lexer.bend:62
law f_scan_comment:
  for +s: String
  String

# Module: src/front/lexer.bend:66
law f_scan_quote:
  for +s: String
  for +quote: Char
  for +acc: String
  for +n: U32
  FScanned

# Module: src/front/lexer.bend:73
law f_two:
  for +s: String
  String

# Module: src/front/lexer.bend:77
law f_pair_op:
  for +s: String
  Bool

# Module: src/front/lexer.bend:81
law f_lex_scanned:
  for +sc: FScanned
  for +l: U32
  for +c: U32
  for +d: U32
  for +k: U32
  for +acc: List<&2, FToken>
  List<&2, FToken>

# Module: src/front/lexer.bend:90
law f_lex_symbol:
  for +s: String
  for +l: U32
  for +c: U32
  for +d: U32
  for +acc: List<&2, FToken>
  List<&2, FToken>

# Module: src/front/lexer.bend:98
law f_lex:
  for +s: String
  for +l: U32
  for +c: U32
  for +d: U32
  for +acc: List<&2, FToken>
  List<&2, FToken>

# Module: src/front/lexer.bend:106
law f_three:
  for +s: String
  String

# Module: src/front/lexer.bend:110
law f_triple_op:
  for +s: String
  Bool

# Module: src/front/lexer.bend:114
law f_symbol_text:
  for +s: String
  for +c: U32
  for +acc: List<&2, FToken>
  String

# Module: src/front/parser.bend:6
law f_pn:
  for +p: FParsed
  KTerm

# Module: src/front/parser.bend:10
law f_pr:
  for +p: FParsed
  List<&2, FToken>

# Module: src/front/parser.bend:14
law f_atid:
  for +ts: List<&2, FToken>
  U32

# Module: src/front/parser.bend:18
law f_err:
  for +ts: List<&2, FToken>
  for +msg: String
  FParsed

# Module: src/front/parser.bend:23
law f_expect:
  for +p: FParsed
  for +s: String
  FParsed

# Module: src/front/parser.bend:28
law f_app:
  for +f: KTerm
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/front/parser.bend:33
law f_args:
  for +ts: List<&2, FToken>
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/parser.bend:39
law f_arg_next:
  for +p: FParsed
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/parser.bend:45
law f_expr:
  for +ts: List<&2, FToken>
  for +min: U32
  FParsed

# Module: src/front/parser.bend:50
law f_atom:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/parser.bend:54
law f_kind_token:
  for +ts: List<&2, FToken>
  U32

# Module: src/front/parser.bend:58
law f_kind_wrap:
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:62
law f_mark:
  for +p: FParsed
  for +q: U32
  FParsed

# Module: src/front/parser.bend:67
law f_grade:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/parser.bend:71
law f_quant:
  for +ts: List<&2, FToken>
  U32

# Module: src/front/parser.bend:75
law f_unmark:
  for +ts: List<&2, FToken>
  List<&2, FToken>

# Module: src/front/parser.bend:79
law f_all:
  for +ts: List<&2, FToken>
  for +exi: Bool
  FParsed

# Module: src/front/parser.bend:84
law f_all_domain:
  for +name: String
  for +id: U32
  for +q: U32
  for +exi: Bool
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:92
law f_all_body:
  for +name: String
  for +id: U32
  for +q: U32
  for +exi: Bool
  for +a: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:101
law f_group:
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:105
law f_group_ann:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:110
law f_tuple:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:115
law f_list:
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:119
law f_list_nodes:
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/front/parser.bend:123
law f_brace:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/parser.bend:127
law f_brace_left:
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:131
law f_equation:
  for +a: KTerm
  for +neg: Bool
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:137
law f_equation_type:
  for +a: KTerm
  for +b: KTerm
  for +neg: Bool
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:144
law f_prec:
  for +s: String
  U32

# Module: src/front/parser.bend:148
law f_grow:
  for +p: FParsed
  for +min: U32
  FParsed

# Module: src/front/parser.bend:153
law f_grow_args:
  for +n: KTerm
  for +op: String
  for +min: U32
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:160
law f_binary:
  for +a: KTerm
  for +op: String
  for +min: U32
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:167
law f_binary_node:
  for +a: KTerm
  for +op: String
  for +b: KTerm
  KTerm

# Module: src/front/parser.bend:173
law f_operator:
  for +s: String
  String

# Module: src/front/parser.bend:177
law f_matcher:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/parser.bend:181
law f_matcher_head:
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:185
law f_matcher_arm:
  for +name: String
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:190
law f_matcher_tail:
  for +name: String
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:432
law f_atom_base:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/parser.bend:440
law f_args_base:
  for +ts: List<&2, FToken>
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/parser.bend:450
law f_grow_base:
  for +p: FParsed
  for +min: U32
  FParsed

# Module: src/front/parser.bend:461
law f_binary_plain:
  for +a: KTerm
  for +op: String
  for +b: KTerm
  KTerm

# Module: src/front/parser.bend:471
law f_rhs:
  for +ts: List<&2, FToken>
  for +op: String
  for +min: U32
  FParsed

# Module: src/front/parser.bend:481
law f_rhs_for:
  for +left: KTerm
  for +ts: List<&2, FToken>
  for +op: String
  for +min: U32
  FParsed

# Module: src/front/declarations.bend:5
law f_parse:
  for +source: String
  FResult

# Module: src/front/declarations.bend:9
law f_result:
  for +book: List<&2, KDef>
  for +err: String
  for +imports: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:15
law f_len:
  for +xs: List<&2, KTerm>
  U32

# Module: src/front/declarations.bend:19
law f_find:
  for +name: String
  for +book: List<&2, KDef>
  KDef

# Module: src/front/declarations.bend:24
law f_dn:
  for +d: KDef
  String

# Module: src/front/declarations.bend:28
law f_dt:
  for +d: KDef
  KTerm

# Module: src/front/declarations.bend:32
law f_dv:
  for +d: KDef
  KTerm

# Module: src/front/declarations.bend:36
law f_dk:
  for +d: KDef
  String

# Module: src/front/declarations.bend:40
law f_dx:
  for +d: KDef
  U32

# Module: src/front/declarations.bend:44
law f_put:
  for +d: KDef
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/front/declarations.bend:49
law f_tops:
  for +ts0: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  FResult

# Module: src/front/declarations.bend:56
law f_top:
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  FResult

# Module: src/front/declarations.bend:63
law f_import:
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:69
law f_tele:
  for +ts0: List<&2, FToken>
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:75
law f_tele_at:
  for +ts: List<&2, FToken>
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:81
law f_tele_binder:
  for +name: String
  for +id: U32
  for +q: U32
  for +temp: Bool
  for +ts: List<&2, FToken>
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:91
law f_tele_type:
  for +name: String
  for +id: U32
  for +q: U32
  for +temp: Bool
  for +p: FParsed
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:101
law f_tbind:
  for +pars: List<&2, KTerm>
  for +result: KTerm
  KTerm

# Module: src/front/declarations.bend:106
law f_lbind:
  for +pars: List<&2, KTerm>
  for +body: KTerm
  KTerm

# Module: src/front/declarations.bend:111
law f_templates:
  for +pars: List<&2, KTerm>
  U32

# Module: src/front/declarations.bend:115
law f_def:
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  FResult

# Module: src/front/declarations.bend:123
law f_def_type:
  for +name: String
  for +pars: List<&2, KTerm>
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  FResult

# Module: src/front/declarations.bend:132
law f_def_signature:
  for +name: String
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/declarations.bend:139
law f_def_body:
  for +name: String
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  FResult

# Module: src/front/declarations.bend:149
law f_foreign:
  for +name: String
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +paths: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:160
law f_law:
  for +name: String
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:168
law f_law_clause:
  for +name: String
  for +exi: Bool
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:177
law f_law_type:
  for +name: String
  for +binder: KTerm
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:186
law f_law_bind:
  for +clauses: List<&2, KTerm>
  for +ty: KTerm
  KTerm

# Module: src/front/declarations.bend:191
law f_law_end:
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:199
law f_type:
  for +name: String
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:206
law f_type_params:
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:213
law f_type_kind:
  for +name: String
  for +pars: List<&2, KTerm>
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:221
law f_type_ctors:
  for +name: String
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +ctors: List<&2, KDef>
  FResult

# Module: src/front/declarations.bend:231
law f_type_ctor:
  for +name: String
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +ctor: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +ctors: List<&2, KDef>
  FResult

# Module: src/front/declarations.bend:242
law f_param_refs:
  for +pars: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/declarations.bend:246
law f_body:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/declarations.bend:250
law f_body_at:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/declarations.bend:254
law f_statement:
  for +p: FParsed
  FParsed

# Module: src/front/declarations.bend:258
law f_typed_let:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/declarations.bend:263
law f_let_ann:
  for +ty: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/declarations.bend:268
law f_let_value:
  for +pat: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/declarations.bend:273
law f_let_body:
  for +pat: KTerm
  for +v: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/declarations.bend:279
law f_match_heads:
  for +ts: List<&2, FToken>
  for +indent: U32
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:285
law f_match_head:
  for +p: FParsed
  for +indent: U32
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:291
law f_match_cases:
  for +ts: List<&2, FToken>
  for +indent: U32
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:298
law f_case_pats:
  for +ts: List<&2, FToken>
  for +indent: U32
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +pats: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:306
law f_case_pat:
  for +p: FParsed
  for +indent: U32
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +pats: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:314
law f_case_body:
  for +p: FParsed
  for +indent: U32
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +pats: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:599
law f_replace:
  for +d: KDef
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/front/declarations.bend:608
law f_type_base:
  for +name: String
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:619
law f_def_base:
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  FResult

# Module: src/front/declarations.bend:631
law f_body_context:
  for +ts: List<&2, FToken>
  for +outer: U32
  FParsed

# Module: src/front/declarations.bend:636
law f_body_context_at:
  for +ts: List<&2, FToken>
  for +outer: U32
  FParsed

# Module: src/front/declarations.bend:641
law f_match_begin:
  for +ts: List<&2, FToken>
  for +outer: U32
  for +heads: List<&2, KTerm>
  FParsed

# Module: src/front/declarations.bend:659
law f_law_arity:
  for +clauses: List<&2, KTerm>
  U32

# Module: src/front/declarations.bend:671
law f_law_base:
  for +name: String
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  FResult

# Module: src/front/declarations.bend:679
law f_type_named:
  for +name: String
  for +ts: List<&2, FToken>
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  FResult

# Module: src/front/flatten.bend:10
law ff_term:
  for +r: FFlatten
  KTerm

# Module: src/front/flatten.bend:14
law ff_next:
  for +r: FFlatten
  U32

# Module: src/front/flatten.bend:18
law ff_flat:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  for +next: U32
  FFlatten

# Module: src/front/flatten.bend:24
law ff_local:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  for +next: U32
  FFlatten

# Module: src/front/flatten.bend:30
law ff_let:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  for +r: FFlatten
  FFlatten

# Module: src/front/flatten.bend:36
law ff_parallel:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  for +r: FFlatten
  FFlatten

# Module: src/front/flatten.bend:42
law ff_match:
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +vars: List<&2, KTerm>
  for +next: U32
  FFlatten

# Module: src/front/flatten.bend:49
law ff_column:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +vars: List<&2, KTerm>
  for +next: U32
  FFlatten

# Module: src/front/flatten.bend:57
law ff_lam:
  for +v: KTerm
  for +r: FFlatten
  FFlatten

# Module: src/front/flatten.bend:62
law ff_split:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +v: KTerm
  for +vs: List<&2, KTerm>
  for +c: KTerm
  for +next: U32
  FFlatten

# Module: src/front/flatten.bend:72
law ff_fields:
  for +ps: List<&2, KTerm>
  for +q: U32
  for +next: U32
  FFields

# Module: src/front/flatten.bend:78
law ff_field_cons:
  for +p: KTerm
  for +r: FFields
  FFields

# Module: src/front/flatten.bend:83
law ff_fields_done:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +v: KTerm
  for +vs: List<&2, KTerm>
  for +c: KTerm
  for +r: FFields
  FFlatten

# Module: src/front/flatten.bend:93
law ff_hit_done:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +v: KTerm
  for +vs: List<&2, KTerm>
  for +c: KTerm
  for +r: FFlatten
  FFlatten

# Module: src/front/flatten.bend:103
law ff_miss_done:
  for +c: KTerm
  for +hit: KTerm
  for +r: FFlatten
  FFlatten

# Module: src/front/flatten.bend:109
law fc_ref:
  for +name: String
  for +env: List<&2, KTerm>
  U32

# Module: src/front/flatten.bend:114
law fc_bind:
  for +v: KTerm
  for +env: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/flatten.bend:119
law fc_binders:
  for +ps: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/flatten.bend:123
law fc_bind_count:
  for +ps: List<&2, KTerm>
  U32

# Module: src/front/flatten.bend:127
law fc_terms:
  for +ts: List<&2, KTerm>
  for +env: List<&2, KTerm>
  U32

# Module: src/front/flatten.bend:132
law fc_term:
  for +t: KTerm
  for +env: List<&2, KTerm>
  U32

# Module: src/front/flatten.bend:137
law fc_rows:
  for +rs: List<&2, KTerm>
  for +env: List<&2, KTerm>
  U32

# Module: src/front/flatten.bend:142
law fc_start:
  for +pars: List<&2, KTerm>
  for +ty: KTerm
  for +body: KTerm
  for +filled: Bool
  U32

# Module: src/front/elaborate.bend:3
law f_elaborate:
  for +r: FResult
  FResult

# Module: src/front/elaborate.bend:7
law f_elab_defs:
  for +ds: List<&2, KDef>
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/front/elaborate.bend:12
law f_elab_def:
  for +d: KDef
  for +book: List<&2, KDef>
  KDef

# Module: src/front/elaborate.bend:17
law f_env:
  for +name: String
  for +env: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:22
law f_tail_terms:
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/elaborate.bend:26
law f_concat:
  for +xs: List<&2, KTerm>
  for +ys: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/elaborate.bend:31
law f_vars:
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/elaborate.bend:35
law f_scope:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/elaborate.bend:41
law f_scope_ref:
  for +t: KTerm
  for +bound: KTerm
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/elaborate.bend:47
law f_scope_terms:
  for +xs: List<&2, KTerm>
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  List<&2, KTerm>

# Module: src/front/elaborate.bend:53
law f_patterns:
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/elaborate.bend:57
law f_penv:
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/elaborate.bend:61
law f_scope_body:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/elaborate.bend:67
law f_scope_local:
  for +t: KTerm
  for +pats: List<&2, KTerm>
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/elaborate.bend:74
law f_scope_rows:
  for +rows: List<&2, KTerm>
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  List<&2, KTerm>

# Module: src/front/elaborate.bend:80
law f_scope_row:
  for +r: KTerm
  for +pats: List<&2, KTerm>
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/elaborate.bend:87
law f_sub:
  for +t: KTerm
  for +id: U32
  for +v: KTerm
  KTerm

# Module: src/front/elaborate.bend:93
law f_subs:
  for +ts: List<&2, KTerm>
  for +id: U32
  for +v: KTerm
  List<&2, KTerm>

# Module: src/front/elaborate.bend:99
law f_flat:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:104
law f_flat_local:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:109
law f_flat_let:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  for +body: KTerm
  KTerm

# Module: src/front/elaborate.bend:115
law f_rowpat:
  for +r: KTerm
  KTerm

# Module: src/front/elaborate.bend:119
law f_first_ctor:
  for +rows: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:123
law f_has_id:
  for +vars: List<&2, KTerm>
  for +id: U32
  Bool

# Module: src/front/elaborate.bend:128
law f_flat_match:
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +vars: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:134
law f_var_rows:
  for +rows: List<&2, KTerm>
  for +v: KTerm
  List<&2, KTerm>

# Module: src/front/elaborate.bend:139
law f_flat_column:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +vars: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:146
law f_flat_split:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +v: KTerm
  for +vs: List<&2, KTerm>
  for +c: KTerm
  KTerm

# Module: src/front/elaborate.bend:155
law f_fresh_fields:
  for +ps: List<&2, KTerm>
  for +id: U32
  List<&2, KTerm>

# Module: src/front/elaborate.bend:160
law f_flat_fields:
  for +h: KTerm
  for +hs: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +v: KTerm
  for +vs: List<&2, KTerm>
  for +c: KTerm
  for +fields: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:170
law f_hit_rows:
  for +rows: List<&2, KTerm>
  for +c: KTerm
  for +fields: List<&2, KTerm>
  for +v: KTerm
  List<&2, KTerm>

# Module: src/front/elaborate.bend:177
law f_hit_row:
  for +r: KTerm
  for +c: KTerm
  for +fields: List<&2, KTerm>
  for +v: KTerm
  KTerm

# Module: src/front/elaborate.bend:184
law f_miss_rows:
  for +rows: List<&2, KTerm>
  for +name: String
  List<&2, KTerm>

# Module: src/front/elaborate.bend:189
law f_word:
  for +n: U32
  for +bits: U32
  KTerm

# Module: src/front/elaborate.bend:194
law f_u32:
  for +n: U32
  KTerm

# Module: src/front/elaborate.bend:198
law f_nat:
  for +n: U32
  KTerm

# Module: src/front/elaborate.bend:202
law f_number:
  for +s: String
  for +acc: U32
  KTerm

# Module: src/front/elaborate.bend:207
law f_literal:
  for +s: String
  KTerm

# Module: src/front/elaborate.bend:211
law f_string:
  for +s: String
  KTerm

# Module: src/front/elaborate.bend:215
law f_string_escape:
  for +s: String
  KTerm

# Module: src/front/elaborate.bend:219
law f_escape_code:
  for +c: Char
  U32

# Module: src/front/elaborate.bend:470
law f_scope_body_base:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/elaborate.bend:476
law f_flat_base:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:489
law f_scope_base:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/elaborate.bend:499
law f_family_book:
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/front/elaborate.bend:511
law f_scope_lower:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/sugar.bend:3
law f_last:
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/front/sugar.bend:7
law f_init:
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/sugar.bend:11
law f_do_start:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/sugar.bend:15
law f_do_types:
  for +monad: String
  for +p: FParsed
  FParsed

# Module: src/front/sugar.bend:20
law f_do:
  for +monad: String
  for +types: List<&2, KTerm>
  for +ts: List<&2, FToken>
  for +indent: U32
  FParsed

# Module: src/front/sugar.bend:27
law f_do_return:
  for +monad: String
  for +types: List<&2, KTerm>
  for +p: FParsed
  FParsed

# Module: src/front/sugar.bend:33
law f_do_statement:
  for +monad: String
  for +types: List<&2, KTerm>
  for +p: FParsed
  for +indent: U32
  FParsed

# Module: src/front/sugar.bend:40
law f_do_annotated:
  for +monad: String
  for +types: List<&2, KTerm>
  for +binder: KTerm
  for +p: FParsed
  for +indent: U32
  FParsed

# Module: src/front/sugar.bend:48
law f_do_value:
  for +monad: String
  for +types: List<&2, KTerm>
  for +binder: KTerm
  for +ty: KTerm
  for +pure: Bool
  for +p: FParsed
  for +indent: U32
  FParsed

# Module: src/front/sugar.bend:58
law f_do_tail:
  for +monad: String
  for +types: List<&2, KTerm>
  for +binder: KTerm
  for +ty: KTerm
  for +pure: Bool
  for +v: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/sugar.bend:68
law f_error_term:
  for +t: KTerm
  String

# Module: src/front/sugar.bend:72
law f_error_terms:
  for +ts: List<&2, KTerm>
  String

# Module: src/front/sugar.bend:76
law f_error_more:
  for +err: String
  for +rest: List<&2, KTerm>
  String

# Module: src/front/sugar.bend:81
law f_error_defs:
  for +ds: List<&2,KDef>
  String

# Module: src/front/sugar.bend:85
law f_error_def_next:
  for +err: String
  for +ctors: List<&2,KDef>
  for +rest: List<&2,KDef>
  String

# Module: src/front/sugar.bend:91
law f_error_defs_more:
  for +err: String
  for +rest: List<&2,KDef>
  String

# Module: src/front/sugar.bend:96
law f_validate_result:
  for +r: FResult
  FResult

# Module: src/front/sugar.bend:100
law f_rewrite:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/sugar.bend:104
law f_rewrite_head:
  for +p: FParsed
  FParsed

# Module: src/front/sugar.bend:108
law f_rewrite_proof:
  for +name: String
  for +id: U32
  for +p: FParsed
  FParsed

# Module: src/front/sugar.bend:114
law f_rewrite_motive:
  for +name: String
  for +id: U32
  for +e: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/sugar.bend:121
law f_rewrite_body:
  for +e: KTerm
  for +motive: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/sugar.bend:256
law f_law_where:
  for +name: String
  for +binder: KTerm
  for +ty: KTerm
  for +p: FParsed
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  for +clauses: List<&2, KTerm>
  FResult

# Module: src/front/sugar.bend:266
law f_erased_local:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/sugar.bend:270
law f_write_statement:
  for +n: KTerm
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/sugar.bend:290
law f_group_namespace:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/sugar.bend:295
law f_template_expr:
  for +p: FParsed
  FParsed

# Module: src/front/unicode.bend:5
law f_decode_char:
  for +s: String
  FDecoded

# Module: src/front/unicode.bend:9
law f_decode_escape:
  for +s: String
  FDecoded

# Module: src/front/unicode.bend:13
law f_escape_valid:
  for +c: Char
  Bool

# Module: src/front/unicode.bend:17
law f_hex:
  for +c: Char
  U32

# Module: src/front/unicode.bend:21
law f_decode_unicode:
  for +s: String
  for +code: U32
  for +count: U32
  FDecoded

# Module: src/front/unicode.bend:27
law f_string_decoded:
  for +d: FDecoded
  KTerm

# Module: src/front/unicode.bend:31
law f_char_literal:
  for +s: String
  KTerm

# Module: src/front/unicode.bend:35
law f_char_decoded:
  for +d: FDecoded
  KTerm

# Module: src/front/unicode.bend:39
law f_float_bits:
  for +bits: U32
  KTerm

# Module: src/front/literals_arrays.bend:3
law f_contains:
  for +s: String
  for +c: Char
  Bool

# Module: src/front/literals_arrays.bend:8
law f_float:
  for +s: String
  KTerm

# Module: src/front/literals_arrays.bend:12
law f_float_read:
  for +m: Maybe<&2, F32>
  KTerm

# Module: src/front/literals_arrays.bend:16
law f_array:
  for +ts: List<&2, FToken>
  FParsed

# Module: src/front/literals_arrays.bend:20
law f_array_first:
  for +p: FParsed
  FParsed

# Module: src/front/literals_arrays.bend:24
law f_array_type:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/literals_arrays.bend:29
law f_array_size:
  for +n: KTerm
  for +ty: KTerm
  for +count: Bool
  for +p: FParsed
  FParsed

# Module: src/front/literals_arrays.bend:36
law f_array_depth:
  for +size: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:40
law f_power_depth:
  for +s: String
  for +n: U32
  KTerm

# Module: src/front/literals_arrays.bend:45
law f_power_bits:
  for +n: U32
  for +d: U32
  KTerm

# Module: src/front/literals_arrays.bend:50
law f_index:
  for +n: KTerm
  for +p: FParsed
  for +min: U32
  FParsed

# Module: src/front/literals_arrays.bend:56
law f_index_value:
  for +n: KTerm
  for +idx: KTerm
  for +p: FParsed
  for +min: U32
  FParsed

# Module: src/front/literals_arrays.bend:63
law f_ends_nat:
  for +s: String
  Bool

# Module: src/front/literals_arrays.bend:67
law f_nat_plus:
  for +lit: KTerm
  for +b: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:72
law f_nat_extend:
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:77
law f_namespace:
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:161
law f_pattern_literal:
  for +s: String
  KTerm

# Module: src/front/literals_arrays.bend:165
law f_pattern_number:
  for +s: String
  for +n: U32
  U32

# Module: src/front/literals_arrays.bend:170
law f_nat_pattern:
  for +n: U32
  KTerm

# Module: src/front/literals_arrays.bend:187
law f_namespace_head:
  for +t: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:191
law f_namespace_operator:
  for +head: KTerm
  Bool

# Module: src/front/literals_arrays.bend:195
law f_namespace_terms:
  for +terms: List<&2, KTerm>
  for +ty: KTerm
  List<&2, KTerm>

# Module: src/front/parallel.bend:3
law f_parallel:
  for +ts: List<&2, FToken>
  for +pats: List<&2, KTerm>
  FParsed

# Module: src/front/parallel.bend:8
law f_parallel_pat:
  for +p: FParsed
  for +pats: List<&2, KTerm>
  FParsed

# Module: src/front/parallel.bend:13
law f_parallel_values:
  for +ts: List<&2, FToken>
  for +pats: List<&2, KTerm>
  for +left: U32
  for +vals: List<&2, KTerm>
  FParsed

# Module: src/front/parallel.bend:20
law f_parallel_value:
  for +p: FParsed
  for +pats: List<&2, KTerm>
  for +left: U32
  for +vals: List<&2, KTerm>
  FParsed

# Module: src/front/parallel.bend:27
law f_parallel_body:
  for +pats: List<&2, KTerm>
  for +vals: List<&2, KTerm>
  for +p: FParsed
  FParsed

# Module: src/front/parallel.bend:33
law f_scope_parallel:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2,KDef>
  KTerm

# Module: src/front/parallel.bend:39
law f_scope_parallel_pats:
  for +t: KTerm
  for +pats: List<&2, KTerm>
  for +env: List<&2, KTerm>
  for +book: List<&2,KDef>
  KTerm

# Module: src/front/parallel.bend:46
law f_parallel_binds:
  for +pats: List<&2, KTerm>
  for +vals: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/parallel.bend:51
law f_unlamb:
  for +body: KTerm
  for +n: U32
  KTerm

# Module: src/front/parallel.bend:56
law f_flat_parallel:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  KTerm

# Module: src/front/parallel.bend:61
law f_statement_more:
  for +p: FParsed
  FParsed

# Module: src/front/parallel.bend:65
law f_typed_let_try:
  for +n: KTerm
  for +old: List<&2, FToken>
  for +p: FParsed
  FParsed

# Module: src/front/fresh_work.bend:11
law f_fresh_stack:
  for +term: KTerm
  for +env: List<&2,KTerm>
  for +next: U32
  FFresh

# Module: src/front/fresh_work.bend:16
law ffw_walk:
  for +term: KTerm
  for +env: List<&2,KTerm>
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:22
law ffw_done:
  for +term: KTerm
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:27
law ffw_frame:
  for +frame: FFFrame
  for +value: KTerm
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:33
law ffw_kids:
  for +term: KTerm
  for +env: List<&2,KTerm>
  for +pending: List<&2,KTerm>
  for +built: List<&2,KTerm>
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:41
law ffw_let:
  for +env: List<&2,KTerm>
  for +bodyenv: List<&2,KTerm>
  for +items: List<&2,KTerm>
  for +built: List<&2,KTerm>
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:49
law ffw_let_tail:
  for +env: List<&2,KTerm>
  for +bodyenv: List<&2,KTerm>
  for +term: KTerm
  for +tail: List<&2,KTerm>
  for +built: List<&2,KTerm>
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:113
law ffw_reverse_onto:
  for +items: List<&2,KTerm>
  for +onto: List<&2,KTerm>
  List<&2,KTerm>

# Module: src/front/fresh_work.bend:134
law f_fresh_book_stack:
  for +book: List<&2,KDef>
  for +next: U32
  FFreshDefs

# Module: src/front/fresh_work.bend:138
law ffd_walk:
  for +book: List<&2,KDef>
  for +next: U32
  for +built: List<&2,KDef>
  for +stack: List<&2,FFDefFrame>
  FFreshDefs

# Module: src/front/fresh_work.bend:144
law ffd_type:
  for +definition: KDef
  for +pending: List<&2,KDef>
  for +built: List<&2,KDef>
  for +stack: List<&2,FFDefFrame>
  for +result: FFresh
  FFreshDefs

# Module: src/front/fresh_work.bend:151
law ffd_value:
  for +definition: KDef
  for +pending: List<&2,KDef>
  for +built: List<&2,KDef>
  for +stack: List<&2,FFDefFrame>
  for +typ: KTerm
  for +result: FFresh
  FFreshDefs

# Module: src/front/fresh_work.bend:159
law ffd_done:
  for +book: List<&2,KDef>
  for +next: U32
  for +stack: List<&2,FFDefFrame>
  FFreshDefs

# Module: src/front/fresh_work.bend:164
law ffd_frame:
  for +frame: FFDefFrame
  for +ctors: List<&2,KDef>
  for +next: U32
  for +stack: List<&2,FFDefFrame>
  FFreshDefs

# Module: src/front/freshen.bend:11
law f_fresh_term:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +next: U32
  FFresh

# Module: src/front/freshen.bend:17
law f_rename_var:
  for +t: KTerm
  for +env: List<&2, KTerm>
  KTerm

# Module: src/front/freshen.bend:22
law f_fresh_terms:
  for +ts: List<&2, KTerm>
  for +env: List<&2, KTerm>
  for +next: U32
  FFreshTerms

# Module: src/front/freshen.bend:28
law f_fresh_cons:
  for +r: FFresh
  for +rest: List<&2, KTerm>
  for +env: List<&2, KTerm>
  FFreshTerms

# Module: src/front/freshen.bend:34
law f_fresh_prepend:
  for +t: KTerm
  for +r: FFreshTerms
  FFreshTerms

# Module: src/front/freshen.bend:39
law f_fresh_generic:
  for +t: KTerm
  for +r: FFreshTerms
  FFresh

# Module: src/front/freshen.bend:44
law f_fresh_all:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +id: U32
  for +r: FFresh
  FFresh

# Module: src/front/freshen.bend:51
law f_fresh_all_body:
  for +t: KTerm
  for +id: U32
  for +a: KTerm
  for +r: FFresh
  FFresh

# Module: src/front/freshen.bend:58
law f_fresh_lam:
  for +t: KTerm
  for +id: U32
  for +r: FFresh
  FFresh

# Module: src/front/freshen.bend:64
law f_fresh_let:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +bodyenv: List<&2, KTerm>
  for +next: U32
  for +items: List<&2, KTerm>
  for +acc: List<&2, KTerm>
  FFresh

# Module: src/front/freshen.bend:73
law f_fresh_let_body:
  for +acc: List<&2, KTerm>
  for +r: FFresh
  FFresh

# Module: src/front/freshen.bend:78
law f_fresh_let_value:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +bodyenv: List<&2, KTerm>
  for +id: U32
  for +binding: KTerm
  for +rest: List<&2, KTerm>
  for +acc: List<&2, KTerm>
  for +r: FFresh
  FFresh

# Module: src/front/freshen.bend:89
law f_fresh_defs:
  for +ds: List<&2,KDef>
  for +next: U32
  FFreshDefs

# Module: src/front/freshen.bend:94
law f_fresh_def_type:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +r: FFresh
  FFreshDefs

# Module: src/front/freshen.bend:100
law f_fresh_def_value:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +ty: KTerm
  for +r: FFresh
  FFreshDefs

# Module: src/front/freshen.bend:107
law f_fresh_def_ctors:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +ty: KTerm
  for +value: KTerm
  for +r: FFreshDefs
  FFreshDefs

# Module: src/front/freshen.bend:115
law f_fresh_defs_prepend:
  for +d: KDef
  for +r: FFreshDefs
  FFreshDefs

# Module: src/front/freshen.bend:120
law f_fresh_result:
  for +r: FResult
  FResult

# Module: src/front/freshen.bend:124
law f_fresh_result_end:
  for +r: FFreshDefs
  for +err: String
  for +imports: List<&2, KTerm>
  FResult

# Module: src/load/paths.bend:3
law f_unquote:
  for +s: String
  String

# Module: src/load/paths.bend:7
law f_unquote_chars:
  for +s: String
  String

# Module: src/load/paths.bend:11
law f_path_dir:
  for +path: String
  String

# Module: src/load/paths.bend:15
law f_path_scan:
  for +path: String
  for +acc: String
  for +dir: String
  String

# Module: src/load/paths.bend:21
law f_path_join:
  for +dir: String
  for +path: String
  String

# Module: src/load/paths.bend:26
law f_path_term:
  for +t: KTerm
  for +dir: String
  KTerm

# Module: src/load/paths.bend:31
law f_path_terms:
  for +ts: List<&2, KTerm>
  for +dir: String
  List<&2, KTerm>

# Module: src/load/paths.bend:36
law f_path_defs:
  for +ds: List<&2,KDef>
  for +dir: String
  for +native: Bool
  List<&2,KDef>

# Module: src/load/paths.bend:42
law f_path_result:
  for +r: FResult
  for +path: String
  for +native: Bool
  FResult

# Module: src/front/families.bend:3
law f_leading_quants:
  for +ty: KTerm
  U32

# Module: src/front/families.bend:7
law f_quants:
  for +n: U32
  for +q: U32
  List<&2, KTerm>

# Module: src/front/families.bend:12
law f_adt:
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +d: KDef
  KTerm

# Module: src/front/families.bend:18
law f_adt_fill:
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +arity: U32
  for +g: U32
  KTerm

# Module: src/front/families.bend:25
law f_drop_terms:
  for +ts: List<&2, KTerm>
  for +n: U32
  List<&2, KTerm>

# Module: src/front/families.bend:30
law f_scope_app:
  for +f: KTerm
  for +x: KTerm
  KTerm

# Module: src/front/families.bend:35
law f_mark_rows:
  for +rows: List<&2, KTerm>
  for +q: U32
  U32

# Module: src/front/families.bend:40
law f_mark_vars:
  for +vars: List<&2, KTerm>
  for +id: U32
  for +q: U32
  List<&2, KTerm>

# Module: src/front/families.bend:46
law f_mark_fields:
  for +vars: List<&2, KTerm>
  for +q: U32
  List<&2, KTerm>

# Module: src/front/families.bend:100
law f_scope_call:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/families.bend:106
law f_scope_call_head:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  for +head: KTerm
  KTerm

# Module: src/front/families.bend:113
law f_templates_valid:
  for +args: List<&2, KTerm>
  for +left: U32
  for +ordinary: Bool
  Bool

# Module: src/front/families.bend:119
law f_scope_call_args:
  for +args: List<&2, KTerm>
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  List<&2, KTerm>

# Module: src/front/families.bend:125
law f_scope_apply_many:
  for +head: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/front/families.bend:130
law f_scope_reference:
  for +t: KTerm
  for +bound: KTerm
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/families.bend:136
law f_scope_lambda:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  KTerm

# Module: src/front/families.bend:142
law f_scope_lambda_var:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +book: List<&2, KDef>
  for +v: KTerm
  KTerm

# Module: src/front/validate.bend:3
law f_reserved:
  for +s: String
  Bool

# Module: src/front/validate.bend:7
law f_ctor_lookup:
  for +name: String
  for +book: List<&2,KDef>
  KDef

# Module: src/front/validate.bend:12
law f_ctor_more:
  for +name: String
  for +found: KDef
  for +rest: List<&2,KDef>
  KDef

# Module: src/front/validate.bend:18
law f_valid_pattern:
  for +p: KTerm
  for +book: List<&2,KDef>
  String

# Module: src/front/validate.bend:23
law f_valid_ctor_pattern:
  for +p: KTerm
  for +ctr: KDef
  for +book: List<&2,KDef>
  String

# Module: src/front/validate.bend:29
law f_valid_patterns:
  for +ps: List<&2, KTerm>
  for +book: List<&2,KDef>
  String

# Module: src/front/validate.bend:34
law f_valid_patterns_next:
  for +err: String
  for +ps: List<&2, KTerm>
  for +book: List<&2,KDef>
  String

# Module: src/front/validate.bend:40
law f_scope_row_valid:
  for +r: KTerm
  for +pats: List<&2, KTerm>
  for +env: List<&2, KTerm>
  for +book: List<&2,KDef>
  for +err: String
  KTerm

# Module: src/front/validate.bend:48
law f_lambda_valid:
  for +a: KTerm
  for +body: KTerm
  KTerm

# Module: src/front/validate.bend:53
law f_case_checked:
  for +p: FParsed
  for +indent: U32
  for +heads: List<&2, KTerm>
  for +rows: List<&2, KTerm>
  for +pats: List<&2, KTerm>
  FParsed

# Module: src/front/validate.bend:112
law f_alias_valid:
  for +s: String
  Bool

# Module: src/front/validate.bend:116
law f_alias_chars:
  for +s: String
  Bool

# Module: src/front/validate.bend:120
law f_import_alias:
  for +ts: List<&2, FToken>
  for +path: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  FResult

# Module: src/front/validate.bend:127
law f_validate_param:
  for +ts: List<&2, FToken>
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/validate.bend:150
law f_valid_name:
  for +s: String
  Bool

# Module: src/front/validate.bend:154
law f_name_chars:
  for +s: String
  Bool

# Module: src/front/validate.bend:166
law f_bare_params:
  for +params: List<&2, KTerm>
  Bool

# Module: src/front/validate.bend:170
law f_def_prior:
  for +name: String
  for +p: FParsed
  for +book: List<&2, KDef>
  for +imports: List<&2, KTerm>
  for +unsafe: Bool
  for +old: KDef
  FResult

# Module: src/front/validate.bend:191
law f_bang:
  for +n: KTerm
  for +ts: List<&2, FToken>
  for +min: U32
  FParsed

# Module: src/front/validate.bend:197
law f_foreign_path_valid:
  for +ts: List<&2, FToken>
  Bool

# Module: src/front/validate.bend:213
law f_scoped_row:
  for +pats: List<&2,KTerm>
  for +body: KTerm
  KTerm

# Module: src/front/validate.bend:218
law f_contains_var:
  for +t: KTerm
  Bool

# Module: src/front/validate.bend:222
law f_contains_var_terms:
  for +ts: List<&2,KTerm>
  Bool

# Module: src/load/imports.bend:3
law f_import_path:
  for +ts: List<&2, FToken>
  for +path: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  FResult

# Module: src/load/graph.bend:7
law f_path_normal:
  for +s: String
  String

# Module: src/load/graph.bend:11
law f_path_parts:
  for +s: String
  for +part: String
  for +parts: List<&2,String>
  for +abs: Bool
  String

# Module: src/load/graph.bend:18
law f_path_push:
  for +part: String
  for +parts: List<&2,String>
  List<&2,String>

# Module: src/load/graph.bend:23
law f_path_parent:
  for +parts: List<&2,String>
  List<&2,String>

# Module: src/load/graph.bend:27
law f_path_join_parts:
  for +parts: List<&2,String>
  for +acc: String
  String

# Module: src/load/graph.bend:32
law f_drop_chars:
  for +s: String
  for +n: U32
  String

# Module: src/load/graph.bend:37
law f_strip_bend:
  for +s: String
  String

# Module: src/load/graph.bend:41
law f_graph_source:
  for +path: String
  for +sources: List<&2,FSource>
  FSource

# Module: src/load/graph.bend:46
law f_load_graph:
  for +main: String
  for +sources: List<&2,FSource>
  FResult

# Module: src/load/graph.bend:51
law f_graph_result:
  for +g: FGraph
  FResult

# Module: src/load/graph.bend:55
law f_graph_load:
  for +path: String
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  FGraph

# Module: src/load/graph.bend:63
law f_graph_source_load:
  for +s: FSource
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  FGraph

# Module: src/load/graph.bend:71
law f_graph_cached:
  for +s: FSource
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  for +entry: KTerm
  FGraph

# Module: src/load/graph.bend:80
law f_graph_error:
  for +g: FGraph
  for +err: String
  FGraph

# Module: src/load/graph.bend:85
law f_graph_parsed:
  for +s: FSource
  for +ns: String
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  for +r: FResult
  FGraph

# Module: src/load/graph.bend:94
law f_import_namespace:
  for +im: KTerm
  for +ns: String
  String

# Module: src/load/graph.bend:99
law f_import_pathname:
  for +im: KTerm
  for +s: FSource
  for +sources: List<&2,FSource>
  String

# Module: src/load/graph.bend:105
law f_graph_imports:
  for +s: FSource
  for +ns: String
  for +book: List<&2,KDef>
  for +allimports: List<&2, KTerm>
  for +imports: List<&2, KTerm>
  for +sources: List<&2,FSource>
  for +g: FGraph
  for +stack: List<&2,String>
  FGraph

# Module: src/load/graph.bend:116
law f_graph_aliases:
  for +imports: List<&2, KTerm>
  for +ns: String
  List<&2, KTerm>

# Module: src/load/graph.bend:121
law f_alias_term:
  for +t: KTerm
  for +imports: List<&2, KTerm>
  KTerm

# Module: src/load/graph.bend:126
law f_alias_terms:
  for +ts: List<&2, KTerm>
  for +imports: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/load/graph.bend:131
law f_alias_defs:
  for +ds: List<&2,KDef>
  for +imports: List<&2, KTerm>
  List<&2,KDef>

# Module: src/load/graph.bend:136
law f_graph_finish:
  for +s: FSource
  for +ns: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  for +g: FGraph
  FGraph

# Module: src/load/graph.bend:144
law f_graph_finish_alias:
  for +s: FSource
  for +ns: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  for +prior: List<&2,KDef>
  for +err: String
  for +done: List<&2, KTerm>
  FGraph

# Module: src/load/graph.bend:289
law f_module_defs:
  for +todo: List<&2, KDef>
  for +visible: List<&2, KDef>
  for +scope: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  List<&2, KDef>

# Module: src/load/graph.bend:297
law f_module_def:
  for +d: KDef
  for +rest: List<&2, KDef>
  for +visible: List<&2, KDef>
  for +scope: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  List<&2, KDef>

# Module: src/load/graph.bend:323
law f_main_names:
  for +main: String
  for +sources: List<&2,FSource>
  List<&2,String>

# Module: src/load/graph.bend:328
law f_main_result_names:
  for +r: FResult
  List<&2,String>

# Module: src/load/graph.bend:332
law f_main_order:
  for +book: List<&2,KDef>
  for +seen: List<&2,String>
  List<&2,String>

# Module: src/load/graph.bend:337
law f_main_seen:
  for +name: String
  for +seen: List<&2,String>
  Bool

# Module: src/load/seed.bend:9
law f_load_graph_seed:
  for +main: String
  for +sources: List<&2, FSource>
  for +seedPath: String
  for +seedText: String
  for +seedBook: List<&2, KDef>
  FResult

# Module: src/load/seed.bend:17
law f_seed_matches:
  for +source: FSource
  for +path: String
  for +text: String
  Bool

# Module: src/load/seed.bend:23
law fs_path:
  for +seed: FSeed
  String

# Module: src/load/seed.bend:27
law fs_book:
  for +seed: FSeed
  List<&2, KDef>

# Module: src/load/seed.bend:31
law fs_load:
  for +path: String
  for +ns: String
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:40
law fs_source:
  for +s: FSource
  for +ns: String
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:49
law fs_cached:
  for +s: FSource
  for +ns: String
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +entry: KTerm
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:59
law fs_inject:
  for +g: FGraph
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:64
law fs_parsed:
  for +s: FSource
  for +ns: String
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +r: FResult
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:74
law fs_imports:
  for +s: FSource
  for +ns: String
  for +book: List<&2, KDef>
  for +allimports: List<&2, KTerm>
  for +imports: List<&2, KTerm>
  for +sources: List<&2, FSource>
  for +g: FGraph
  for +stack: List<&2, String>
  for +seed: FSeed
  FGraph

# Module: src/load/seed.bend:143
law f_seed_text_equal:
  for +a: String
  for +b: String
  Bool

# Module: src/load/modules.bend:10
law f_parse_at:
  for +source: String
  for +namespace: String
  FResult

# Module: src/load/modules.bend:15
law f_qual_result:
  for +r: FResult
  for +ns: String
  FResult

# Module: src/load/modules.bend:20
law f_qual_name:
  for +name: String
  for +ns: String
  String

# Module: src/load/modules.bend:25
law f_prefix:
  for +s: String
  for +prefix: String
  Bool

# Module: src/load/modules.bend:30
law f_drop_prefix:
  for +s: String
  for +prefix: String
  String

# Module: src/load/modules.bend:35
law f_alias:
  for +name: String
  for +imports: List<&2, KTerm>
  String

# Module: src/load/modules.bend:40
law f_declared:
  for +name: String
  for +book: List<&2, KDef>
  Bool

# Module: src/load/modules.bend:45
law f_resolve_name:
  for +name: String
  for +book: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  String

# Module: src/load/modules.bend:52
law f_qual_term:
  for +t: KTerm
  for +book: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  KTerm

# Module: src/load/modules.bend:59
law f_qual_terms:
  for +ts: List<&2, KTerm>
  for +book: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/load/modules.bend:66
law f_qual_defs:
  for +ds: List<&2, KDef>
  for +book: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  List<&2, KDef>

# Module: src/load/modules.bend:73
law f_qual_def:
  for +d: KDef
  for +book: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  KDef

# Module: src/load/modules.bend:80
law f_source:
  for +name: String
  for +sources: List<&2, FSource>
  FSource

# Module: src/load/modules.bend:85
law f_source_name:
  for +source: FSource
  String

# Module: src/load/modules.bend:89
law f_source_text:
  for +source: FSource
  String

# Module: src/load/modules.bend:93
law f_source_path:
  for +source: FSource
  String

# Module: src/load/modules.bend:97
law f_load:
  for +main: String
  for +sources: List<&2, FSource>
  FResult

# Module: src/load/modules.bend:102
law f_loaded_result:
  for +r: FLoaded
  FResult

# Module: src/load/modules.bend:106
law f_load_module:
  for +name: String
  for +ns: String
  for +sources: List<&2, FSource>
  for +seen: List<&2, String>
  for +stack: List<&2, String>
  FLoaded

# Module: src/load/modules.bend:114
law f_load_source:
  for +name: String
  for +ns: String
  for +source: FSource
  for +sources: List<&2, FSource>
  for +seen: List<&2, String>
  for +stack: List<&2, String>
  FLoaded

# Module: src/load/modules.bend:123
law f_load_parsed:
  for +name: String
  for +r: FResult
  for +sources: List<&2, FSource>
  for +seen: List<&2, String>
  for +stack: List<&2, String>
  FLoaded

# Module: src/load/modules.bend:131
law f_defs_append:
  for +xs: List<&2, KDef>
  for +ys: List<&2, KDef>
  List<&2, KDef>

# Module: src/load/modules.bend:136
law f_load_imports:
  for +imports: List<&2, KTerm>
  for +sources: List<&2, FSource>
  for +seen: List<&2, String>
  for +stack: List<&2, String>
  for +book: List<&2, KDef>
  FLoaded

# Module: src/load/modules.bend:144
law f_load_import_next:
  for +imports: List<&2, KTerm>
  for +sources: List<&2, FSource>
  for +stack: List<&2, String>
  for +book: List<&2, KDef>
  for +r: FLoaded
  FLoaded

# Module: src/load/modules.bend:299
law f_qual_optional:
  for +defs: List<&2, KDef>
  for +book: List<&2, KDef>
  for +ns: String
  for +imports: List<&2, KTerm>
  List<&2, KDef>

# Module: src/load/modules.bend:312
law f_source_parsed:
  for +name: String
  for +path: String
  for +text: String
  for +parsed: FResult
  FSource

# Module: src/load/modules.bend:319
law f_parse_source:
  for +source: FSource
  FResult

# Module: src/diagnostic/render.bend:4
law dg_units:
  for +c: Char
  U32

# Module: src/diagnostic/render.bend:8
law dg_width:
  for +s: String
  U32

# Module: src/diagnostic/render.bend:12
law dg_line_at:
  for +s: String
  for +offset: U32
  for +line: U32
  U32

# Module: src/diagnostic/render.bend:18
law dg_padding:
  for +n: U32
  String

# Module: src/diagnostic/render.bend:22
law dg_lpad:
  for +s: String
  for +width: U32
  String

# Module: src/diagnostic/render.bend:27
law dg_rpad:
  for +s: String
  for +width: U32
  String

# Module: src/diagnostic/render.bend:32
law dg_lines_count:
  for +lines: List<&2, String>
  U32

# Module: src/diagnostic/render.bend:36
law dg_snippet:
  for +span: DSpan
  String

# Module: src/diagnostic/render.bend:40
law dg_snippet_at:
  for +lines: List<&2, String>
  for +at: U32
  String

# Module: src/diagnostic/render.bend:45
law dg_snippet_lines:
  for +lines: List<&2, String>
  for +at: U32
  for +end: U32
  for +line: U32
  String

# Module: src/diagnostic/render.bend:52
law dg_scope:
  for +ctx: List<&2, KTerm>
  for +env: List<&2, KPName>
  List<&2, KPName>

# Module: src/diagnostic/render.bend:57
law dg_context_width:
  for +ctx: List<&2, KTerm>
  U32

# Module: src/diagnostic/render.bend:61
law dg_expr:
  for +book: List<&2, KDef>
  for +expr: DExpr
  for +env: List<&2, KPName>
  String

# Module: src/diagnostic/render.bend:67
law dg_context:
  for +book: List<&2, KDef>
  for +ctx: List<&2, KTerm>
  for +env: List<&2, KPName>
  for +width: U32
  String

# Module: src/diagnostic/render.bend:74
law dg_location:
  for +name: String
  for +span: DSpan
  String

# Module: src/diagnostic/render.bend:79
law dg_location_text:
  for +name: String
  for +snippet: String
  String

# Module: src/diagnostic/render.bend:84
law dg_render:
  for +book: List<&2, KDef>
  for +diagnostic: DDiagnostic
  String

# Module: src/diagnostic/render.bend:89
law dg_render_parts:
  for +book: List<&2, KDef>
  for +expected: DExpr
  for +observed: DExpr
  for +has_observed: Bool
  for +ctx: List<&2, KTerm>
  for +name: String
  for +span: DSpan
  for +note: String
  String

# Module: src/diagnostic/render.bend:100
law diagnostic_render:
  for +result: DResult
  String

# Module: src/diagnostic/render.bend:104
law dg_render_checked:
  for +book: List<&2, KDef>
  for +diagnostic: DDiagnostic
  for +error: String
  String

# Module: src/diagnostic/trace.bend:4
law dg_text:
  for +s: String
  KTerm

# Module: src/diagnostic/trace.bend:8
law dg_bad_detail:
  for +message: String
  for +expected: KTerm
  for +observed: KTerm
  KChecked

# Module: src/diagnostic/trace.bend:14
law dg_bad_message:
  for +message: String
  for +expected: KTerm
  KChecked

# Module: src/diagnostic/trace.bend:19
law dg_pair:
  for +expected: KTerm
  for +observed: KTerm
  KTerm

# Module: src/diagnostic/trace.bend:24
law dg_family:
  for +book: List<&2, KDef>
  for +name: String
  String

# Module: src/diagnostic/trace.bend:29
law dg_typeless:
  for +book: List<&2, KDef>
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/diagnostic/trace.bend:35
law dg_trace:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +r: KChecked
  KChecked

# Module: src/diagnostic/trace.bend:43
law dg_trace_detail:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +r: KChecked
  for +detail: KTerm
  KChecked

# Module: src/diagnostic/trace.bend:51
law dg_reason:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +code: String
  KTerm

# Module: src/diagnostic/trace.bend:59
law dg_as_expr:
  for +t: KTerm
  DExpr

# Module: src/diagnostic/trace.bend:63
law dg_no_report:
  for +name: String
  for +message: String
  DDiagnostic

# Module: src/diagnostic/trace.bend:68
law dg_report:
  for +r: KChecked
  for +name: String
  DDiagnostic

# Module: src/diagnostic/produce.bend:4
law dg_span_same:
  for +a: DSpan
  for +b: DSpan
  Bool

# Module: src/diagnostic/produce.bend:9
law dg_span_fields:
  for +s: String
  for +b0: U32
  for +e0: U32
  for +b: DSpan
  Bool

# Module: src/diagnostic/produce.bend:16
law dg_has_span:
  for +s: DSpan
  Bool

# Module: src/diagnostic/produce.bend:20
law dg_origin_scan:
  for +origins: List<&2, DOrigin>
  for +name: String
  for +t: KTerm
  for +found: DSpan
  DSpan

# Module: src/diagnostic/produce.bend:27
law dg_origin_trail:
  for +origins: List<&2, DOrigin>
  for +name: String
  for +trail: List<&2, KTerm>
  DSpan

# Module: src/diagnostic/produce.bend:33
law dg_origin_found:
  for +origins: List<&2, DOrigin>
  for +name: String
  for +rest: List<&2, KTerm>
  for +found: DSpan
  DSpan

# Module: src/diagnostic/produce.bend:40
law diagnostic_locate:
  for +diagnostic: DDiagnostic
  for +origins: List<&2, DOrigin>
  DDiagnostic

# Module: src/diagnostic/produce.bend:45
law diagnostic_result_locate:
  for +result: DResult
  for +origins: List<&2, DOrigin>
  DResult

# Module: src/diagnostic/produce.bend:50
law dg_finish:
  for +error: String
  for +book: List<&2, KDef>
  for +diagnostic: DDiagnostic
  for +origins: List<&2, DOrigin>
  DResult

# Module: src/diagnostic/produce.bend:57
law check_book_diagnostic:
  for +book: List<&2, KDef>
  for +origins: List<&2, DOrigin>
  DResult

# Module: src/diagnostic/produce.bend:62
law dg_book_checked:
  for +book: List<&2, KDef>
  for +origins: List<&2, DOrigin>
  for +error: String
  DResult

# Module: src/diagnostic/produce.bend:68
law dg_events:
  for +todo: List<&2, KDef>
  for +done: List<&2, KDef>
  for +origins: List<&2, DOrigin>
  for +error: String
  DResult

# Module: src/diagnostic/produce.bend:75
law dg_event_guard:
  for +rest: List<&2, KDef>
  for +done: List<&2, KDef>
  for +d: KDef
  for +origins: List<&2, DOrigin>
  for +error: String
  for +guard: String
  DResult

# Module: src/diagnostic/produce.bend:84
law dg_event_check:
  for +rest: List<&2, KDef>
  for +done: List<&2, KDef>
  for +d: KDef
  for +origins: List<&2, DOrigin>
  for +error: String
  for +checked: String
  DResult

# Module: src/diagnostic/produce.bend:93
law dg_definition:
  for +book: List<&2, KDef>
  for +d: KDef
  KChecked

# Module: src/diagnostic/produce.bend:98
law dg_definition_type:
  for +book: List<&2, KDef>
  for +d: KDef
  for +r: KChecked
  KChecked

# Module: src/diagnostic/produce.bend:104
law dg_template:
  for +book: List<&2, KDef>
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  KChecked

# Module: src/diagnostic/produce.bend:113
law dg_template_binder:
  for +book: List<&2, KDef>
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  KChecked

# Module: src/diagnostic/produce.bend:122
law dg_template_open:
  for +book: List<&2, KDef>
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  for +name: String
  KChecked

# Module: src/diagnostic/produce.bend:132
law dg_quant_error:
  for +message: String
  for +name: String
  for +allowed: U32
  for +used: U32
  KChecked

# Module: src/diagnostic/produce.bend:139
law dg_constructor_names:
  for +ds: List<&2, KDef>
  String

# Module: src/diagnostic/produce.bend:143
law dg_ctor_error:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  for +ctr: KDef
  KChecked

# Module: src/diagnostic/frontend.bend:11
law f_load_origins:
  for +main: String
  for +sources: List<&2,FSource>
  FProvenance

# Module: src/diagnostic/frontend.bend:15
law fp_graph:
  for +graph: FGraph
  for +sources: List<&2,FSource>
  FProvenance

# Module: src/diagnostic/frontend.bend:19
law fp_result:
  for +result: FResult
  for +done: List<&2,KTerm>
  for +sources: List<&2,FSource>
  FProvenance

# Module: src/diagnostic/frontend.bend:24
law fp_modules:
  for +done: List<&2,KTerm>
  for +sources: List<&2,FSource>
  List<&2,FPSource>

# Module: src/diagnostic/frontend.bend:28
law fp_module:
  for +source: FSource
  List<&2,FPSource>

# Module: src/diagnostic/frontend.bend:31
law fp_module_parsed:
  for +text: String
  for +tokens: List<&2,FToken>
  for +parsed: FResult
  List<&2,FPSource>

# Module: src/diagnostic/frontend.bend:36
law fp_event_sources:
  for +book: List<&2,KDef>
  for +source: FPSource
  List<&2,FPSource>

# Module: src/diagnostic/frontend.bend:40
law fp_join:
  for +left: List<&2,FPSource>
  for +right: List<&2,FPSource>
  List<&2,FPSource>

# Module: src/diagnostic/frontend.bend:44
law fp_defs:
  for +book: List<&2,KDef>
  for +sources: List<&2,FPSource>
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:48
law fp_defs_source:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +sources: List<&2,FPSource>
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:53
law fp_def:
  for +d: KDef
  for +source: FPSource
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:57
law fp_ctors:
  for +ctors: List<&2,KDef>
  for +definition: String
  for +source: FPSource
  for +index: U32
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:63
law fp_term:
  for +t: KTerm
  for +definition: String
  for +source: FPSource
  for +route: List<&2,U32>
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:69
law fp_children:
  for +terms: List<&2,KTerm>
  for +definition: String
  for +source: FPSource
  for +route: List<&2,U32>
  for +index: U32
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:76
law fp_origin:
  for +t: KTerm
  for +definition: String
  for +source: FPSource
  for +route: List<&2,U32>
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:82
law fp_find_token:
  for +tokens: List<&2,FToken>
  for +line: U32
  for +column: U32
  List<&2,FToken>

# Module: src/diagnostic/frontend.bend:87
law fp_at_token:
  for +t: KTerm
  for +definition: String
  for +text: String
  for +tokens: List<&2,FToken>
  for +route: List<&2,U32>
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:94
law fp_token_origin:
  for +t: KTerm
  for +definition: String
  for +text: String
  for +token: FToken
  for +route: List<&2,U32>
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:101
law fp_utf16:
  for +text: String
  U32

# Module: src/diagnostic/frontend.bend:104
law fp_offset:
  for +text: String
  for +line: U32
  for +column: U32
  for +targetLine: U32
  for +targetColumn: U32
  for +offset: U32
  U32

# Module: src/diagnostic/frontend.bend:223
law f_load_origins_for:
  for +main: String
  for +sources: List<&2,FSource>
  for +definition: String
  FProvenance

# Module: src/diagnostic/frontend.bend:228
law fp_graph_for:
  for +graph: FGraph
  for +sources: List<&2,FSource>
  for +definition: String
  FProvenance

# Module: src/diagnostic/frontend.bend:233
law fp_result_for:
  for +result: FResult
  for +done: List<&2,KTerm>
  for +sources: List<&2,FSource>
  for +definition: String
  FProvenance

# Module: src/diagnostic/frontend.bend:239
law fp_defs_for:
  for +book: List<&2,KDef>
  for +sources: List<&2,FPSource>
  for +definition: String
  List<&2,DOrigin>

# Module: src/diagnostic/frontend.bend:244
law fp_defs_source_for:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +sources: List<&2,FPSource>
  for +definition: String
  List<&2,DOrigin>

# Module: src/back/js/foreign.bend:4
law j_foreign_path:
  for +paths: List<&2, KTerm>
  String

# Module: src/back/js/foreign.bend:16
law j_foreign_name:
  for +name: String
  String

# Module: src/back/js/foreign.bend:24
law j_foreign_chars:
  for +name: String
  String

# Module: src/back/js/foreign.bend:36
law j_foreign_def:
  for +book: List<&2, KDef>
  for +d: KDef
  String

# Module: src/back/js/foreign.bend:45
law j_foreign_args:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +n: U32
  String

# Module: src/back/js/foreign.bend:55
law j_foreign_return:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +n: U32
  KTerm

# Module: src/back/js/foreign.bend:65
law j_io_result:
  for +book: List<&2, KDef>
  for +ty: KTerm
  KTerm

# Module: src/back/js/foreign.bend:74
law j_modules:
  for +book: List<&2, KDef>
  for +sources: List<&2, KTerm>
  String

# Module: src/back/js/foreign.bend:87
law j_module_exports:
  for +book: List<&2, KDef>
  for +path: String
  String

# Module: src/back/js/foreign.bend:100
law j_module_export:
  for +name: String
  for +implementation: String
  String

# Module: src/back/js/foreign.bend:109
law j_ctor_metadata:
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/foreign.bend:121
law j_ctor_keys:
  for +ctors: List<&2, KDef>
  for +params: U32
  String

# Module: src/back/js/foreign.bend:134
law j_field_keys:
  for +ty: KTerm
  for +skip: U32
  String

# Module: src/back/js/foreign.bend:144
law j_foreign_paths:
  for +book: List<&2, KDef>
  List<&2, String>

# Module: src/back/js/foreign.bend:156
law j_foreign_error:
  for +book: List<&2, KDef>
  String

# Module: src/back/js/foreign.bend:168
law j_builtin_effect:
  for +name: String
  Bool

# Module: src/back/js/literals.bend:4
law j_strip:
  for +t: KTerm
  KTerm

# Module: src/back/js/literals.bend:12
law j_literal:
  for +t: KTerm
  String

# Module: src/back/js/literals.bend:20
law j_literal_node:
  for +t: KTerm
  String

# Module: src/back/js/literals.bend:28
law j_literal_ctor:
  for +t: KTerm
  String

# Module: src/back/js/literals.bend:36
law j_u32:
  for +t: KTerm
  Maybe<&2, U32>

# Module: src/back/js/literals.bend:44
law j_u32_node:
  for +t: KTerm
  Maybe<&2, U32>

# Module: src/back/js/literals.bend:52
law j_word:
  for +t: KTerm
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

# Module: src/back/js/literals.bend:62
law j_word_bit:
  for +bit: KTerm
  for +rest: KTerm
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

# Module: src/back/js/literals.bend:73
law j_word_text:
  for +value: Maybe<&2, U32>
  for +float: Bool
  String

# Module: src/back/js/literals.bend:86
law j_char_text:
  for +value: Maybe<&2, U32>
  String

# Module: src/back/js/literals.bend:98
law j_nat:
  for +t: KTerm
  for +acc: Nat
  Maybe<&2, Nat>

# Module: src/back/js/literals.bend:107
law j_nat_text:
  for +value: Maybe<&2, Nat>
  String

# Module: src/back/js/literals.bend:119
law j_string:
  for +t: KTerm
  for +acc: String
  Maybe<&2, String>

# Module: src/back/js/literals.bend:128
law j_string_head:
  for +head: KTerm
  for +tail: KTerm
  for +acc: String
  Maybe<&2, String>

# Module: src/back/js/literals.bend:138
law j_string_char:
  for +value: Maybe<&2, U32>
  for +tail: KTerm
  for +acc: String
  Maybe<&2, String>

# Module: src/back/js/literals.bend:152
law j_string_text:
  for +value: Maybe<&2, String>
  String

# Module: src/back/js/literals.bend:167
law j_literal_typed:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/literals.bend:173
law j_literal_provenance:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +literal: String
  String

# Module: src/back/js/validate.bend:5
law j_compile_error:
  for +book: List<&2, KDef>
  String

# Module: src/back/js/validate.bend:13
law j_main_error:
  for +book: List<&2, KDef>
  for +main: KDef
  String

# Module: src/back/js/validate.bend:22
law j_printable:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Bool

# Module: src/back/js/validate.bend:33
law j_printable_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Bool

# Module: src/back/js/validate.bend:44
law j_printable_adt:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Bool

# Module: src/back/js/validate.bend:55
law j_printable_ctors:
  for +book: List<&2, KDef>
  for +ctors: List<&2, KDef>
  for +params: List<&2, KTerm>
  for +seen: List<&2, String>
  for +fuel: U32
  Bool

# Module: src/back/js/validate.bend:71
law j_printable_fields:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Bool

# Module: src/back/js/validate.bend:85
law j_layout_error:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  for +roots: List<&2, String>
  for +stops: List<&2, String>
  String

# Module: src/back/js/validate.bend:96
law j_layout_visit:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  for +todo: List<&2, String>
  for +seen: List<&2, String>
  for +stops: List<&2, String>
  Bool

# Module: src/back/js/validate.bend:111
law j_layout_def:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  for +d: KDef
  for +todo: List<&2, String>
  for +seen: List<&2, String>
  for +stops: List<&2, String>
  Bool

# Module: src/back/js/validate.bend:124
law j_layout_mark:
  for +bad: Bool
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:133
law j_layout_open:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/back/js/validate.bend:142
law j_layout_open_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/back/js/validate.bend:151
law j_layout_term:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:163
law j_layout_kind:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  for +key: String
  List<&2, String>

# Module: src/back/js/validate.bend:183
law j_layout_lam:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:195
law j_layout_match:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:207
law j_layout_app:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +fty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:219
law j_layout_function:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:231
law j_layout_array_intrinsic:
  for +book: List<&2, KDef>
  for +f: KTerm
  Bool

# Module: src/back/js/validate.bend:240
law j_layout_intrinsic:
  for +book: List<&2, KDef>
  for +f: KTerm
  for +element: KTerm
  Bool

# Module: src/back/js/validate.bend:250
law j_layout_fields:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +tel: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:265
law j_layout_let:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:277
law j_layout_bindings:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/choice.bend:3
law j_choice_call:
  for +book: List<&2, KDef>
  for +spine: KTerm
  Bool

# Module: src/back/js/choice.bend:8
law j_choice_definition:
  for +book: List<&2, KDef>
  for +d: KDef
  Bool

# Module: src/back/js/choice.bend:13
law j_choice_match:
  for +t: KTerm
  Bool

# Module: src/back/js/choice.bend:17
law j_choice_arm:
  for +t: KTerm
  for +first: Bool
  Bool

# Module: src/back/js/choice.bend:22
law j_choice_leaf:
  for +t: KTerm
  for +binder: U32
  Bool

# Module: src/back/js/choice.bend:27
law j_choice_emit:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +spine: KTerm
  for +tail: Bool
  String

# Module: src/back/js/choice.bend:34
law j_choice_after_type:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +tail: Bool
  for +ty: KTerm
  String

# Module: src/back/js/choice.bend:42
law j_choice_after_bool:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +tail: Bool
  for +condition: String
  for +ty: KTerm
  String

# Module: src/back/js/choice.bend:51
law j_choice_branch:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +tail: Bool
  String

# Module: src/back/js/projection.bend:4
law j_projection_worker:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/projection.bend:10
law j_projection_match:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/projection.bend:16
law j_projection_arm:
  for +t: KTerm
  for +tel: KTerm
  for +slots: List<&2, KTerm>
  for +at: U32
  String

# Module: src/back/js/projection.bend:23
law j_projection_slot:
  for +id: U32
  for +slots: List<&2, KTerm>
  String

# Module: src/back/js/projection.bend:28
law j_projection_code:
  for +name: String
  for +slot: String
  String

# Module: src/back/js/projection.bend:33
law j_l_global_worker:
  for +book: List<&2, KDef>
  for +d: KDef
  for +t: KTerm
  for +worker: String
  String

# Module: src/back/js/emit.bend:3
law j_l_name:
  for +t: KTerm
  String

# Module: src/back/js/emit.bend:7
law j_l_names:
  for +names: List<&2, String>
  String

# Module: src/back/js/emit.bend:11
law j_l_capture:
  for +env: List<&2, KTerm>
  for +seen: List<&2, String>
  String

# Module: src/back/js/emit.bend:16
law j_l_deep:
  for +t: KTerm
  for +depth: U32
  Bool

# Module: src/back/js/emit.bend:21
law j_l_deeps:
  for +ts: List<&2, KTerm>
  for +depth: U32
  Bool

# Module: src/back/js/emit.bend:26
law j_l_mark:
  for +t: KTerm
  for +path: String
  for +depth: U32
  KTerm

# Module: src/back/js/emit.bend:32
law j_l_marks:
  for +ts: List<&2, KTerm>
  for +path: String
  for +depth: U32
  for +at: U32
  List<&2, KTerm>

# Module: src/back/js/emit.bend:39
law j_l_def:
  for +book: List<&2, KDef>
  for +d: KDef
  String

# Module: src/back/js/emit.bend:44
law j_l_definition:
  for +book: List<&2, KDef>
  for +d: KDef
  for +t: KTerm
  String

# Module: src/back/js/emit.bend:50
law j_l_walk:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:57
law j_l_children:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:64
law j_l_lam:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:71
law j_l_mat:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:78
law j_l_app:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:85
law j_l_fields:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +ts: List<&2, KTerm>
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:92
law j_l_bindings:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +ts: List<&2, KTerm>
  String


# JavaScript emission from the checked first-order core.
# Emission is Bend2; JavaScript only supplies primitive values and effects.
# Erased binders retain a null ABI slot, but their arguments are never evaluated.

# Module: src/back/js/emit.bend:102
law j_escape:
  for +s: String
  String

# Module: src/back/js/emit.bend:114
law j_escape_char:
  for +c: Char
  String

# Module: src/back/js/emit.bend:122
law j_escape_char_on:
  for +c: Char
  for +key: U32
  String

# Module: src/back/js/emit.bend:145
law j_quote:
  for +s: String
  String

# Module: src/back/js/emit.bend:153
law j_local:
  for +id: U32
  String

# Module: src/back/js/emit.bend:161
law j_env:
  for +env: List<&2, KTerm>
  for +id: U32
  KTerm

# Module: src/back/js/emit.bend:174
law j_type:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/back/js/emit.bend:184
law j_type_on:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +key: String
  KTerm

# Module: src/back/js/emit.bend:195
law j_app_type:
  for +ty: KTerm
  for +arg: KTerm
  KTerm

# Module: src/back/js/emit.bend:204
law j_exprs:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  String

# Module: src/back/js/emit.bend:218
law j_exprs_tail:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  String

# Module: src/back/js/emit.bend:232
law j_expr:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +tail: Bool
  String

# Module: src/back/js/emit.bend:244
law j_expr_on:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +tail: Bool
  for +key: String
  String

# Module: src/back/js/emit.bend:257
law j_lambda:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:268
law j_lambda_count:
  for +t: KTerm
  U32

# Module: src/back/js/emit.bend:276
law j_lambda_code:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +at: U32
  String

# Module: src/back/js/emit.bend:288
law j_lambda_bind:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +at: U32
  String

# Module: src/back/js/emit.bend:300
law j_apply:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +tail: Bool
  for +fty: KTerm
  String

# Module: src/back/js/emit.bend:312
law j_apply_one:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +tail: Bool
  for +fty: KTerm
  String

# Module: src/back/js/emit.bend:324
law j_call_spine:
  for +t: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/back/js/emit.bend:333
law j_apply_spine:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +tail: Bool
  for +fty: KTerm
  for +spine: KTerm
  String

# Module: src/back/js/emit.bend:346
law j_apply_regular:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +tail: Bool
  for +fty: KTerm
  for +spine: KTerm
  String

# Module: src/back/js/emit.bend:359
law j_call_arity:
  for +d: KDef
  U32

# Module: src/back/js/emit.bend:367
law j_apply_args:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:378
law j_apply_args_head:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:392
law j_descriptor:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +fuel: U32
  String

# Module: src/back/js/emit.bend:402
law j_desc_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +fuel: U32
  String

# Module: src/back/js/emit.bend:412
law j_desc_head_on:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +fuel: U32
  for +key: String
  String

# Module: src/back/js/emit.bend:423
law j_intrinsic:
  for +name: String
  Bool

# Module: src/back/js/emit.bend:431
law j_def:
  for +book: List<&2, KDef>
  for +d: KDef
  String

# Module: src/back/js/emit.bend:442
law j_defs:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:455
law j_program:
  for +book: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:463
law j_program_selected:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:472
law j_program_context:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:481
law j_let:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +ty: KTerm
  for +tail: Bool
  String

# Module: src/back/js/emit.bend:493
law j_bindings:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  String

# Module: src/back/js/emit.bend:509
law j_context:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/back/js/emit.bend:525
law j_body:
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/back/js/emit.bend:539
law j_find_ctor:
  for +book: List<&2, KDef>
  for +name: String
  KDef

# Module: src/back/js/emit.bend:552
law j_found_ctor:
  for +found: KDef
  for +rest: List<&2, KDef>
  for +name: String
  KDef

# Module: src/back/js/emit.bend:562
law j_specialize:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/back/js/emit.bend:576
law j_arm_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +name: String
  KTerm

# Module: src/back/js/emit.bend:586
law j_arm_tel:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +ret: KTerm
  KTerm

# Module: src/back/js/emit.bend:597
law j_schemas:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:610
law j_schema_ctors:
  for +book: List<&2, KDef>
  for +ctors: List<&2, KDef>
  for +params: U32
  String

# Module: src/back/js/emit.bend:624
law j_schema_params:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +left: U32
  for +index: U32
  String

# Module: src/back/js/emit.bend:635
law j_schema_fields:
  for +book: List<&2, KDef>
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:644
law j_desc_args:
  for +book: List<&2, KDef>
  for +args: List<&2, KTerm>
  for +fuel: U32
  String

# Module: src/back/js/emit.bend:657
law j_ctor_args:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +tel: KTerm
  String

# Module: src/back/js/emit.bend:672
law j_constructor:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:685
law j_constructor_mode:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +tail: Bool
  String

# Module: src/back/js/emit.bend:697
law j_ctor_thunks:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +tel: KTerm
  String

# Module: src/back/js/emit.bend:712
law j_constructor_literal:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +literal: String
  String

# Module: src/back/js/emit.bend:724
law j_io_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/back/js/emit.bend:733
law j_io_shadow:
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/back/js/emit.bend:741
law j_io_shadow_def:
  for +book: List<&2, KDef>
  for +d: KDef
  List<&2, KDef>

# Module: src/back/js/emit.bend:750
law j_io_spine:
  for +t: KTerm
  for +args: U32
  Bool

# Module: src/back/js/emit.bend:761
law j_library:
  for +book: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:769
law j_library_selected:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:778
law j_library_context:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  String

# Module: src/back/js/emit.bend:787
law j_desc_kind:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +fuel: U32
  String

# Module: src/back/js/emit.bend:797
law j_roots:
  for +book: List<&2, KDef>
  for +library: Bool
  List<&2, String>

# Module: src/back/js/emit.bend:806
law j_library_roots:
  for +book: List<&2, KDef>
  List<&2, String>

# Module: src/back/js/emit.bend:818
law j_stops:
  for +book: List<&2, KDef>
  List<&2, String>

# Module: src/back/js/emit.bend:831
law j_match:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  String

# Module: src/back/js/emit.bend:844
law j_constructor_count:
  for +book: List<&2, KDef>
  for +ty: KTerm
  U32

# Module: src/back/js/emit.bend:853
law j_count_constructors:
  for +ctors: List<&2, KDef>
  for +removed: List<&2, String>
  U32

# Module: src/back/js/emit.bend:867
law j_let_values:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  String

# Module: src/back/js/emit.bend:973
law j_l_global:
  for +book: List<&2, KDef>
  for +d: KDef
  for +t: KTerm
  String

# Module: src/back/native/text.bend:62
law nt_replace_go:
  for +s: String
  for +key: String
  for +value: String
  for +acc: String
  String

# Module: src/back/native/text.bend:69
law nt_replace_step:
  for +s: String
  for +key: String
  for +value: String
  for +acc: String
  String

# Module: src/back/native/identity.bend:6
law nc_ctor_identity:
  for +book: List<&2, KDef>
  for +name: String
  String

# Module: src/back/native/identity.bend:11
law nc_ctor_owned:
  for +book: List<&2, KDef>
  for +name: String
  Bool

# Module: src/back/native/identity.bend:16
law nc_ctor_encode:
  for +name: String
  String

# Module: src/back/native/identity.bend:20
law nc_ctor_codes:
  for +name: String
  String

# Module: src/back/native/identity.bend:24
law nc_ctor_display:
  for +name: String
  String

# Module: src/back/native/identity.bend:28
law nc_ctor_decode:
  for +rest: String
  for +acc: U32
  for +digits: U32
  for +out: String
  for +original: String
  String

# Module: src/back/native/identity.bend:36
law nc_ctor_decode_step:
  for +h: Char
  for +rest: String
  for +acc: U32
  for +digits: U32
  for +out: String
  for +original: String
  String

# Module: src/back/native/tables.bend:162
law nb_fork_next:
  for +ss: List<&2, N_Segment>
  for +roots: List<&2, String>
  for +next: List<&2, String>
  for +fuel: U32
  List<&2, String>

# Module: src/back/native/erase.bend:4
law nc_erase:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/back/native/erase.bend:9
law nc_erase_list:
  for +book: List<&2, KDef>
  for +ts: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/back/native/erase.bend:14
law nc_erase_args:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/back/native/bridge.bend:14
law nc_lower:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  NC_Code

# Module: src/back/native/bridge.bend:100
law nc_occurs:
  for +t: KTerm
  for +id: U32
  Bool

# Module: src/back/native/bridge.bend:105
law nc_occurs_list:
  for +ts: List<&2, KTerm>
  for +id: U32
  Bool

# Module: src/back/native/bridge.bend:110
law nc_lower_live:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  NC_Code

# Module: src/back/native/bridge.bend:300
law nc_match_apply_slow:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  NC_Code

# Module: src/back/native/bridge.bend:330
law nc_array_known:
  for +k: String
  Bool

# Module: src/back/native/bridge.bend:391
law nc_compact:
  for +t: KTerm
  KTerm

# Module: src/back/native/bridge.bend:394
law nc_compact_list:
  for +ts: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/back/native/direct.bend:3
law nd_app:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  NC_Code

# Module: src/back/native/pattern.bend:10
law np_level:
  for +term: KTerm
  for +zero: KTerm
  for +successor: KTerm
  for +hasZero: Bool
  for +hasSucc: Bool
  NPLevel

# Module: src/back/native/pattern.bend:17
law np_level_mat:
  for +term: KTerm
  for +zero: KTerm
  for +successor: KTerm
  for +hasZero: Bool
  for +hasSucc: Bool
  NPLevel

# Module: src/back/native/pattern.bend:24
law np_collect:
  for +term: KTerm
  for +depth: U32
  for +built: List<&2,NPRow>
  List<&2,NPRow>

# Module: src/back/native/pattern.bend:29
law np_collect_level:
  for +term: KTerm
  for +depth: U32
  for +built: List<&2,NPRow>
  for +level: NPLevel
  List<&2,NPRow>

# Module: src/back/native/pattern.bend:35
law np_emit:
  for +book: List<&2,KDef>
  for +rows: List<&2,NPRow>
  for +word: String
  for +env: List<&2,NC_Binding>
  for +next: U32
  NC_Code

# Module: src/back/native/pattern.bend:42
law np_emit_row:
  for +book: List<&2,KDef>
  for +row: NPRow
  for +rest: List<&2,NPRow>
  for +word: String
  for +env: List<&2,NC_Binding>
  for +next: U32
  NC_Code

# Module: src/back/native/pattern.bend:50
law np_emit_done:
  for +book: List<&2,KDef>
  for +index: U32
  for +last: Bool
  for +rest: List<&2,NPRow>
  for +word: String
  for +env: List<&2,NC_Binding>
  for +code: NC_Code
  NC_Code

# Module: src/back/native/pattern.bend:59
law np_emit_join:
  for +index: U32
  for +last: Bool
  for +word: String
  for +code: NC_Code
  for +tail: NC_Code
  NC_Code

# Module: src/back/native/pattern.bend:66
law np_row_code:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +residual: U32
  for +apply: Bool
  for +word: String
  for +env: List<&2,NC_Binding>
  for +next: U32
  NC_Code

# Module: src/back/native/pattern.bend:75
law np_match_apply:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +env: List<&2,NC_Binding>
  for +next: U32
  NC_Code

# Module: src/back/native/pattern.bend:81
law np_supported:
  for +term: KTerm
  Bool

# Module: src/back/native/pattern.bend:132
law np_level_valid:
  for +level: NPLevel
  Bool

# Module: src/back/native/pattern.bend:135
law np_can_match:
  for +term: KTerm
  Bool

# Module: src/back/native/show.bend:9
law nc_show_nodes:
  for +book: List<&2, KDef>
  for +types: List<&2, KTerm>
  for +i: U32
  for +offset: U32
  for +defs: String
  for +cells: List<&2, String>
  NC_Show

# Module: src/back/native/show.bend:18
law nc_show_fields:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +left: U32
  for +i: U32
  for +types: List<&2, KTerm>
  NC_Desc

# Module: src/back/native/show.bend:26
law nc_show_field:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +left: U32
  for +i: U32
  for +d: NC_Desc
  NC_Desc

# Module: src/back/native/show.bend:34
law nc_show_arms:
  for +book: List<&2, KDef>
  for +cs: List<&2, KDef>
  for +args: List<&2, KTerm>
  for +types: List<&2, KTerm>
  NC_Desc

# Module: src/back/native/show.bend:41
law nc_show_arm:
  for +book: List<&2, KDef>
  for +c: KDef
  for +rest: List<&2, KDef>
  for +args: List<&2, KTerm>
  for +d: NC_Desc
  NC_Desc

# Module: src/back/native/parallel.bend:3
law nc_parallel:
  for +book: List<&2, KDef>
  for +xs: List<&2, KTerm>
  for +env: List<&2, NC_Binding>
  for +n: U32
  NC_Code

# Module: src/back/native/array.bend:3
law nc_array:
  for +k: String
  for +ws: List<&2, String>
  for +n: U32
  NC_Code

# Module: src/back/native/book.bend:7
law nc_unann:
  for +t: KTerm
  KTerm

# Module: src/back/native/book.bend:11
law nc_constructors:
  for +book: List<&2, KDef>
  for +ds: List<&2, KDef>
  List<&2, N_Constructor>

# Module: src/back/native/book.bend:16
law nc_refs:
  for +t: KTerm
  List<&2, String>

# Module: src/back/native/book.bend:20
law nc_refs_list:
  for +ts: List<&2, KTerm>
  List<&2, String>

# Module: src/back/native/book.bend:24
law nc_compile_defs:
  for +book: List<&2, KDef>
  for +todo: List<&2, String>
  for +done: List<&2, String>
  for +n: U32
  for +bangs: List<&2, String>
  NC_Book

# Module: src/back/native/book.bend:32
law nc_term_fork:
  for +t: KTerm
  Bool

# Module: src/back/native/book.bend:36
law nc_terms_fork:
  for +ts: List<&2, KTerm>
  Bool

# Module: src/back/native/book.bend:81
law nc_term_bang:
  for +t: KTerm
  for +name: String
  Bool

# Module: src/back/native/book.bend:86
law nc_terms_bang:
  for +ts: List<&2, KTerm>
  for +name: String
  Bool

# Module: src/back/native/book.bend:253
law nc_bangs_term:
  for +t: KTerm
  List<&2, String>

# Module: src/back/native/book.bend:257
law nc_bangs_terms:
  for +ts: List<&2, KTerm>
  List<&2, String>

# Module: src/driver/report.bend:3
law driver_report:
  for +book: List<&2,KDef>
  for +names: List<&2,String>
  String

# Module: src/driver/report.bend:8
law dr_bad_names:
  for +book: List<&2,KDef>
  for names: List<&2,String>
  List<&2,String>

# Module: src/driver/report.bend:13
law dr_relies:
  for +book: List<&2,KDef>
  for todo: List<&2,String>
  for +seen: List<&2,String>
  Bool

# Module: src/driver/report.bend:19
law dr_relies_def:
  for +book: List<&2,KDef>
  for +todo: List<&2,String>
  for +seen: List<&2,String>
  for +d: KDef
  Bool

# Module: src/driver/report.bend:26
law dr_verdict:
  for +names: List<&2,String>
  String

# Module: src/driver/report.bend:30
law dr_count:
  for names: List<&2,String>
  U32

# Module: src/driver/report.bend:34
law dr_lines:
  for names: List<&2,String>
  String

# Module: src/driver/api.bend:2
law driver_has_main:
  for +book: List<&2, KDef>
  Bool

# Module: src/driver/api.bend:10
law driver_is_io:
  for +book: List<&2, KDef>
  Bool

# Module: src/driver/api.bend:18
law driver_interpret:
  for +book: List<&2, KDef>
  String

# Module: src/driver/api.bend:22
law driver_final:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

# Module: src/driver/api.bend:38
law driver_todos:
  for +book: List<&2,KDef>
  U32

# Module: src/driver/api.bend:46
law driver_count_todos:
  for +book: List<&2,KDef>
  U32

# Module: src/driver/api.bend:57
law driver_holes:
  for +t: KTerm
  U32

# Module: src/driver/api.bend:65
law driver_holes_terms:
  for +ts: List<&2,KTerm>
  U32

# Module: src/driver/api.bend:77
law driver_owned:
  for +book: List<&2,KDef>
  String

# Module: src/driver/api.bend:92
law driver_emit_owned:
  for +book: List<&2,KDef>
  String

# Module: src/driver/api.bend:96
law driver_owned_names:
  for +book: List<&2,KDef>
  for +names: List<&2,String>
  String

# Module: src/driver/api.bend:101
law driver_owned_name:
  for +book: List<&2,KDef>
  for +name: String
  Bool

# Module: src/core/term.bend:11
@unsafe
def kc(A, b, yes, no):
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# First-order trusted core. Binder identifiers are globally unique.
# Quantities: 0 erased, 1 affine, 2 unrestricted. No function-valued fields.

# Module: src/core/term.bend:35
@unsafe
def kt(tag, name, id, quant, kids):
  KTerm{tag, name, id, quant, kids, Nil{}}

# Module: src/core/term.bend:43
@unsafe
def atom(tag):
  kt(tag, "", 0, 0, Nil{})

# Module: src/core/term.bend:51
@unsafe
def tg(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      tag

# Module: src/core/term.bend:61
@unsafe
def nm(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      name

# Module: src/core/term.bend:71
@unsafe
def ix(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      id

# Module: src/core/term.bend:81
@unsafe
def qt(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      quant

# Module: src/core/term.bend:91
@unsafe
def ks(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      kids

# Module: src/core/term.bend:101
@unsafe
def rm(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      removed

# Module: src/core/term.bend:112
@unsafe
def terms_at(ts, n):
  match ts:
    case Nil{}:
      atom("Absent")
    case Con{h, t}:
      kc(KTerm, U32.is_eq(n, 0), u => h, u => terms_at(t, U32.sub(n, 1)))

# Module: src/core/term.bend:125
@unsafe
def kid(t, n):
  terms_at(ks(t), n)

# Module: src/core/term.bend:134
@unsafe
def var(name, id):
  kt("Var", name, id, 0, Nil{})

# Module: src/core/term.bend:142
@unsafe
def ref(name):
  kt("Ref", name, 0, 0, Nil{})

# Module: src/core/term.bend:150
@unsafe
def qua(q):
  kt("Qua", "", 0, q, Nil{})

# Module: src/core/term.bend:158
@unsafe
def typ(q):
  kt("Typ", "", 0, 0, Con{qua(q), Nil{}})

# Module: src/core/term.bend:167
@unsafe
def app(f, x):
  kt("App", "", 0, 0, Con{f, Con{x, Nil{}}})

# Module: src/core/term.bend:179
@unsafe
def all(q, name, id, a, b):
  kt("All", name, id, q, Con{a, Con{b, Nil{}}})

# Module: src/core/term.bend:187
@unsafe
def dn(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      name

# Module: src/core/term.bend:197
@unsafe
def dk(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      kind

# Module: src/core/term.bend:207
@unsafe
def da(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      arity

# Module: src/core/term.bend:217
@unsafe
def dx(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      templates

# Module: src/core/term.bend:227
@unsafe
def dt(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      typ

# Module: src/core/term.bend:237
@unsafe
def dv(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      value

# Module: src/core/term.bend:247
@unsafe
def dc(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      ctors

# Module: src/core/term.bend:257
@unsafe
def db(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      native

# Module: src/core/term.bend:267
@unsafe
def du(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      unsafe

# Module: src/core/term.bend:276
@unsafe
def missing():
  KDef{"", "Absent", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}

# Module: src/core/term.bend:285
@unsafe
def lookup(book, name):
  match book:
    case Nil{}:
      missing()
    case Con{d, rest}:
      kc(KDef, String.eq(dk(d), "BookCache"), u => index_lookup(d, name), u => kc(KDef, String.eq(dn(d), name), u => d, u => lookup(rest, name)))

# Module: src/core/term.bend:297
@unsafe
def terms_len(ts):
  match ts:
    case Nil{}:
      0
    case Con{h, t}:
      U32.add(1, terms_len(t))

# Module: src/core/term.bend:310
@unsafe
def has_name(ns, name):
  match ns:
    case Nil{}:
      False{}
    case Con{h, t}:
      kc(Bool, String.eq(h, name), u => True{}, u => has_name(t, name))

# Module: src/core/term.bend:349
@unsafe
def subst(t, id, v):
  kc(KTerm, String.eq(tg(t), "Var"), u => kc(KTerm, U32.is_eq(ix(t), id), u => v, u => t), u => subst_node(t, id, v))

# Module: src/core/term.bend:353
@unsafe
def subst_node(t, id, v):
  match t:
    case KTerm{tag, name, n, q, kids, removed}:
      core_rebuild(KTerm{tag, name, n, q, subst_terms(kids, id, v), removed})

# Module: src/core/term.bend:359
@unsafe
def subst_terms(ts, id, v):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{subst(h, id, v), subst_terms(t, id, v)}

# Module: src/core/term.bend:368
@unsafe
def core_force(t):
  kc(KTerm, String.eq(tg(t), "Ann"), u => core_force(kid(t, 0)),
    u => kc(KTerm, String.eq(tg(t), "Var") && U32.is_gt(terms_len(ks(t)), 0), u => core_force(kid(t, 0)), u => t))

# Module: src/core/term.bend:373
@unsafe
def core_rebuild(t):
  kc(KTerm, String.eq(tg(t), "App"), u => core_apply(kid(t, 0), kid(t, 1)), u => t)

# Module: src/core/term.bend:377
@unsafe
def core_apply(f, x):
  kc(KTerm, String.eq(tg(f), "Lam"), u => subst(kid(f, 0), ix(f), x), u => app(f, x))

# Module: src/core/term.bend:385
@unsafe
def core_beta(t):
  kc(KTerm, String.eq(tg(t), "App"), u => core_apply(core_beta(kid(t, 0)), kid(t, 1)), u => t)

# Module: src/core/index.bend:75
@unsafe
def index_hash(name, acc):
  match name:
    case SNil{}:
      acc
    case SCon{h, rest}:
      index_hash(rest, U32.mul(U32.xor(acc, Char.to_u32(h)), 16777619))

# Module: src/core/index.bend:83
@unsafe
def index_child(tree, right):
  index_child_list(dc(tree), right)

# Module: src/core/index.bend:87
@unsafe
def index_child_list(ds, right):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, right, u => index_first(rest), u => h)

# Module: src/core/index.bend:95
@unsafe
def index_first(ds):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      h

# Module: src/core/index.bend:103
@unsafe
def index_find(tree, name, hash, bits):
  kc(KDef, String.eq(dk(tree), "Absent"), u => missing(), u => kc(KDef, U32.is_eq(bits, 0), u => index_bucket(dc(tree), name), u => index_find(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, 1), 0))), name, U32.shr(hash), U32.sub(bits, 1))))

# Module: src/core/index.bend:107
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, String.eq(dn(h), name), u => h, u => index_bucket(rest, name))

# Module: src/core/index.bend:115
@unsafe
def index_remove(ds, name):
  match ds:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      kc(List<&2, KDef>, String.eq(dn(h), name), u => index_remove(rest, name), u => Con{h, index_remove(rest, name)})

# Module: src/core/index.bend:123
@unsafe
def index_set(tree, d, hash, bits):
  kc(KDef, U32.is_eq(bits, 0), u => KDef{"", "IndexLeaf", 0, 0, atom("Absent"), atom("Absent"), Con{d, index_remove(dc(tree), dn(d))}, True{}, False{}}, u => index_set_node(tree, d, hash, bits, Bool.not(U32.is_eq(U32.and(hash, 1), 0))))

# Module: src/core/index.bend:127
@unsafe
def index_set_node(tree, d, hash, bits, right):
  KDef{"", "IndexNode", 0, 0, atom("Absent"), atom("Absent"), Con{kc(KDef, right, u => index_child(tree, False{}), u => index_set(index_child(tree, False{}), d, U32.shr(hash), U32.sub(bits, 1))), Con{kc(KDef, right, u => index_set(index_child(tree, True{}), d, U32.shr(hash), U32.sub(bits, 1)), u => index_child(tree, True{})), Nil{}}}, True{}, False{}}

# Module: src/core/index.bend:131
@unsafe
def index_build(book):
  match book:
    case Nil{}:
      missing()
    case Con{h, rest}:
      index_set(index_build(rest), h, index_hash(dn(h), 2166136261), 32)

# Module: src/core/index.bend:139
@unsafe
def index_lookup(cache, name):
  index_find(index_first(dc(cache)), name, index_hash(name, 2166136261), 32)

# Module: src/core/index.bend:143
@unsafe
def book_cached(book, bound):
  Con{KDef{"$kernel.cache", "BookCache", bound, 0, atom("Absent"), atom("Absent"), Con{index_build(book), Nil{}}, True{}, False{}}, book}

# Module: src/core/index.bend:147
@unsafe
def book_put(book, d):
  match book:
    case Nil{}:
      Con{d, Nil{}}
    case Con{h, rest}:
      kc(List<&2, KDef>, String.eq(dk(h), "BookCache"), u => Con{KDef{dn(h), dk(h), da(h), 0, atom("Absent"), atom("Absent"), Con{index_set(index_first(dc(h)), d, index_hash(dn(d), 2166136261), 32), Nil{}}, True{}, False{}}, Con{d, index_remove(rest, dn(d))}}, u => Con{d, index_remove(book, dn(d))})


# An immutable context may be reused by several backend phases. Never nest the
# sentinel or recompute its maximum binder ID from the index's implementation.

# Module: src/core/index.bend:162
@unsafe
def book_context(book):
  match book:
    case Nil{}:
      book_cached(book, 0)
    case Con{h, rest}:
      kc(List<&2, KDef>, String.eq(dk(h), "BookCache"), u => book, u => book_cached(book, norm_max_book(book)))

# Module: src/core/normalize.bend:11
@unsafe
def norm_join(a, b):
  match a:
    case Nil{}:
      b
    case Con{h, t}:
      Con{h, norm_join(t, b)}

# Module: src/core/normalize.bend:24
@unsafe
def norm_apply(t, args):
  match args:
    case Nil{}:
      t
    case Con{h, rest}:
      norm_apply(app(t, h), rest)

# Module: src/core/normalize.bend:37
@unsafe
def wnf(book, t):
  norm_eval(book, t, Nil{}, 0, atom("Absent"))

# Module: src/core/normalize.bend:57
@unsafe
def norm_eval_node(book, t, args, left, fallback):
  kc(KTerm, String.eq(tg(t), "App"), u => norm_eval(book, kid(t, 0), Con{kid(t, 1), args}, left, fallback), u => kc(KTerm, String.eq(tg(t), "Ann"), u => norm_eval(book, kid(t, 0), args, left, fallback), u => kc(KTerm, String.eq(tg(t), "Let"), u => norm_eval(book, norm_let(ks(t)), args, left, fallback), u => kc(KTerm, String.eq(tg(t), "Ref"), u => norm_ref(book, t, args, lookup(book, nm(t))), u => kc(KTerm, String.eq(tg(t), "Min"), u => norm_apply(norm_min(book, kid(t, 0), kid(t, 1)), args), u => kc(KTerm, String.eq(tg(t), "Rwt"), u => kc(KTerm, String.eq(tg(wnf(book, kid(t, 0))), "Rfl"), u => norm_eval(book, kid(t, 2), args, left, fallback), u => norm_apply(t, args)), u => norm_args(book, t, args, left, fallback)))))))

# Module: src/core/normalize.bend:67
@unsafe
def norm_ref(book, t, args, d):
  kc(KTerm, String.eq(dk(d), "ADT"), u => kc(KTerm, U32.is_eq(da(d), 0), u => norm_apply(kt("ADT", nm(t), 0, 0, Nil{}), args), u => norm_apply(t, args)), u => kc(KTerm, Bool.and(Bool.not(String.eq(tg(dv(d)), "Absent") || String.eq(tg(dv(d)), "Foreign")), U32.is_le(da(d), terms_len(args))), u => norm_eval(book, dv(d), args, da(d), norm_apply(t, args)), u => norm_apply(t, args)))

# Module: src/core/normalize.bend:78
@unsafe
def norm_args(book, t, args, left, fallback):
  match args:
    case Nil{}:
      t
    case Con{x, rest}:
      kc(KTerm, String.eq(tg(t), "Lam"), u => norm_eval(book, subst(kid(t, 0), ix(t), x), rest, norm_dec(left), fallback), u => kc(KTerm, String.eq(tg(t), "Mat"), u => norm_match(book, t, t, x, wnf(book, x), rest, left, fallback), u => kc(KTerm, Bool.and(String.eq(tg(t), "Efq"), Bool.not(U32.is_eq(left, 0))), u => fallback, u => norm_apply(t, args))))

# Module: src/core/normalize.bend:89
@unsafe
def norm_dec(n):
  kc(U32, U32.is_eq(n, 0), u => 0, u => U32.sub(n, 1))

# Module: src/core/normalize.bend:103
@unsafe
def norm_match(book, arm, original, raw, x, args, left, fallback):
  kc(KTerm, String.eq(tg(x), "Ctr"), u => kc(KTerm, String.eq(tg(arm), "Ann"), u => norm_match(book, kid(arm, 0), original, raw, x, args, left, fallback), u => kc(KTerm, String.eq(tg(arm), "Mat"), u => kc(KTerm, String.eq(nm(arm), nm(x)), u => kc(KTerm, U32.is_eq(left, 0), u => norm_eval(book, kid(arm, 0), norm_join(ks(x), args), 0, fallback), u => norm_eval(book, kid(arm, 0), norm_join(ks(x), args), U32.add(norm_dec(left), terms_len(ks(x))), fallback)), u => norm_match(book, kid(arm, 1), original, raw, x, args, left, fallback)), u => kc(KTerm, String.eq(tg(arm), "Efq"), u => norm_stuck(original, raw, args, left, fallback), u => norm_eval(book, arm, Con{x, args}, left, fallback)))), u => norm_stuck(original, raw, args, left, fallback))

# Module: src/core/normalize.bend:114
@unsafe
def norm_stuck(t, x, args, left, fallback):
  kc(KTerm, U32.is_eq(left, 0), u => norm_apply(app(t, x), args), u => fallback)

# Module: src/core/normalize.bend:123
@unsafe
def norm_min(book, a, b):
  norm_min_left(book, wnf(book, a), b)

# Module: src/core/normalize.bend:133
@unsafe
def norm_min_left(book, a, b):
  kc(KTerm, Bool.and(String.eq(tg(a), "Qua"), U32.is_eq(qt(a), 2)), u => wnf(book, b), u => kc(KTerm, Bool.and(String.eq(tg(a), "Qua"), U32.is_eq(qt(a), 0)), u => a, u => norm_min_right(a, wnf(book, b))))

# Module: src/core/normalize.bend:141
@unsafe
def norm_min_right(a, b):
  kc(KTerm, String.eq(tg(b), "Qua"), u => kc(KTerm, U32.is_eq(qt(b), 2), u => a, u => kc(KTerm, Bool.and(U32.is_eq(qt(b), 1), Bool.not(String.eq(tg(a), "Qua"))), u => kt("Min", "", 0, 0, Con{a, Con{b, Nil{}}}), u => b)), u => kt("Min", "", 0, 0, Con{a, Con{b, Nil{}}}))

# Module: src/core/normalize.bend:149
@unsafe
def strong(book, t):
  graph_strong(book, t)

# Module: src/core/normalize.bend:158
@unsafe
def norm_strong(book, t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      KTerm{tag, name, id, quant, norm_strongs(book, kids), removed}

# Module: src/core/normalize.bend:169
@unsafe
def norm_strongs(book, ts):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{strong(book, h), norm_strongs(book, t)}

# Module: src/core/normalize.bend:182
@unsafe
def norm_max(a, b):
  kc(U32, U32.is_le(a, b), u => b, u => a)

# Module: src/core/normalize.bend:189
@unsafe
def norm_max_term(t):
  norm_max_walk(Con{t, Nil{}}, 0)

# Module: src/core/normalize.bend:197
@unsafe
def norm_max_terms(ts):
  norm_max_walk(ts, 0)

# Module: src/core/normalize.bend:205
@unsafe
def norm_max_book(book):
  norm_max_defs(book, 0)

# Module: src/core/normalize.bend:216
@unsafe
def compare(book, a, b, le):
  norm_compare(book, a, b, le, U32.add(1, norm_max(norm_book_bound(book), norm_max(norm_max_term(a), norm_max_term(b)))))

# Module: src/core/normalize.bend:228
@unsafe
def norm_compare(book, a, b, le, fresh):
  kc(Bool, norm_exact(a, b), u => True{}, u => norm_cmp_loop(book, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}))

# Module: src/core/normalize.bend:240
@unsafe
def norm_compare_heads(book, a, b, le, fresh):
  kc(Bool, Bool.or(String.eq(tg(a), "Lam"), String.eq(tg(b), "Lam")), u => norm_compare(book, app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.add(fresh, 1)), u => kc(Bool, String.eq(tg(a), tg(b)), u => norm_compare_same(book, a, b, le, fresh), u => False{}))

# Module: src/core/normalize.bend:251
@unsafe
def norm_compare_same(book, a, b, le, fresh):
  kc(Bool, String.eq(tg(a), "Var"), u => U32.is_eq(ix(a), ix(b)), u => kc(Bool, String.eq(tg(a), "Typ"), u => kc(Bool, le, u => norm_kind(book, a, b, wnf(book, kid(a, 0)), wnf(book, kid(b, 0)), fresh), u => norm_compare(book, kid(a, 0), kid(b, 0), False{}, fresh)), u => kc(Bool, String.eq(tg(a), "All"), u => Bool.and(U32.is_eq(qt(a), qt(b)), Bool.and(norm_compare(book, kid(b, 0), kid(a, 0), le, fresh), norm_compare(book, subst(kid(a, 1), ix(a), var("_", fresh)), subst(kid(b, 1), ix(b), var("_", fresh)), le, U32.add(fresh, 1)))), u => kc(Bool, String.eq(tg(a), "ADT"), u => Bool.and(String.eq(nm(a), nm(b)), Bool.and(norm_removed(rm(a), rm(b), le), norm_compare_terms(book, ks(a), ks(b), fresh))), u => kc(Bool, String.eq(tg(a), "Qua"), u => U32.is_eq(qt(a), qt(b)), u => norm_compare_plain(book, a, b, fresh))))))

# Module: src/core/normalize.bend:261
@unsafe
def norm_compare_plain(book, a, b, fresh):
  kc(Bool, Bool.or(String.eq(tg(a), "Ref"), String.eq(tg(a), "Hol")), u => String.eq(nm(a), nm(b)), u => kc(Bool, Bool.or(String.eq(tg(a), "Ctr"), String.eq(tg(a), "Mat")), u => Bool.and(String.eq(nm(a), nm(b)), norm_compare_terms(book, ks(a), ks(b), fresh)), u => kc(Bool, Bool.or(Bool.or(String.eq(tg(a), "App"), String.eq(tg(a), "Min")), Bool.or(String.eq(tg(a), "Eql"), String.eq(tg(a), "Rwt"))), u => norm_compare_terms(book, ks(a), ks(b), fresh), u => Bool.or(String.eq(tg(a), "Qnt"), Bool.or(String.eq(tg(a), "Rfl"), String.eq(tg(a), "Efq"))))))

# Module: src/core/normalize.bend:271
@unsafe
def norm_compare_terms(book, as, bs, fresh):
  match as:
    case Nil{}:
      match bs:
        case Nil{}:
          True{}
        case Con{h, t}:
          False{}
    case Con{ah, at}:
      match bs:
        case Nil{}:
          False{}
        case Con{bh, bt}:
          Bool.and(norm_compare(book, ah, bh, False{}, fresh), norm_compare_terms(book, at, bt, fresh))

# Module: src/core/normalize.bend:292
@unsafe
def norm_subset(as, bs):
  match bs:
    case Nil{}:
      True{}
    case Con{h, t}:
      Bool.and(has_name(as, h), norm_subset(as, t))

# Module: src/core/normalize.bend:306
@unsafe
def norm_removed(as, bs, le):
  kc(Bool, le, u => norm_subset(as, bs), u => Bool.and(U32.is_eq(norm_names_len(as), norm_names_len(bs)), norm_subset(as, bs)))

# Module: src/core/normalize.bend:318
@unsafe
def norm_kind(book, a, b, g, h, fresh):
  kc(Bool, Bool.or(Bool.and(String.eq(tg(g), "Qua"), U32.is_eq(qt(g), 2)), Bool.and(String.eq(tg(h), "Qua"), Bool.not(U32.is_eq(qt(h), 2)))), u => True{}, u => kc(Bool, String.eq(tg(g), "Min"), u => Bool.and(norm_compare(book, kt("Typ", "", 0, 0, Con{kid(g, 0), Nil{}}), b, True{}, fresh), norm_compare(book, kt("Typ", "", 0, 0, Con{kid(g, 1), Nil{}}), b, True{}, fresh)), u => kc(Bool, String.eq(tg(h), "Min"), u => Bool.or(norm_compare(book, a, kt("Typ", "", 0, 0, Con{kid(h, 0), Nil{}}), True{}, fresh), norm_compare(book, a, kt("Typ", "", 0, 0, Con{kid(h, 1), Nil{}}), True{}, fresh)), u => norm_compare(book, g, h, True{}, fresh))))

# Module: src/core/normalize.bend:325
@unsafe
def norm_let(ts):
  match ts:
    case Nil{}:
      atom("Absent")
    case Con{h, rest}:
      norm_let_tail(h, rest)

# Module: src/core/normalize.bend:338
@unsafe
def norm_let_tail(h, rest):
  match rest:
    case Nil{}:
      h
    case Con{x, xs}:
      subst(norm_let(rest), ix(h), kid(h, 0))

# Module: src/core/normalize.bend:347
@unsafe
def norm_eval(book, t, args, left, fallback):
  kc(KTerm, String.eq(tg(t), "Var"), u => norm_var(book, t, ks(t), args, left, fallback), u => norm_eval_node(book, t, args, left, fallback))

# Module: src/core/normalize.bend:360
@unsafe
def norm_var(book, t, values, args, left, fallback):
  match values:
    case Nil{}:
      norm_apply(t, args)
    case Con{h, rest}:
      norm_eval(book, h, args, left, fallback)

# Module: src/core/normalize.bend:372
@unsafe
def norm_names_len(names):
  match names:
    case Nil{}:
      0
    case Con{h, rest}:
      U32.add(1, norm_names_len(rest))

# The book checker computes this immutable bound once per source book. Public
# callers without a stamp retain the complete scan, so fresh IDs stay sound.

# Module: src/core/normalize.bend:391
@unsafe
def norm_book_bound(book):
  match book:
    case Nil{}:
      0
    case Con{h, rest}:
      kc(U32, String.eq(dk(h), "BookCache"), u => da(h), u => norm_bound_found(book, lookup(book, "$kernel.max-id")))

# Module: src/core/normalize.bend:399
@unsafe
def norm_bound_found(book, stamp):
  kc(U32, String.eq(dk(stamp), "BookBound"), u => da(stamp), u => norm_max_book(book))

# Strong normalization uses an explicit traversal stack. Each opened binder
# receives a fresh identity even when the same recursive definition unfolds
# repeatedly underneath another copy of its binder.

# Module: src/core/normalize.bend:466
@unsafe
def norm_max_walk(todo, bound):
  match todo:
    case Nil{}:
      bound
    case Con{h, rest}:
      norm_max_walk(norm_join(ks(h), rest), norm_max(bound, ix(h)))

# Module: src/core/normalize.bend:474
@unsafe
def norm_max_defs(todo, bound):
  match todo:
    case Nil{}:
      bound
    case Con{h, rest}:
      norm_max_defs(norm_defs_join(dc(h), rest), norm_max(bound, norm_max(norm_max_term(dt(h)), norm_max_term(dv(h)))))

# Module: src/core/normalize.bend:482
@unsafe
def norm_defs_join(a, b):
  match a:
    case Nil{}:
      b
    case Con{h, rest}:
      Con{h, norm_defs_join(rest, b)}

# Module: src/core/normalize.bend:490
@unsafe
def norm_snf_go(book, t, stack, fresh):
  norm_snf_head(book, wnf(book, t), stack, fresh)

# Module: src/core/normalize.bend:494
@unsafe
def norm_snf_head(book, t, stack, fresh):
  kc(KTerm, String.eq(tg(t), "Lam") || String.eq(tg(t), "All"), u => norm_snf_open(book, norm_rebind(t, fresh), stack, U32.add(fresh, 1)), u => norm_snf_open(book, t, stack, fresh))

# Module: src/core/normalize.bend:498
@unsafe
def norm_rebind(t, fresh):
  KTerm{tg(t), nm(t), fresh, qt(t), kc(List<&2, KTerm>, String.eq(tg(t), "Lam"), u => Con{subst(kid(t, 0), ix(t), var(nm(t), fresh)), Nil{}}, u => Con{kid(t, 0), Con{subst(kid(t, 1), ix(t), var(nm(t), fresh)), Nil{}}}), rm(t)}

# Module: src/core/normalize.bend:502
@unsafe
def norm_snf_open(book, t, stack, fresh):
  norm_snf_children(book, t, Nil{}, ks(t), stack, fresh)

# Module: src/core/normalize.bend:506
@unsafe
def norm_snf_children(book, parent, done, todo, stack, fresh):
  match todo:
    case Nil{}:
      norm_snf_return(book, KTerm{tg(parent), nm(parent), ix(parent), qt(parent), List.reverse(&2, KTerm, done), rm(parent)}, stack, fresh)
    case Con{h, rest}:
      norm_snf_go(book, h, Con{KNormFrame{parent, done, rest}, stack}, fresh)

# Module: src/core/normalize.bend:514
@unsafe
def norm_snf_return(book, t, stack, fresh):
  match stack:
    case Nil{}:
      t
    case Con{KNormFrame{parent, done, todo}, rest}:
      norm_snf_children(book, parent, Con{t, done}, todo, rest, fresh)

# Syntactic reflexivity precedes evaluation, as pointer reflexivity does in
# upstream. Cell contents are included; different stored values never match.

# Module: src/core/normalize.bend:544
@unsafe
def norm_exact(a, b):
  norm_exact_lists(Con{a, Nil{}}, Con{b, Nil{}})

# Module: src/core/normalize.bend:548
@unsafe
def norm_exact_lists(as, bs):
  match as bs:
    case Nil{} Nil{}:
      True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, norm_exact_head(a, b), u => norm_exact_lists(norm_join(ks(a), ar), norm_join(ks(b), br)), u => False{})
    case other_a other_b:
      False{}

# Module: src/core/normalize.bend:558
@unsafe
def norm_exact_head(a, b):
  String.eq(tg(a), tg(b)) && String.eq(nm(a), nm(b)) && U32.is_eq(ix(a), ix(b)) && U32.is_eq(qt(a), qt(b)) && U32.is_eq(terms_len(ks(a)), terms_len(ks(b))) && norm_exact_names(rm(a), rm(b))

# Module: src/core/normalize.bend:562
@unsafe
def norm_exact_names(as, bs):
  match as bs:
    case Nil{} Nil{}:
      True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, String.eq(a, b), u => norm_exact_names(ar, br), u => False{})
    case other_a other_b:
      False{}

# Comparison is a worklist of conjunctions with explicit alternatives for
# the right-hand kind meet. Deep constructor equality does not grow the host stack.

# Module: src/core/normalize.bend:658
@unsafe
def norm_cmp_loop(book, todo, alts):
  match todo:
    case Nil{}:
      True{}
    case Con{KNormCmp{a, b, le, fresh}, rest}:
      kc(Bool, norm_cmp_quick(a, b), u => norm_cmp_loop(book, rest, alts), u => norm_cmp_heads(book, wnf(book, a), wnf(book, b), le, fresh, rest, alts))

# Module: src/core/normalize.bend:666
@unsafe
def norm_cmp_quick(a, b):
  kc(Bool, String.eq(tg(a), "App") || String.eq(tg(a), "Ref") || String.eq(tg(a), "Var"), u => norm_exact(a, b), u => False{})

# Module: src/core/normalize.bend:670
@unsafe
def norm_cmp_fail(book, alts):
  match alts:
    case Nil{}:
      False{}
    case Con{KNormAlt{todo}, rest}:
      norm_cmp_loop(book, todo, rest)

# Module: src/core/normalize.bend:678
@unsafe
def norm_cmp_test(book, yes, rest, alts):
  kc(Bool, yes, u => norm_cmp_loop(book, rest, alts), u => norm_cmp_fail(book, alts))

# Module: src/core/normalize.bend:682
@unsafe
def norm_cmp_heads(book, a, b, le, fresh, rest, alts):
  kc(Bool, String.eq(tg(a), "Lam") || String.eq(tg(b), "Lam"),
   u => norm_cmp_loop(book, Con{KNormCmp{app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.add(fresh, 1)}, rest}, alts),
   u => kc(Bool, String.eq(tg(a), tg(b)), u => norm_cmp_same(book, a, b, le, fresh, rest, alts), u => norm_cmp_fail(book, alts)))

# Module: src/core/normalize.bend:688
@unsafe
def norm_cmp_same(book, a, b, le, fresh, rest, alts):
  kc(Bool, String.eq(tg(a), "Var"), u => norm_cmp_test(book, U32.is_eq(ix(a), ix(b)), rest, alts),
   u => kc(Bool, String.eq(tg(a), "Typ"), u => kc(Bool, le, u => norm_cmp_kind(book, a, b, wnf(book, kid(a, 0)), wnf(book, kid(b, 0)), fresh, rest, alts), u => norm_cmp_loop(book, Con{KNormCmp{kid(a, 0), kid(b, 0), False{}, fresh}, rest}, alts)),
   u => kc(Bool, String.eq(tg(a), "All"), u => kc(Bool, U32.is_eq(qt(a), qt(b)),
     u => norm_cmp_loop(book, Con{KNormCmp{kid(b, 0), kid(a, 0), le, fresh}, Con{KNormCmp{subst(kid(a, 1), ix(a), var("_", fresh)), subst(kid(b, 1), ix(b), var("_", fresh)), le, U32.add(fresh, 1)}, rest}}, alts), u => norm_cmp_fail(book, alts)),
   u => kc(Bool, String.eq(tg(a), "ADT"), u => kc(Bool, String.eq(nm(a), nm(b)) && norm_removed(rm(a), rm(b), le), u => norm_cmp_fields(book, ks(a), ks(b), fresh, rest, alts), u => norm_cmp_fail(book, alts)),
   u => kc(Bool, String.eq(tg(a), "Qua"), u => norm_cmp_test(book, U32.is_eq(qt(a), qt(b)), rest, alts),
   u => norm_cmp_plain(book, a, b, fresh, rest, alts))))))

# Module: src/core/normalize.bend:698
@unsafe
def norm_cmp_plain(book, a, b, fresh, rest, alts):
  kc(Bool, String.eq(tg(a), "Ref") || String.eq(tg(a), "Hol"), u => norm_cmp_test(book, String.eq(nm(a), nm(b)), rest, alts),
   u => kc(Bool, String.eq(tg(a), "Ctr") || String.eq(tg(a), "Mat"), u => kc(Bool, String.eq(nm(a), nm(b)), u => norm_cmp_fields(book, ks(a), ks(b), fresh, rest, alts), u => norm_cmp_fail(book, alts)),
   u => kc(Bool, String.eq(tg(a), "App") || String.eq(tg(a), "Min") || String.eq(tg(a), "Eql") || String.eq(tg(a), "Rwt"), u => norm_cmp_fields(book, ks(a), ks(b), fresh, rest, alts),
   u => norm_cmp_test(book, String.eq(tg(a), "Qnt") || String.eq(tg(a), "Rfl") || String.eq(tg(a), "Efq"), rest, alts))))

# Module: src/core/normalize.bend:705
@unsafe
def norm_cmp_fields(book, as, bs, fresh, rest, alts):
  kc(Bool, U32.is_eq(terms_len(as), terms_len(bs)), u => norm_cmp_loop(book, norm_cmp_zip(as, bs, fresh, rest), alts), u => norm_cmp_fail(book, alts))

# Module: src/core/normalize.bend:709
@unsafe
def norm_cmp_zip(as, bs, fresh, rest):
  match as bs:
    case Con{a, ar} Con{b, br}:
      Con{KNormCmp{a, b, False{}, fresh}, norm_cmp_zip(ar, br, fresh, rest)}
    case other_a other_b:
      rest

# Module: src/core/normalize.bend:717
@unsafe
def norm_cmp_kind(book, a, b, g, h, fresh, rest, alts):
  kc(Bool, (String.eq(tg(g), "Qua") && U32.is_eq(qt(g), 2)) || (String.eq(tg(h), "Qua") && Bool.not(U32.is_eq(qt(h), 2))), u => norm_cmp_loop(book, rest, alts),
   u => kc(Bool, String.eq(tg(g), "Min"),
     u => norm_cmp_loop(book, Con{KNormCmp{kt("Typ", "", 0, 0, Con{kid(g, 0), Nil{}}), b, True{}, fresh}, Con{KNormCmp{kt("Typ", "", 0, 0, Con{kid(g, 1), Nil{}}), b, True{}, fresh}, rest}}, alts),
   u => kc(Bool, String.eq(tg(h), "Min"),
     u => norm_cmp_loop(book, Con{KNormCmp{a, kt("Typ", "", 0, 0, Con{kid(h, 0), Nil{}}), True{}, fresh}, rest}, Con{KNormAlt{Con{KNormCmp{a, kt("Typ", "", 0, 0, Con{kid(h, 1), Nil{}}), True{}, fresh}, rest}}, alts}),
     u => norm_cmp_loop(book, Con{KNormCmp{g, h, True{}, fresh}, rest}, alts))))

# Module: src/core/graph.bend:280
@unsafe
def g_heap(st):
  match st:
    case GState{heap, next}:
      heap

# Module: src/core/graph.bend:286
@unsafe
def g_next(st):
  match st:
    case GState{heap, next}:
      next

# Module: src/core/graph.bend:292
@unsafe
def g_state(r):
  match r:
    case GResult{state, term}:
      state

# Module: src/core/graph.bend:298
@unsafe
def g_term(r):
  match r:
    case GResult{state, term}:
      term

# Module: src/core/graph.bend:304
@unsafe
def g_states(r):
  match r:
    case GTerms{state, terms}:
      state

# Module: src/core/graph.bend:310
@unsafe
def g_terms(r):
  match r:
    case GTerms{state, terms}:
      terms

# Module: src/core/graph.bend:316
@unsafe
def g_get(heap, id):
  match heap:
    case GEmpty{}:
      atom("Absent")
    case GNode{value, left, right}:
      kc(KTerm, U32.is_eq(id, 0), u => value, u => kc(KTerm, U32.is_eq(U32.and(id, 1), 0), u => g_get(left, U32.shr(id)), u => g_get(right, U32.shr(id))))

# Module: src/core/graph.bend:324
@unsafe
def g_put(heap, id, value):
  match heap:
    case GEmpty{}:
      g_put_node(atom("Absent"), GEmpty{}, GEmpty{}, id, value)
    case GNode{old, left, right}:
      g_put_node(old, left, right, id, value)

# Module: src/core/graph.bend:332
@unsafe
def g_put_node(old, left, right, id, value):
  kc(GHeap, U32.is_eq(id, 0), u => GNode{value, left, right}, u => kc(GHeap, U32.is_eq(U32.and(id, 1), 0), u => GNode{old, g_put(left, U32.shr(id), value), right}, u => GNode{old, left, g_put(right, U32.shr(id), value)}))

# Module: src/core/graph.bend:336
@unsafe
def g_share(st, t):
  kc(GResult, String.eq(tg(t), "GCell"), u => GResult{st, t}, u => GResult{GState{g_put(g_heap(st), g_next(st), kt("GThunk", "", 0, 0, Con{t, Nil{}})), U32.add(g_next(st), 1)}, kt("GCell", "", g_next(st), 0, Nil{})})

# Module: src/core/graph.bend:340
@unsafe
def g_share_terms(st, ts, done):
  match ts:
    case Nil{}:
      GTerms{st, List.reverse(&2, KTerm, done)}
    case Con{h, rest}:
      g_shared_term(rest, done, g_share(st, h))

# Module: src/core/graph.bend:348
@unsafe
def g_shared_term(rest, done, r):
  g_share_terms(g_state(r), rest, Con{g_term(r), done})

# Module: src/core/graph.bend:352
@unsafe
def g_share_head(st, t):
  kc(GResult, String.eq(tg(t), "Ctr") || String.eq(tg(t), "ADT") || String.eq(tg(t), "Mat") || String.eq(tg(t), "Eql") || String.eq(tg(t), "Min") || String.eq(tg(t), "Typ"), u => g_shared_head(t, g_share_terms(st, ks(t), Nil{})), u => GResult{st, t})

# Module: src/core/graph.bend:356
@unsafe
def g_shared_head(t, r):
  GResult{g_states(r), KTerm{tg(t), nm(t), ix(t), qt(t), g_terms(r), rm(t)}}

# Module: src/core/graph.bend:360
@unsafe
def g_cache(st, id, t):
  GState{g_put(g_heap(st), id, kt("GValue", "", 0, 0, Con{t, Nil{}})), g_next(st)}

# Module: src/core/graph.bend:364
@unsafe
def g_wnf(book, st, t):
  g_eval(book, st, t, Nil{}, 0, atom("Absent"), Nil{})

# Module: src/core/graph.bend:368
@unsafe
def g_eval(book, st, t, args, pending, fallback, stack):
  kc(GResult, String.eq(tg(t), "GCell"), u => g_cell(book, st, t, args, pending, fallback, stack, g_get(g_heap(st), ix(t))),
   u => kc(GResult, String.eq(tg(t), "App"), u => g_app(book, kid(t, 0), args, pending, fallback, stack, g_share(st, kid(t, 1))),
   u => kc(GResult, String.eq(tg(t), "Ann"), u => g_eval(book, st, kid(t, 0), args, pending, fallback, stack),
   u => kc(GResult, String.eq(tg(t), "Var") && U32.is_gt(terms_len(ks(t)), 0), u => g_eval(book, st, kid(t, 0), args, pending, fallback, stack),
   u => kc(GResult, String.eq(tg(t), "Let"), u => g_let(book, st, ks(t), Nil{}, args, pending, fallback, stack),
   u => kc(GResult, String.eq(tg(t), "Ref"), u => g_ref(book, st, t, args, stack, lookup(book, nm(t))),
   u => kc(GResult, String.eq(tg(t), "Min"), u => g_eval(book, st, kid(t, 0), Nil{}, 0, atom("Absent"), Con{GMinA{kid(t, 1), args}, stack}),
   u => kc(GResult, String.eq(tg(t), "Rwt"), u => g_eval(book, st, kid(t, 0), Nil{}, 0, atom("Absent"), Con{GRewrite{t, args, pending, fallback}, stack}),
   u => g_args(book, st, t, args, pending, fallback, stack)))))))))

# Module: src/core/graph.bend:380
@unsafe
def g_cell(book, st, t, args, pending, fallback, stack, cell):
  kc(GResult, String.eq(tg(cell), "GValue"), u => g_eval(book, st, kid(cell, 0), args, pending, fallback, stack), u => g_eval(book, st, kid(cell, 0), Nil{}, 0, atom("Absent"), Con{GFill{ix(t), args, pending, fallback}, stack}))

# Module: src/core/graph.bend:384
@unsafe
def g_app(book, fn, args, pending, fallback, stack, r):
  g_eval(book, g_state(r), fn, Con{g_term(r), args}, pending, fallback, stack)

# Module: src/core/graph.bend:388
@unsafe
def g_ref(book, st, t, args, stack, d):
  kc(GResult, String.eq(dk(d), "ADT"), u => g_return(book, st, norm_apply(kc(KTerm, U32.is_eq(da(d), 0), u => kt("ADT", nm(t), 0, 0, Nil{}), u => t), args), stack),
   u => kc(GResult, Bool.not(String.eq(tg(dv(d)), "Absent") || String.eq(tg(dv(d)), "Foreign")) && U32.is_le(da(d), terms_len(args)), u => g_eval(book, st, dv(d), args, da(d), norm_apply(t, args), stack), u => g_return(book, st, norm_apply(t, args), stack)))

# Module: src/core/graph.bend:393
@unsafe
def g_args(book, st, t, args, pending, fallback, stack):
  match args:
    case Nil{}:
      g_return(book, st, t, stack)
    case Con{x, rest}:
      kc(GResult, String.eq(tg(t), "Lam"), u => g_eval(book, st, subst(kid(t, 0), ix(t), x), rest, norm_dec(pending), fallback, stack),
       u => kc(GResult, String.eq(tg(t), "Mat"), u => g_eval(book, st, x, Nil{}, 0, atom("Absent"), Con{GMatch{t, x, rest, pending, fallback}, stack}),
       u => g_return(book, st, kc(KTerm, String.eq(tg(t), "Efq") && U32.is_gt(pending, 0), u => fallback, u => norm_apply(t, args)), stack)))

# Module: src/core/graph.bend:403
@unsafe
def g_return(book, st, t, stack):
  match stack:
    case Nil{}:
      GResult{st, t}
    case Con{frame, rest}:
      g_resume(book, st, t, frame, rest)

# Module: src/core/graph.bend:411
@unsafe
def g_resume(book, st, t, frame, stack):
  match frame:
    case GFill{id, args, pending, fallback}:
      g_filled(book, id, args, pending, fallback, stack, g_share_head(st, t))
    case GMatch{arm, raw, args, pending, fallback}:
      g_match(book, st, arm, arm, raw, t, args, pending, fallback, stack)
    case GMinA{other, args}:
      g_min_left(book, st, t, other, args, stack)
    case GMinB{other, args}:
      g_return(book, st, norm_apply(norm_min_right(other, t), args), stack)
    case GRewrite{original, args, pending, fallback}:
      kc(GResult, String.eq(tg(t), "Rfl"), u => g_eval(book, st, kid(original, 2), args, pending, fallback, stack), u => g_return(book, st, norm_apply(original, args), stack))

# Module: src/core/graph.bend:425
@unsafe
def g_filled(book, id, args, pending, fallback, stack, r):
  g_eval(book, g_cache(g_state(r), id, g_term(r)), g_term(r), args, pending, fallback, stack)

# Module: src/core/graph.bend:429
@unsafe
def g_min_left(book, st, a, b, args, stack):
  kc(GResult, String.eq(tg(a), "Qua") && U32.is_eq(qt(a), 2), u => g_eval(book, st, b, args, 0, atom("Absent"), stack),
   u => kc(GResult, String.eq(tg(a), "Qua") && U32.is_eq(qt(a), 0), u => g_return(book, st, norm_apply(a, args), stack), u => g_eval(book, st, b, Nil{}, 0, atom("Absent"), Con{GMinB{a, args}, stack})))

# Module: src/core/graph.bend:434
@unsafe
def g_match(book, st, arm, original, raw, x, args, pending, fallback, stack):
  kc(GResult, Bool.not(String.eq(tg(x), "Ctr")), u => g_return(book, st, norm_stuck(original, raw, args, pending, fallback), stack),
   u => kc(GResult, String.eq(tg(arm), "Ann"), u => g_match(book, st, kid(arm, 0), original, raw, x, args, pending, fallback, stack),
   u => kc(GResult, String.eq(tg(arm), "Mat"), u => kc(GResult, String.eq(nm(arm), nm(x)),
     u => g_eval(book, st, kid(arm, 0), norm_join(ks(x), args), kc(U32, U32.is_eq(pending, 0), u => 0, u => U32.add(norm_dec(pending), terms_len(ks(x)))), fallback, stack),
     u => g_match(book, st, kid(arm, 1), original, raw, x, args, pending, fallback, stack)),
   u => kc(GResult, String.eq(tg(arm), "Efq"), u => g_return(book, st, norm_stuck(original, raw, args, pending, fallback), stack), u => g_eval(book, st, arm, Con{x, args}, pending, fallback, stack)))))

# Module: src/core/graph.bend:443
@unsafe
def g_let(book, st, ts, bindings, args, pending, fallback, stack):
  match ts:
    case Nil{}:
      g_return(book, st, atom("Absent"), stack)
    case Con{h, rest}:
      kc(GResult, String.eq(tg(h), "Bind"), u => g_let_shared(book, h, rest, bindings, args, pending, fallback, stack, g_share(st, kid(h, 0))), u => g_eval(book, st, g_let_sub(h, bindings), args, pending, fallback, stack))

# Module: src/core/graph.bend:451
@unsafe
def g_let_shared(book, h, rest, bindings, args, pending, fallback, stack, r):
  g_let(book, g_state(r), rest, Con{kt("Bind", nm(h), ix(h), qt(h), Con{g_term(r), Nil{}}), bindings}, args, pending, fallback, stack)

# Module: src/core/graph.bend:455
@unsafe
def g_let_sub(t, bindings):
  match bindings:
    case Nil{}:
      t
    case Con{h, rest}:
      g_let_sub(subst(t, ix(h), kid(h, 0)), rest)

# Module: src/core/graph.bend:463
@unsafe
def graph_strong(book, t):
  g_start(book, t, norm_max(norm_book_bound(book), norm_max_term(t)))

# Module: src/core/graph.bend:467
@unsafe
def g_snf_go(book, st, t, stack, fresh):
  g_snf_head(book, stack, fresh, g_wnf(book, st, t))

# Module: src/core/graph.bend:471
@unsafe
def g_snf_head(book, stack, fresh, r):
  kc(KTerm, String.eq(tg(g_term(r)), "Lam") || String.eq(tg(g_term(r)), "All"), u => g_snf_open(book, g_state(r), norm_rebind(g_term(r), fresh), stack, U32.add(fresh, 1)), u => g_snf_open(book, g_state(r), g_term(r), stack, fresh))

# Module: src/core/graph.bend:475
@unsafe
def g_snf_open(book, st, t, stack, fresh):
  g_snf_children(book, st, t, Nil{}, ks(t), stack, fresh)

# Module: src/core/graph.bend:479
@unsafe
def g_snf_children(book, st, parent, done, todo, stack, fresh):
  match todo:
    case Nil{}:
      g_snf_return(book, st, KTerm{tg(parent), nm(parent), ix(parent), qt(parent), List.reverse(&2, KTerm, done), rm(parent)}, stack, fresh)
    case Con{h, rest}:
      g_snf_go(book, st, h, Con{KNormFrame{parent, done, rest}, stack}, fresh)

# Module: src/core/graph.bend:487
@unsafe
def g_snf_return(book, st, t, stack, fresh):
  match stack:
    case Nil{}:
      t
    case Con{KNormFrame{parent, done, todo}, rest}:
      g_snf_children(book, st, parent, Con{t, done}, todo, rest, fresh)

# Module: src/core/graph.bend:502
@unsafe
def g_start(book, t, bound):
  g_snf_go(book_cached(book, bound), GState{GEmpty{}, 1}, t, Nil{}, U32.add(bound, 1))

# Module: src/core/reach.bend:76
@unsafe
def reach_book(book, roots, stops):
  kr_filter(book, kr_visit(book, roots, Nil{}, stops))

# Module: src/core/reach.bend:80
@unsafe
def kr_filter(book, live):
  match book:
    case Nil{}: Nil{}
    case Con{+d, +rest}: kc(List<&2, KDef>, has_name(live, dn(d)), u => Con{d, kr_filter(rest, live)}, u => kr_filter(rest, live))

# Module: src/core/reach.bend:86
@unsafe
def kr_visit(book, todo, seen, stops):
  match todo:
    case Nil{}: seen
    case Con{+name, +rest}: kc(List<&2, String>, has_name(seen, name), u => kr_visit(book, rest, seen, stops), u => kr_visit_def(book, rest, Con{name, seen}, stops, kr_resolve(book, name)))

# Module: src/core/reach.bend:92
@unsafe
def kr_visit_def(book, todo, seen, stops, d):
  kc(List<&2, String>, String.eq(dk(d), "Absent"), u => kr_visit(book, todo, seen, stops), u => kr_visit(book, kr_dependencies(d, stops, todo), Con{dn(d), seen}, stops))

# Module: src/core/reach.bend:96
@unsafe
def kr_resolve(book, name):
  kr_resolve_head(book, name, lookup(book, name))

# Module: src/core/reach.bend:100
@unsafe
def kr_resolve_head(book, name, d):
  kc(KDef, String.eq(dk(d), "Absent"), u => kr_parent(book, name), u => d)

# Module: src/core/reach.bend:104
@unsafe
def kr_parent(book, name):
  match book:
    case Nil{}: missing()
    case Con{+d, +rest}: kc(KDef, String.eq(dk(d), "ADT") && Bool.not(String.eq(dk(lookup(dc(d), name)), "Absent")), u => d, u => kr_parent(rest, name))

# Module: src/core/reach.bend:110
@unsafe
def kr_dependencies(d, stops, todo):
  List.append(&2, String, kr_refs(dt(d), kr_ctor_refs(dc(d), kc(List<&2, String>, has_name(stops, dn(d)), u => Nil{}, u => kr_refs(dv(d), Nil{})))), todo)

# Module: src/core/reach.bend:114
@unsafe
def kr_ctor_refs(ctors, todo):
  match ctors:
    case Nil{}: todo
    case Con{d, rest}: kr_refs(dt(d), kr_ctor_refs(rest, todo))

# Module: src/core/reach.bend:120
@unsafe
def kr_refs(t, todo):
  kr_refs_list(ks(t), kc(List<&2, String>, String.eq(tg(t), "Ref") || String.eq(tg(t), "ADT") || String.eq(tg(t), "Ctr") || String.eq(tg(t), "Mat"), u => kr_push(nm(t), todo), u => todo))

# Module: src/core/reach.bend:124
@unsafe
def kr_refs_list(terms, todo):
  match terms:
    case Nil{}: todo
    case Con{h, rest}: kr_refs(h, kr_refs_list(rest, todo))

# Module: src/core/reach.bend:130
@unsafe
def kr_push(name, names):
  kc(List<&2, String>, has_name(names, name), u => names, u => Con{name, names})

# Module: src/core/pretty.bend:289
@unsafe
def kp_eq(a, b):
  String.eq(a, b)

# Module: src/core/pretty.bend:293
@unsafe
def kp_is(t, tag, name):
  kp_eq(tg(t), tag) && kp_eq(nm(t), name)

# Module: src/core/pretty.bend:297
@unsafe
def kp_quant(q):
  kc(String, U32.is_eq(q, 0), u => "-", u => kc(String, U32.is_eq(q, 2), u => "+", u => ""))

# Module: src/core/pretty.bend:301
@unsafe
def kp_join(xs, sep):
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: h
    case Con{h, t}: h ++ sep ++ kp_join(t, sep)

# Module: src/core/pretty.bend:308
@unsafe
def kp_par(s, yes):
  kc(String, yes, u => "(" ++ s ++ ")", u => s)

# Module: src/core/pretty.bend:312
@unsafe
def kp_show(t):
  kp_go(t, 0, Nil{})

# Module: src/core/pretty.bend:316
@unsafe
def kp_scope(env, id, name):
  match env:
    case Nil{}: name ++ "^" ++ U32.show(id)
    case Con{KPName{+n, +i, +depth}, +tail}:
      kc(String, kp_eq(n, name), u => kc(String, U32.is_eq(i, id), u => name, u => name ++ "^" ++ U32.show(kp_index(tail, id))), u => kp_scope(tail, id, name))

# Module: src/core/pretty.bend:323
@unsafe
def kp_index(env, id):
  match env:
    case Nil{}: id
    case Con{KPName{n, +i, +depth}, +tail}:
      kc(U32, U32.is_eq(i, id), u => depth, u => kp_index(tail, id))

# Module: src/core/pretty.bend:330
@unsafe
def kp_depth(env):
  match env:
    case Nil{}: 0
    case Con{h, t}: U32.add(1, kp_depth(t))

# Module: src/core/pretty.bend:336
@unsafe
def kp_bound(env, name):
  match env:
    case Nil{}: False{}
    case Con{KPName{n, i, depth}, t}: kp_eq(n, name) || kp_bound(t, name)

# Module: src/core/pretty.bend:342
@unsafe
def kp_bind(env, t):
  Con{KPName{nm(t), ix(t), kp_depth(env)}, env}

# Module: src/core/pretty.bend:346
@unsafe
def kp_each(ts, p, env):
  match ts:
    case Nil{}: Nil{}
    case Con{h, t}: Con{kp_go(h, p, env), kp_each(t, p, env)}

# Module: src/core/pretty.bend:352
@unsafe
def kp_chain(t, name, arity, acc):
  kc(KPChain, kp_is(t, "Ctr", name) && U32.is_eq(terms_len(ks(t)), arity),
    u => kp_chain(kid(t, U32.sub(arity, 1)), name, arity, Con{kid(t, 0), acc}),
    u => KPChain{List.reverse(&2, KTerm, acc), t})

# Module: src/core/pretty.bend:358
@unsafe
def kp_spine(t, acc):
  kc(KPChain, kp_eq(tg(t), "App"), u => kp_spine(kid(t, 0), Con{kid(t, 1), acc}), u => KPChain{acc, t})

# Module: src/core/pretty.bend:362
@unsafe
def kp_application(s, p, env):
  match s:
    case KPChain{+xs, +h}: kc(String, kp_is(h, "Ref", "Exists") && U32.is_eq(terms_len(xs), 2) && kp_eq(tg(terms_at(xs, 1)), "Lam"), u => kp_exists(terms_at(xs, 0), terms_at(xs, 1), p, env), u => kp_go(h, 3, env) ++ "(" ++ kp_join(kp_each(xs, 1, env), ", ") ++ ")")

# Module: src/core/pretty.bend:367
@unsafe
def kp_removed(xs):
  match xs:
    case Nil{}: ""
    case Con{h, t}: " - " ++ h ++ "{}" ++ kp_removed(t)

# Module: src/core/pretty.bend:373
@unsafe
def kp_adt(t, p, env):
  kp_par(nm(t) ++ kc(String, U32.is_eq(terms_len(ks(t)), 0) && Bool.not(kp_has_removed(rm(t))), u => "", u => "<" ++ kp_join(kp_each(ks(t), 1, env), ", ") ++ ">") ++ kp_removed(rm(t)), kp_has_removed(rm(t)) && U32.is_gt(p, 2))

# Module: src/core/pretty.bend:377
@unsafe
def kp_has_removed(xs):
  match xs:
    case Nil{}: False{}
    case Con{h,t}: True{}

# Module: src/core/pretty.bend:383
@unsafe
def kp_word(t, bit, left, acc):
  kc(Maybe<&2, U32>, U32.is_eq(left, 0),
    u => kc(Maybe<&2, U32>, kp_is(t, "Ctr", "WNil"), u => Some{acc}, u => None{}),
    u => kc(Maybe<&2, U32>, kp_is(t, "Ctr", "WCon") && U32.is_eq(terms_len(ks(t)), 2) && (kp_is(kid(t, 0), "Ctr", "True") || kp_is(kid(t, 0), "Ctr", "False")),
      u => kp_word(kid(t, 1), U32.shl(bit), U32.sub(left, 1), kc(U32, kp_is(kid(t, 0), "Ctr", "True"), u => U32.or(acc, bit), u => acc)), u => None{}))

# Module: src/core/pretty.bend:390
@unsafe
def kp_number(t):
  kc(Maybe<&2, U32>, (kp_is(t, "Ctr", "U32") || kp_is(t, "Ctr", "F32")) && U32.is_eq(terms_len(ks(t)), 1), u => kp_word(kid(t, 0), 1, 32, 0), u => None{})

# Module: src/core/pretty.bend:394
@unsafe
def kp_float(n):
  match n:
    case U32{w}: F32{w}

# Module: src/core/pretty.bend:399
@unsafe
def kp_float_show(n):
  kp_float_text(F32.show(kp_float(n)))

# Module: src/core/pretty.bend:403
@unsafe
def kp_float_text(s):
  kc(String, String.contains(s, ".") || String.contains(s, "n"), u => s, u => kp_float_point(s))

# Module: src/core/pretty.bend:407
@unsafe
def kp_hex(n):
  kc(String, U32.is_lt(n, 16), u => kp_digit(n), u => kp_hex(U32.div(n, 16)) ++ kp_digit(U32.mod(n, 16)))

# Module: src/core/pretty.bend:411
@unsafe
def kp_digit(n):
  Char.show(Char.from_u32(kc(U32, U32.is_lt(n, 10), u => U32.add(n, 48), u => U32.add(n, 87))))

# Module: src/core/pretty.bend:415
@unsafe
def kp_escape(n, quote):
  kc(String, U32.is_eq(n, 10), u => "\\n",
    u => kc(String, U32.is_eq(n, 9), u => "\\t",
    u => kc(String, U32.is_eq(n, 13), u => "\\r",
    u => kc(String, U32.is_eq(n, 0), u => "\\0",
    u => kc(String, U32.is_eq(n, 92), u => "\\\\",
    u => kc(String, U32.is_eq(n, quote), u => "\\" ++ Char.show(Char.from_u32(n)),
    u => kc(String, U32.is_lt(n, 32) || U32.is_eq(n, 127) || (U32.is_ge(n, 55296) && U32.is_le(n, 57343)) || U32.is_gt(n, 1114111), u => "\\u{" ++ kp_hex(n) ++ "}", u => Char.show(Char.from_u32(n)))))))))

# Module: src/core/pretty.bend:425
@unsafe
def kp_char(t, quote):
  kc(Maybe<&2, String>, kp_is(t, "Ctr", "Chr") && U32.is_eq(terms_len(ks(t)), 1), u => kp_char_num(kp_number(kid(t, 0)), quote), u => None{})

# Module: src/core/pretty.bend:429
@unsafe
def kp_char_num(n, quote):
  match n:
    case None{}: None{}
    case Some{x}: Some{kp_escape(x, quote)}

# Module: src/core/pretty.bend:435
@unsafe
def kp_string(t):
  kc(Maybe<&2, String>, kp_is(t, "Ctr", "SNil"), u => Some{""},
    u => kc(Maybe<&2, String>, kp_is(t, "Ctr", "SCon") && U32.is_eq(terms_len(ks(t)), 2), u => kp_append(kp_char(kid(t, 0), 34), kp_string(kid(t, 1))), u => None{}))

# Module: src/core/pretty.bend:440
@unsafe
def kp_append(a, b):
  match a b:
    case Some{x} Some{y}: Some{x ++ y}
    case _ _: None{}

# Module: src/core/pretty.bend:446
@unsafe
def kp_list(chain, p, env):
  match chain:
    case KPChain{+xs, +t}:
      kc(String, kp_is(t, "Ctr", "Nil"), u => "[" ++ kp_join(kp_each(xs, 1, env), ", ") ++ "]",
        u => kp_par(kp_join(kp_each(xs, 3, env), " <> ") ++ " <> " ++ kp_go(t, 2, env), U32.is_gt(p, 2)))

# Module: src/core/pretty.bend:453
@unsafe
def kp_tuple(chain, env):
  match chain:
    case KPChain{xs, t}: "(" ++ kp_join(kp_each(xs, 1, env), ", ") ++ ", " ++ kp_go(t, 1, env) ++ ")"

# Module: src/core/pretty.bend:458
@unsafe
def kp_nat(t, n, p, env):
  kc(String, kp_is(t, "Ctr", "Zero"), u => Nat.show(n) ++ "n",
    u => kc(String, kp_is(t, "Ctr", "Succ") && U32.is_eq(terms_len(ks(t)), 1), u => kp_nat(kid(t, 0), Nat.add(n, 1n), p, env),
      u => kp_par(Nat.show(n) ++ "n+" ++ kp_go(t, 2, env), U32.is_gt(p, 2))))

# Module: src/core/pretty.bend:464
@unsafe
def kp_array(t):
  kc(Maybe<&2, List<&2, KTerm>>, kp_is(t, "Ctr", "ALeaf"), u => Some{[kid(t, 0)]},
    u => kc(Maybe<&2, List<&2, KTerm>>, kp_is(t, "Ctr", "ANode"), u => kp_array_join(kp_array(kid(t, 0)), kp_array(kid(t, 1))), u => None{}))

# Module: src/core/pretty.bend:469
@unsafe
def kp_array_join(a, b):
  match a b:
    case Some{x} Some{y}: Some{List.append(&2, KTerm, x, y)}
    case _ _: None{}

# Module: src/core/pretty.bend:475
@unsafe
def kp_ctor(t, p, env):
  kp_ctor_number(kp_number(t), t, p, env)

# Module: src/core/pretty.bend:479
@unsafe
def kp_ctor_number(n, t, p, env):
  match n:
    case Some{+x}: kc(String, kp_eq(nm(t), "F32"), u => kp_float_show(x), u => U32.show(x))
    case None{}: kp_ctor_other(t, p, env)

# Module: src/core/pretty.bend:485
@unsafe
def kp_ctor_other(t, p, env):
  kc(String, kp_eq(nm(t), "Succ") || kp_eq(nm(t), "Zero"), u => kp_nat(t, 0n, p, env),
    u => kp_ctor_char(kp_char(t, 39), t, p, env))

# Module: src/core/pretty.bend:490
@unsafe
def kp_ctor_char(c, t, p, env):
  match c:
    case Some{s}: "'" ++ s ++ "'"
    case None{}: kp_ctor_string(kp_string(t), t, p, env)

# Module: src/core/pretty.bend:496
@unsafe
def kp_ctor_string(s, t, p, env):
  match s:
    case Some{x}: "\"" ++ x ++ "\""
    case None{}:
      kc(String, kp_eq(nm(t), "Con") || kp_eq(nm(t), "Nil"), u => kp_list(kp_chain(t, "Con", 2, Nil{}), p, env),
        u => kc(String, kp_eq(nm(t), "Tuple"), u => kp_tuple(kp_chain(t, "Tuple", 2, Nil{}), env), u => kp_ctor_array(kp_array(t), t, env)))

# Module: src/core/pretty.bend:504
@unsafe
def kp_ctor_array(a, t, env):
  match a:
    case Some{xs}: "[" ++ kp_join(kp_each(xs, 1, env), ", ") ++ "]"
    case None{}: nm(t) ++ "{" ++ kp_join(kp_each(ks(t), 1, env), ", ") ++ "}"

# Module: src/core/pretty.bend:510
@unsafe
def kp_matches(t, env):
  kc(String, kp_eq(tg(t), "Mat"), u => nm(t) ++ ": " ++ kp_go(kid(t, 0), 2, env) ++ kc(String, kp_eq(tg(kid(t, 1)), "Efq"), u => "", u => "; " ++ kp_matches(kid(t, 1), env)), u => kp_go(t, 2, env))

# Module: src/core/pretty.bend:514
@unsafe
def kp_go(t, p, env):
  kc(String, kp_eq(tg(t), "Var"), u => kp_scope(env, ix(t), nm(t)),
    u => kc(String, kp_eq(tg(t), "Ref"), u => nm(t) ++ kc(String, kp_bound(env, nm(t)), u => "^", u => "") ++ kc(String, U32.is_eq(qt(t), 3), u => "!", u => ""),
    u => kc(String, kp_eq(tg(t), "Typ"), u => kc(String, kp_eq(tg(kid(t, 0)), "Qua") && U32.is_eq(qt(kid(t, 0)), 1), u => "Type", u => kc(String, kp_eq(tg(kid(t, 0)), "Qua") && U32.is_eq(qt(kid(t, 0)), 2), u => "Data", u => "Kind(" ++ kp_go(kid(t, 0), 1, env) ++ ")")),
    u => kc(String, kp_eq(tg(t), "Qnt"), u => "Quant",
    u => kc(String, kp_eq(tg(t), "Qua"), u => "&" ++ U32.show(qt(t)),
    u => kc(String, kp_eq(tg(t), "Min"), u => kp_par(kp_go(kid(t, 0), 3, env) ++ " <&> " ++ kp_go(kid(t, 1), 3, env), U32.is_gt(p, 2)),
    u => kc(String, kp_eq(tg(t), "All"), u => kp_par("@" ++ kp_quant(qt(t)) ++ nm(t) ++ ":" ++ kp_go(kid(t, 0), 3, env) ++ " -> " ++ kp_go(kid(t, 1), 2, kp_bind(env, t)), U32.is_gt(p, 2)),
    u => kc(String, kp_eq(tg(t), "Lam"), u => kp_par(kp_quant(qt(t)) ++ nm(t) ++ " => " ++ kp_go(kid(t, 0), 0, kp_bind(env, t)), U32.is_gt(p, 1)),
    u => kp_go_tail(t, p, env)))))))))

# Module: src/core/pretty.bend:526
@unsafe
def kp_go_tail(t, p, env):
  kc(String, kp_eq(tg(t), "App"), u => kp_application(kp_spine(t, Nil{}), p, env),
    u => kc(String, kp_eq(tg(t), "ADT"), u => kp_adt(t, p, env),
    u => kc(String, kp_eq(tg(t), "Ctr"), u => kp_ctor(t, p, env),
    u => kc(String, kp_eq(tg(t), "Mat"), u => "\\{" ++ kp_matches(t, env) ++ "}",
    u => kc(String, kp_eq(tg(t), "Efq"), u => "\\{}",
    u => kc(String, kp_eq(tg(t), "Eql"), u => "{" ++ kp_go(kid(t, 0), 2, env) ++ " == " ++ kp_go(kid(t, 1), 2, env) ++ " : " ++ kp_go(kid(t, 2), 2, env) ++ "}",
    u => kc(String, kp_eq(tg(t), "Rfl"), u => "{==}",
    u => kc(String, kp_eq(tg(t), "Hol"), u => "?" ++ nm(t),
    u => kc(String, kp_eq(tg(t), "Ann"), u => "{" ++ kp_go(kid(t, 0), 2, env) ++ " : " ++ kp_go(kid(t, 1), 2, env) ++ "}",
    u => kp_go_last(t, p, env))))))))))

# Module: src/core/pretty.bend:539
@unsafe
def kp_go_last(t, p, env):
  kc(String, kp_eq(tg(t), "Sub"), u => kp_go(kid(t, 1), p, env),
    u => kc(String, kp_eq(tg(t), "Rwt"), u => kp_rewrite(t, p, env),
    u => kc(String, kp_eq(tg(t), "Let"), u => kp_let(t, p, env),
    u => kc(String, kp_eq(tg(t), "Literal"), u => nm(t),
    u => "<" ++ tg(t) ++ ":" ++ nm(t) ++ ">"))))

# Module: src/core/pretty.bend:547
@unsafe
def kp_float_point(s):
  match s:
    case SNil{}: ".0"
    case SCon{+h, +t}: kc(String, U32.is_eq(Char.to_u32(h), 101), u => ".0e" ++ t, u => Char.show(h) ++ kp_float_point(t))

# Module: src/core/pretty.bend:553
@unsafe
def kp_exists(A, b, p, env):
  kp_par("&" ++ nm(b) ++ ":" ++ kp_go(A, 3, env) ++ " -> " ++ kp_go(kid(b, 0), 2, kp_bind(env, b)), U32.is_gt(p, 2))

# Module: src/core/pretty.bend:557
@unsafe
def kp_rewrite(t, p, env):
  kp_par("%" ++ kp_rewrite_motive(kid(t, 0), kid(t, 1), env) ++ "; " ++ kp_go(kid(t, 2), 0, env), U32.is_gt(p, 1))

# Module: src/core/pretty.bend:561
@unsafe
def kp_rewrite_motive(e, m, env):
  kc(String, kp_eq(tg(m), "Lam") && kp_eq(tg(kid(m, 0)), "Lam"), u => kc(String, kp_eq(nm(kid(m, 0)), ""), u => "", u => nm(kid(m, 0)) ++ "@") ++ kp_go(e, 2, env) ++ " : " ++ kp_go(kid(kid(m, 0), 0), 2, kp_bind(kp_bind(env, m), kid(m, 0))), u => kp_go(e, 2, env) ++ " : " ++ kp_go(m, 2, env))

# Module: src/core/pretty.bend:565
@unsafe
def kp_let(t, p, env):
  kp_par(kp_let_names(ks(t)) ++ " = " ++ kp_let_vals(ks(t), env) ++ "; " ++ kp_let_body(ks(t), env), U32.is_gt(p, 0))

# Module: src/core/pretty.bend:569
@unsafe
def kp_let_names(ts):
  match ts:
    case Nil{}: ""
    case Con{+h, +rest}: kc(String, U32.is_eq(terms_len(rest), 0), u => "", u => kp_quant(qt(h)) ++ nm(h) ++ kc(String, U32.is_eq(terms_len(rest), 1), u => "", u => " " ++ kp_let_names(rest)))

# Module: src/core/pretty.bend:575
@unsafe
def kp_let_vals(ts, env):
  match ts:
    case Nil{}: ""
    case Con{+h, +rest}: kc(String, U32.is_eq(terms_len(rest), 0), u => "", u => kp_go(kid(h, 0), 2, env) ++ kc(String, U32.is_eq(terms_len(rest), 1), u => "", u => " " ++ kp_let_vals(rest, env)))

# Module: src/core/pretty.bend:581
@unsafe
def kp_let_body(ts, env):
  match ts:
    case Nil{}: "<missing let body>"
    case Con{+h, +rest}: kc(String, U32.is_eq(terms_len(rest), 0), u => kp_go(h, 0, env), u => kp_let_body(rest, kp_bind(env, h)))

# Module: src/check/quantity.bend:85
@unsafe
def qadd(a, b):
  kc(U32, U32.is_eq(a, 0), u => b, u => kc(U32, U32.is_eq(b, 0), u => a, u => 2))

# Module: src/check/quantity.bend:89
@unsafe
def qjoin(a, b):
  kc(U32, U32.is_gt(a, b), u => a, u => b)

# Module: src/check/quantity.bend:93
@unsafe
def qdem(q, d):
  kc(U32, U32.is_eq(q, 0), u => 0, u => d)

# Module: src/check/quantity.bend:97
@unsafe
def uses_get(xs, id):
  match xs:
    case Nil{}:
      0
    case Con{h, t}:
      kc(U32, U32.is_eq(ix(h), id), u => qt(h), u => uses_get(t, id))

# Module: src/check/quantity.bend:105
@unsafe
def uses_del(xs, id):
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      kc(List<&2, KTerm>, U32.is_eq(ix(h), id), u => uses_del(t, id), u => Con{h, uses_del(t, id)})

# Module: src/check/quantity.bend:113
@unsafe
def uses_merge(a, b, join):
  match a:
    case Nil{}:
      b
    case Con{h, t}:
      Con{kt("Use", "", ix(h), kc(U32, join, u => qjoin(qt(h), uses_get(b, ix(h))), u => qadd(qt(h), uses_get(b, ix(h)))), Nil{}), uses_merge(t, uses_del(b, ix(h)), join)}

# Module: src/check/quantity.bend:121
@unsafe
def strip(t):
  core_force(t)

# Module: src/check/quantity.bend:125
@unsafe
def descend(q, a, p):
  kc(U32, U32.is_eq(q, 0), u => 1, u => descend_go(strip(a), strip(p)))

# Module: src/check/quantity.bend:129
@unsafe
def descend_go(a, p):
  kc(U32, String.eq(tg(p), "Var"),
    u => kc(U32, String.eq(tg(a), "Var") && U32.is_eq(ix(a), ix(p)), u => 1, u => 2),
    u => kc(U32, String.eq(tg(p), "Ctr"),
      u => descend_ctr(a, p, kc(U32, String.eq(tg(a), "Ctr") && String.eq(nm(a), nm(p)) && U32.is_eq(terms_len(ks(a)), terms_len(ks(p))), u => descend_fields(ks(a), ks(p), 1), u => 2)),
      u => 2))

# Module: src/check/quantity.bend:137
@unsafe
def descend_fields(a, p, ord):
  match a:
    case Nil{}:
      ord
    case Con{h, t}:
      kc(U32, U32.is_eq(ord, 2), u => 2, u => descend_fields(t, terms_tail(p), kc(U32, U32.is_eq(descend(1, h, terms_at(p, 0)), 1), u => ord, u => descend(1, h, terms_at(p, 0)))))

# Module: src/check/quantity.bend:145
@unsafe
def terms_tail(ts):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      t

# Module: src/check/quantity.bend:153
@unsafe
def descend_ctr(a, p, ord):
  kc(U32, U32.is_eq(ord, 2), u => descend_sub(a, ks(p)), u => ord)

# Module: src/check/quantity.bend:157
@unsafe
def descend_sub(a, ps):
  match ps:
    case Nil{}:
      2
    case Con{h, t}:
      kc(U32, U32.is_eq(descend(1, a, h), 2), u => descend_sub(a, t), u => 0)

# Module: src/check/quantity.bend:165
@unsafe
def descend_spine(qs, args, cols):
  match cols:
    case Nil{}:
      False{}
    case Con{h, t}:
      descend_step(descend(qt(terms_at(qs, 0)), terms_at(args, 0), h), terms_tail(qs), terms_tail(args), t)

# Module: src/check/quantity.bend:173
@unsafe
def descend_step(ord, qs, args, cols):
  kc(Bool, U32.is_eq(ord, 0), u => True{}, u => kc(Bool, U32.is_eq(ord, 1), u => descend_spine(qs, args, cols), u => False{}))

# Module: src/check/kernel.bend:675
@unsafe
def cb(e):
  match e:
    case KEnv{book, name, lhs, pending, quantities, unsafe}:
      book

# Module: src/check/kernel.bend:681
@unsafe
def cn(e):
  match e:
    case KEnv{book, name, lhs, pending, quantities, unsafe}:
      name

# Module: src/check/kernel.bend:687
@unsafe
def cl(e):
  match e:
    case KEnv{book, name, lhs, pending, quantities, unsafe}:
      lhs

# Module: src/check/kernel.bend:693
@unsafe
def cp(e):
  match e:
    case KEnv{book, name, lhs, pending, quantities, unsafe}:
      pending

# Module: src/check/kernel.bend:699
@unsafe
def cq(e):
  match e:
    case KEnv{book, name, lhs, pending, quantities, unsafe}:
      quantities

# Module: src/check/kernel.bend:705
@unsafe
def cu(e):
  match e:
    case KEnv{book, name, lhs, pending, quantities, unsafe}:
      unsafe

# Module: src/check/kernel.bend:711
@unsafe
def ct(r):
  match r:
    case KChecked{term, typ, uses, error}:
      term

# Module: src/check/kernel.bend:717
@unsafe
def cy(r):
  match r:
    case KChecked{term, typ, uses, error}:
      typ

# Module: src/check/kernel.bend:723
@unsafe
def cs(r):
  match r:
    case KChecked{term, typ, uses, error}:
      uses

# Module: src/check/kernel.bend:729
@unsafe
def ce(r):
  match r:
    case KChecked{term, typ, uses, error}:
      error

# Module: src/check/kernel.bend:735
@unsafe
def ok(t, ty, us):
  KChecked{t, ty, us, ""}

# Module: src/check/kernel.bend:739
@unsafe
def bad(msg):
  KChecked{atom("Error"), atom("Error"), Nil{}, msg}

# Module: src/check/kernel.bend:743
@unsafe
def good(r):
  String.eq(ce(r), "")

# Module: src/check/kernel.bend:747
@unsafe
def checked(r, t, ty):
  kc(KChecked, good(r), u => ok(t, ty, cs(r)), u => r)

# Module: src/check/kernel.bend:751
@unsafe
def both(a, b, t, ty, join):
  kc(KChecked, good(a), u => kc(KChecked, good(b), u => ok(t, ty, uses_merge(cs(a), cs(b), join)), u => b), u => a)

# Module: src/check/kernel.bend:755
@unsafe
def ctx_get(ctx, id):
  match ctx:
    case Nil{}:
      atom("Absent")
    case Con{h, t}:
      kc(KTerm, U32.is_eq(ix(h), id), u => h, u => ctx_get(t, id))

# Module: src/check/kernel.bend:763
@unsafe
def ctx_bind(ctx, id, q, name, ty):
  Con{kt("Bind", name, id, q, Con{ty, Nil{}}), ctx}

# Module: src/check/kernel.bend:767
@unsafe
def kindq(e, q):
  kc(U32, cu(e) && U32.is_eq(q, 2), u => 1, u => q)

# Module: src/check/kernel.bend:771
@unsafe
def kapply(fn, x):
  kc(KTerm, String.eq(tg(strip(fn)), "Lam"), u => subst(kid(strip(fn), 0), ix(strip(fn)), x), u => app(fn, x))

# Module: src/check/kernel.bend:775
@unsafe
def lhs_step(e, x):
  kc(KEnv, U32.is_eq(cp(e), 0), u => e, u => KEnv{cb(e), cn(e), kapply(cl(e), x), U32.sub(cp(e), 1), cq(e), cu(e)})

# Module: src/check/kernel.bend:779
@unsafe
def unargs(t, acc):
  kc(List<&2, KTerm>, String.eq(tg(t), "App"), u => unargs(kid(t, 0), Con{kid(t, 1), acc}), u => acc)

# Module: src/check/kernel.bend:783
@unsafe
def infer(e, ctx, t, dem, sp):
  dg_trace(e, ctx, t, atom("Absent"), infer_node(e, ctx, core_beta(t), dem, sp))

# Module: src/check/kernel.bend:787
@unsafe
def infer_node(e, ctx, t, dem, sp):
  kc(KChecked, String.eq(tg(t), "Var"), u => infer_var(ctx, t, dem),
   u => kc(KChecked, String.eq(tg(t), "Ref"), u => infer_ref(e, t, dem, sp, lookup(cb(e), nm(t))),
   u => kc(KChecked, String.eq(tg(t), "Typ"), u => checked(check(e, ctx, kid(t, 0), 0, atom("Qnt")), t, typ(1)),
   u => kc(KChecked, String.eq(tg(t), "Qnt"), u => ok(t, typ(1), Nil{}),
   u => kc(KChecked, String.eq(tg(t), "Qua"), u => ok(t, atom("Qnt"), Nil{}),
   u => kc(KChecked, String.eq(tg(t), "Min"), u => both(check(e, ctx, kid(t, 0), dem, atom("Qnt")), check(e, ctx, kid(t, 1), dem, atom("Qnt")), t, atom("Qnt"), False{}),
   u => kc(KChecked, String.eq(tg(t), "All"), u => both(check(e, ctx, kid(t, 0), 0, typ(kindq(e, qt(t)))), check(e, ctx_bind(ctx, ix(t), qt(t), nm(t), kid(t, 0)), kid(t, 1), 0, typ(1)), t, typ(1), False{}),
   u => kc(KChecked, String.eq(tg(t), "App"), u => infer_app(e, ctx, t, dem, infer(e, ctx, kid(t, 0), dem, Con{kid(t, 1), sp})),
   u => kc(KChecked, String.eq(tg(t), "ADT"), u => infer_adt(e, ctx, t, dem, lookup(cb(e), nm(t))),
   u => kc(KChecked, String.eq(tg(t), "Eql"), u => both(check(e, ctx, kid(t, 2), 0, typ(1)), both(check(e, ctx, kid(t, 0), 0, kid(t, 2)), check(e, ctx, kid(t, 1), 0, kid(t, 2)), t, typ(2), False{}), t, typ(2), False{}),
   u => kc(KChecked, String.eq(tg(t), "Ann"), u => both(check(e, ctx, kid(t, 1), 0, typ(1)), check(e, ctx, kid(t, 0), dem, kid(t, 1)), kid(t, 0), kid(t, 1), False{}),
   u => bad("cannot infer: annotation required"))))))))))))

# Module: src/check/kernel.bend:802
@unsafe
def infer_var(ctx, t, dem):
  kc(KChecked, String.eq(tg(ctx_get(ctx, ix(t))), "Absent"), u => bad("unbound variable"), u => ok(t, kid(ctx_get(ctx, ix(t)), 0), Con{kt("Use", "", ix(t), dem, Nil{}), Nil{}}))

# Module: src/check/kernel.bend:806
@unsafe
def infer_ref(e, t, dem, sp, d):
  kc(KChecked, String.eq(dk(d), "Absent"), u => bad("undefined name"),
   u => kc(KChecked, String.eq(dk(d), "ADT") && U32.is_gt(da(d), 0), u => bad("a family requires angle-bracket parameters"),
   u => kc(KChecked, U32.is_eq(dem, 0), u => ok(t, dt(d), Nil{}),
   u => kc(KChecked, String.eq(nm(t), cn(e)) && Bool.not(cu(e)) && Bool.not(descend_spine(cq(e), sp, unargs(cl(e), Nil{}))), u => bad("nondecreasing self-call"),
   u => kc(KChecked, String.eq(tg(dv(d)), "Absent") && Bool.not(db(d)) && Bool.not(cu(e)) && Bool.not(String.eq(nm(t), cn(e))), u => bad("live use of an unfilled law"),
   u => infer_template(e, t, dem, sp, d))))))

# Module: src/check/kernel.bend:815
@unsafe
def infer_app(e, ctx, t, dem, r):
  kc(KChecked, good(r), u => infer_app_type(e, ctx, t, dem, r, wnf(cb(e), cy(r))), u => r)

# Module: src/check/kernel.bend:819
@unsafe
def infer_app_type(e, ctx, t, dem, r, ty):
  kc(KChecked, String.eq(tg(ty), "All"), u => both(r, check(e, ctx, kid(t, 1), qdem(qt(ty), dem), kid(ty, 0)), t, subst(kid(ty, 1), ix(ty), kid(t, 1)), False{}), u => dg_bad_detail("application requires a function type", dg_text("a function type"), cy(r)))

# Module: src/check/kernel.bend:823
@unsafe
def infer_adt(e, ctx, t, dem, d):
  kc(KChecked, String.eq(dk(d), "ADT") && U32.is_eq(terms_len(ks(t)), da(d)), u => infer_adt_done(t, tele_check(e, ctx, dt(d), ks(t), dem)), u => dg_bad_detail("unknown family or wrong parameter count", dg_text(kc(String, String.eq(dk(d), "ADT"), u => nm(t) ++ " with " ++ U32.show(da(d)) ++ kc(String, U32.is_eq(da(d), 1), u => " parameter", u => " parameters"), u => "a datatype")), t))

# Module: src/check/kernel.bend:827
@unsafe
def infer_adt_done(t, r):
  checked(r, t, cy(r))

# Module: src/check/kernel.bend:831
@unsafe
def tele_check(e, ctx, tel, args, dem):
  match args:
    case Nil{}:
      ok(atom("Args"), tel, Nil{})
    case Con{h, t}:
      tele_check_head(e, ctx, wnf(cb(e), tel), h, t, dem)

# Module: src/check/kernel.bend:839
@unsafe
def tele_check_head(e, ctx, tel, h, rest, dem):
  kc(KChecked, String.eq(tg(tel), "All"), u => tele_check_done(check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)), tele_check(e, ctx, subst(kid(tel, 1), ix(tel), h), rest, dem)), u => bad("too many telescope arguments"))

# Module: src/check/kernel.bend:843
@unsafe
def tele_check_done(a, b):
  both(a, b, ct(b), cy(b), False{})

# Module: src/check/kernel.bend:847
@unsafe
def tele_fill(book, tel, args):
  match args:
    case Nil{}:
      tel
    case Con{h, t}:
      tele_fill_head(book, wnf(book, tel), h, t)

# Module: src/check/kernel.bend:855
@unsafe
def tele_fill_head(book, tel, h, rest):
  kc(KTerm, String.eq(tg(tel), "All"), u => tele_fill(book, subst(kid(tel, 1), ix(tel), h), rest), u => atom("Error"))

# Module: src/check/kernel.bend:859
@unsafe
def check(e, ctx, t, dem, ty):
  dg_trace(e, ctx, t, ty, check_node(e, ctx, core_beta(t), dem, ty))

# Module: src/check/kernel.bend:863
@unsafe
def check_node(e, ctx, t, dem, ty):
  kc(KChecked, String.eq(tg(t), "Lam"), u => check_lam(e, ctx, t, dem, wnf(cb(e), ty)),
   u => kc(KChecked, String.eq(tg(t), "Ctr"), u => check_ctr(e, ctx, t, dem, wnf(cb(e), ty)),
   u => kc(KChecked, String.eq(tg(t), "Mat") || String.eq(tg(t), "Efq"), u => check_mat(e, ctx, t, dem, wnf(cb(e), ty)),
   u => kc(KChecked, String.eq(tg(t), "Rfl"), u => check_rfl(e, t, wnf(cb(e), ty)),
   u => kc(KChecked, String.eq(tg(t), "Hol"), u => bad("unresolved hole"),
   u => kc(KChecked, String.eq(tg(t), "Let"), u => check_let(e, ctx, ctx, ks(t), dem, ty, Nil{}, Nil{}),
   u => kc(KChecked, String.eq(tg(t), "Rwt"), u => check_rwt(e, ctx, t, dem, ty, infer(e, ctx, kid(t, 0), dem, Nil{})),
   u => check_fits(e, infer(e, ctx, t, dem, Nil{}), ty))))))))

# Module: src/check/kernel.bend:874
@unsafe
def check_fits(e, r, ty):
  kc(KChecked, good(r), u => kc(KChecked, compare(cb(e), cy(r), ty, True{}), u => checked(r, ct(r), ty), u => dg_bad_detail("type mismatch", ty, cy(r))), u => r)

# Module: src/check/kernel.bend:878
@unsafe
def check_lam(e, ctx, t, dem, ty):
  kc(KChecked, String.eq(tg(ty), "All"), u => check_lam_q(e, ctx, t, dem, ty, kc(U32, U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => 2, u => qt(ty))), u => bad("lambda requires a function type"))

# Module: src/check/kernel.bend:882
@unsafe
def check_lam_q(e, ctx, t, dem, ty, q):
  check_lam_done(t, ty, q, both(check(e, ctx, kid(ty, 0), 0, typ(kindq(e, q))), check(lhs_step(e, var(nm(t), ix(t))), ctx_bind(ctx, ix(t), q, nm(t), kid(ty, 0)), kid(t, 0), dem, subst(kid(ty, 1), ix(ty), var(nm(t), ix(t)))), t, ty, False{}))

# Module: src/check/kernel.bend:886
@unsafe
def check_lam_done(t, ty, q, r):
  kc(KChecked, good(r), u => kc(KChecked, U32.is_gt(uses_get(cs(r), ix(t)), q), u => dg_quant_error("affine variable consumed more than allowed", nm(t), q, uses_get(cs(r), ix(t))), u => ok(t, ty, uses_del(cs(r), ix(t)))), u => r)

# Module: src/check/kernel.bend:890
@unsafe
def check_ctr(e, ctx, t, dem, ty):
  kc(KChecked, String.eq(tg(ty), "ADT"), u => check_ctr_found(e, ctx, t, dem, ty, lookup(dc(lookup(cb(e), nm(ty))), nm(t))), u => bad("constructor requires a datatype goal"))

# Module: src/check/kernel.bend:894
@unsafe
def check_ctr_found(e, ctx, t, dem, ty, ctr):
  kc(KChecked, Bool.not(String.eq(dk(ctr), "Absent")) && Bool.not(has_name(rm(ty), nm(t))) && U32.is_eq(da(ctr), terms_len(ks(t))), u => checked(tele_check(e, ctx, tele_fill(cb(e), dt(ctr), ks(ty)), ks(t), dem), t, ty), u => dg_ctor_error(e, t, ty, ctr))

# Module: src/check/kernel.bend:898
@unsafe
def check_rfl(e, t, ty):
  kc(KChecked, String.eq(tg(ty), "Eql"), u => kc(KChecked, compare(cb(e), kid(ty, 0), kid(ty, 1), False{}), u => ok(t, ty, Nil{}), u => dg_bad_detail("reflexivity endpoints differ", kid(ty, 0), kid(ty, 1))), u => bad("reflexivity requires equality goal"))

# Module: src/check/kernel.bend:902
@unsafe
def check_let(e, outer, ctx, xs, dem, ty, bindings, us):
  match xs:
    case Nil{}:
      bad("let has no body")
    case Con{h, rest}:
      kc(KChecked, String.eq(tg(h), "Bind"), u => check_let_value(e, outer, ctx, h, rest, dem, ty, bindings, us, infer(e, outer, kid(h, 0), qdem(qt(h), dem), Nil{})), u => check_let_done(check(e, ctx, let_cells(h, bindings), dem, ty), bindings, us))

# Module: src/check/kernel.bend:910
@unsafe
def check_let_value(e, outer, ctx, h, rest, dem, ty, bindings, us, r):
  kc(KChecked, good(r), u => check_let_kind(e, outer, ctx, h, rest, dem, ty, bindings, us, r, check(e, outer, cy(r), 0, typ(kindq(e, qt(h))))), u => r)

# Module: src/check/kernel.bend:914
@unsafe
def check_let_kind(e, outer, ctx, h, rest, dem, ty, bindings, us, r, k):
  kc(KChecked, good(k), u => check_let(e, outer, ctx_bind(ctx, ix(h), qt(h), nm(h), cy(r)), rest, dem, ty, Con{h, bindings}, uses_merge(us, cs(r), False{})), u => k)

# Module: src/check/kernel.bend:918
@unsafe
def let_cells(body, bs):
  match bs:
    case Nil{}:
      body
    case Con{h, t}:
      let_cells(subst(body, ix(h), kt("Var", nm(h), ix(h), 0, Con{kid(h, 0), Nil{}})), t)

# Module: src/check/kernel.bend:926
@unsafe
def check_let_done(r, bs, us):
  match bs:
    case Nil{}:
      kc(KChecked, good(r), u => ok(ct(r), cy(r), uses_merge(us, cs(r), False{})), u => r)
    case Con{h, t}:
      kc(KChecked, U32.is_gt(uses_get(cs(r), ix(h)), qt(h)), u => dg_quant_error("let binder consumed more than allowed", nm(h), qt(h), uses_get(cs(r), ix(h))), u => kc(KChecked, good(r), u => check_let_done(ok(ct(r), cy(r), uses_del(cs(r), ix(h))), t, us), u => r))

# Module: src/check/kernel.bend:934
@unsafe
def remaining(cs, removed):
  match cs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      kc(List<&2, KDef>, has_name(removed, dn(h)), u => remaining(t, removed), u => Con{h, remaining(t, removed)})

# Module: src/check/kernel.bend:942
@unsafe
def defs_empty(ds):
  match ds:
    case Nil{}:
      True{}
    case Con{h, t}:
      False{}

# Module: src/check/kernel.bend:950
@unsafe
def ctx_dead(book, ctx):
  match ctx:
    case Nil{}:
      False{}
    case Con{h, t}:
      kc(Bool, U32.is_eq(qt(h), 0), u => ctx_dead(book, t), u => dead_type(book, wnf(book, kid(h, 0))) || ctx_dead(book, t))

# Module: src/check/kernel.bend:958
@unsafe
def dead_type(book, ty):
  String.eq(tg(ty), "ADT") && String.eq(dk(lookup(book, nm(ty))), "ADT") && defs_empty(remaining(dc(lookup(book, nm(ty))), rm(ty)))

# Module: src/check/kernel.bend:962
@unsafe
def check_mat(e, ctx, t, dem, ty):
  kc(KChecked, String.eq(tg(ty), "All"),
   u => kc(KChecked, Bool.not(U32.is_eq(dem, 0)) && U32.is_eq(qt(ty), 0), u => dg_bad_message("erased scrutinee in live match", dg_text("a live scrutinee (a - scrutinee matches only in a dead region)")),
   u => check_mat_type(e, ctx, t, dem, ty, wnf(cb(e), kid(ty, 0)))),
   u => bad("matcher requires a function type"))

# Module: src/check/kernel.bend:969
@unsafe
def check_mat_type(e, ctx, t, dem, ty, a):
  kc(KChecked, String.eq(tg(a), "ADT") && String.eq(dk(lookup(cb(e), nm(a))), "ADT"),
   u => kc(KChecked, String.eq(tg(t), "Efq"),
   u => kc(KChecked, dead_type(cb(e), a) || ctx_dead(cb(e), ctx), u => ok(t, ty, Nil{}), u => dg_bad_detail("nonexhaustive match", dg_text("cases for " ++ dg_constructor_names(remaining(dc(lookup(cb(e), nm(a))), rm(a)))), t)),
   u => check_mat_ctr(e, ctx, t, dem, ty, a, lookup(remaining(dc(lookup(cb(e), nm(a))), rm(a)), nm(t)))),
   u => dg_bad_detail("match scrutinee requires a datatype", dg_text("a datatype"), kid(ty, 0)))

# Module: src/check/kernel.bend:977
@unsafe
def check_mat_ctr(e, ctx, t, dem, ty, a, ctr):
  kc(KChecked, String.eq(dk(ctr), "Absent"), u => dg_bad_detail("unknown or duplicate match constructor", dg_text("a constructor of " ++ nm(a) ++ " (missing, or already matched)"), t),
   u => both(check(mat_lhs(e, nm(t), tele_fill(cb(e), dt(ctr), ks(a)), da(ctr)), ctx, kid(t, 0), dem, mat_goal(cb(e), ty, tele_fill(cb(e), dt(ctr), ks(a)), da(ctr), nm(t), Nil{})),
   check(e, ctx, kid(t, 1), dem, all(qt(ty), nm(ty), ix(ty), KTerm{tg(a), nm(a), ix(a), qt(a), ks(a), Con{nm(t), rm(a)}}, kid(ty, 1))), t, ty, True{}))

# Module: src/check/kernel.bend:983
@unsafe
def mat_goal(book, goal, tel, n, name, xs):
  kc(KTerm, U32.is_eq(n, 0), u => subst(kid(goal, 1), ix(goal), kt("Ctr", name, 0, 0, norm_join(xs, Nil{}))), u => mat_goal_head(book, goal, wnf(book, tel), n, name, xs))

# Module: src/check/kernel.bend:987
@unsafe
def mat_goal_head(book, goal, tel, n, name, xs):
  all(kc(U32, U32.is_eq(qt(tel), 0), u => 0, u => kc(U32, U32.is_eq(qt(tel), 1), u => qt(goal), u => qadd(qt(goal), qt(goal)))), nm(tel), ix(tel), kid(tel, 0), mat_goal(book, goal, kid(tel, 1), U32.sub(n, 1), name, norm_join(xs, Con{var(nm(tel), ix(tel)), Nil{}})))

# Module: src/check/kernel.bend:991
@unsafe
def lhs_ext(lhs, name, tel, n, xs):
  kc(KTerm, U32.is_eq(n, 0), u => kapply(lhs, kt("Ctr", name, 0, 0, xs)), u => kt("Lam", nm(tel), ix(tel), qt(tel), Con{lhs_ext(lhs, name, kid(tel, 1), U32.sub(n, 1), norm_join(xs, Con{var(nm(tel), ix(tel)), Nil{}})), Nil{}}))

# Module: src/check/kernel.bend:995
@unsafe
def mat_lhs(e, name, tel, n):
  kc(KEnv, U32.is_eq(cp(e), 0), u => e, u => KEnv{cb(e), cn(e), lhs_ext(cl(e), name, tel, n, Nil{}), U32.add(U32.sub(cp(e), 1), n), cq(e), cu(e)})

# Module: src/check/kernel.bend:999
@unsafe
def check_rwt(e, ctx, t, dem, ty, r):
  kc(KChecked, good(r), u => check_rwt_type(e, ctx, t, dem, ty, r, wnf(cb(e), cy(r))), u => r)

# Module: src/check/kernel.bend:1003
@unsafe
def check_rwt_type(e, ctx, t, dem, ty, r, eq):
  kc(KChecked, String.eq(tg(eq), "Eql"), u => check_rwt_goal(e, ctx, t, dem, ty, r, eq, U32.add(norm_book_bound(cb(e)), U32.add(norm_max_term(t), 1))), u => dg_bad_detail("rewrite requires equality evidence", dg_text("an equation {a == b : T}"), cy(r)))

# Module: src/check/kernel.bend:1007
@unsafe
def check_rwt_goal(e, ctx, t, dem, ty, r, eq, fresh):
  kc(KChecked, compare(cb(e), kapply(kapply(kid(t, 1), kid(eq, 1)), kid(t, 0)), ty, True{}),
   u => both(r, both(check(e, ctx, kid(t, 1), 0, all(1, "_", fresh, kid(eq, 2), all(1, "e", U32.add(fresh, 1), kt("Eql", "", 0, 0, Con{kid(eq, 0), Con{var("_", fresh), Con{kid(eq, 2), Nil{}}}}), typ(1)))), check(e, ctx, kid(t, 2), dem, kapply(kapply(kid(t, 1), kid(eq, 0)), atom("Rfl"))), t, ty, False{}), t, ty, False{}),
   u => dg_bad_detail("rewrite motive does not fit goal", ty, kapply(kapply(kid(t, 1), kid(eq, 1)), kid(t, 0))))

# Module: src/check/kernel.bend:1013
@unsafe
def tele_quantities(book, ty, n):
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => Nil{}, u => tele_quantities_head(book, wnf(book, ty), n))

# Module: src/check/kernel.bend:1017
@unsafe
def tele_quantities_head(book, ty, n):
  Con{qua(kc(U32, String.eq(tg(ty), "All"), u => qt(ty), u => 1)), tele_quantities(book, kid(ty, 1), U32.sub(n, 1))}

# Module: src/check/kernel.bend:1021
@unsafe
def declared(d):
  KDef{dn(d), dk(d), da(d), dx(d), dt(d), atom("Absent"), dc(d), db(d), du(d)}

# Module: src/check/kernel.bend:1025
@unsafe
def book_without(book, name):
  match book:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      kc(List<&2, KDef>, String.eq(dn(h), name), u => book_without(t, name), u => Con{h, book_without(t, name)})

# Module: src/check/kernel.bend:1033
@unsafe
def check_book(book):
  check_events(book, book_cached(Nil{}, norm_max_book(book)))

# Module: src/check/kernel.bend:1037
@unsafe
def check_events(todo, done):
  match todo:
    case Nil{}:
      check_open(done)
    case Con{d, rest}:
      check_event_guard(rest, done, d, event_error(done, d, lookup(done, dn(d))))

# Module: src/check/kernel.bend:1045
@unsafe
def check_open(book):
  check_open_message(count_open(book))

# Module: src/check/kernel.bend:1049
@unsafe
def count_open(book):
  match book:
    case Nil{}:
      0
    case Con{d, rest}:
      U32.add(kc(U32, String.eq(dk(d), "Def") && String.eq(tg(dv(d)), "Absent") && Bool.not(db(d)), u => 1, u => 0), count_open(rest))

# Module: src/check/kernel.bend:1057
@unsafe
def check_open_message(n):
  kc(String, U32.is_eq(n, 0), u => "", u => U32.show(n) ++ " TODO" ++ kc(String, U32.is_eq(n, 1), u => "", u => "s") ++ " found.\nThe code is incomplete, and not a valid proof yet.")

# Module: src/check/kernel.bend:1061
@unsafe
def check_event_guard(rest, done, d, err):
  kc(String, String.eq(err, ""), u => check_event_done(rest, done, d, check_definition(book_put(done, declared(d)), signature_mode(d, rest))), u => dn(d) ++ ": " ++ err)

# Module: src/check/kernel.bend:1065
@unsafe
def signature_mode(d, later):
  kc(KDef, String.eq(dk(d), "Def") && String.eq(tg(dv(d)), "Absent") && Bool.not(du(d)), u => signature_fill_mode(d, lookup(later, dn(d))), u => d)

# Module: src/check/kernel.bend:1069
@unsafe
def signature_fill_mode(d, fill):
  KDef{dn(d), dk(d), da(d), dx(d), dt(d), dv(d), dc(d), db(d), du(d) || (String.eq(dk(fill), "Def") && Bool.not(String.eq(tg(dv(fill)), "Absent")) && du(fill))}

# Module: src/check/kernel.bend:1073
@unsafe
def event_error(done, d, old):
  kc(String, String.eq(dk(old), "Absent"), u => kc(String, String.eq(dk(d), "ADT"), u => constructor_names(done, dc(d), Nil{}), u => ""), u => kc(String, String.eq(dk(old), "Def") && String.eq(dk(d), "Def") && String.eq(tg(dv(old)), "Absent") && Bool.not(String.eq(tg(dv(d)), "Absent")), u => kc(String, compare(done, dt(old), dt(d), False{}) && U32.is_eq(dx(old), dx(d)), u => "", u => "definition does not match prior law signature"), u => "duplicate declaration"))

# Module: src/check/kernel.bend:1077
@unsafe
def constructor_exists(ds, name):
  match ds:
    case Nil{}:
      False{}
    case Con{h, rest}:
      Bool.not(String.eq(dk(lookup(dc(h), name)), "Absent")) || constructor_exists(rest, name)

# Module: src/check/kernel.bend:1085
@unsafe
def constructor_names(done, ctrs, names):
  match ctrs:
    case Nil{}:
      ""
    case Con{h, rest}:
      kc(String, has_name(names, dn(h)) || constructor_exists(done, dn(h)), u => "duplicate constructor name", u => constructor_names(done, rest, Con{dn(h), names}))

# Module: src/check/kernel.bend:1093
@unsafe
def check_event_done(rest, done, d, err):
  kc(String, String.eq(err, ""), u => check_events(rest, book_put(done, d)), u => String.append(dn(d), String.append(": ", err)))

# Module: src/check/kernel.bend:1097
@unsafe
def check_definition(book, d):
  check_definition_type(book, d, KEnv{book, dn(d), ref(dn(d)), 0, Nil{}, du(d)}, check(KEnv{book, dn(d), ref(dn(d)), 0, Nil{}, du(d)}, Nil{}, dt(d), 0, typ(1)))

# Module: src/check/kernel.bend:1101
@unsafe
def check_definition_type(book, d, e, r):
  kc(String, good(r), u => kc(String, String.eq(dk(d), "ADT"), u => check_adt_declaration(e, d),
   u => kc(String, String.eq(tg(dv(d)), "Absent"), u => "", u => kc(String, String.eq(tg(dv(d)), "Foreign"), u => check_foreign(book, d), u => check_template_definition(book, d, dt(d), dv(d), ref(dn(d)), dx(d))))), u => ce(r))

# Module: src/check/kernel.bend:1106
@unsafe
def foreign_tip(t):
  kc(KTerm, String.eq(tg(strip(t)), "All"), u => foreign_tip(kid(strip(t), 1)), u => strip(t))

# Module: src/check/kernel.bend:1110
@unsafe
def foreign_head(t):
  kc(KTerm, String.eq(tg(t), "App"), u => foreign_head(kid(t, 0)), u => t)

# Module: src/check/kernel.bend:1114
@unsafe
def check_foreign(book, d):
  kc(String, U32.is_eq(dx(d), 0) && String.eq(tg(foreign_head(foreign_tip(dt(d)))), "Ref") && String.eq(nm(foreign_head(foreign_tip(dt(d)))), "IO") && String.eq(dk(lookup(book, "IO")), "Def") && db(lookup(book, "IO")), u => "", u => "foreign definition must return base IO directly")

# Module: src/check/kernel.bend:1118
@unsafe
def tele_tip(book, t):
  tele_tip_head(book, wnf(book, t))

# Module: src/check/kernel.bend:1122
@unsafe
def tele_tip_head(book, t):
  kc(KTerm, String.eq(tg(t), "All"), u => tele_tip(book, kid(t, 1)), u => t)

# Module: src/check/kernel.bend:1126
@unsafe
def check_adt_declaration(e, d):
  kc(String, String.eq(tg(tele_tip(cb(e), dt(d))), "Typ"), u => check_ctors(e, d, dc(d), dt(d)), u => "datatype declaration must return a kind")

# Module: src/check/kernel.bend:1130
@unsafe
def check_ctors(e, d, ctrs, kind):
  match ctrs:
    case Nil{}:
      ""
    case Con{h, t}:
      check_ctors_next(e, d, t, kind, check_ctor_tel(e, d, dt(h), kind, da(d), da(h), Nil{}, Nil{}))

# Module: src/check/kernel.bend:1138
@unsafe
def check_ctors_next(e, d, rest, kind, err):
  kc(String, String.eq(err, ""), u => check_ctors(e, d, rest, kind), u => err)

# Module: src/check/kernel.bend:1142
@unsafe
def check_ctor_tel(e, d, tel, kind, params, fields, ctx, args):
  kc(String, U32.is_eq(U32.add(params, fields), 0), u => kc(String, compare(cb(e), tel, kt("ADT", dn(d), 0, 0, args), False{}), u => "", u => "constructor result must apply family to its parameters"), u => check_ctor_head(e, d, wnf(cb(e), tel), kind, params, fields, ctx, args))

# Module: src/check/kernel.bend:1146
@unsafe
def check_ctor_head(e, d, tel, kind, params, fields, ctx, args):
  kc(String, String.eq(tg(tel), "All"), u => check_ctor_domain(e, d, tel, kind, params, fields, ctx, args, check(e, ctx, kid(tel, 0), 0, kc(KTerm, U32.is_eq(params, 0) && U32.is_eq(qt(tel), 1), u => kind, u => typ(qt(tel))))), u => "constructor telescope missing a binder")

# Module: src/check/kernel.bend:1150
@unsafe
def check_ctor_domain(e, d, tel, kind, params, fields, ctx, args, r):
  kc(String, good(r), u => check_ctor_tel(e, d, kid(tel, 1), kc(KTerm, U32.is_eq(params, 0), u => kind, u => subst(kid(wnf(cb(e), kind), 1), ix(wnf(cb(e), kind)), var(nm(tel), ix(tel)))), kc(U32, U32.is_eq(params, 0), u => 0, u => U32.sub(params, 1)), kc(U32, U32.is_eq(params, 0), u => U32.sub(fields, 1), u => fields), ctx_bind(ctx, ix(tel), qt(tel), nm(tel), kid(tel, 0)), kc(List<&2, KTerm>, U32.is_eq(params, 0), u => args, u => norm_join(args, Con{var(nm(tel), ix(tel)), Nil{}}))), u => ce(r))

# Module: src/check/kernel.bend:1154
@unsafe
def infer_template(e, t, dem, sp, d):
  kc(KChecked, U32.is_eq(dx(d), 0) || U32.is_gt(dx(lookup(cb(e), cn(e))), 0), u => ok(t, dt(d), Nil{}), u => checked(template_args(e, dt(d), sp, dx(d)), t, dt(d)))

# Module: src/check/kernel.bend:1158
@unsafe
def template_args(e, ty, sp, n):
  kc(KChecked, U32.is_eq(n, 0), u => ok(atom("Args"), ty, Nil{}), u => template_arg_head(e, wnf(cb(e), ty), sp, n))

# Module: src/check/kernel.bend:1162
@unsafe
def template_arg_head(e, ty, sp, n):
  match sp:
    case Nil{}:
      bad("template requires all closed comptime arguments")
    case Con{h, t}:
      kc(KChecked, String.eq(tg(ty), "All"), u => template_arg_done(e, ty, h, t, n, check(e, Nil{}, h, 0, kid(ty, 0))), u => bad("invalid template telescope"))

# Module: src/check/kernel.bend:1170
@unsafe
def template_arg_done(e, ty, h, rest, n, r):
  kc(KChecked, good(r), u => template_args(e, subst(kid(ty, 1), ix(ty), h), rest, U32.sub(n, 1)), u => bad("template argument is open or ill-typed"))

# Module: src/check/kernel.bend:1174
@unsafe
def self_pending(d, body):
  kc(U32, Bool.not(du(d)) && contains_self(Con{body, Nil{}}, dn(d)), u => U32.sub(da(d), dx(d)), u => 0)

# Module: src/check/kernel.bend:1178
@unsafe
def contains_self(todo, name):
  match todo:
    case Nil{}:
      False{}
    case Con{h, rest}:
      kc(Bool, String.eq(tg(h), "Ref") && String.eq(nm(h), name), u => True{}, u => contains_self(norm_join(ks(h), rest), name))

# Module: src/check/kernel.bend:1186
@unsafe
def check_template_definition(book, d, ty, body, lhs, n):
  kc(String, U32.is_eq(n, 0), u => ce(check(KEnv{book, dn(d), lhs, self_pending(d, body), tele_quantities(book, dt(d), da(d)), du(d)}, Nil{}, body, 1, ty)), u => check_template_binder(book, d, wnf(book, ty), body, lhs, n))

# Module: src/check/kernel.bend:1190
@unsafe
def check_template_binder(book, d, ty, body, lhs, n):
  kc(String, String.eq(tg(ty), "All"), u => check_template_open(book, d, ty, body, lhs, n, dn(d) ++ "~" ++ nm(ty) ++ U32.show(ix(ty))), u => "template telescope is too short")

# Module: src/check/kernel.bend:1194
@unsafe
def check_template_open(book, d, ty, body, lhs, n, name):
  check_template_definition(book_put(book, KDef{name, "Def", 0, 0, kid(ty, 0), atom("Absent"), Nil{}, True{}, False{}}), d, subst(kid(ty, 1), ix(ty), ref(name)), kapply(body, ref(name)), app(lhs, ref(name)), U32.sub(n, 1))

# Module: src/check/specialize.bend:520
@unsafe
def specialized_book(r):
  match r:
    case KSpecialized{book, error}:
      book

# Module: src/check/specialize.bend:526
@unsafe
def specialized_error(r):
  match r:
    case KSpecialized{book, error}:
      error

# Module: src/check/specialize.bend:532
@unsafe
def sp_book(st):
  match st:
    case KSpecState{book, memo, serial, fresh, error, templates}:
      book

# Module: src/check/specialize.bend:538
@unsafe
def sp_memo(st):
  match st:
    case KSpecState{book, memo, serial, fresh, error, templates}:
      memo

# Module: src/check/specialize.bend:544
@unsafe
def sp_serial(st):
  match st:
    case KSpecState{book, memo, serial, fresh, error, templates}:
      serial

# Module: src/check/specialize.bend:550
@unsafe
def sp_fresh(st):
  match st:
    case KSpecState{book, memo, serial, fresh, error, templates}:
      fresh

# Module: src/check/specialize.bend:556
@unsafe
def sp_error(st):
  match st:
    case KSpecState{book, memo, serial, fresh, error, templates}:
      error

# Module: src/check/specialize.bend:562
@unsafe
def sp_state(r):
  match r:
    case KSpecTerm{state, term}:
      state

# Module: src/check/specialize.bend:568
@unsafe
def sp_value(r):
  match r:
    case KSpecTerm{state, term}:
      term

# Module: src/check/specialize.bend:574
@unsafe
def sp_states(r):
  match r:
    case KSpecTerms{state, terms}:
      state

# Module: src/check/specialize.bend:580
@unsafe
def sp_values(r):
  match r:
    case KSpecTerms{state, terms}:
      terms

# Module: src/check/specialize.bend:586
@unsafe
def sp_mtemplate(m):
  match m:
    case KSpecMemo{template, key, name, active}:
      template

# Module: src/check/specialize.bend:592
@unsafe
def sp_mkey(m):
  match m:
    case KSpecMemo{template, key, name, active}:
      key

# Module: src/check/specialize.bend:598
@unsafe
def sp_mname(m):
  match m:
    case KSpecMemo{template, key, name, active}:
      name

# Module: src/check/specialize.bend:604
@unsafe
def sp_active(m):
  match m:
    case KSpecMemo{template, key, name, active}:
      active

# Module: src/check/specialize.bend:610
@unsafe
def sp_fail(st, err):
  KSpecState{sp_book(st), sp_memo(st), sp_serial(st), sp_fresh(st), kc(String, String.eq(sp_error(st), ""), u => err, u => sp_error(st)), sp_templates(st)}

# Module: src/check/specialize.bend:614
@unsafe
def sp_put(st, d):
  KSpecState{Con{d, book_without(sp_book(st), dn(d))}, sp_memo(st), sp_serial(st), sp_fresh(st), sp_error(st), sp_templates(st)}

# Module: src/check/specialize.bend:618
@unsafe
def sp_canonical(book, done):
  match book:
    case Nil{}:
      done
    case Con{h, rest}:
      sp_canonical(rest, Con{h, book_without(done, dn(h))})

# Module: src/check/specialize.bend:626
@unsafe
def specialize_book(book):
  sp_finish(sp_definitions(book, sp_initial(sp_canonical(book, Nil{}), norm_max_book(book))))

# Module: src/check/specialize.bend:630
@unsafe
def sp_finish(st):
  KSpecialized{book_without(sp_book(st), "$kernel.max-id"), sp_error(st)}

# Module: src/check/specialize.bend:634
@unsafe
def sp_definitions(todo, st):
  match todo:
    case Nil{}:
      st
    case Con{d, rest}:
      kc(KSpecState, String.eq(sp_error(st), ""), u => sp_definition_next(rest, st, d), u => st)

# Module: src/check/specialize.bend:642
@unsafe
def sp_definition_next(rest, st, d):
  kc(KSpecState, U32.is_gt(dx(d), 0) || String.eq(tg(dv(d)), "Absent") || String.eq(dk(d), "ADT") || Bool.not(sp_needed(sp_templates(st), dv(d))), u => sp_definitions(rest, st), u => sp_definition_done(rest, d, sp_term(st, dv(d), Nil{}, dt(d), dn(d), 0)))

# Module: src/check/specialize.bend:646
@unsafe
def sp_definition_done(rest, d, r):
  sp_definitions(rest, sp_put(sp_state(r), KDef{dn(d), dk(d), da(d), dx(d), dt(d), sp_value(r), dc(d), db(d), du(d)}))

# Module: src/check/specialize.bend:650
@unsafe
def sp_len(s):
  U32.from_nat(String.length(s))

# Module: src/check/specialize.bend:654
@unsafe
def sp_key_string(s):
  U32.show(sp_len(s)) ++ ":" ++ s

# Module: src/check/specialize.bend:658
@unsafe
def term_key(t):
  sp_key_string(tg(t)) ++ sp_key_string(nm(t)) ++ U32.show(ix(t)) ++ ":" ++ U32.show(qt(t)) ++ "[" ++ sp_keys(ks(t)) ++ "][" ++ sp_name_keys(rm(t)) ++ "]"

# Module: src/check/specialize.bend:662
@unsafe
def sp_keys(ts):
  match ts:
    case Nil{}:
      ""
    case Con{h, rest}:
      term_key(h) ++ sp_keys(rest)

# Module: src/check/specialize.bend:670
@unsafe
def sp_name_keys(ns):
  match ns:
    case Nil{}:
      ""
    case Con{h, rest}:
      sp_key_string(h) ++ sp_name_keys(rest)

# Module: src/check/specialize.bend:678
@unsafe
def sp_find(ms, name, key):
  match ms:
    case Nil{}:
      KSpecMemo{"", "", "", False{}}
    case Con{h, rest}:
      kc(KSpecMemo, String.eq(sp_mtemplate(h), name) && String.eq(sp_mkey(h), key), u => h, u => sp_find(rest, name, key))

# Module: src/check/specialize.bend:686
@unsafe
def sp_done_memo(ms, name):
  match ms:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      Con{kc(KSpecMemo, String.eq(sp_mname(h), name), u => KSpecMemo{sp_mtemplate(h), sp_mkey(h), sp_mname(h), False{}}, u => h), sp_done_memo(rest, name)}

# Module: src/check/specialize.bend:694
@unsafe
def sp_take(ts, n):
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => Nil{}, u => sp_take_next(ts, n))

# Module: src/check/specialize.bend:698
@unsafe
def sp_take_next(ts, n):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      Con{h, sp_take(rest, U32.sub(n, 1))}

# Module: src/check/specialize.bend:706
@unsafe
def sp_drop(ts, n):
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => ts, u => sp_drop_next(ts, n))

# Module: src/check/specialize.bend:710
@unsafe
def sp_drop_next(ts, n):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      sp_drop(rest, U32.sub(n, 1))

# Module: src/check/specialize.bend:718
@unsafe
def sp_shift(t, offset):
  KTerm{tg(t), nm(t), kc(U32, String.eq(tg(t), "Var") || String.eq(tg(t), "All") || String.eq(tg(t), "Lam") || String.eq(tg(t), "Bind") || String.eq(tg(t), "Sub"), u => U32.add(ix(t), offset), u => ix(t)), qt(t), sp_shifts(ks(t), offset), rm(t)}

# Module: src/check/specialize.bend:722
@unsafe
def sp_shifts(ts, offset):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      Con{sp_shift(h, offset), sp_shifts(rest, offset)}

# Module: src/check/specialize.bend:730
@unsafe
def sp_type(st, t, ctx, owner):
  cy(infer(KEnv{sp_book(st), owner, ref(owner), 0, Nil{}, True{}}, ctx, t, 0, Nil{}))

# Module: src/check/specialize.bend:734
@unsafe
def sp_term(st, t, ctx, goal, owner, depth):
  kc(KSpecTerm, Bool.not(String.eq(sp_error(st), "")), u => KSpecTerm{st, t},
   u => kc(KSpecTerm, String.eq(tg(t), "App") || String.eq(tg(t), "Ref"), u => sp_spine(st, t, Nil{}, ctx, owner, depth),
   u => kc(KSpecTerm, String.eq(tg(t), "Ann"), u => sp_annotation(t, sp_term(st, kid(t, 0), ctx, kid(t, 1), owner, depth)),
   u => kc(KSpecTerm, String.eq(tg(t), "Lam"), u => sp_lambda(st, t, ctx, wnf(sp_book(st), goal), owner, depth),
   u => kc(KSpecTerm, String.eq(tg(t), "Mat"), u => sp_match(st, t, ctx, wnf(sp_book(st), goal), owner, depth),
   u => kc(KSpecTerm, String.eq(tg(t), "Ctr"), u => sp_constructor(st, t, ctx, wnf(sp_book(st), goal), owner, depth),
   u => kc(KSpecTerm, String.eq(tg(t), "Let"), u => sp_let_result(t, sp_let(st, ks(t), ctx, ctx, goal, owner, depth)),
   u => kc(KSpecTerm, String.eq(tg(t), "Rwt"), u => sp_rewrite(st, t, ctx, owner, depth),
   u => KSpecTerm{st, t}))))))))

# Module: src/check/specialize.bend:746
@unsafe
def sp_annotation(t, r):
  KSpecTerm{sp_state(r), KTerm{tg(t), nm(t), ix(t), qt(t), Con{sp_value(r), Con{kid(t, 1), Nil{}}}, rm(t)}}

# Module: src/check/specialize.bend:750
@unsafe
def sp_lambda(st, t, ctx, goal, owner, depth):
  sp_single(t, sp_term(st, kid(t, 0), ctx_bind(ctx, ix(t), qt(goal), nm(t), kid(goal, 0)), subst(kid(goal, 1), ix(goal), var(nm(t), ix(t))), owner, depth))

# Module: src/check/specialize.bend:754
@unsafe
def sp_single(t, r):
  KSpecTerm{sp_state(r), KTerm{tg(t), nm(t), ix(t), qt(t), Con{sp_value(r), Nil{}}, rm(t)}}

# Module: src/check/specialize.bend:758
@unsafe
def sp_constructor(st, t, ctx, goal, owner, depth):
  sp_ctor_done(t, sp_args(st, ks(t), ctx, tele_fill(sp_book(st), dt(lookup(dc(lookup(sp_book(st), nm(goal))), nm(t))), ks(goal)), owner, depth))

# Module: src/check/specialize.bend:762
@unsafe
def sp_ctor_done(t, r):
  KSpecTerm{sp_states(r), KTerm{tg(t), nm(t), ix(t), qt(t), sp_values(r), rm(t)}}

# Module: src/check/specialize.bend:766
@unsafe
def sp_args(st, xs, ctx, ty, owner, depth):
  match xs:
    case Nil{}:
      KSpecTerms{st, Nil{}}
    case Con{x, rest}:
      sp_arg_head(st, x, rest, ctx, wnf(sp_book(st), ty), owner, depth)

# Module: src/check/specialize.bend:774
@unsafe
def sp_arg_head(st, x, rest, ctx, ty, owner, depth):
  sp_arg_done(x, rest, ctx, ty, owner, depth, kc(KSpecTerm, String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 0), u => KSpecTerm{st, x}, u => sp_term(st, x, ctx, kid(ty, 0), owner, depth)))

# Module: src/check/specialize.bend:778
@unsafe
def sp_arg_done(raw, rest, ctx, ty, owner, depth, r):
  sp_cons(sp_value(r), sp_args(sp_state(r), rest, ctx, subst(kid(ty, 1), ix(ty), raw), owner, depth))

# Module: src/check/specialize.bend:782
@unsafe
def sp_cons(h, r):
  KSpecTerms{sp_states(r), Con{h, sp_values(r)}}

# Module: src/check/specialize.bend:786
@unsafe
def sp_spine(st, t, xs, ctx, owner, depth):
  kc(KSpecTerm, String.eq(tg(t), "App"), u => sp_spine(st, kid(t, 0), Con{kid(t, 1), xs}, ctx, owner, depth), u => sp_head(st, t, xs, ctx, owner, depth, lookup(sp_book(st), nm(strip(t)))))

# Module: src/check/specialize.bend:790
@unsafe
def sp_head(st, head, xs, ctx, owner, depth, d):
  kc(KSpecTerm, String.eq(tg(strip(head)), "Ref") && U32.is_gt(dx(d), 0), u => sp_template(st, d, xs, ctx, owner, depth), u => sp_regular_head(st, head, xs, ctx, owner, depth))

# Module: src/check/specialize.bend:794
@unsafe
def sp_regular_head(st, head, xs, ctx, owner, depth):
  sp_regular_done(xs, ctx, owner, depth, sp_type(st, head, ctx, owner), kc(KSpecTerm, String.eq(tg(head), "Ref"), u => KSpecTerm{st, head}, u => sp_term(st, head, ctx, sp_type(st, head, ctx, owner), owner, depth)))

# Module: src/check/specialize.bend:798
@unsafe
def sp_regular_done(xs, ctx, owner, depth, ty, r):
  sp_apply_result(sp_value(r), sp_args(sp_state(r), xs, ctx, ty, owner, depth))

# Module: src/check/specialize.bend:802
@unsafe
def sp_apply_result(head, r):
  KSpecTerm{sp_states(r), norm_apply(head, sp_values(r))}

# Module: src/check/specialize.bend:806
@unsafe
def sp_template(st, d, xs, ctx, owner, depth):
  kc(KSpecTerm, U32.is_lt(terms_len(xs), dx(d)), u => KSpecTerm{sp_fail(st, "template requires all closed comptime arguments"), norm_apply(ref(dn(d)), xs)}, u => sp_template_args(st, d, sp_take(xs, dx(d)), sp_drop(xs, dx(d)), ctx, owner, depth))

# Module: src/check/specialize.bend:810
@unsafe
def sp_template_args(st, d, closed, rest, ctx, owner, depth):
  sp_template_checked(st, d, closed, rest, ctx, owner, depth, template_args(KEnv{sp_book(st), owner, ref(owner), 0, Nil{}, du(d)}, dt(d), closed, dx(d)))

# Module: src/check/specialize.bend:814
@unsafe
def sp_template_checked(st, d, closed, rest, ctx, owner, depth, checked):
  kc(KSpecTerm, good(checked), u => sp_template_key(st, d, closed, rest, ctx, owner, depth, sp_keys(closed)), u => KSpecTerm{sp_fail(st, ce(checked)), norm_apply(ref(dn(d)), norm_join(closed, rest))})

# Module: src/check/specialize.bend:818
@unsafe
def sp_template_key(st, d, closed, rest, ctx, owner, depth, key):
  kc(KSpecTerm, U32.is_gt(sp_len(key), 32768), u => KSpecTerm{sp_fail(st, "a comptime argument must stop growing"), ref(dn(d))}, u => sp_template_inst(rest, ctx, owner, depth, sp_instance(st, d, closed, owner, depth, key, sp_find(sp_memo(st), dn(d), key))))

# Module: src/check/specialize.bend:822
@unsafe
def sp_template_inst(rest, ctx, owner, depth, r):
  sp_apply_result(sp_value(r), sp_args(sp_state(r), rest, ctx, dt(lookup(sp_book(sp_state(r)), nm(sp_value(r)))), owner, depth))

# Module: src/check/specialize.bend:826
@unsafe
def sp_instance(st, d, xs, owner, depth, key, memo):
  kc(KSpecTerm, Bool.not(String.eq(sp_mname(memo), "")),
   u => kc(KSpecTerm, sp_active(memo) && Bool.not(String.eq(sp_mname(memo), owner)), u => KSpecTerm{sp_fail(st, "nondecreasing cross-instance template recursion"), ref(sp_mname(memo))}, u => KSpecTerm{st, ref(sp_mname(memo))}),
   u => kc(KSpecTerm, U32.is_ge(depth, 64), u => KSpecTerm{sp_fail(st, "template instantiation exceeds 64 levels"), ref(dn(d))}, u => sp_mint(st, d, xs, U32.add(depth, 1), key, dn(d) ++ "~" ++ U32.show(sp_serial(st)))))

# Module: src/check/specialize.bend:832
@unsafe
def sp_mint(st, d, xs, depth, key, name):
  sp_mint_type(st, d, xs, depth, key, name, tele_fill(sp_book(st), sp_shift(dt(d), sp_fresh(st)), xs), sp_apply_template(sp_shift(dv(d), sp_fresh(st)), xs))

# Module: src/check/specialize.bend:836
@unsafe
def sp_apply_template(body, xs):
  match xs:
    case Nil{}:
      body
    case Con{h, rest}:
      sp_apply_template(kapply(body, h), rest)

# Module: src/check/specialize.bend:844
@unsafe
def sp_mint_type(st, d, xs, depth, key, name, ty, body):
  sp_mint_body(d, name, ty, sp_term(KSpecState{Con{KDef{name, "Def", U32.sub(da(d), dx(d)), 0, ty, atom("Absent"), Nil{}, False{}, du(d)}, sp_stamp(sp_book(st), U32.add(sp_fresh(st), norm_max(norm_max_term(dt(d)), norm_max_term(dv(d)))))}, Con{KSpecMemo{dn(d), key, name, True{}}, sp_memo(st)}, U32.add(sp_serial(st), 1), U32.add(U32.add(sp_fresh(st), norm_max(norm_max_term(dt(d)), norm_max_term(dv(d)))), 1), sp_error(st), sp_templates(st)}, body, Nil{}, ty, name, depth))

# Module: src/check/specialize.bend:848
@unsafe
def sp_mint_body(d, name, ty, r):
  sp_validate(sp_state(r), KDef{name, "Def", U32.sub(da(d), dx(d)), 0, ty, sp_value(r), Nil{}, False{}, du(d)})

# Module: src/check/specialize.bend:852
@unsafe
def sp_validate(st, d):
  kc(KSpecTerm, String.eq(sp_error(st), ""), u => sp_validate_done(st, d, check_definition(sp_book(st), d)), u => KSpecTerm{st, ref(dn(d))})

# Module: src/check/specialize.bend:856
@unsafe
def sp_validate_done(st, d, error):
  kc(KSpecTerm, String.eq(error, ""), u => KSpecTerm{KSpecState{Con{d, book_without(sp_book(st), dn(d))}, sp_done_memo(sp_memo(st), dn(d)), sp_serial(st), sp_fresh(st), sp_error(st), sp_templates(st)}, ref(dn(d))}, u => KSpecTerm{sp_fail(st, dn(d) ++ ": " ++ error), ref(dn(d))})

# Module: src/check/specialize.bend:860
@unsafe
def sp_match(st, t, ctx, goal, owner, depth):
  sp_match_type(st, t, ctx, goal, owner, depth, wnf(sp_book(st), kid(goal, 0)))

# Module: src/check/specialize.bend:864
@unsafe
def sp_match_type(st, t, ctx, goal, owner, depth, a):
  sp_match_ctor(st, t, ctx, goal, owner, depth, a, lookup(dc(lookup(sp_book(st), nm(a))), nm(t)))

# Module: src/check/specialize.bend:868
@unsafe
def sp_match_ctor(st, t, ctx, goal, owner, depth, a, ctr):
  sp_match_hit(t, ctx, goal, owner, depth, a, sp_term(st, kid(t, 0), ctx, mat_goal(sp_book(st), goal, tele_fill(sp_book(st), dt(ctr), ks(a)), da(ctr), nm(t), Nil{}), owner, depth))

# Module: src/check/specialize.bend:872
@unsafe
def sp_match_hit(t, ctx, goal, owner, depth, a, r):
  sp_pair(t, sp_value(r), sp_term(sp_state(r), kid(t, 1), ctx, all(qt(goal), nm(goal), ix(goal), KTerm{tg(a), nm(a), ix(a), qt(a), ks(a), Con{nm(t), rm(a)}}, kid(goal, 1)), owner, depth))

# Module: src/check/specialize.bend:876
@unsafe
def sp_pair(t, h, r):
  KSpecTerm{sp_state(r), KTerm{tg(t), nm(t), ix(t), qt(t), Con{h, Con{sp_value(r), Nil{}}}, rm(t)}}

# Module: src/check/specialize.bend:880
@unsafe
def sp_let(st, xs, outer, ctx, goal, owner, depth):
  match xs:
    case Nil{}:
      KSpecTerms{sp_fail(st, "let has no body"), Nil{}}
    case Con{h, rest}:
      kc(KSpecTerms, String.eq(tg(h), "Bind"), u => sp_let_binding(st, h, rest, outer, ctx, goal, owner, depth, sp_type(st, kid(h, 0), outer, owner)), u => sp_let_body(sp_term(st, h, ctx, goal, owner, depth)))

# Module: src/check/specialize.bend:888
@unsafe
def sp_let_binding(st, h, rest, outer, ctx, goal, owner, depth, ty):
  sp_let_bound(h, rest, outer, ctx, goal, owner, depth, ty, kc(KSpecTerm, U32.is_eq(qt(h), 0), u => KSpecTerm{st, kid(h, 0)}, u => sp_term(st, kid(h, 0), outer, ty, owner, depth)))

# Module: src/check/specialize.bend:892
@unsafe
def sp_let_bound(h, rest, outer, ctx, goal, owner, depth, ty, r):
  sp_cons(KTerm{tg(h), nm(h), ix(h), qt(h), Con{sp_value(r), Nil{}}, rm(h)}, sp_let(sp_state(r), rest, outer, ctx_bind(ctx, ix(h), qt(h), nm(h), ty), goal, owner, depth))

# Module: src/check/specialize.bend:896
@unsafe
def sp_let_body(r):
  KSpecTerms{sp_state(r), Con{sp_value(r), Nil{}}}

# Module: src/check/specialize.bend:900
@unsafe
def sp_let_result(t, r):
  sp_ctor_done(t, r)

# Module: src/check/specialize.bend:904
@unsafe
def sp_rewrite(st, t, ctx, owner, depth):
  sp_rewrite_type(st, t, ctx, owner, depth, wnf(sp_book(st), sp_type(st, kid(t, 0), ctx, owner)))

# Module: src/check/specialize.bend:908
@unsafe
def sp_rewrite_type(st, t, ctx, owner, depth, eq):
  sp_rewrite_done(t, sp_term(st, kid(t, 2), ctx, app(app(kid(t, 1), kid(eq, 0)), atom("Rfl")), owner, depth))

# Module: src/check/specialize.bend:912
@unsafe
def sp_rewrite_done(t, r):
  KSpecTerm{sp_state(r), KTerm{tg(t), nm(t), ix(t), qt(t), Con{kid(t, 0), Con{kid(t, 1), Con{sp_value(r), Nil{}}}}, rm(t)}}

# Module: src/check/specialize.bend:937
@unsafe
def sp_initial(book, bound):
  KSpecState{sp_stamp(book, bound), Nil{}, 0, U32.add(bound, 1), "", sp_template_book(book)}

# Module: src/check/specialize.bend:941
@unsafe
def sp_stamp(book, bound):
  Con{KDef{"$kernel.max-id", "BookBound", bound, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, book_without(book, "$kernel.max-id")}

# Module: src/check/specialize.bend:945
@unsafe
def sp_needed(book, t):
  kc(Bool, String.eq(tg(t), "Ref"), u => U32.is_gt(dx(lookup(book, nm(t))), 0), u => sp_neededs(book, ks(t)))

# Module: src/check/specialize.bend:949
@unsafe
def sp_neededs(book, ts):
  match ts:
    case Nil{}:
      False{}
    case Con{h, rest}:
      kc(Bool, sp_needed(book, h), u => True{}, u => sp_neededs(book, rest))

# Module: src/check/specialize.bend:965
@unsafe
def sp_templates(st):
  match st:
    case KSpecState{book, memo, serial, fresh, error, templates}:
      templates

# Module: src/check/specialize.bend:971
@unsafe
def sp_template_book(book):
  match book:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      kc(List<&2, KDef>, U32.is_gt(dx(h), 0), u => Con{h, sp_template_book(rest)}, u => sp_template_book(rest))

# Module: src/check/prefix.bend:81
@unsafe
def exact_names(a, b):
  match a:
    case Nil{}:
      exact_names_empty(b)
    case Con{h, rest}:
      exact_names_head(h, rest, b)

# Module: src/check/prefix.bend:89
@unsafe
def exact_names_empty(b):
  match b:
    case Nil{}:
      True{}
    case Con{h, rest}:
      False{}

# Module: src/check/prefix.bend:97
@unsafe
def exact_names_head(h, rest, b):
  match b:
    case Nil{}:
      False{}
    case Con{x, xs}:
      String.eq(h, x) && exact_names(rest, xs)

# Module: src/check/prefix.bend:105
@unsafe
def exact_term(a, b):
  String.eq(tg(a), tg(b)) && String.eq(nm(a), nm(b)) && U32.is_eq(ix(a), ix(b)) && U32.is_eq(qt(a), qt(b)) && exact_terms(ks(a), ks(b)) && exact_names(rm(a), rm(b))

# Module: src/check/prefix.bend:109
@unsafe
def exact_terms(a, b):
  match a:
    case Nil{}:
      U32.is_eq(terms_len(b), 0)
    case Con{h, rest}:
      exact_terms_head(h, rest, b)

# Module: src/check/prefix.bend:117
@unsafe
def exact_terms_head(h, rest, b):
  match b:
    case Nil{}:
      False{}
    case Con{x, xs}:
      exact_term(h, x) && exact_terms(rest, xs)

# Module: src/check/prefix.bend:125
@unsafe
def exact_def(a, b):
  String.eq(dn(a), dn(b)) && String.eq(dk(a), dk(b)) && U32.is_eq(da(a), da(b)) && U32.is_eq(dx(a), dx(b)) && Bool.not(Bool.xor(db(a), db(b))) && Bool.not(Bool.xor(du(a), du(b))) && exact_term(dt(a), dt(b)) && exact_term(dv(a), dv(b)) && exact_defs(dc(a), dc(b))

# Module: src/check/prefix.bend:129
@unsafe
def exact_defs(a, b):
  match a:
    case Nil{}:
      defs_empty(b)
    case Con{h, rest}:
      exact_defs_head(h, rest, b)

# Module: src/check/prefix.bend:137
@unsafe
def exact_defs_head(h, rest, b):
  match b:
    case Nil{}:
      False{}
    case Con{x, xs}:
      exact_def(h, x) && exact_defs(rest, xs)

# Module: src/check/prefix.bend:145
@unsafe
def exact_prefix(book, prefix):
  match prefix:
    case Nil{}:
      True{}
    case Con{h, rest}:
      exact_prefix_head(book, h, rest)

# Module: src/check/prefix.bend:153
@unsafe
def exact_prefix_head(book, h, rest):
  match book:
    case Nil{}:
      False{}
    case Con{x, xs}:
      exact_def(x, h) && exact_prefix(xs, rest)

# Module: src/check/prefix.bend:161
@unsafe
def check_from_exact_prefix(book, validated):
  kc(String, exact_prefix(book, validated), u => check_prefix_seed(book, validated, book_cached(Nil{}, norm_max_book(book))), u => check_book(book))

# Module: src/check/prefix.bend:165
@unsafe
def check_prefix_seed(book, validated, done):
  match validated:
    case Nil{}:
      check_events(book, done)
    case Con{h, rest}:
      check_prefix_step(book, h, rest, done)

# Module: src/check/prefix.bend:173
@unsafe
def check_prefix_step(book, h, rest, done):
  match book:
    case Nil{}:
      "invalid validated prefix"
    case Con{x, xs}:
      check_prefix_seed(xs, rest, book_put(done, h))

# Module: src/check/annotate.bend:145
@unsafe
def ka_wrap(t, ty):
  kt("Ann", "", 0, 0, Con{t, Con{ty, Nil{}}})

# Module: src/check/annotate.bend:149
@unsafe
def annotate_book(book):
  ka_defs(book_context(book), book)

# Module: src/check/annotate.bend:153
@unsafe
def annotate_except(book, stops):
  ka_defs_except(book_context(book), book, stops)

# Module: src/check/annotate.bend:157
@unsafe
def annotate_selected(book, selected, stops):
  ka_defs_except(book_context(book), selected, stops)

# Module: src/check/annotate.bend:161
@unsafe
def ka_defs_except(book, ds, stops):
  match ds:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      Con{kc(KDef, has_name(stops, dn(d)), u => d, u => ka_def(book, d)), ka_defs_except(book, rest, stops)}

# Module: src/check/annotate.bend:169
@unsafe
def ka_defs(book, ds):
  match ds:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      Con{ka_def(book, d), ka_defs(book, rest)}

# Module: src/check/annotate.bend:177
@unsafe
def ka_def(book, d):
  KDef{dn(d), dk(d), da(d), dx(d), dt(d), kc(KTerm, String.eq(tg(dv(d)), "Absent") || String.eq(tg(dv(d)), "Foreign") || U32.is_gt(dx(d), 0), u => dv(d), u => annotate(KEnv{book, dn(d), ref(dn(d)), 0, Nil{}, du(d)}, Nil{}, dv(d), dt(d))), dc(d), db(d), du(d)}

# Module: src/check/annotate.bend:181
@unsafe
def annotate(e, ctx, t, ty):
  ka_wrap(ka_node(e, ctx, core_beta(t), wnf(cb(e), ty)), ty)

# Module: src/check/annotate.bend:185
@unsafe
def ka_node(e, ctx, t, ty):
  kc(KTerm, String.eq(tg(t), "Ann"), u => ka_node(e, ctx, kid(t, 0), wnf(cb(e), kid(t, 1))),
   u => kc(KTerm, String.eq(tg(t), "Lam"), u => ka_lam(e, ctx, t, ty),
   u => kc(KTerm, String.eq(tg(t), "App"), u => ka_app(e, ctx, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0)))),
   u => kc(KTerm, String.eq(tg(t), "Ctr"), u => kt("Ctr", nm(t), ix(t), qt(t), ka_args(e, ctx, tele_fill(cb(e), dt(lookup(dc(lookup(cb(e), nm(ty))), nm(t))), ks(ty)), ks(t))),
   u => kc(KTerm, String.eq(tg(t), "Mat"), u => ka_mat(e, ctx, t, ty, wnf(cb(e), kid(ty, 0))),
   u => kc(KTerm, String.eq(tg(t), "Let"), u => kt("Let", nm(t), ix(t), qt(t), ka_let(e, ctx, ctx, ks(t), ty)),
   u => kc(KTerm, String.eq(tg(t), "Rwt"), u => ka_rwt(e, ctx, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0)))),
   u => t)))))))

# Module: src/check/annotate.bend:196
@unsafe
def ka_type(e, ctx, t):
  ka_type_node(e, ctx, core_beta(t))

# Module: src/check/annotate.bend:200
@unsafe
def ka_type_node(e, ctx, t):
  kc(KTerm, String.eq(tg(t), "Var"), u => kid(ctx_get(ctx, ix(t)), 0),
   u => kc(KTerm, String.eq(tg(t), "Ref"), u => dt(lookup(cb(e), nm(t))),
   u => kc(KTerm, String.eq(tg(t), "Ann"), u => kid(t, 1),
   u => kc(KTerm, String.eq(tg(t), "App"), u => ka_type_app(e, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0)))),
   u => kc(KTerm, String.eq(tg(t), "ADT"), u => tele_fill(cb(e), dt(lookup(cb(e), nm(t))), ks(t)),
   u => kc(KTerm, String.eq(tg(t), "Eql"), u => typ(2),
   u => kc(KTerm, String.eq(tg(t), "Qua") || String.eq(tg(t), "Min"), u => atom("Qnt"),
   u => kc(KTerm, String.eq(tg(t), "Typ") || String.eq(tg(t), "Qnt") || String.eq(tg(t), "All"), u => typ(1),
   u => atom("Error")))))))))

# Module: src/check/annotate.bend:212
@unsafe
def ka_type_app(e, t, fty):
  subst(kid(fty, 1), ix(fty), kid(t, 1))

# Module: src/check/annotate.bend:216
@unsafe
def ka_lam(e, ctx, t, ty):
  kt("Lam", nm(t), ix(t), kc(U32, U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => 2, u => qt(ty)), Con{annotate(e, ctx_bind(ctx, ix(t), qt(ty), nm(t), kid(ty, 0)), kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t)))), Nil{}})

# Module: src/check/annotate.bend:220
@unsafe
def ka_app(e, ctx, t, fty):
  app(annotate(e, ctx, kid(t, 0), fty), annotate(e, ctx, kid(t, 1), kid(fty, 0)))

# Module: src/check/annotate.bend:224
@unsafe
def ka_args(e, ctx, tel, xs):
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      ka_args_head(e, ctx, wnf(cb(e), tel), h, rest)

# Module: src/check/annotate.bend:232
@unsafe
def ka_args_head(e, ctx, tel, h, rest):
  Con{annotate(e, ctx, h, kid(tel, 0)), ka_args(e, ctx, subst(kid(tel, 1), ix(tel), h), rest)}

# Module: src/check/annotate.bend:236
@unsafe
def ka_mat(e, ctx, t, ty, a):
  ka_mat_ctr(e, ctx, t, ty, a, lookup(dc(lookup(cb(e), nm(a))), nm(t)))

# Module: src/check/annotate.bend:240
@unsafe
def ka_mat_ctr(e, ctx, t, ty, a, c):
  kt("Mat", nm(t), ix(t), qt(t), Con{annotate(e, ctx, kid(t, 0), mat_goal(cb(e), ty, tele_fill(cb(e), dt(c), ks(a)), da(c), nm(t), Nil{})), Con{annotate(e, ctx, kid(t, 1), all(qt(ty), nm(ty), ix(ty), KTerm{tg(a), nm(a), ix(a), qt(a), ks(a), Con{nm(t), rm(a)}}, kid(ty, 1))), Nil{}}})

# Module: src/check/annotate.bend:244
@unsafe
def ka_let(e, outer, ctx, xs, ty):
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      kc(List<&2, KTerm>, String.eq(tg(h), "Bind"), u => ka_let_head(e, outer, ctx, h, rest, ty, ka_type(e, outer, kid(h, 0))), u => Con{annotate(e, ctx, h, ty), Nil{}})

# Module: src/check/annotate.bend:252
@unsafe
def ka_let_head(e, outer, ctx, h, rest, ty, vty):
  Con{kt("Bind", nm(h), ix(h), qt(h), Con{annotate(e, outer, kid(h, 0), vty), Nil{}}), ka_let(e, outer, ctx_bind(ctx, ix(h), qt(h), nm(h), vty), subst_terms(rest, ix(h), kt("Var", nm(h), ix(h), 0, Con{kid(h, 0), Nil{}})), ty)}

# Module: src/check/annotate.bend:256
@unsafe
def ka_rwt(e, ctx, t, eq):
  kt("Rwt", nm(t), ix(t), qt(t), Con{annotate(e, ctx, kid(t, 0), eq), Con{kid(t, 1), Con{annotate(e, ctx, kid(t, 2), kapply(kapply(kid(t, 1), kid(eq, 0)), atom("Rfl"))), Nil{}}}})

# Module: src/front/lexer.bend:121
@unsafe
def f_choose(A, b, yes, no):
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# Module: src/front/lexer.bend:129
@unsafe
def f_eq(a, b):
  String.eq(a, b)

# Module: src/front/lexer.bend:133
@unsafe
def f_tx(ts):
  match ts:
    case Nil{}:
      "<eof>"
    case Con{FToken{t, l, c, k}, rest}:
      t

# Module: src/front/lexer.bend:141
@unsafe
def f_tl(ts):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      rest

# Module: src/front/lexer.bend:149
@unsafe
def f_line(ts):
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k}, rest}:
      l

# Module: src/front/lexer.bend:157
@unsafe
def f_col(ts):
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k}, rest}:
      c

# Module: src/front/lexer.bend:165
@unsafe
def f_kind(ts):
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k}, rest}:
      k

# Module: src/front/lexer.bend:173
@unsafe
def f_skip(ts):
  f_choose(List<&2, FToken>, Bool.or(f_eq(f_tx(ts), "\n"), f_eq(f_tx(ts), ";")),
    u => f_skip(f_tl(ts)), u => ts)

# Module: src/front/lexer.bend:178
@unsafe
def f_head(s):
  match s:
    case SNil{}:
      '\0'
    case SCon{h, t}:
      h

# Module: src/front/lexer.bend:186
@unsafe
def f_tail(s):
  match s:
    case SNil{}:
      ""
    case SCon{h, t}:
      t

# Module: src/front/lexer.bend:194
@unsafe
def f_ident(c):
  Char.is_alpha(c) || Char.is_digit(c) || Char.is_eq(c, '_') || Char.is_eq(c, '.')

# Module: src/front/lexer.bend:198
@unsafe
def f_scan_word(s, acc, n):
  f_choose(FScanned, f_ident(f_head(s)) || ((Char.is_eq(f_head(s), '+') || Char.is_eq(f_head(s), '-')) && (Char.is_eq(f_head(acc), 'e') || Char.is_eq(f_head(acc), 'E')) && Char.is_digit(f_head(f_tail(s)))),
    u => f_scan_word(f_tail(s), SCon{f_head(s), acc}, U32.add(n, 1)),
    u => FScanned{String.reverse(acc), s, n})

# Module: src/front/lexer.bend:204
@unsafe
def f_scan_comment(s):
  f_choose(String, String.is_empty(s) || Char.is_eq(f_head(s), '\n'),
    u => s, u => f_scan_comment(f_tail(s)))

# Module: src/front/lexer.bend:209
@unsafe
def f_scan_quote(s, quote, acc, n):
  f_choose(FScanned, String.is_empty(s),
    u => FScanned{"", "", 0},
    u => f_choose(FScanned, Char.is_eq(f_head(s), quote),
      u => FScanned{String.reverse(SCon{quote, acc}), f_tail(s), U32.add(n, 1)},
      u => f_choose(FScanned, Char.is_eq(f_head(s), '\\'),
        u => f_scan_quote(f_tail(f_tail(s)), quote, SCon{f_head(f_tail(s)), SCon{'\\', acc}}, U32.add(n, 2)),
        u => f_scan_quote(f_tail(s), quote, SCon{f_head(s), acc}, U32.add(n, 1)))))

# Module: src/front/lexer.bend:219
@unsafe
def f_two(s):
  SCon{f_head(s), SCon{f_head(f_tail(s)), ""}}

# Module: src/front/lexer.bend:223
@unsafe
def f_pair_op(s):
  f_eq(s, "->") || f_eq(s, "=>") || f_eq(s, "<-") || f_eq(s, "++") || f_eq(s, "<>") || f_eq(s, "==") || f_eq(s, "!=") || f_eq(s, "<=") || f_eq(s, ">=") || f_eq(s, "&&") || f_eq(s, "||") || f_eq(s, "<<") || f_eq(s, ">>")

# Module: src/front/lexer.bend:227
@unsafe
def f_lex_scanned(sc, l, c, d, k, acc):
  match sc:
    case FScanned{word, rest, size}:
      f_choose(List<&2, FToken>, U32.is_eq(size, 0),
        u => List.reverse(&2, FToken, Con{FToken{"unterminated string", l, c, 3}, acc}),
        u => f_lex(rest, l, U32.add(c, size), d, Con{FToken{word, l, c, k}, acc}))

# Module: src/front/lexer.bend:235
@unsafe
def f_lex_symbol(s, l, c, d, acc):
  f_choose(List<&2, FToken>, f_pair_op(f_two(s)) && Bool.not(f_eq(f_two(s), "++") && String.ends_with(f_tx(acc), "n") && U32.is_eq(c, U32.add(f_col(acc), U32.from_nat(String.length(f_tx(acc)))))),
    u => f_lex(f_tail(f_tail(s)), l, U32.add(c, 2), d, Con{FToken{f_choose(String, f_eq(f_two(s), ">>") && U32.is_gt(c, U32.add(f_col(acc), U32.from_nat(String.length(f_tx(acc))))), u => ">>op", u => f_two(s)), l, c, 0}, acc}),
    u => f_lex(f_tail(s), l, U32.add(c, 1),
      f_choose(U32, Char.is_eq(f_head(s), '(') || Char.is_eq(f_head(s), '[') || Char.is_eq(f_head(s), '{'),
        u => U32.add(d, 1),
        u => f_choose(U32, Char.is_eq(f_head(s), ')') || Char.is_eq(f_head(s), ']') || Char.is_eq(f_head(s), '}'),
          u => U32.sub(d, 1), u => d)),
      Con{FToken{f_symbol_text(s, c, acc), l, c, 0}, acc}))

# Module: src/front/lexer.bend:246
@unsafe
def f_lex(s, l, c, d, acc):
  f_choose(List<&2, FToken>, String.is_empty(s),
    u => List.reverse(&2, FToken, acc),
    u => f_choose(List<&2, FToken>, Char.is_eq(f_head(s), '\n'),
      u => f_lex(f_tail(s), U32.add(l, 1), 0, d,
        f_choose(List<&2, FToken>, U32.is_eq(d, 0), u => Con{FToken{"\n", l, c, 0}, acc}, u => acc)),
      u => f_choose(List<&2, FToken>, Char.is_space(f_head(s)),
        u => f_lex(f_tail(s), l, U32.add(c, 1), d, acc),
        u => f_choose(List<&2, FToken>, Char.is_eq(f_head(s), '#'),
          u => f_lex(f_scan_comment(s), l, c, d, acc),
          u => f_choose(List<&2, FToken>, Char.is_eq(f_head(s), '"') || Char.is_eq(f_head(s), '\''),
            u => f_lex_scanned(f_scan_quote(f_tail(s), f_head(s), SCon{f_head(s), ""}, 1), l, c, d, 2, acc),
            u => f_choose(List<&2, FToken>, f_triple_op(s),
              u => f_lex(f_tail(f_tail(f_tail(s))), l, U32.add(c, 3), d, Con{FToken{f_three(s), l, c, 0}, acc}),
            u => f_choose(List<&2, FToken>, f_ident(f_head(s)),
              u => f_lex_scanned(f_scan_word(s, "", 0), l, c, d, 1, acc),
              u => f_lex_symbol(s, l, c, d, acc))))))))

# Module: src/front/lexer.bend:265
@unsafe
def f_three(s):
  SCon{f_head(s), SCon{f_head(f_tail(s)), SCon{f_head(f_tail(f_tail(s))), ""}}}

# Module: src/front/lexer.bend:269
@unsafe
def f_triple_op(s):
  f_eq(f_three(s), ".&.") || f_eq(f_three(s), ".|.") || f_eq(f_three(s), ".^.") || f_eq(f_three(s), "<&>")

# Module: src/front/lexer.bend:273
@unsafe
def f_symbol_text(s, c, acc):
  f_choose(String, Char.is_eq(f_head(s), '+') && Char.is_alpha(f_head(f_tail(s))) && Bool.not(String.ends_with(f_tx(acc), "n") && U32.is_eq(U32.add(f_col(acc), U32.from_nat(String.length(f_tx(acc)))), c)),
    u => "+bind", u => f_choose(String, Char.is_eq(f_head(s), '>') && U32.is_gt(c, U32.add(f_col(acc), U32.from_nat(String.length(f_tx(acc))))), u => ">op", u => SCon{f_head(s), ""}))

# Module: src/front/parser.bend:197
@unsafe
def f_pn(p):
  match p:
    case FParsed{n, ts}:
      n

# Module: src/front/parser.bend:203
@unsafe
def f_pr(p):
  match p:
    case FParsed{n, ts}:
      ts

# Module: src/front/parser.bend:209
@unsafe
def f_atid(ts):
  U32.add(U32.mul(f_line(ts), 65536), f_col(ts))

# Module: src/front/parser.bend:213
@unsafe
def f_err(ts, msg):
  FParsed{kt("Error", "line " ++ U32.show(f_line(ts)) ++ ":" ++ U32.show(f_col(ts)) ++ ": " ++ msg ++ "; got " ++ f_tx(ts), 0, 0, Nil{}), Nil{}}

# Module: src/front/parser.bend:217
@unsafe
def f_expect(p, s):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Error") || f_eq(f_tx(ts), s), u => FParsed{n, f_tl(ts)}, u => f_err(ts, "expected " ++ s))

# Module: src/front/parser.bend:223
@unsafe
def f_app(f, xs):
  match xs:
    case Nil{}:
      f
    case Con{x, xt}:
      f_app(kt("App", "", 0, 1, [f, x]), xt)

# Module: src/front/parser.bend:231
@unsafe
def f_args_base(ts, end, acc):
  f_choose(FParsed, f_eq(f_tx(f_skip(ts)), end), u => FParsed{kt("Args", "", 0, 1, List.reverse(&2, KTerm, acc)), f_tl(f_skip(ts))}, u => f_arg_next(f_expr(f_skip(ts), 0), end, acc))

# Module: src/front/parser.bend:235
@unsafe
def f_arg_next(p, end, acc):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_args(f_choose(List<&2, FToken>, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), end, Con{n, acc}))

# Module: src/front/parser.bend:241
@unsafe
def f_expr(ts, min):
  f_grow(f_atom(f_skip(ts)), min)

# Module: src/front/parser.bend:245
@unsafe
def f_atom_base(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "("), u => f_group(f_body(f_tl(ts))),
    u => f_choose(FParsed, f_eq(f_tx(ts), "{"), u => f_brace(f_tl(ts)),
    u => f_choose(FParsed, f_eq(f_tx(ts), "["), u => f_array(f_tl(ts)),
    u => f_choose(FParsed, f_eq(f_tx(ts), "@"), u => f_all(f_tl(ts), False{}),
    u => f_choose(FParsed, f_eq(f_tx(ts), "&"), u => f_grade(f_tl(ts)),
    u => f_choose(FParsed, f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind"), u => f_mark(f_atom(f_tl(ts)), 2),
    u => f_choose(FParsed, f_eq(f_tx(ts), "?"), u => FParsed{kt("Hol", f_tx(f_tl(ts)), 0, 0, Nil{}), f_tl(f_tl(ts))},
    u => f_choose(FParsed, f_eq(f_tx(ts), "\\"), u => f_matcher(f_tl(f_tl(ts))),
    u => f_choose(FParsed, f_eq(f_tx(ts), "Type") || f_eq(f_tx(ts), "Data"), u => FParsed{kt("Typ", "", 0, 0, [kt("Qua", "", 0, f_choose(U32, f_eq(f_tx(ts), "Data"), u => 2, u => 1), Nil{})]), f_tl(ts)},
    u => f_choose(FParsed, f_eq(f_tx(ts), "Quant"), u => FParsed{kt("Qnt", "", 0, 0, Nil{}), f_tl(ts)},
    u => f_choose(FParsed, f_eq(f_tx(ts), "Kind"), u => f_kind_wrap(f_expect(f_expr(f_tl(f_tl(ts)), 0), ")")),
    u => f_choose(FParsed, U32.is_eq(f_kind_token(ts), 2), u => FParsed{kt("Literal", f_tx(ts), 0, 1, Nil{}), f_tl(ts)},
    u => f_choose(FParsed, U32.is_eq(f_kind_token(ts), 1) && Bool.not(f_reserved(f_tx(ts))), u => FParsed{kt(f_choose(String, Char.is_digit(f_head(f_tx(ts))), u => "Literal", u => "Ref"), f_tx(ts), f_atid(ts), 1, Nil{}), f_tl(ts)},
    u => f_err(ts, "expected term"))))))))))))))

# Module: src/front/parser.bend:262
@unsafe
def f_kind_token(ts):
  f_kind(ts)

# Module: src/front/parser.bend:266
@unsafe
def f_kind_wrap(p):
  match p:
    case FParsed{n, ts}:
      FParsed{kt("Typ", "", 0, 0, [n]), ts}

# Module: src/front/parser.bend:272
@unsafe
def f_mark(p, q):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_eq(tg(n), "Ref") || f_eq(tg(n), "ADT") || f_eq(tg(n), "Error"), u => FParsed{kt(tg(n), nm(n), ix(n), q, ks(n)), ts}, u => f_err(ts, "+ requires a binder or quantified datatype"))

# Module: src/front/parser.bend:278
@unsafe
def f_grade(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "0") || f_eq(f_tx(ts), "1") || f_eq(f_tx(ts), "2"), u => FParsed{kt("Qua", "", 0, f_choose(U32, f_eq(f_tx(ts), "0"), u => 0, u => f_choose(U32, f_eq(f_tx(ts), "1"), u => 1, u => 2)), Nil{}), f_tl(ts)}, u => f_all(ts, True{}))

# Module: src/front/parser.bend:282
@unsafe
def f_quant(ts):
  f_choose(U32, f_eq(f_tx(ts), "-") || f_eq(f_tx(ts), "~"), u => 0, u => f_choose(U32, f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind"), u => 2, u => 1))

# Module: src/front/parser.bend:286
@unsafe
def f_unmark(ts):
  f_choose(List<&2, FToken>, U32.is_eq(f_quant(ts), 1), u => ts, u => f_tl(ts))

# Module: src/front/parser.bend:290
@unsafe
def f_all(ts, exi):
  f_choose(FParsed, f_eq(f_tx(ts), "~"), u => f_err(ts, "~ is only allowed on leading def or law template parameters"), u => f_all_domain(f_tx(f_unmark(ts)), f_atid(ts), f_quant(ts), exi, f_expect(f_expr(f_tl(f_tl(f_unmark(ts))), 1), "->")))

# Module: src/front/parser.bend:294
@unsafe
def f_all_domain(name, id, q, exi, p):
  match p:
    case FParsed{a, ts}:
      f_all_body(name, id, q, exi, a, f_expr(ts, 0))

# Module: src/front/parser.bend:300
@unsafe
def f_all_body(name, id, q, exi, a, p):
  match p:
    case FParsed{b, ts}:
      FParsed{f_choose(KTerm, exi, u => f_app(kt("Ref", "Exists", 0, 1, Nil{}), [a, kt("Lam", name, id, q, [b])]), u => kt("All", name, id, q, [a, b])), ts}

# Module: src/front/parser.bend:306
@unsafe
def f_group(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), ","), u => f_tuple(n, f_group(f_body(f_tl(ts)))), u => f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_group_namespace(n, f_expect(f_expr(f_tl(ts), 0), ")")), u => f_expect(FParsed{n, ts}, ")")))

# Module: src/front/parser.bend:312
@unsafe
def f_group_ann(n, p):
  match p:
    case FParsed{ty, ts}:
      FParsed{kt("Ann", "", 0, 1, [n, ty]), ts}

# Module: src/front/parser.bend:318
@unsafe
def f_tuple(n, p):
  match p:
    case FParsed{m, ts}:
      FParsed{kt("Ctr", "Tuple", 0, 1, [n, m]), ts}

# Module: src/front/parser.bend:324
@unsafe
def f_list(p):
  match p:
    case FParsed{n, ts}:
      FParsed{f_list_nodes(ks(n)), ts}

# Module: src/front/parser.bend:330
@unsafe
def f_list_nodes(xs):
  match xs:
    case Nil{}:
      kt("Ctr", "Nil", 0, 1, Nil{})
    case Con{x, xt}:
      kt("Ctr", "Con", 0, 1, [x, f_list_nodes(xt)])

# Module: src/front/parser.bend:338
@unsafe
def f_brace(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "=="), u => f_expect(FParsed{kt("Rfl", "", 0, 1, Nil{}), f_tl(ts)}, "}"), u => f_brace_left(f_expr(ts, 0)))

# Module: src/front/parser.bend:342
@unsafe
def f_brace_left(p):
  match p:
    case FParsed{+a, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "==") || f_eq(f_tx(ts), "!="), u => f_equation(a, f_eq(f_tx(ts), "!="), f_expect(f_expr(f_tl(ts), 0), ":")), u => f_group_ann(a, f_expect(f_expr(f_pr(f_expect(FParsed{a, ts}, ":")), 0), "}")))

# Module: src/front/parser.bend:348
@unsafe
def f_equation(a, neg, p):
  match p:
    case FParsed{b, ts}:
      f_equation_type(a, b, neg, f_expect(f_expr(ts, 0), "}"))

# Module: src/front/parser.bend:354
@unsafe
def f_equation_type(a, b, neg, p):
  match p:
    case FParsed{ty, ts}:
      FParsed{f_choose(KTerm, neg, u => kt("All", "_", 0, 1, [kt("Eql", "", 0, 1, [a, b, ty]), kt("Ref", "Empty", 0, 1, Nil{})]), u => kt("Eql", "", 0, 1, [a, b, ty])), ts}

# Module: src/front/parser.bend:360
@unsafe
def f_prec(s):
  f_choose(U32, f_eq(s, "=>") || f_eq(s, "->"), u => 1,
    u => f_choose(U32, f_eq(s, "&") || f_eq(s, "|"), u => 2,
    u => f_choose(U32, f_eq(s, "||"), u => 3,
    u => f_choose(U32, f_eq(s, "&&"), u => 4,
    u => f_choose(U32, f_eq(s, "<") || f_eq(s, ">op") || f_eq(s, "<=") || f_eq(s, ">="), u => 5,
    u => f_choose(U32, f_eq(s, "<>") || f_eq(s, "++") || f_eq(s, "<&>"), u => 6,
    u => f_choose(U32, f_eq(s, ".|."), u => 7,
    u => f_choose(U32, f_eq(s, ".^."), u => 8,
    u => f_choose(U32, f_eq(s, ".&."), u => 9,
    u => f_choose(U32, f_eq(s, "<<") || f_eq(s, ">>op"), u => 10,
    u => f_choose(U32, f_eq(s, "+") || f_eq(s, "-"), u => 11,
    u => f_choose(U32, f_eq(s, "*") || f_eq(s, "/") || f_eq(s, "%"), u => 12, u => 0))))))))))))

# Module: src/front/parser.bend:375
@unsafe
def f_grow_base(p, min):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts},
        u => f_choose(FParsed, f_eq(f_tx(ts), "(") || (f_eq(f_tx(ts), "{") && f_eq(tg(n), "Ref")) || (f_eq(f_tx(ts), "<") && Char.is_upper(f_head(nm(n)))),
          u => f_grow_args(n, f_tx(ts), min, f_args(f_tl(ts), f_choose(String, f_eq(f_tx(ts), "("), u => ")", u => f_choose(String, f_eq(f_tx(ts), "{"), u => "}", u => ">")), Nil{})),
        u => f_choose(FParsed, U32.is_gt(f_prec(f_tx(ts)), min) && Bool.not((f_eq(f_tx(ts), "%") || f_eq(f_tx(ts), "-")) && U32.is_eq(f_col(f_tl(ts)), U32.add(f_col(ts), 1)) && Char.is_alpha(f_head(f_tx(f_tl(ts))))) && Bool.not(f_eq(f_tx(ts), ">")) && Bool.not(f_eq(f_tx(ts), ">>") && (f_eq(f_tx(f_tl(ts)), ")") || f_eq(f_tx(f_tl(ts)), "}") || f_eq(f_tx(f_tl(ts)), ",") || f_eq(f_tx(f_tl(ts)), ":") || f_eq(f_tx(f_tl(ts)), ">") || f_eq(f_tx(f_tl(ts)), "\n") || f_eq(f_tx(f_tl(ts)), "->") || f_eq(f_tx(f_tl(ts)), "<eof>") || f_eq(f_tx(f_tl(ts)), "]"))),
          u => f_binary(n, f_tx(ts), min, f_rhs_for(n, f_tl(ts), f_tx(ts), f_choose(U32, f_eq(f_tx(ts), "=>") || f_eq(f_tx(ts), "->") || f_eq(f_tx(ts), "<>") || f_eq(f_tx(ts), "&") || f_eq(f_tx(ts), "|"), u => U32.sub(f_prec(f_tx(ts)), 1), u => f_prec(f_tx(ts))))),
          u => FParsed{n, ts})))

# Module: src/front/parser.bend:386
@unsafe
def f_grow_args(n, op, min, p):
  match p:
    case FParsed{+args, ts}:
      f_choose(FParsed, f_eq(tg(args), "Error"), u => FParsed{args, ts}, u => f_grow(FParsed{f_choose(KTerm, f_eq(op, "("), u => kt("Call", "", 0, 1, Con{n, ks(args)}), u => kt(f_choose(String, f_eq(op, "{"), u => "Ctr", u => "ADT"), nm(n), ix(n), qt(n), ks(args))), ts}, min))

# Module: src/front/parser.bend:392
@unsafe
def f_binary(a, op, min, p):
  match p:
    case FParsed{b, ts}:
      f_grow(FParsed{f_binary_node(a, op, b), ts}, min)

# Module: src/front/parser.bend:398
@unsafe
def f_binary_plain(a, op, b):
  f_choose(KTerm, f_eq(op, "=>"), u => f_lambda_valid(a, b),
    u => f_choose(KTerm, f_eq(op, "->"), u => kt("All", "_", ix(a), 1, [a, b]),
    u => f_choose(KTerm, f_eq(op, "<>"), u => kt("Ctr", "Con", 0, 1, [a, b]),
    u => f_choose(KTerm, f_eq(op, "<&>"), u => kt("Min", "", 0, 1, [a, b]),
    u => f_app(kt("Ref", f_operator(op), 0, 1, Nil{}), [a, b])))))

# Module: src/front/parser.bend:406
@unsafe
def f_operator(s):
  f_choose(String, f_eq(s, "&"), u => "Pair", u => f_choose(String, f_eq(s, "|"), u => "Or", u => f_choose(String, f_eq(s, "++"), u => "String.append", u => f_choose(String, f_eq(s, "||"), u => "Bool.or", u => f_choose(String, f_eq(s, "&&"), u => "Bool.and", u => f_choose(String, f_eq(s, "+"), u => ".add", u => f_choose(String, f_eq(s, "-"), u => ".sub", u => f_choose(String, f_eq(s, "*"), u => ".mul", u => f_choose(String, f_eq(s, "/"), u => ".div", u => f_choose(String, f_eq(s, "%"), u => ".mod", u => f_choose(String, f_eq(s, "<"), u => ".is_lt", u => f_choose(String, f_eq(s, ">op"), u => ".is_gt", u => f_choose(String, f_eq(s, "<="), u => ".is_le", u => f_choose(String, f_eq(s, ">="), u => ".is_ge", u => f_choose(String, f_eq(s, "<<"), u => ".shln", u => f_choose(String, f_eq(s, ">>op"), u => ".shrn", u => f_choose(String, f_eq(s, ".&."), u => ".and", u => f_choose(String, f_eq(s, ".|."), u => ".or", u => f_choose(String, f_eq(s, ".^."), u => ".xor", u => s)))))))))))))))))))

# Module: src/front/parser.bend:410
@unsafe
def f_matcher(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "}"), u => FParsed{kt("Efq", "", 0, 1, Nil{}), f_tl(ts)}, u => f_matcher_head(f_expr(ts, 0)))

# Module: src/front/parser.bend:414
@unsafe
def f_matcher_head(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_matcher_arm(nm(n), f_expr(f_tl(ts), 0)), u => f_expect(FParsed{n, ts}, "}"))

# Module: src/front/parser.bend:420
@unsafe
def f_matcher_arm(name, p):
  match p:
    case FParsed{n, ts}:
      f_matcher_tail(name, n, f_matcher(f_skip(ts)))

# Module: src/front/parser.bend:426
@unsafe
def f_matcher_tail(name, n, p):
  match p:
    case FParsed{m, ts}:
      FParsed{kt("Mat", name, 0, 1, [n, m]), ts}

# Module: src/front/parser.bend:437
@unsafe
def f_atom(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "~"), u => f_template_expr(f_expr(f_tl(ts), 0)), u => f_choose(FParsed, f_eq(f_tx(ts), "do"), u => f_do_start(f_tl(ts)), u => f_choose(FParsed, f_eq(f_tx(ts), "%"), u => f_rewrite(f_tl(ts)), u => f_atom_base(ts))))

# Module: src/front/parser.bend:447
@unsafe
def f_args(ts, end, acc):
  f_choose(FParsed, f_eq(end, ">") && f_eq(f_tx(ts), ">>"), u => FParsed{kt("Args", "", 0, 1, List.reverse(&2, KTerm, acc)), Con{FToken{">", f_line(ts), U32.add(f_col(ts), 1), 0}, f_tl(ts)}}, u => f_args_base(ts, end, acc))

# Module: src/front/parser.bend:456
@unsafe
def f_grow(p, min):
  match p:
    case FParsed{n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "\n") && U32.is_gt(f_prec(f_tx(f_skip(ts))), 0) && Bool.not((f_eq(f_tx(f_skip(ts)), "%") || f_eq(f_tx(f_skip(ts)), "-")) && U32.is_eq(f_col(f_tl(f_skip(ts))), U32.add(f_col(f_skip(ts)), 1))), u => f_grow_base(FParsed{n, f_skip(ts)}, min), u => f_choose(FParsed, f_eq(f_tx(ts), "!"), u => f_bang(n, ts, min), u => f_choose(FParsed, f_eq(f_tx(ts), "["), u => f_index(n, f_expect(f_expr(f_tl(ts), 0), "]"), min), u => f_grow_base(FParsed{n, ts}, min))))

# Module: src/front/parser.bend:468
@unsafe
def f_binary_node(a, op, b):
  f_choose(KTerm, f_eq(op, "+") && f_eq(tg(a), "Literal") && f_ends_nat(nm(a)), u => f_nat_plus(a, b), u => f_binary_plain(a, op, b))

# Module: src/front/parser.bend:478
@unsafe
def f_rhs(ts, op, min):
  f_choose(FParsed, f_eq(op, "=>"), u => f_body(ts), u => f_expr(ts, min))

# Module: src/front/parser.bend:489
@unsafe
def f_rhs_for(left, ts, op, min):
  f_choose(FParsed, f_eq(op, "+") && f_eq(tg(left), "Literal") && String.ends_with(nm(left), "n"), u => f_expr(ts, 0), u => f_rhs(ts, op, min))

# Module: src/front/declarations.bend:323
@unsafe
def f_parse(source):
  f_tops(f_lex(source, 1, 0, 0, Nil{}), Nil{}, Nil{}, False{})

# Module: src/front/declarations.bend:327
@unsafe
def f_result(book, err, imports):
  FResult{List.reverse(&2, KDef, book), err, List.reverse(&2, KTerm, imports)}

# Module: src/front/declarations.bend:331
@unsafe
def f_len(xs):
  match xs:
    case Nil{}:
      0
    case Con{x, xt}:
      U32.add(1, f_len(xt))

# Module: src/front/declarations.bend:339
@unsafe
def f_find(name, book):
  match book:
    case Nil{}:
      KDef{name, "Missing", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}
    case Con{+d, ds}:
      f_choose(KDef, f_eq(name, f_dn(d)), u => d, u => f_find(name, ds))

# Module: src/front/declarations.bend:347
@unsafe
def f_dn(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      name

# Module: src/front/declarations.bend:353
@unsafe
def f_dt(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      typ

# Module: src/front/declarations.bend:359
@unsafe
def f_dv(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      value

# Module: src/front/declarations.bend:365
@unsafe
def f_dk(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      kind

# Module: src/front/declarations.bend:371
@unsafe
def f_dx(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      templates

# Module: src/front/declarations.bend:377
@unsafe
def f_replace(d, book):
  match book:
    case Nil{}:
      [d]
    case Con{+x, xs}:
      f_choose(List<&2, KDef>, f_eq(f_dn(d), f_dn(x)), u => Con{d, xs}, u => Con{x, f_replace(d, xs)})

# Module: src/front/declarations.bend:385
@unsafe
def f_tops(ts0, book, imports, unsafe):
  f_top(f_skip(ts0), book, imports, unsafe)

# Module: src/front/declarations.bend:389
@unsafe
def f_top(ts, book, imports, unsafe):
  f_choose(FResult, f_eq(f_tx(ts), "<eof>"), u => f_result(book, "", imports),
    u => f_choose(FResult, f_eq(f_tx(ts), "@") && f_eq(f_tx(f_tl(ts)), "unsafe"), u => f_tops(f_tl(f_tl(ts)), book, imports, True{}),
    u => f_choose(FResult, f_eq(f_tx(ts), "import"), u => f_import(f_tl(ts), book, imports),
    u => f_choose(FResult, f_eq(f_tx(ts), "law"), u => f_law(f_tx(f_tl(ts)), f_skip(f_tl(f_tl(f_tl(ts)))), book, imports, Nil{}),
    u => f_choose(FResult, f_eq(f_tx(ts), "def"), u => f_def(f_tx(f_tl(ts)), f_tele(f_tl(f_tl(f_tl(ts))), ")", Nil{}), book, imports, unsafe),
    u => f_choose(FResult, f_eq(f_tx(ts), "type"), u => f_type(f_tx(f_tl(ts)), f_tl(f_tl(ts)), book, imports),
    u => f_result(book, nm(f_pn(f_err(ts, "expected def, law, type or import"))), imports)))))))

# Module: src/front/declarations.bend:399
@unsafe
def f_import(ts, book, imports):
  f_import_path(ts, "", book, imports)

# Module: src/front/declarations.bend:403
@unsafe
def f_tele(ts0, end, acc):
  f_tele_at(f_skip(ts0), end, acc)

# Module: src/front/declarations.bend:407
@unsafe
def f_tele_at(ts, end, acc):
  f_choose(FParsed, f_eq(f_tx(ts), end), u => FParsed{kt("Tele", "", 0, 0, List.reverse(&2, KTerm, acc)), f_tl(ts)}, u => f_validate_param(ts, end, acc))

# Module: src/front/declarations.bend:411
@unsafe
def f_tele_binder(name, id, q, temp, ts, end, acc):
  f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_tele_type(name, id, q, temp, f_expr(f_tl(ts), 0), end, acc), u => f_tele_type(name, id, 0, temp, FParsed{atom("Qnt"), ts}, end, acc))

# Module: src/front/declarations.bend:415
@unsafe
def f_tele_type(name, id, q, temp, p, end, acc):
  match p:
    case FParsed{+ty, +ts}:
      f_choose(FParsed, f_eq(tg(ty), "Error"), u => FParsed{ty, ts}, u => f_tele(f_choose(List<&2, FToken>, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), end, Con{kt(f_choose(String, temp, u => "Template", u => "Bind"), name, id, q, [ty]), acc}))

# Module: src/front/declarations.bend:421
@unsafe
def f_tbind(pars, result):
  match pars:
    case Nil{}:
      result
    case Con{+p, ps}:
      kt("All", nm(p), ix(p), qt(p), [kid(p, 0), f_tbind(ps, result)])

# Module: src/front/declarations.bend:429
@unsafe
def f_lbind(pars, body):
  match pars:
    case Nil{}:
      body
    case Con{+p, ps}:
      kt("Lam", nm(p), ix(p), qt(p), [f_lbind(ps, body)])

# Module: src/front/declarations.bend:437
@unsafe
def f_templates(pars):
  match pars:
    case Nil{}:
      0
    case Con{p, ps}:
      U32.add(f_choose(U32, f_eq(tg(p), "Template"), u => 1, u => 0), f_templates(ps))

# Module: src/front/declarations.bend:445
@unsafe
def f_def_base(name, p, book, imports, unsafe):
  match p:
    case FParsed{+pars, +ts}:
      f_choose(FResult, f_eq(tg(pars), "Error"), u => f_result(book, nm(pars), imports), u => f_choose(FResult, f_eq(f_tx(ts), "->"), u => f_def_type(name, ks(pars), f_expr(f_tl(ts), 0), book, imports, unsafe), u => f_def_type(name, ks(pars), FParsed{f_dt(f_find(name, book)), ts}, book, imports, unsafe)))

# Module: src/front/declarations.bend:451
@unsafe
def f_def_type(name, pars, p, book, imports, unsafe):
  match p:
    case FParsed{+ty, +ts}:
      f_choose(FResult, f_eq(tg(ty), "Absent"), u => f_result(book, "definition without return type needs a law: " ++ name, imports), u => f_choose(FResult, f_eq(f_tx(f_skip(f_tl(ts))), "import"), u => f_foreign(name, pars, f_def_signature(name, pars, ty, book), f_skip(f_tl(ts)), book, imports, unsafe, Nil{}), u => f_def_body(name, pars, f_def_signature(name, pars, ty, book), f_body(f_pr(f_expect(FParsed{ty, ts}, ":"))), book, imports, unsafe)))

# Module: src/front/declarations.bend:457
@unsafe
def f_def_signature(name, pars, ty, book):
  f_choose(KTerm, f_eq(f_dk(f_find(name, book)), "Missing"), u => f_tbind(pars, ty), u => ty)

# Module: src/front/declarations.bend:461
@unsafe
def f_def_body(name, pars, ty, p, book, imports, unsafe):
  match p:
    case FParsed{+body, ts}:
      f_choose(FResult, f_eq(tg(body), "Error"), u => f_result(book, nm(body), imports), u => f_tops(ts, f_put(KDef{name, "Def", f_len(pars), f_choose(U32, f_eq(f_dk(f_find(name, book)), "Missing"), u => f_templates(pars), u => f_dx(f_find(name, book))), ty, kt("Body", "", fc_start(pars, ty, body, Bool.not(f_eq(f_dk(f_find(name, book)), "Missing"))), 0, [kt("Params", "", 0, 0, pars), body]), Nil{}, False{}, unsafe}, book), imports, False{}))

# Module: src/front/declarations.bend:467
@unsafe
def f_foreign(name, pars, ty, ts, book, imports, unsafe, paths):
  f_choose(FResult, f_eq(f_tx(ts), "import"), u => f_choose(FResult, f_foreign_path_valid(ts), u => f_foreign(name, pars, ty, f_skip(f_tl(f_tl(ts))), book, imports, unsafe, Con{kt("Path", f_unquote(f_tx(f_tl(ts))), 0, 0, Nil{}), paths}), u => f_result(book, "foreign import requires a quoted .c or .js path", imports)), u => f_tops(ts, f_put(KDef{name, "Def", f_len(pars), 0, ty, kt("Foreign", name, 0, 0, List.reverse(&2, KTerm, paths)), Nil{}, False{}, unsafe}, book), imports, False{}))

# Module: src/front/declarations.bend:471
@unsafe
def f_law_base(name, ts, book, imports, clauses):
  f_choose(FResult, f_eq(f_tx(ts), "for") || f_eq(f_tx(ts), "exs"), u => f_law_clause(name, f_eq(f_tx(ts), "exs"), f_tl(ts), book, imports, clauses), u => f_law_end(name, f_expr(ts, 0), book, imports, List.reverse(&2, KTerm, clauses)))

# Module: src/front/declarations.bend:475
@unsafe
def f_law_clause(name, exi, ts, book, imports, clauses):
  f_law_type(name, kt(f_choose(String, exi, u => "Exists", u => f_choose(String, f_eq(f_tx(ts), "~"), u => "Template", u => "Bind")), f_tx(f_unmark(ts)), f_atid(ts), f_quant(ts), Nil{}), f_expr(f_tl(f_tl(f_unmark(ts))), 0), book, imports, clauses)

# Module: src/front/declarations.bend:479
@unsafe
def f_law_type(name, binder, p, book, imports, clauses):
  match p:
    case FParsed{+ty, ts}:
      f_choose(FResult, f_eq(tg(ty), "Error"), u => f_result(book, nm(ty), imports), u => f_choose(FResult, f_eq(f_tx(f_skip(ts)), "where"), u => f_law_where(name, binder, ty, f_expr(f_tl(f_skip(ts)), 0), book, imports, clauses), u => f_law(name, f_skip(ts), book, imports, Con{kt(tg(binder), nm(binder), ix(binder), qt(binder), [ty]), clauses})))

# Module: src/front/declarations.bend:485
@unsafe
def f_law_bind(clauses, ty):
  match clauses:
    case Nil{}:
      ty
    case Con{+c, cs}:
      f_choose(KTerm, f_eq(tg(c), "Exists"), u => f_app(kt("Ref", "Exists", 0, 1, Nil{}), [kid(c, 0), kt("Lam", nm(c), ix(c), 1, [f_law_bind(cs, ty)])]), u => kt("All", nm(c), ix(c), qt(c), [kid(c, 0), f_law_bind(cs, ty)]))

# Module: src/front/declarations.bend:493
@unsafe
def f_law_end(name, p, book, imports, clauses):
  match p:
    case FParsed{+ty, ts}:
      f_choose(FResult, f_eq(tg(ty), "Error"), u => f_result(book, nm(ty), imports), u => f_tops(ts, Con{KDef{name, "Def", f_law_arity(clauses), f_templates(clauses), f_law_bind(clauses, ty), atom("Absent"), Nil{}, False{}, False{}}, book}, imports, False{}))

# Module: src/front/declarations.bend:499
@unsafe
def f_type_base(name, ts, book, imports):
  f_choose(FResult, f_eq(f_tx(ts), "<") || f_eq(f_tx(ts), "<-"), u => f_type_params(name, f_tele(f_choose(List<&2, FToken>, f_eq(f_tx(ts), "<-"), u => Con{FToken{"-", f_line(ts), U32.add(f_col(ts), 1), 0}, f_tl(ts)}, u => f_tl(ts)), ">", Nil{}), book, imports), u => f_type_params(name, FParsed{kt("Tele", "", 0, 0, Nil{}), ts}, book, imports))

# Module: src/front/declarations.bend:503
@unsafe
def f_type_params(name, p, book, imports):
  match p:
    case FParsed{pars, ts}:
      f_choose(FResult, f_eq(tg(pars), "Error"), u => f_result(book, nm(pars), imports), u => f_type_kind(name, ks(pars), f_expect(f_expr(f_pr(f_expect(FParsed{pars, ts}, "is")), 0), ":"), book, imports))

# Module: src/front/declarations.bend:509
@unsafe
def f_type_kind(name, pars, p, book, imports):
  match p:
    case FParsed{ty, ts}:
      f_choose(FResult, f_eq(tg(ty), "Error"), u => f_result(book, nm(ty), imports), u => f_type_ctors(name, pars, ty, f_skip(ts), book, imports, Nil{}))

# Module: src/front/declarations.bend:515
@unsafe
def f_type_ctors(name, pars, ty, ts, book, imports, ctors):
  f_choose(FResult, U32.is_gt(f_col(ts), 0) && f_eq(f_tx(f_tl(ts)), "{"), u => f_type_ctor(name, pars, ty, f_tx(ts), f_tele(f_tl(f_tl(ts)), "}", Nil{}), book, imports, ctors), u => f_tops(ts, Con{KDef{name, "ADT", f_len(pars), 0, f_tbind(pars, ty), atom("Absent"), List.reverse(&2, KDef, ctors), False{}, False{}}, book}, imports, False{}))

# Module: src/front/declarations.bend:519
@unsafe
def f_type_ctor(name, pars, ty, ctor, p, book, imports, ctors):
  match p:
    case FParsed{fields, ts}:
      f_choose(FResult, f_eq(tg(fields), "Error"), u => f_result(book, nm(fields), imports), u => f_type_ctors(name, pars, ty, f_skip(ts), book, imports, Con{KDef{ctor, "Ctr", f_len(ks(fields)), 0, f_tbind(pars, f_tbind(ks(fields), kt("ADT", name, 0, 1, f_param_refs(pars)))), kt("Absent", ctor, 0, 0, Nil{}), Nil{}, False{}, False{}}, ctors}))

# Module: src/front/declarations.bend:525
@unsafe
def f_param_refs(pars):
  match pars:
    case Nil{}:
      Nil{}
    case Con{+p, ps}:
      Con{kt("Ref", nm(p), ix(p), qt(p), Nil{}), f_param_refs(ps)}

# Module: src/front/declarations.bend:533
@unsafe
def f_body(ts):
  f_body_context(ts, 0)

# Module: src/front/declarations.bend:537
@unsafe
def f_body_at(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "-"), u => f_erased_local(f_tl(ts)), u => f_choose(FParsed, f_eq(f_tx(ts), "match"), u => f_match_heads(f_tl(ts), f_col(ts), Nil{}), u => f_statement(f_expr(ts, 0))))

# Module: src/front/declarations.bend:541
@unsafe
def f_statement(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "="), u => f_let_value(n, f_expr(f_tl(ts), 0)), u => f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_typed_let_try(n, ts, f_expr(f_tl(ts), 0)), u => f_statement_more(FParsed{n, ts})))

# Module: src/front/declarations.bend:547
@unsafe
def f_typed_let(n, p):
  match p:
    case FParsed{ty, ts}:
      f_let_value(n, f_let_ann(ty, f_expr(f_pr(f_expect(FParsed{ty, ts}, "=")), 0)))

# Module: src/front/declarations.bend:553
@unsafe
def f_let_ann(ty, p):
  match p:
    case FParsed{v, ts}:
      FParsed{kt("Ann", "", 0, 1, [v, ty]), ts}

# Module: src/front/declarations.bend:559
@unsafe
def f_let_value(pat, p):
  match p:
    case FParsed{v, ts}:
      f_let_body(pat, v, f_body(ts))

# Module: src/front/declarations.bend:565
@unsafe
def f_let_body(pat, v, p):
  match p:
    case FParsed{b, ts}:
      FParsed{kt("Local", "", 0, 1, [pat, v, b]), ts}

# Module: src/front/declarations.bend:571
@unsafe
def f_match_heads(ts, indent, acc):
  f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_match_begin(f_skip(f_tl(ts)), indent, List.reverse(&2, KTerm, acc)), u => f_match_head(f_expr(f_choose(List<&2, FToken>, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), 0), indent, acc))

# Module: src/front/declarations.bend:575
@unsafe
def f_match_head(p, indent, acc):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_match_heads(ts, indent, Con{n, acc}))

# Module: src/front/declarations.bend:581
@unsafe
def f_match_cases(ts, indent, heads, rows):
  f_choose(FParsed, f_eq(f_tx(ts), "case") && U32.is_gt(f_col(ts), indent), u => f_case_pats(f_tl(ts), indent, heads, rows, Nil{}), u => FParsed{kt("Match", "", 0, 1, Con{kt("Heads", "", 0, 1, heads), List.reverse(&2, KTerm, rows)}), ts})

# Module: src/front/declarations.bend:585
@unsafe
def f_case_pats(ts, indent, heads, rows, pats):
  f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_case_body(f_body_context(f_tl(ts), U32.add(indent, 1)), indent, heads, rows, List.reverse(&2, KTerm, pats)), u => f_case_pat(f_expr(f_choose(List<&2, FToken>, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), 0), indent, heads, rows, pats))

# Module: src/front/declarations.bend:589
@unsafe
def f_case_pat(p, indent, heads, rows, pats):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_case_pats(ts, indent, heads, rows, Con{n, pats}))

# Module: src/front/declarations.bend:595
@unsafe
def f_case_body(p, indent, heads, rows, pats):
  f_case_checked(p, indent, heads, rows, pats)

# Module: src/front/declarations.bend:605
@unsafe
def f_put(d, book):
  Con{d, book}

# Module: src/front/declarations.bend:616
@unsafe
def f_type_named(name, ts, book, imports):
  f_choose(FResult, f_eq(f_tx(ts), "<>"), u => f_type_params(name, FParsed{kt("Tele", "", 0, 0, Nil{}), f_tl(ts)}, book, imports), u => f_type_base(name, ts, book, imports))

# Module: src/front/declarations.bend:628
@unsafe
def f_def(name, p, book, imports, unsafe):
  f_choose(FResult, Bool.not(f_valid_name(name)), u => f_result(book, "reserved definition name: " ++ name, imports), u => f_def_prior(name, p, book, imports, unsafe, f_find(name, book)))

# Module: src/front/declarations.bend:648
@unsafe
def f_body_context(ts, outer):
  f_body_context_at(f_skip(ts), outer)

# Module: src/front/declarations.bend:652
@unsafe
def f_body_context_at(ts, outer):
  f_choose(FParsed, f_eq(f_tx(ts), "match"), u => f_match_heads(f_tl(ts), outer, Nil{}), u => f_body_at(ts))

# Module: src/front/declarations.bend:656
@unsafe
def f_match_begin(ts, outer, heads):
  f_choose(FParsed, f_eq(f_tx(ts), "case") && U32.is_gt(f_col(ts), outer), u => f_match_cases(ts, U32.sub(f_col(ts), 1), heads, Nil{}), u => FParsed{kt("Match", "", 0, 1, [kt("Heads", "", 0, 1, heads)]), ts})

# Module: src/front/declarations.bend:664
@unsafe
def f_law_arity(clauses):
  match clauses:
    case Nil{}:
      0
    case Con{c, rest}:
      f_choose(U32, f_eq(tg(c), "Exists"), u => 0, u => U32.add(1, f_law_arity(rest)))

# Module: src/front/declarations.bend:687
@unsafe
def f_law(name, ts, book, imports, clauses):
  f_choose(FResult, f_valid_name(name) && f_eq(dk(f_find(name, book)), "Missing"), u => f_law_base(name, ts, book, imports, clauses), u => f_result(book, "invalid or reserved law name: " ++ name, imports))

# Module: src/front/declarations.bend:691
@unsafe
def f_type(name, ts, book, imports):
  f_choose(FResult, f_valid_name(name) && f_eq(dk(f_find(name, book)), "Missing"), u => f_type_named(name, ts, book, imports), u => f_result(book, "invalid or reserved datatype name: " ++ name, imports))

# Module: src/front/flatten.bend:150
@unsafe
def ff_term(r):
  match r:
    case FFlatten{t, next}:
      t

# Module: src/front/flatten.bend:156
@unsafe
def ff_next(r):
  match r:
    case FFlatten{t, next}:
      next

# Module: src/front/flatten.bend:162
@unsafe
def ff_flat(t, vars, next):
  f_choose(FFlatten, f_eq(tg(t), "Match"), u => ff_match(ks(kid(t, 0)), f_tail_terms(ks(t)), vars, next), u => f_choose(FFlatten, f_eq(tg(t), "Local"), u => ff_local(t, vars, next), u => f_choose(FFlatten, f_eq(tg(t), "Parallel"), u => ff_parallel(t, vars, ff_flat(kid(t, 2), ks(kid(t, 0)), next)), u => FFlatten{f_lbind(vars, t), next})))

# Module: src/front/flatten.bend:166
@unsafe
def ff_local(t, vars, next):
  f_choose(FFlatten, f_eq(tg(kid(t, 0)), "Ctr"), u => ff_match([kid(t, 1)], [kt("Row", "", 0, 1, [kt("Patterns", "", 0, 1, [kid(t, 0)]), kid(t, 2)])], vars, next), u => ff_let(t, vars, ff_flat(kid(t, 2), [kid(t, 0)], next)))

# Module: src/front/flatten.bend:170
@unsafe
def ff_let(t, vars, r):
  match r:
    case FFlatten{+body, next}:
      FFlatten{f_choose(KTerm, f_eq(tg(body), "Lam"), u => f_lbind(vars, kt("Let", "", 0, 1, [kt("Bind", nm(kid(t, 0)), ix(kid(t, 0)), qt(kid(t, 0)), [kid(t, 1)]), kid(body, 0)])), u => kt("Error", "a match cannot scrutinize a local binding", 0, 0, Nil{})), next}

# Module: src/front/flatten.bend:176
@unsafe
def ff_parallel(t, vars, r):
  match r:
    case FFlatten{body, next}:
      FFlatten{f_lbind(vars, kt("Let", "", 0, 1, f_concat(f_parallel_binds(ks(kid(t, 0)), ks(kid(t, 1))), [f_unlamb(body, f_len(ks(kid(t, 0))))]))), next}

# Module: src/front/flatten.bend:182
@unsafe
def ff_match(heads, rows, vars, next):
  match heads:
    case Nil{}:
      f_choose(FFlatten, U32.is_eq(f_len(rows), 0), u => FFlatten{atom("Efq"), next}, u => ff_flat(kid(terms_at(rows, 0), 1), vars, next))
    case Con{+h, hs}:
      f_choose(FFlatten, f_eq(tg(f_first_ctor(rows)), "Absent") && U32.is_gt(f_len(rows), 0) && f_has_id(vars, ix(h)), u => ff_match(hs, f_var_rows(rows, h), f_mark_vars(vars, ix(h), f_mark_rows(rows, qt(h))), next), u => ff_column(h, hs, rows, vars, next))

# Module: src/front/flatten.bend:190
@unsafe
def ff_column(h, hs, rows, vars, next):
  match vars:
    case Nil{}:
      FFlatten{kt("Error", "match requires an unconsumed parameter or constructor field", 0, 0, Nil{}), next}
    case Con{+v, vs}:
      f_choose(FFlatten, U32.is_eq(ix(h), ix(v)), u => ff_split(h, hs, rows, v, vs, f_first_ctor(rows), next), u => ff_lam(v, ff_match(Con{h, hs}, rows, vs, next)))

# Module: src/front/flatten.bend:198
@unsafe
def ff_lam(v, r):
  match r:
    case FFlatten{body, next}:
      FFlatten{kt("Lam", nm(v), ix(v), qt(v), [body]), next}

# Module: src/front/flatten.bend:204
@unsafe
def ff_split(h, hs, rows, v, vs, c, next):
  f_choose(FFlatten, f_eq(tg(c), "Absent"), u => FFlatten{atom("Efq"), next}, u => ff_fields_done(h, hs, rows, v, vs, c, ff_fields(ks(c), f_mark_rows(rows, qt(v)), next)))

# Module: src/front/flatten.bend:208
@unsafe
def ff_fields(ps, q, next):
  match ps:
    case Nil{}:
      FFields{Nil{}, next}
    case Con{+p, rest}:
      f_choose(FFields, f_eq(tg(p), "Var"), u => ff_field_cons(kt("Var", nm(p), ix(p), f_choose(U32, U32.is_eq(q, 2), u => 2, u => qt(p)), Nil{}), ff_fields(rest, q, next)), u => ff_field_cons(kt("Var", "_" ++ U32.show(next), U32.add(2147483648, next), q, Nil{}), ff_fields(rest, q, U32.add(next, 1))))

# Module: src/front/flatten.bend:216
@unsafe
def ff_field_cons(p, r):
  match r:
    case FFields{fields, next}:
      FFields{Con{p, fields}, next}

# Module: src/front/flatten.bend:222
@unsafe
def ff_fields_done(h, hs, rows, v, vs, c, r):
  match r:
    case FFields{+fields, next}:
      ff_hit_done(h, hs, rows, v, vs, c, ff_match(f_concat(fields, hs), f_hit_rows(rows, c, fields, v), f_concat(fields, vs), next))

# Module: src/front/flatten.bend:228
@unsafe
def ff_hit_done(h, hs, rows, v, vs, c, r):
  match r:
    case FFlatten{hit, next}:
      ff_miss_done(c, hit, ff_match(Con{h, hs}, f_miss_rows(rows, nm(c)), Con{v, vs}, next))

# Module: src/front/flatten.bend:234
@unsafe
def ff_miss_done(c, hit, r):
  match r:
    case FFlatten{miss, next}:
      FFlatten{kt("Mat", nm(c), 0, 1, [hit, miss]), next}

# Module: src/front/flatten.bend:240
@unsafe
def fc_ref(name, env):
  f_choose(U32, f_contains(name, '.') || Bool.not(f_eq(tg(f_env(name, env)), "Absent")), u => 0, u => 1)

# Module: src/front/flatten.bend:244
@unsafe
def fc_bind(v, env):
  f_choose(List<&2,KTerm>, f_eq(nm(v), "_"), u => env, u => Con{v, env})

# Module: src/front/flatten.bend:248
@unsafe
def fc_binders(ps):
  match ps:
    case Nil{}:
      Nil{}
    case Con{+p, rest}:
      f_choose(List<&2,KTerm>, f_eq(tg(p), "Ref") || f_eq(tg(p), "Var"), u => fc_bind(p, fc_binders(rest)), u => f_concat(fc_binders(ks(p)), fc_binders(rest)))

# Module: src/front/flatten.bend:256
@unsafe
def fc_bind_count(ps):
  match ps:
    case Nil{}:
      0
    case Con{+p, rest}:
      U32.add(f_choose(U32, f_eq(tg(p), "Ref") || f_eq(tg(p), "Var"), u => 1, u => fc_bind_count(ks(p))), fc_bind_count(rest))

# Module: src/front/flatten.bend:264
@unsafe
def fc_terms(ts, env):
  match ts:
    case Nil{}:
      0
    case Con{t, rest}:
      U32.add(fc_term(t, env), fc_terms(rest, env))

# Module: src/front/flatten.bend:272
@unsafe
def fc_term(t, env):
  f_choose(U32, f_eq(tg(t), "Ref"), u => fc_ref(nm(t), env),
    u => f_choose(U32, f_eq(tg(t), "ADT"), u => U32.add(fc_ref(nm(t), env), fc_terms(ks(t), env)),
    u => f_choose(U32, f_eq(tg(t), "All"), u => U32.add(1, U32.add(fc_term(kid(t, 0), env), fc_term(kid(t, 1), fc_bind(t, env)))),
    u => f_choose(U32, f_eq(tg(t), "Lam"), u => U32.add(1, U32.add(fc_ref(nm(t), env), fc_term(kid(t, 0), fc_bind(t, env)))),
    u => f_choose(U32, f_eq(tg(t), "Match"), u => U32.add(fc_terms(ks(kid(t, 0)), env), fc_rows(f_tail_terms(ks(t)), env)),
    u => f_choose(U32, f_eq(tg(t), "Local"), u => U32.add(f_choose(U32, U32.is_eq(qt(kid(t, 0)), 0), u => 0, u => fc_term(kid(t, 0), env)), U32.add(fc_term(kid(t, 1), env), U32.add(fc_bind_count([kid(t, 0)]), fc_term(kid(t, 2), f_concat(fc_binders([kid(t, 0)]), env))))),
    u => f_choose(U32, f_eq(tg(t), "Parallel"), u => U32.add(fc_terms(ks(kid(t, 0)), env), U32.add(fc_terms(ks(kid(t, 1)), env), U32.add(fc_bind_count(ks(kid(t, 0))), fc_term(kid(t, 2), f_concat(fc_binders(ks(kid(t, 0))), env))))),
    u => f_choose(U32, f_eq(tg(t), "Mat"), u => U32.add(fc_ref(nm(t), env), fc_terms(ks(t), env)),
    u => fc_terms(ks(t), env)))))))))

# Module: src/front/flatten.bend:284
@unsafe
def fc_rows(rs, env):
  match rs:
    case Nil{}:
      0
    case Con{+r, rest}:
      U32.add(fc_terms(ks(kid(r, 0)), env), U32.add(fc_bind_count(ks(kid(r, 0))), U32.add(fc_term(kid(r, 1), f_concat(fc_binders(ks(kid(r, 0))), env)), fc_rows(rest, env))))

# Module: src/front/flatten.bend:292
@unsafe
def fc_start(pars, ty, body, filled):
  U32.add(f_choose(U32, filled, u => f_len(pars), u => fc_term(ty, Nil{})), fc_term(body, pars))

# Module: src/front/elaborate.bend:224
@unsafe
def f_elaborate(r):
  match r:
    case FResult{+book, err, imports}:
      f_validate_result(FResult{f_elab_defs(book, f_family_book(book)), err, imports})

# Module: src/front/elaborate.bend:230
@unsafe
def f_elab_defs(ds, book):
  match ds:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      Con{f_elab_def(d, book), f_elab_defs(rest, book)}

# Module: src/front/elaborate.bend:238
@unsafe
def f_elab_def(d, book):
  match d:
    case KDef{name, kind, arity, templates, ty, value, ctors, native, unsafe}:
      KDef{name, kind, arity, templates, f_scope(ty, Nil{}, book), f_scope(value, Nil{}, book), f_elab_defs(ctors, book), native, unsafe}

# Module: src/front/elaborate.bend:244
@unsafe
def f_env(name, env):
  match env:
    case Nil{}:
      atom("Absent")
    case Con{+x, xs}:
      f_choose(KTerm, f_eq(name, nm(x)) && (Bool.not(f_eq(name, "_")) || f_eq(tg(x), "RewriteVar")), u => x, u => f_env(name, xs))

# Module: src/front/elaborate.bend:252
@unsafe
def f_tail_terms(xs):
  match xs:
    case Nil{}:
      Nil{}
    case Con{x, xt}:
      xt

# Module: src/front/elaborate.bend:260
@unsafe
def f_concat(xs, ys):
  match xs:
    case Nil{}:
      ys
    case Con{x, xt}:
      Con{x, f_concat(xt, ys)}

# Module: src/front/elaborate.bend:268
@unsafe
def f_vars(xs):
  match xs:
    case Nil{}:
      Nil{}
    case Con{+x, xt}:
      Con{kt("Var", nm(x), ix(x), 1, Nil{}), f_vars(xt)}

# Module: src/front/elaborate.bend:276
@unsafe
def f_scope_base(t, env, book):
  f_choose(KTerm, f_eq(tg(t), "Ref"), u => f_scope_ref(t, f_env(nm(t), env), book),
    u => f_choose(KTerm, f_eq(tg(t), "Literal"), u => f_literal(nm(t)),
    u => f_choose(KTerm, f_eq(tg(t), "All"), u => kt("All", nm(t), ix(t), qt(t), [f_scope(kid(t, 0), env, book), f_scope(kid(t, 1), Con{kt("Var", nm(t), ix(t), qt(t), Nil{}), env}, book)]),
    u => f_choose(KTerm, f_eq(tg(t), "Lam"), u => f_scope_lambda(t, env, book),
    u => f_choose(KTerm, f_eq(tg(t), "Body"), u => ff_term(ff_flat(f_scope_body(kid(t, 1), f_concat(f_vars(ks(kid(t, 0))), env), book), f_vars(ks(kid(t, 0))), ix(t))),
    u => f_choose(KTerm, f_eq(tg(t), "Local") || f_eq(tg(t), "Match"), u => f_flat(f_scope_body(t, env, book), Nil{}),
    u => KTerm{tg(t), nm(t), ix(t), qt(t), f_scope_terms(ks(t), env, book), rm(t)}))))))

# Module: src/front/elaborate.bend:286
@unsafe
def f_scope_ref(t, bound, book):
  f_scope_reference(t, bound, book)

# Module: src/front/elaborate.bend:290
@unsafe
def f_scope_terms(xs, env, book):
  match xs:
    case Nil{}:
      Nil{}
    case Con{x, xt}:
      Con{f_scope(x, env, book), f_scope_terms(xt, env, book)}

# Module: src/front/elaborate.bend:298
@unsafe
def f_patterns(xs):
  match xs:
    case Nil{}:
      Nil{}
    case Con{+x, xt}:
      Con{f_choose(KTerm, f_eq(tg(x), "Ref"), u => kt("Var", nm(x), ix(x), qt(x), Nil{}), u => f_choose(KTerm, f_eq(tg(x), "Literal"), u => f_pattern_literal(nm(x)), u => kt(tg(x), nm(x), ix(x), qt(x), f_patterns(ks(x))))), f_patterns(xt)}

# Module: src/front/elaborate.bend:306
@unsafe
def f_penv(xs):
  match xs:
    case Nil{}:
      Nil{}
    case Con{+x, xt}:
      f_choose(List<&2, KTerm>, f_eq(tg(x), "Var"), u => Con{x, f_penv(xt)}, u => f_concat(f_penv(ks(x)), f_penv(xt)))

# Module: src/front/elaborate.bend:314
@unsafe
def f_scope_body_base(t, env, book):
  f_choose(KTerm, f_eq(tg(t), "Local"), u => f_scope_local(t, f_patterns([kid(t, 0)]), env, book), u => f_choose(KTerm, f_eq(tg(t), "Match"), u => kt("Match", "", 0, 1, Con{kt("Heads", "", 0, 1, f_scope_terms(ks(kid(t, 0)), env, book)), f_scope_rows(f_tail_terms(ks(t)), env, book)}), u => f_scope(t, env, book)))

# Module: src/front/elaborate.bend:318
@unsafe
def f_scope_local(t, pats, env, book):
  kt("Local", "", 0, qt(t), [terms_at(pats, 0), f_scope(kid(t, 1), env, book), f_scope_body(kid(t, 2), f_concat(f_penv(pats), env), book)])

# Module: src/front/elaborate.bend:322
@unsafe
def f_scope_rows(rows, env, book):
  match rows:
    case Nil{}:
      Nil{}
    case Con{r, rs}:
      Con{f_scope_row(r, f_patterns(ks(kid(r, 0))), env, book), f_scope_rows(rs, env, book)}

# Module: src/front/elaborate.bend:330
@unsafe
def f_scope_row(r, pats, env, book):
  f_scope_row_valid(r, pats, env, book, f_valid_patterns(pats, book))

# Module: src/front/elaborate.bend:334
@unsafe
def f_sub(t, id, v):
  f_choose(KTerm, f_eq(tg(t), "Var") && U32.is_eq(ix(t), id), u => v, u => KTerm{tg(t), nm(t), ix(t), qt(t), f_subs(ks(t), id, v), rm(t)})

# Module: src/front/elaborate.bend:338
@unsafe
def f_subs(ts, id, v):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      Con{f_sub(t, id, v), f_subs(rest, id, v)}

# Module: src/front/elaborate.bend:346
@unsafe
def f_flat_base(t, vars):
  f_choose(KTerm, f_eq(tg(t), "Match"), u => f_flat_match(ks(kid(t, 0)), f_tail_terms(ks(t)), vars), u => f_choose(KTerm, f_eq(tg(t), "Local"), u => f_flat_local(t, vars), u => f_lbind(vars, t)))

# Module: src/front/elaborate.bend:350
@unsafe
def f_flat_local(t, vars):
  f_choose(KTerm, f_eq(tg(kid(t, 0)), "Ctr"), u => f_flat_match([kid(t, 1)], [kt("Row", "", 0, 1, [kt("Patterns", "", 0, 1, [kid(t, 0)]), kid(t, 2)])], vars), u => f_flat_let(t, vars, f_flat(kid(t, 2), [kid(t, 0)])))

# Module: src/front/elaborate.bend:354
@unsafe
def f_flat_let(t, vars, body):
  f_choose(KTerm, f_eq(tg(body), "Lam"), u => f_lbind(vars, kt("Let", "", 0, 1, [kt("Bind", nm(kid(t, 0)), ix(kid(t, 0)), qt(kid(t, 0)), [kid(t, 1)]), kid(body, 0)])), u => kt("Error", "a match cannot scrutinize a local binding", 0, 0, Nil{}))

# Module: src/front/elaborate.bend:358
@unsafe
def f_rowpat(r):
  kid(kid(r, 0), 0)

# Module: src/front/elaborate.bend:362
@unsafe
def f_first_ctor(rows):
  match rows:
    case Nil{}:
      atom("Absent")
    case Con{+r, rs}:
      f_choose(KTerm, f_eq(tg(f_rowpat(r)), "Ctr"), u => f_rowpat(r), u => f_first_ctor(rs))

# Module: src/front/elaborate.bend:370
@unsafe
def f_has_id(vars, id):
  match vars:
    case Nil{}:
      False{}
    case Con{v, vs}:
      U32.is_eq(ix(v), id) || f_has_id(vs, id)

# Module: src/front/elaborate.bend:378
@unsafe
def f_flat_match(heads, rows, vars):
  match heads:
    case Nil{}:
      f_choose(KTerm, U32.is_eq(f_len(rows), 0), u => atom("Efq"), u => f_flat(kid(terms_at(rows, 0), 1), vars))
    case Con{+h, hs}:
      f_choose(KTerm, f_eq(tg(f_first_ctor(rows)), "Absent") && U32.is_gt(f_len(rows), 0) && f_has_id(vars, ix(h)), u => f_flat_match(hs, f_var_rows(rows, h), f_mark_vars(vars, ix(h), f_mark_rows(rows, qt(h)))), u => f_flat_column(h, hs, rows, vars))

# Module: src/front/elaborate.bend:386
@unsafe
def f_var_rows(rows, v):
  match rows:
    case Nil{}:
      Nil{}
    case Con{+r, rs}:
      Con{kt("Row", "", 0, qt(r), [kt("Patterns", "", 0, 1, f_tail_terms(ks(kid(r, 0)))), f_choose(KTerm, U32.is_eq(qt(r), 0), u => kid(r, 1), u => f_sub(kid(r, 1), ix(f_rowpat(r)), v))]), f_var_rows(rs, v)}

# Module: src/front/elaborate.bend:394
@unsafe
def f_flat_column(h, hs, rows, vars):
  match vars:
    case Nil{}:
      kt("Error", "match requires an unconsumed parameter or constructor field", 0, 0, Nil{})
    case Con{+v, vs}:
      f_choose(KTerm, U32.is_eq(ix(h), ix(v)), u => f_flat_split(h, hs, rows, v, vs, f_first_ctor(rows)), u => kt("Lam", nm(v), ix(v), qt(v), [f_flat_match(Con{h, hs}, rows, vs)]))

# Module: src/front/elaborate.bend:402
@unsafe
def f_flat_split(h, hs, rows, v, vs, c):
  f_choose(KTerm, f_eq(tg(c), "Absent"), u => atom("Efq"), u => f_flat_fields(h, hs, rows, v, vs, c, f_mark_fields(f_fresh_fields(ks(c), U32.add(2147483648, ix(c))), f_mark_rows(rows, qt(v)))))

# Module: src/front/elaborate.bend:406
@unsafe
def f_fresh_fields(ps, id):
  match ps:
    case Nil{}:
      Nil{}
    case Con{+p, rest}:
      Con{f_choose(KTerm, f_eq(tg(p), "Var"), u => p, u => kt("Var", "_field", id, 1, Nil{})), f_fresh_fields(rest, U32.add(id, 1))}

# Module: src/front/elaborate.bend:414
@unsafe
def f_flat_fields(h, hs, rows, v, vs, c, fields):
  kt("Mat", nm(c), 0, 1, [f_flat_match(f_concat(fields, hs), f_hit_rows(rows, c, fields, v), f_concat(fields, vs)), f_flat_match(Con{h, hs}, f_miss_rows(rows, nm(c)), Con{v, vs})])

# Module: src/front/elaborate.bend:418
@unsafe
def f_hit_rows(rows, c, fields, v):
  match rows:
    case Nil{}:
      Nil{}
    case Con{+r, rs}:
      f_choose(List<&2, KTerm>, f_eq(tg(f_rowpat(r)), "Var") || f_eq(nm(f_rowpat(r)), nm(c)), u => Con{f_hit_row(r, c, fields, v), f_hit_rows(rs, c, fields, v)}, u => f_hit_rows(rs, c, fields, v))

# Module: src/front/elaborate.bend:426
@unsafe
def f_hit_row(r, c, fields, v):
  kt("Row", "", 0, qt(r), [kt("Patterns", "", 0, 1, f_concat(f_choose(List<&2, KTerm>, f_eq(tg(f_rowpat(r)), "Var"), u => fields, u => ks(f_rowpat(r))), f_tail_terms(ks(kid(r, 0))))), f_choose(KTerm, U32.is_eq(qt(r), 0), u => kid(r, 1), u => f_sub(f_choose(KTerm, f_eq(tg(f_rowpat(r)), "Var"), u => f_sub(kid(r, 1), ix(f_rowpat(r)), v), u => kid(r, 1)), ix(v), kt("Ctr", nm(c), 0, 1, fields)))])

# Module: src/front/elaborate.bend:430
@unsafe
def f_miss_rows(rows, name):
  match rows:
    case Nil{}:
      Nil{}
    case Con{+r, rs}:
      f_choose(List<&2, KTerm>, f_eq(tg(f_rowpat(r)), "Ctr") && f_eq(nm(f_rowpat(r)), name), u => f_miss_rows(rs, name), u => Con{r, f_miss_rows(rs, name)})

# Module: src/front/elaborate.bend:438
@unsafe
def f_word(n, bits):
  f_choose(KTerm, U32.is_eq(bits, 0), u => kt("Ctr", "WNil", 0, 1, Nil{}), u => kt("Ctr", "WCon", 0, 1, [kt("Ctr", f_choose(String, U32.is_eq(U32.and(n, 1), 0), u => "False", u => "True"), 0, 1, Nil{}), f_word(U32.shrn(n, 1n), U32.sub(bits, 1))]))

# Module: src/front/elaborate.bend:442
@unsafe
def f_u32(n):
  kt("Ctr", "U32", 0, 1, [f_word(n, 32)])

# Module: src/front/elaborate.bend:446
@unsafe
def f_nat(n):
  f_choose(KTerm, U32.is_gt(n, 256), u => app(ref("U32.to_nat"), f_u32(n)), u => f_choose(KTerm, U32.is_eq(n, 0), u => kt("Ctr", "Zero", 0, 1, Nil{}), u => kt("Ctr", "Succ", 0, 1, [f_nat(U32.sub(n, 1))])))

# Module: src/front/elaborate.bend:450
@unsafe
def f_number(s, acc):
  f_choose(KTerm, String.is_empty(s), u => f_u32(acc), u => f_choose(KTerm, f_eq(s, "n"), u => f_nat(acc), u => f_choose(KTerm, Char.is_digit(f_head(s)) && (U32.is_lt(acc, 429496729) || (U32.is_eq(acc, 429496729) && U32.is_le(Char.to_u32(f_head(s)), 53))), u => f_number(f_tail(s), U32.add(U32.mul(acc, 10), U32.sub(Char.to_u32(f_head(s)), 48))), u => kt("Error", "invalid or unsupported numeric literal", 0, 0, Nil{}))))

# Module: src/front/elaborate.bend:454
@unsafe
def f_literal(s):
  f_choose(KTerm, Char.is_eq(f_head(s), '"'), u => f_string(f_tail(s)), u => f_choose(KTerm, Char.is_eq(f_head(s), '\''), u => f_char_literal(f_tail(s)), u => f_choose(KTerm, f_contains(s, '.'), u => f_float(s), u => f_number(s, 0))))

# Module: src/front/elaborate.bend:458
@unsafe
def f_string(s):
  f_choose(KTerm, Char.is_eq(f_head(s), '"'), u => kt("Ctr", "SNil", 0, 1, Nil{}), u => f_string_decoded(f_decode_char(s)))

# Module: src/front/elaborate.bend:462
@unsafe
def f_string_escape(s):
  kt("Ctr", "SCon", 0, 1, [kt("Ctr", "Chr", 0, 1, [f_u32(f_escape_code(f_head(s)))]), f_string(f_tail(s))])

# Module: src/front/elaborate.bend:466
@unsafe
def f_escape_code(c):
  f_choose(U32, Char.is_eq(c, 'n'), u => 10, u => f_choose(U32, Char.is_eq(c, 't'), u => 9, u => f_choose(U32, Char.is_eq(c, 'r'), u => 13, u => f_choose(U32, Char.is_eq(c, '0'), u => 0, u => Char.to_u32(c)))))

# Module: src/front/elaborate.bend:482
@unsafe
def f_scope_body(t, env, book):
  f_choose(KTerm, f_eq(tg(t), "Parallel"), u => f_scope_parallel(t, env, book), u => f_scope_body_base(t, env, book))

# Module: src/front/elaborate.bend:486
@unsafe
def f_flat(t, vars):
  f_choose(KTerm, f_eq(tg(t), "Parallel"), u => f_flat_parallel(t, vars), u => f_flat_base(t, vars))

# Module: src/front/elaborate.bend:496
@unsafe
def f_scope_lower(t, env, book):
  f_choose(KTerm, f_eq(tg(t), "Write"), u => f_scope(kid(t, 0), env, book), u => f_choose(KTerm, f_eq(tg(t), "ADT"), u => f_adt(t, f_scope_terms(ks(t), env, book), f_find(nm(t), book)), u => f_choose(KTerm, f_eq(tg(t), "App"), u => f_scope_app(f_scope(kid(t, 0), env, book), f_scope(kid(t, 1), env, book)), u => f_scope_base(t, env, book))))

# Module: src/front/elaborate.bend:504
@unsafe
def f_family_book(book):
  match book:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      f_choose(List<&2, KDef>, f_eq(dk(d), "ADT") || U32.is_gt(dx(d), 0), u => Con{d, f_family_book(rest)}, u => f_family_book(rest))

# Module: src/front/elaborate.bend:518
@unsafe
def f_scope(t, env, book):
  f_choose(KTerm, f_eq(tg(t), "Call"), u => f_scope_call(t, env, book), u => f_choose(KTerm, f_eq(tg(t), "TemplateArg"), u => kt("Error", "~ is only valid in a named template call", 0, 0, Nil{}), u => f_scope_lower(t, env, book)))

# Module: src/front/sugar.bend:128
@unsafe
def f_last(xs):
  match xs:
    case Nil{}:
      atom("Absent")
    case Con{+x, xt}:
      f_choose(KTerm, U32.is_eq(f_len(xt), 0), u => x, u => f_last(xt))

# Module: src/front/sugar.bend:136
@unsafe
def f_init(xs):
  match xs:
    case Nil{}:
      Nil{}
    case Con{x, +xt}:
      f_choose(List<&2, KTerm>, U32.is_eq(f_len(xt), 0), u => Nil{}, u => Con{x, f_init(xt)})

# Module: src/front/sugar.bend:144
@unsafe
def f_do_start(ts):
  f_do_types(f_tx(ts), f_args(f_tl(f_tl(ts)), ">", Nil{}))

# Module: src/front/sugar.bend:148
@unsafe
def f_do_types(monad, p):
  match p:
    case FParsed{types, ts}:
      f_do(monad, ks(types), f_skip(f_pr(f_expect(FParsed{types, ts}, ":"))), f_col(f_skip(f_tl(ts))))

# Module: src/front/sugar.bend:154
@unsafe
def f_do(monad, types, ts, indent):
  f_choose(FParsed, f_eq(f_tx(ts), "return"), u => f_do_return(monad, types, f_expr(f_tl(ts), 0)), u => f_do_statement(monad, types, f_expr(ts, 0), indent))

# Module: src/front/sugar.bend:158
@unsafe
def f_do_return(monad, types, p):
  match p:
    case FParsed{n, ts}:
      FParsed{f_app(ref(monad ++ ".pure"), f_concat(types, [n])), ts}

# Module: src/front/sugar.bend:164
@unsafe
def f_do_statement(monad, types, p, indent):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_do_annotated(monad, types, n, f_expr(f_tl(ts), 1), indent), u => f_choose(FParsed, f_eq(f_tx(ts), "<-"), u => f_do_value(monad, types, kt("Ref", "_", ix(n), 1, Nil{}), n, False{}, f_expr(f_tl(ts), 0), indent), u => f_choose(FParsed, (f_eq(f_tx(ts), ";") || U32.is_eq(f_col(f_skip(ts)), indent)) && Bool.not(f_eq(f_tx(f_skip(ts)), "<eof>")), u => f_do_value(monad, types, kt("Ref", "_", ix(n), 1, Nil{}), ref("Unit"), False{}, FParsed{n, ts}, indent), u => FParsed{n, ts})))

# Module: src/front/sugar.bend:170
@unsafe
def f_do_annotated(monad, types, binder, p, indent):
  match p:
    case FParsed{ty, +ts}:
      f_do_value(monad, types, binder, ty, f_eq(f_tx(ts), "="), f_expr(f_tl(ts), 0), indent)

# Module: src/front/sugar.bend:176
@unsafe
def f_do_value(monad, types, binder, ty, pure, p, indent):
  match p:
    case FParsed{v, ts}:
      f_do_tail(monad, types, binder, ty, pure, v, f_do(monad, types, f_skip(ts), indent))

# Module: src/front/sugar.bend:182
@unsafe
def f_do_tail(monad, types, binder, ty, pure, v, p):
  match p:
    case FParsed{body, ts}:
      FParsed{f_choose(KTerm, pure, u => kt("Local", "", 0, 1, [binder, kt("Ann", "", 0, 1, [v, ty]), body]), u => f_app(ref(monad ++ ".bind"), f_concat(f_init(types), [ty, f_last(types), v, kt("Lam", nm(binder), ix(binder), qt(binder), [body])]))), ts}

# Module: src/front/sugar.bend:188
@unsafe
def f_error_term(t):
  f_choose(String, f_eq(tg(t), "Error"), u => nm(t), u => f_error_terms(ks(t)))

# Module: src/front/sugar.bend:192
@unsafe
def f_error_terms(ts):
  match ts:
    case Nil{}:
      ""
    case Con{t, rest}:
      f_error_more(f_error_term(t), rest)

# Module: src/front/sugar.bend:200
@unsafe
def f_error_more(err, rest):
  f_choose(String, String.is_empty(err), u => f_error_terms(rest), u => err)

# Module: src/front/sugar.bend:204
@unsafe
def f_error_defs(ds):
  match ds:
    case Nil{}:
      ""
    case Con{+d, rest}:
      f_error_def_next(f_error_terms([dt(d), dv(d)]), dc(d), rest)

# Module: src/front/sugar.bend:212
@unsafe
def f_error_def_next(err, ctors, rest):
  f_choose(String, String.is_empty(err), u => f_error_defs_more(f_error_defs(ctors), rest), u => err)

# Module: src/front/sugar.bend:216
@unsafe
def f_error_defs_more(err, rest):
  f_choose(String, String.is_empty(err), u => f_error_defs(rest), u => err)

# Module: src/front/sugar.bend:220
@unsafe
def f_validate_result(r):
  match r:
    case FResult{+book, +err, imports}:
      FResult{book, f_choose(String, String.is_empty(err), u => f_error_defs(book), u => err), imports}

# Module: src/front/sugar.bend:226
@unsafe
def f_rewrite(ts):
  f_rewrite_head(f_expr(ts, 0))

# Module: src/front/sugar.bend:230
@unsafe
def f_rewrite_head(p):
  match p:
    case FParsed{+e, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "@"), u => f_rewrite_proof(nm(e), ix(e), f_expect(f_expr(f_tl(ts), 0), ":")), u => f_rewrite_proof("", ix(e), f_expect(FParsed{e, ts}, ":")))

# Module: src/front/sugar.bend:236
@unsafe
def f_rewrite_proof(name, id, p):
  match p:
    case FParsed{e, ts}:
      f_rewrite_motive(name, id, e, f_expr(ts, 0))

# Module: src/front/sugar.bend:242
@unsafe
def f_rewrite_motive(name, id, e, p):
  match p:
    case FParsed{motive, ts}:
      f_rewrite_body(e, kt("Lam", "_", U32.add(id, 2147483648), 4, [kt("Lam", name, id, 1, [motive])]), f_body(ts))

# Module: src/front/sugar.bend:248
@unsafe
def f_rewrite_body(e, motive, p):
  match p:
    case FParsed{body, ts}:
      FParsed{kt("Rwt", "", 0, 1, [e, motive, body]), ts}


# Layout-sensitive locals and refinement clauses.

# Module: src/front/sugar.bend:276
@unsafe
def f_law_where(name, binder, ty, p, book, imports, clauses):
  match p:
    case FParsed{predicate, ts}:
      f_law_type(name, binder, FParsed{f_app(ref("Exists"), [ty, kt("Lam", nm(binder), ix(binder), 1, [predicate])]), ts}, book, imports, clauses)

# Module: src/front/sugar.bend:282
@unsafe
def f_erased_local(ts):
  f_statement(FParsed{kt("Ref", f_tx(ts), f_atid(ts), 0, Nil{}), f_tl(ts)})

# Module: src/front/sugar.bend:286
@unsafe
def f_write_statement(n, ts):
  f_choose(FParsed, (f_eq(f_tx(ts), ";") || U32.is_eq(f_col(f_skip(ts)), U32.and(ix(n), 65535))) && Bool.not(f_eq(f_tx(f_skip(ts)), "<eof>")), u => f_let_value(kt("Ref", nm(n), ix(n), 1, Nil{}), FParsed{kid(n, 0), ts}), u => FParsed{kid(n, 0), ts})

# Module: src/front/sugar.bend:300
@unsafe
def f_group_namespace(n, p):
  match p:
    case FParsed{ty, ts}:
      FParsed{f_namespace(n, ty), ts}

# Module: src/front/sugar.bend:306
@unsafe
def f_template_expr(p):
  match p:
    case FParsed{t, ts}:
      FParsed{kt("TemplateArg", "", 0, 0, [t]), ts}

# Module: src/front/unicode.bend:44
@unsafe
def f_decode_char(s):
  f_choose(FDecoded, String.is_empty(s), u => FDecoded{0, "", "expected character"}, u => f_choose(FDecoded, Char.is_eq(f_head(s), '\\'), u => f_decode_escape(f_tail(s)), u => FDecoded{Char.to_u32(f_head(s)), f_tail(s), ""}))

# Module: src/front/unicode.bend:48
@unsafe
def f_decode_escape(s):
  f_choose(FDecoded, Char.is_eq(f_head(s), 'u') && Char.is_eq(f_head(f_tail(s)), '{'), u => f_decode_unicode(f_tail(f_tail(s)), 0, 0), u => f_choose(FDecoded, f_escape_valid(f_head(s)), u => FDecoded{f_escape_code(f_head(s)), f_tail(s), ""}, u => FDecoded{0, s, "invalid character escape"}))

# Module: src/front/unicode.bend:52
@unsafe
def f_escape_valid(c):
  Char.is_eq(c, 'n') || Char.is_eq(c, 't') || Char.is_eq(c, 'r') || Char.is_eq(c, '0') || Char.is_eq(c, '\\') || Char.is_eq(c, '\'') || Char.is_eq(c, '"')

# Module: src/front/unicode.bend:56
@unsafe
def f_hex(c):
  f_choose(U32, Char.is_digit(c), u => U32.sub(Char.to_u32(c), 48), u => f_choose(U32, U32.is_ge(Char.to_u32(Char.to_lower(c)), 97) && U32.is_le(Char.to_u32(Char.to_lower(c)), 102), u => U32.sub(Char.to_u32(Char.to_lower(c)), 87), u => 16))

# Module: src/front/unicode.bend:60
@unsafe
def f_decode_unicode(s, code, count):
  f_choose(FDecoded, Char.is_eq(f_head(s), '}') && U32.is_gt(count, 0), u => FDecoded{code, f_tail(s), ""}, u => f_choose(FDecoded, U32.is_lt(f_hex(f_head(s)), 16) && U32.is_lt(count, 6), u => f_decode_unicode(f_tail(s), U32.add(U32.mul(code, 16), f_hex(f_head(s))), U32.add(count, 1)), u => FDecoded{0, s, "invalid Unicode escape"}))

# Module: src/front/unicode.bend:64
@unsafe
def f_string_decoded(d):
  match d:
    case FDecoded{code, rest, +err}:
      f_choose(KTerm, String.is_empty(err), u => kt("Ctr", "SCon", 0, 1, [kt("Ctr", "Chr", 0, 1, [f_u32(code)]), f_string(rest)]), u => kt("Error", err, 0, 0, Nil{}))

# Module: src/front/unicode.bend:70
@unsafe
def f_char_literal(s):
  f_char_decoded(f_decode_char(s))

# Module: src/front/unicode.bend:74
@unsafe
def f_char_decoded(d):
  match d:
    case FDecoded{code, +rest, +err}:
      f_choose(KTerm, String.is_empty(err) && f_eq(rest, "'"), u => kt("Ctr", "Chr", 0, 1, [f_u32(code)]), u => kt("Error", "character literal requires one character and a closing quote", 0, 0, Nil{}))

# Module: src/front/unicode.bend:80
@unsafe
def f_float_bits(bits):
  f_choose(KTerm, U32.is_eq(U32.and(bits, 2139095040), 2139095040), u => kt("Error", "float literal must be finite", 0, 0, Nil{}), u => kt("Ctr", "F32", 0, 1, [f_word(bits, 32)]))

# Module: src/front/literals_arrays.bend:83
@unsafe
def f_contains(s, c):
  f_choose(Bool, String.is_empty(s), u => False{}, u => Char.is_eq(f_head(s), c) || f_contains(f_tail(s), c))

# Module: src/front/literals_arrays.bend:87
@unsafe
def f_float(s):
  f_float_read(F32.read(s))

# Module: src/front/literals_arrays.bend:91
@unsafe
def f_float_read(m):
  match m:
    case None{}:
      kt("Error", "invalid f32 literal", 0, 0, Nil{})
    case Some{v}:
      f_float_bits(F32.bits(v))

# Module: src/front/literals_arrays.bend:99
@unsafe
def f_array(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "]"), u => FParsed{kt("Ctr", "Nil", 0, 1, Nil{}), f_tl(ts)}, u => f_array_first(f_expr(ts, 0)))

# Module: src/front/literals_arrays.bend:103
@unsafe
def f_array_first(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_array_type(n, f_expr(f_tl(ts), 12)), u => f_list(f_args(f_choose(List<&2, FToken>, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), "]", [n])))

# Module: src/front/literals_arrays.bend:109
@unsafe
def f_array_type(n, p):
  match p:
    case FParsed{ty, +ts}:
      f_array_size(n, ty, f_eq(f_tx(ts), "*"), f_expect(f_expr(f_tl(ts), 0), "]"))

# Module: src/front/literals_arrays.bend:115
@unsafe
def f_array_size(n, ty, count, p):
  match p:
    case FParsed{size, ts}:
      FParsed{f_app(ref("Array.new"), [ty, f_choose(KTerm, count, u => f_array_depth(size), u => size), f_namespace(n, ty)]), ts}

# Module: src/front/literals_arrays.bend:121
@unsafe
def f_array_depth(size):
  f_choose(KTerm, f_eq(tg(size), "Literal"), u => f_power_depth(nm(size), 0), u => kt("Error", "array count must be a literal power of two", 0, 0, Nil{}))

# Module: src/front/literals_arrays.bend:125
@unsafe
def f_power_depth(s, n):
  f_choose(KTerm, String.is_empty(s) || f_eq(s, "n"), u => f_power_bits(n, 0), u => f_choose(KTerm, Char.is_digit(f_head(s)), u => f_power_depth(f_tail(s), U32.add(U32.mul(n, 10), U32.sub(Char.to_u32(f_head(s)), 48))), u => kt("Error", "array count must be a literal power of two", 0, 0, Nil{})))

# Module: src/front/literals_arrays.bend:129
@unsafe
def f_power_bits(n, d):
  f_choose(KTerm, U32.is_eq(n, 1), u => f_nat(d), u => f_choose(KTerm, U32.is_eq(n, 0) || U32.is_eq(U32.and(n, 1), 1), u => kt("Error", "array count must be a positive power of two", 0, 0, Nil{}), u => f_power_bits(U32.shrn(n, 1n), U32.add(d, 1))))

# Module: src/front/literals_arrays.bend:133
@unsafe
def f_index(n, p, min):
  match p:
    case FParsed{idx, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "<-"), u => f_index_value(n, idx, f_expr(f_tl(ts), 2), min), u => f_grow(FParsed{f_app(ref("Array.get"), [ref("U32"), n, f_namespace(idx, ref("U32"))]), ts}, min))

# Module: src/front/literals_arrays.bend:139
@unsafe
def f_index_value(n, idx, p, min):
  match p:
    case FParsed{v, ts}:
      f_grow(FParsed{f_choose(KTerm, f_eq(tg(n), "Ref"), u => kt("Write", nm(n), ix(n), 1, [f_app(ref("Array.set"), [ref("U32"), n, f_namespace(idx, ref("U32")), v])]), u => f_app(ref("Array.set"), [ref("U32"), n, f_namespace(idx, ref("U32")), v])), ts}, min)

# Module: src/front/literals_arrays.bend:145
@unsafe
def f_ends_nat(s):
  f_choose(Bool, String.is_empty(f_tail(s)), u => f_eq(s, "n"), u => f_ends_nat(f_tail(s)))

# Module: src/front/literals_arrays.bend:149
@unsafe
def f_nat_plus(lit, b):
  f_nat_extend(f_literal(nm(lit)), b)

# Module: src/front/literals_arrays.bend:153
@unsafe
def f_nat_extend(a, b):
  f_choose(KTerm, f_eq(tg(a), "Ctr") && f_eq(nm(a), "Zero"), u => b, u => f_choose(KTerm, f_eq(tg(a), "Ctr") && f_eq(nm(a), "Succ"), u => kt("Ctr", "Succ", 0, 1, [f_nat_extend(kid(a, 0), b)]), u => f_app(ref("Nat.add"), [a, b])))

# Module: src/front/literals_arrays.bend:157
@unsafe
def f_namespace(t, ty):
  f_choose(KTerm, f_eq(tg(t), "Local") || f_eq(tg(t), "Parallel"), u => kt(tg(t), nm(t), ix(t), qt(t), [kid(t, 0), kid(t, 1), f_namespace(kid(t, 2), ty)]), u => f_choose(KTerm, f_eq(tg(t), "Ref") && Char.is_eq(f_head(nm(t)), '.'), u => ref(nm(f_namespace_head(ty)) ++ nm(t)), u => f_choose(KTerm, (f_eq(tg(t), "App") || f_eq(tg(t), "Call")) && f_namespace_operator(f_namespace_head(t)), u => KTerm{tg(t), nm(t), ix(t), qt(t), f_namespace_terms(ks(t), ty), rm(t)}, u => t)))

# Module: src/front/literals_arrays.bend:175
@unsafe
def f_pattern_literal(s):
  f_choose(KTerm, String.ends_with(s, "n"), u => f_nat_pattern(f_pattern_number(s, 0)), u => f_literal(s))

# Module: src/front/literals_arrays.bend:179
@unsafe
def f_pattern_number(s, n):
  f_choose(U32, f_eq(s, "n") || String.is_empty(s), u => n, u => f_pattern_number(f_tail(s), U32.add(U32.mul(n, 10), U32.sub(Char.to_u32(f_head(s)), 48))))

# Module: src/front/literals_arrays.bend:183
@unsafe
def f_nat_pattern(n):
  f_choose(KTerm, U32.is_eq(n, 0), u => kt("Ctr", "Zero", 0, 1, Nil{}), u => kt("Ctr", "Succ", 0, 1, [f_nat_pattern(U32.sub(n, 1))]))

# Module: src/front/literals_arrays.bend:201
@unsafe
def f_namespace_head(t):
  f_choose(KTerm, f_eq(tg(t), "App") || f_eq(tg(t), "Call"), u => f_namespace_head(kid(t, 0)), u => t)

# Module: src/front/literals_arrays.bend:205
@unsafe
def f_namespace_operator(head):
  f_eq(tg(head), "Ref") && (Char.is_eq(f_head(nm(head)), '.') || f_eq(nm(head), "Bool.and") || f_eq(nm(head), "Bool.or") || f_eq(nm(head), "String.append"))

# Module: src/front/literals_arrays.bend:209
@unsafe
def f_namespace_terms(terms, ty):
  match terms:
    case Nil{}:
      Nil{}
    case Con{term, rest}:
      Con{f_namespace(term, ty), f_namespace_terms(rest, ty)}

# Module: src/front/parallel.bend:72
@unsafe
def f_parallel(ts, pats):
  f_choose(FParsed, f_eq(f_tx(ts), "="), u => f_parallel_values(f_tl(ts), List.reverse(&2, KTerm, pats), f_len(pats), Nil{}), u => f_parallel_pat(f_expr(ts, 0), pats))

# Module: src/front/parallel.bend:76
@unsafe
def f_parallel_pat(p, pats):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_parallel(ts, Con{n, pats}))

# Module: src/front/parallel.bend:82
@unsafe
def f_parallel_values(ts, pats, left, vals):
  f_choose(FParsed, U32.is_eq(left, 0), u => f_parallel_body(pats, List.reverse(&2, KTerm, vals), f_body(ts)), u => f_parallel_value(f_expr(ts, 0), pats, left, vals))

# Module: src/front/parallel.bend:86
@unsafe
def f_parallel_value(p, pats, left, vals):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_parallel_values(ts, pats, U32.sub(left, 1), Con{n, vals}))

# Module: src/front/parallel.bend:92
@unsafe
def f_parallel_body(pats, vals, p):
  match p:
    case FParsed{body, ts}:
      FParsed{kt("Parallel", "", 0, 1, [kt("Patterns", "", 0, 1, pats), kt("Values", "", 0, 1, vals), body]), ts}

# Module: src/front/parallel.bend:98
@unsafe
def f_scope_parallel(t, env, book):
  f_scope_parallel_pats(t, f_patterns(ks(kid(t, 0))), env, book)

# Module: src/front/parallel.bend:102
@unsafe
def f_scope_parallel_pats(t, pats, env, book):
  kt("Parallel", "", 0, 1, [kt("Patterns", "", 0, 1, pats), kt("Values", "", 0, 1, f_scope_terms(ks(kid(t, 1)), env, book)), f_scope_body(kid(t, 2), f_concat(f_penv(pats), env), book)])

# Module: src/front/parallel.bend:106
@unsafe
def f_parallel_binds(pats, vals):
  match pats:
    case Nil{}:
      Nil{}
    case Con{+p, ps}:
      Con{kt("Bind", nm(p), ix(p), qt(p), [terms_at(vals, 0)]), f_parallel_binds(ps, f_tail_terms(vals))}

# Module: src/front/parallel.bend:114
@unsafe
def f_unlamb(body, n):
  f_choose(KTerm, U32.is_eq(n, 0), u => body, u => f_choose(KTerm, f_eq(tg(body), "Lam"), u => f_unlamb(kid(body, 0), U32.sub(n, 1)), u => kt("Error", "cannot match a parallel let binding", 0, 0, Nil{})))

# Module: src/front/parallel.bend:118
@unsafe
def f_flat_parallel(t, vars):
  f_lbind(vars, kt("Let", "", 0, 1, f_concat(f_parallel_binds(ks(kid(t, 0)), ks(kid(t, 1))), [f_unlamb(f_flat(kid(t, 2), ks(kid(t, 0))), f_len(ks(kid(t, 0))))])))

# Module: src/front/parallel.bend:122
@unsafe
def f_statement_more(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Write"), u => f_write_statement(n, ts), u => f_choose(FParsed, U32.is_eq(f_kind(ts), 1) || f_eq(f_tx(ts), "+bind"), u => f_parallel(ts, [n]), u => FParsed{n, ts}))

# Module: src/front/parallel.bend:128
@unsafe
def f_typed_let_try(n, old, p):
  match p:
    case FParsed{ty, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "="), u => f_let_value(n, f_let_ann(ty, f_expr(f_tl(ts), 0))), u => FParsed{n, old})

# Module: src/front/fresh_work.bend:60
@unsafe
def f_fresh_stack(term, env, next):
  ffw_walk(term, env, next, Nil{})

# Module: src/front/fresh_work.bend:63
@unsafe
def ffw_walk(term, env, next, stack):
  f_choose(FFresh, String.eq(tg(term), "Var"), u => ffw_done(f_rename_var(term, env), next, stack),
    u => f_choose(FFresh, String.eq(tg(term), "All"), u => ffw_walk(kid(term, 0), env, U32.add(next, 1), Con{FFAllA{term, env, next}, stack}),
    u => f_choose(FFresh, String.eq(tg(term), "Lam"), u => ffw_walk(kid(term, 0), Con{kt("Map", "", ix(term), 0, [var(nm(term), next)]), env}, U32.add(next, 1), Con{FFLambda{term, next}, stack}),
    u => f_choose(FFresh, String.eq(tg(term), "Let"), u => ffw_let(env, env, ks(term), Nil{}, next, stack),
    u => ffw_kids(term, env, ks(term), Nil{}, next, stack)))))

# Module: src/front/fresh_work.bend:70
@unsafe
def ffw_done(term, next, stack):
  match stack:
    case Nil{}:
      FFresh{term, next}
    case Con{frame, rest}:
      ffw_frame(frame, term, next, rest)

# Module: src/front/fresh_work.bend:77
@unsafe
def ffw_frame(frame, value, next, stack):
  match frame:
    case FFAllA{+term, +env, +id}:
      ffw_walk(kid(term, 1), Con{kt("Map", "", ix(term), 0, [var(nm(term), id)]), env}, next, Con{FFAllB{term, id, value}, stack})
    case FFAllB{+term, id, typ}:
      ffw_done(kt("All", nm(term), id, qt(term), [typ, value]), next, stack)
    case FFLambda{+term, id}:
      ffw_done(kt("Lam", nm(term), id, qt(term), [value]), next, stack)
    case FFKids{term, env, pending, built}:
      ffw_kids(term, env, pending, Con{value, built}, next, stack)
    case FFLetValue{env, bodyenv, +id, +binding, pending, built}:
      ffw_let(env, Con{kt("Map", "", ix(binding), 0, [var(nm(binding), id)]), bodyenv}, pending, Con{kt("Bind", nm(binding), id, qt(binding), [value]), built}, next, stack)
    case FFLetBody{built}:
      ffw_done(kt("Let", "", 0, 1, ffw_reverse_onto(built, [value])), next, stack)

# Module: src/front/fresh_work.bend:92
@unsafe
def ffw_kids(term, env, pending, built, next, stack):
  match pending:
    case Nil{}:
      ffw_done(KTerm{tg(term), nm(term), ix(term), qt(term), List.reverse(&2,KTerm,built), rm(term)}, next, stack)
    case Con{head, rest}:
      ffw_walk(head, env, next, Con{FFKids{term, env, rest, built}, stack})

# Module: src/front/fresh_work.bend:99
@unsafe
def ffw_let(env, bodyenv, items, built, next, stack):
  match items:
    case Nil{}:
      ffw_done(kt("Error", "empty core let", 0, 0, Nil{}), next, stack)
    case Con{term, tail}:
      ffw_let_tail(env, bodyenv, term, tail, built, next, stack)

# Module: src/front/fresh_work.bend:106
@unsafe
def ffw_let_tail(env, bodyenv, term, tail, built, next, stack):
  match tail:
    case Nil{}:
      ffw_walk(term, bodyenv, next, Con{FFLetBody{built}, stack})
    case Con{head, rest}:
      ffw_walk(kid(term, 0), env, U32.add(next, 1), Con{FFLetValue{env, bodyenv, next, term, tail, built}, stack})

# Module: src/front/fresh_work.bend:119
@unsafe
def ffw_reverse_onto(items, onto):
  match items:
    case Nil{}:
      onto
    case Con{head, tail}:
      ffw_reverse_onto(tail, Con{head, onto})

# Definition lists require the same explicit continuation discipline: computing
# the freshened tail before constructing its enclosing list consumes host stack
# even when each individual term is shallow. Constructor-definition lists share
# this worklist, so both declaration breadth and nested list depth are bounded
# by heap storage rather than JavaScript's call stack.

# Module: src/front/fresh_work.bend:172
@unsafe
def f_fresh_book_stack(book, next):
  ffd_walk(book, next, Nil{}, Nil{})

# Module: src/front/fresh_work.bend:175
@unsafe
def ffd_walk(book, next, built, stack):
  match book:
    case Nil{}:
      ffd_done(List.reverse(&2,KDef,built), next, stack)
    case Con{+definition, pending}:
      ffd_type(definition, pending, built, stack, f_fresh_term(dt(definition), Nil{}, next))

# Module: src/front/fresh_work.bend:182
@unsafe
def ffd_type(definition, pending, built, stack, result):
  match result:
    case FFresh{typ, next}:
      ffd_value(definition, pending, built, stack, typ, f_fresh_term(dv(definition), Nil{}, next))

# Module: src/front/fresh_work.bend:187
@unsafe
def ffd_value(definition, pending, built, stack, typ, result):
  match result:
    case FFresh{value, next}:
      ffd_walk(dc(definition), next, Nil{}, Con{FFDefFrame{definition, pending, built, typ, value}, stack})

# Module: src/front/fresh_work.bend:192
@unsafe
def ffd_done(book, next, stack):
  match stack:
    case Nil{}:
      FFreshDefs{book, next}
    case Con{frame, rest}:
      ffd_frame(frame, book, next, rest)

# Module: src/front/fresh_work.bend:199
@unsafe
def ffd_frame(frame, ctors, next, stack):
  match frame:
    case FFDefFrame{+definition, pending, built, typ, value}:
      ffd_walk(pending, next, Con{KDef{dn(definition), dk(definition), da(definition), dx(definition), typ, value, ctors, db(definition), du(definition)}, built}, stack)

# Module: src/front/freshen.bend:131
@unsafe
def f_fresh_term(t, env, next):
  f_fresh_stack(t, env, next)

# Module: src/front/freshen.bend:135
@unsafe
def f_rename_var(t, env):
  match env:
    case Nil{}:
      t
    case Con{+m, ms}:
      f_choose(KTerm, U32.is_eq(ix(t), ix(m)), u => kt("Var", nm(t), ix(kid(m, 0)), qt(t), Nil{}), u => f_rename_var(t, ms))

# Module: src/front/freshen.bend:143
@unsafe
def f_fresh_terms(ts, env, next):
  match ts:
    case Nil{}:
      FFreshTerms{Nil{}, next}
    case Con{t, rest}:
      f_fresh_cons(f_fresh_term(t, env, next), rest, env)

# Module: src/front/freshen.bend:151
@unsafe
def f_fresh_cons(r, rest, env):
  match r:
    case FFresh{t, next}:
      f_fresh_prepend(t, f_fresh_terms(rest, env, next))

# Module: src/front/freshen.bend:157
@unsafe
def f_fresh_prepend(t, r):
  match r:
    case FFreshTerms{ts, next}:
      FFreshTerms{Con{t, ts}, next}

# Module: src/front/freshen.bend:163
@unsafe
def f_fresh_generic(t, r):
  match r:
    case FFreshTerms{ts, next}:
      FFresh{KTerm{tg(t), nm(t), ix(t), qt(t), ts, rm(t)}, next}

# Module: src/front/freshen.bend:169
@unsafe
def f_fresh_all(t, env, id, r):
  match r:
    case FFresh{a, next}:
      f_fresh_all_body(t, id, a, f_fresh_term(kid(t, 1), Con{kt("Map", "", ix(t), 0, [var(nm(t), id)]), env}, next))

# Module: src/front/freshen.bend:175
@unsafe
def f_fresh_all_body(t, id, a, r):
  match r:
    case FFresh{b, next}:
      FFresh{kt("All", nm(t), id, qt(t), [a, b]), next}

# Module: src/front/freshen.bend:181
@unsafe
def f_fresh_lam(t, id, r):
  match r:
    case FFresh{b, next}:
      FFresh{kt("Lam", nm(t), id, qt(t), [b]), next}

# Module: src/front/freshen.bend:187
@unsafe
def f_fresh_let(t, env, bodyenv, next, items, acc):
  match items:
    case Nil{}:
      FFresh{kt("Error", "empty core let", 0, 0, Nil{}), next}
    case Con{+x, +xs}:
      f_choose(FFresh, U32.is_eq(f_len(xs), 0), u => f_fresh_let_body(acc, f_fresh_term(x, bodyenv, next)), u => f_fresh_let_value(t, env, bodyenv, next, x, xs, acc, f_fresh_term(kid(x, 0), env, U32.add(next, 1))))

# Module: src/front/freshen.bend:195
@unsafe
def f_fresh_let_body(acc, r):
  match r:
    case FFresh{body, next}:
      FFresh{kt("Let", "", 0, 1, f_concat(List.reverse(&2, KTerm, acc), [body])), next}

# Module: src/front/freshen.bend:201
@unsafe
def f_fresh_let_value(t, env, bodyenv, id, binding, rest, acc, r):
  match r:
    case FFresh{value, next}:
      f_fresh_let(t, env, Con{kt("Map", "", ix(binding), 0, [var(nm(binding), id)]), bodyenv}, next, rest, Con{kt("Bind", nm(binding), id, qt(binding), [value]), acc})

# Module: src/front/freshen.bend:207
@unsafe
def f_fresh_defs(ds, next):
  f_fresh_book_stack(ds, next)

# Module: src/front/freshen.bend:211
@unsafe
def f_fresh_def_type(d, rest, r):
  match r:
    case FFresh{ty, next}:
      f_fresh_def_value(d, rest, ty, f_fresh_term(dv(d), Nil{}, next))

# Module: src/front/freshen.bend:217
@unsafe
def f_fresh_def_value(d, rest, ty, r):
  match r:
    case FFresh{value, next}:
      f_fresh_def_ctors(d, rest, ty, value, f_fresh_defs(dc(d), next))

# Module: src/front/freshen.bend:223
@unsafe
def f_fresh_def_ctors(d, rest, ty, value, r):
  match r:
    case FFreshDefs{ctors, next}:
      f_fresh_defs_prepend(KDef{dn(d), dk(d), da(d), dx(d), ty, value, ctors, db(d), du(d)}, f_fresh_defs(rest, next))

# Module: src/front/freshen.bend:229
@unsafe
def f_fresh_defs_prepend(d, r):
  match r:
    case FFreshDefs{ds, next}:
      FFreshDefs{Con{d, ds}, next}

# Module: src/front/freshen.bend:235
@unsafe
def f_fresh_result(r):
  match r:
    case FResult{book, err, imports}:
      f_fresh_result_end(f_fresh_defs(book, 1), err, imports)

# Module: src/front/freshen.bend:241
@unsafe
def f_fresh_result_end(r, err, imports):
  match r:
    case FFreshDefs{book, next}:
      FResult{book, err, imports}

# Module: src/load/paths.bend:49
@unsafe
def f_unquote(s):
  f_unquote_chars(f_tail(s))

# Module: src/load/paths.bend:53
@unsafe
def f_unquote_chars(s):
  f_choose(String, String.is_empty(s) || Char.is_eq(f_head(s), '"'), u => "", u => f_choose(String, Char.is_eq(f_head(s), '\\'), u => SCon{Chr{f_escape_code(f_head(f_tail(s)))}, f_unquote_chars(f_tail(f_tail(s)))}, u => SCon{f_head(s), f_unquote_chars(f_tail(s))}))

# Module: src/load/paths.bend:57
@unsafe
def f_path_dir(path):
  f_path_scan(path, "", "")

# Module: src/load/paths.bend:61
@unsafe
def f_path_scan(path, acc, dir):
  f_choose(String, String.is_empty(path), u => dir, u => f_path_scan(f_tail(path), acc ++ SCon{f_head(path), ""}, f_choose(String, Char.is_eq(f_head(path), '/'), u => acc ++ "/", u => dir)))

# Module: src/load/paths.bend:65
@unsafe
def f_path_join(dir, path):
  f_choose(String, Char.is_eq(f_head(path), '/'), u => path, u => dir ++ path)

# Module: src/load/paths.bend:69
@unsafe
def f_path_term(t, dir):
  KTerm{tg(t), f_choose(String, f_eq(tg(t), "Path"), u => f_path_join(dir, nm(t)), u => nm(t)), ix(t), qt(t), f_path_terms(ks(t), dir), rm(t)}

# Module: src/load/paths.bend:73
@unsafe
def f_path_terms(ts, dir):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      Con{f_path_term(t, dir), f_path_terms(rest, dir)}

# Module: src/load/paths.bend:81
@unsafe
def f_path_defs(ds, dir, native):
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), f_choose(KTerm, f_eq(tg(dv(d)), "Foreign"), u => f_path_term(dv(d), dir), u => dv(d)), f_path_defs(dc(d), dir, native), native || db(d), du(d)}, f_path_defs(rest, dir, native)}

# Module: src/load/paths.bend:89
@unsafe
def f_path_result(r, path, native):
  match r:
    case FResult{book, err, imports}:
      FResult{f_path_defs(book, f_path_dir(path), native), err, imports}

# Module: src/front/families.bend:52
@unsafe
def f_leading_quants(ty):
  f_choose(U32, f_eq(tg(ty), "All") && f_eq(tg(kid(ty, 0)), "Qnt"), u => U32.add(1, f_leading_quants(kid(ty, 1))), u => 0)

# Module: src/front/families.bend:56
@unsafe
def f_quants(n, q):
  f_choose(List<&2, KTerm>, U32.is_eq(n, 0), u => Nil{}, u => Con{qua(q), f_quants(U32.sub(n, 1), q)})

# Module: src/front/families.bend:60
@unsafe
def f_adt(t, args, d):
  f_adt_fill(t, args, da(d), f_leading_quants(dt(d)))

# Module: src/front/families.bend:64
@unsafe
def f_adt_fill(t, args, arity, g):
  f_choose(KTerm, U32.is_eq(U32.add(f_len(args), g), arity), u => KTerm{"ADT", nm(t), ix(t), qt(t), f_concat(f_quants(g, f_choose(U32, U32.is_eq(qt(t), 2), u => 2, u => 1)), args), rm(t)}, u => KTerm{"ADT", nm(t), ix(t), qt(t), f_choose(List<&2,KTerm>, U32.is_eq(qt(t), 2), u => f_concat(f_quants(g, 2), f_drop_terms(args, g)), u => args), rm(t)})

# Module: src/front/families.bend:68
@unsafe
def f_drop_terms(ts, n):
  f_choose(List<&2,KTerm>, U32.is_eq(n, 0), u => ts, u => f_drop_terms(f_tail_terms(ts), U32.sub(n, 1)))

# Module: src/front/families.bend:72
@unsafe
def f_scope_app(f, x):
  f_choose(KTerm, f_eq(tg(f), "Lam"), u => f_sub(kid(f, 0), ix(f), x), u => app(f, x))

# Module: src/front/families.bend:76
@unsafe
def f_mark_rows(rows, q):
  match rows:
    case Nil{}:
      q
    case Con{+r, rs}:
      f_mark_rows(rs, f_choose(U32, f_eq(tg(f_rowpat(r)), "Var") && U32.is_eq(qt(f_rowpat(r)), 2), u => 2, u => q))

# Module: src/front/families.bend:84
@unsafe
def f_mark_vars(vars, id, q):
  match vars:
    case Nil{}:
      Nil{}
    case Con{+v, vs}:
      Con{f_choose(KTerm, U32.is_eq(ix(v), id), u => kt("Var", nm(v), ix(v), q, Nil{}), u => v), f_mark_vars(vs, id, q)}

# Module: src/front/families.bend:92
@unsafe
def f_mark_fields(vars, q):
  match vars:
    case Nil{}:
      Nil{}
    case Con{+v, vs}:
      Con{kt("Var", nm(v), ix(v), f_choose(U32, U32.is_eq(q, 2), u => 2, u => qt(v)), Nil{}), f_mark_fields(vs, q)}

# Module: src/front/families.bend:150
@unsafe
def f_scope_call(t, env, book):
  f_scope_call_head(t, env, book, f_scope(kid(t, 0), env, book))

# Module: src/front/families.bend:154
@unsafe
def f_scope_call_head(t, env, book, head):
  f_choose(KTerm, f_templates_valid(f_tail_terms(ks(t)), f_choose(U32, f_eq(tg(head), "Ref") && f_eq(tg(kid(t, 0)), "Ref"), u => dx(f_find(nm(head), book)), u => 0), False{}), u => f_scope_apply_many(head, f_scope_call_args(f_tail_terms(ks(t)), env, book)), u => kt("Error", "~ arguments require leading template slots on a named template definition", 0, 0, Nil{}))

# Module: src/front/families.bend:158
@unsafe
def f_templates_valid(args, left, ordinary):
  match args:
    case Nil{}:
      True{}
    case Con{+a, rest}:
      f_choose(Bool, f_eq(tg(a), "TemplateArg"), u => Bool.not(ordinary) && U32.is_gt(left, 0) && f_templates_valid(rest, U32.sub(left, 1), False{}), u => f_templates_valid(rest, left, True{}))

# Module: src/front/families.bend:166
@unsafe
def f_scope_call_args(args, env, book):
  match args:
    case Nil{}:
      Nil{}
    case Con{+a, rest}:
      Con{f_scope(f_choose(KTerm, f_eq(tg(a), "TemplateArg"), u => kid(a, 0), u => a), env, book), f_scope_call_args(rest, env, book)}

# Module: src/front/families.bend:174
@unsafe
def f_scope_apply_many(head, args):
  match args:
    case Nil{}:
      head
    case Con{a, rest}:
      f_scope_apply_many(f_scope_app(head, a), rest)

# Module: src/front/families.bend:182
@unsafe
def f_scope_reference(t, bound, book):
  f_choose(KTerm, U32.is_eq(qt(t), 2) && Bool.not(f_eq(dk(f_find(nm(t), book)), "ADT")), u => kt("Error", "+ marks a binder or a quantified datatype, not a value reference", 0, 0, Nil{}), u => f_choose(KTerm, U32.is_eq(qt(t), 3) && (Bool.not(f_eq(tg(bound), "Absent")) || f_eq(dk(f_find(nm(t), book)), "ADT")), u => kt("Error", "offload requires a named definition", 0, 0, Nil{}), u => f_choose(KTerm, Bool.not(f_eq(tg(bound), "Absent")), u => kt("Var", nm(bound), ix(bound), qt(bound), Nil{}), u => f_choose(KTerm, f_eq(dk(f_find(nm(t), book)), "ADT"), u => f_adt(t, Nil{}, f_find(nm(t), book)), u => t))))

# Module: src/front/families.bend:186
@unsafe
def f_scope_lambda(t, env, book):
  f_scope_lambda_var(t, env, book, kt(f_choose(String, U32.is_eq(qt(t), 4), u => "RewriteVar", u => "Var"), nm(t), ix(t), f_choose(U32, U32.is_eq(qt(t), 4), u => 1, u => qt(t)), Nil{}))

# Module: src/front/families.bend:190
@unsafe
def f_scope_lambda_var(t, env, book, v):
  f_flat(f_scope_body(kid(t, 0), Con{v, env}, book), [kt("Var", nm(v), ix(v), qt(v), Nil{})])

# Module: src/front/validate.bend:62
@unsafe
def f_reserved(s):
  f_eq(s, "def") || f_eq(s, "type") || f_eq(s, "law") || f_eq(s, "match") || f_eq(s, "case") || f_eq(s, "do") || f_eq(s, "return") || f_eq(s, "for") || f_eq(s, "exs") || f_eq(s, "where") || f_eq(s, "is") || f_eq(s, "import") || f_eq(s, "Type") || f_eq(s, "Data") || f_eq(s, "Kind") || f_eq(s, "Quant")

# Module: src/front/validate.bend:66
@unsafe
def f_ctor_lookup(name, book):
  match book:
    case Nil{}:
      f_find(name, Nil{})
    case Con{+d, ds}:
      f_choose(KDef, f_eq(dk(d), "Ctr") && f_eq(dn(d), name), u => d, u => f_ctor_more(name, f_ctor_lookup(name, dc(d)), ds))

# Module: src/front/validate.bend:74
@unsafe
def f_ctor_more(name, found, rest):
  f_choose(KDef, f_eq(dk(found), "Missing"), u => f_ctor_lookup(name, rest), u => found)

# Module: src/front/validate.bend:78
@unsafe
def f_valid_pattern(p, book):
  f_choose(String, f_eq(tg(p), "Var"), u => f_choose(String, Bool.not(f_valid_name(nm(p))), u => "reserved pattern binder: " ++ nm(p), u => f_choose(String, f_eq(dk(f_ctor_lookup(nm(p), book)), "Missing"), u => "", u => "a constructor pattern requires braces: " ++ nm(p))), u => f_choose(String, f_eq(tg(p), "Ctr"), u => f_valid_ctor_pattern(p, f_ctor_lookup(nm(p), book), book), u => "expected a binder or constructor pattern"))

# Module: src/front/validate.bend:82
@unsafe
def f_valid_ctor_pattern(p, ctr, book):
  f_choose(String, f_eq(dk(ctr), "Missing"), u => "unknown constructor pattern: " ++ nm(p), u => f_choose(String, U32.is_eq(da(ctr), f_len(ks(p))), u => f_valid_patterns(ks(p), book), u => "constructor pattern field count differs: " ++ nm(p)))

# Module: src/front/validate.bend:86
@unsafe
def f_valid_patterns(ps, book):
  match ps:
    case Nil{}:
      ""
    case Con{p, rest}:
      f_valid_patterns_next(f_valid_pattern(p, book), rest, book)

# Module: src/front/validate.bend:94
@unsafe
def f_valid_patterns_next(err, ps, book):
  f_choose(String, String.is_empty(err), u => f_valid_patterns(ps, book), u => err)

# Module: src/front/validate.bend:98
@unsafe
def f_scope_row_valid(r, pats, env, book, err):
  f_choose(KTerm, String.is_empty(err), u => f_scoped_row(pats, f_scope_body(kid(r, 1), f_concat(f_penv(pats), env), book)), u => kt("Row", "", 0, 1, [kt("Patterns", "", 0, 1, pats), kt("Error", err, 0, 0, Nil{})]))

# Module: src/front/validate.bend:102
@unsafe
def f_lambda_valid(a, body):
  f_choose(KTerm, f_eq(tg(a), "Ref") && f_valid_name(nm(a)), u => kt("Lam", nm(a), ix(a), qt(a), [body]), u => kt("Error", "a lambda binder must be a non-reserved name", 0, 0, Nil{}))

# Module: src/front/validate.bend:106
@unsafe
def f_case_checked(p, indent, heads, rows, pats):
  match p:
    case FParsed{n, ts}:
      f_choose(FParsed, U32.is_eq(f_len(pats), f_len(heads)), u => f_match_cases(f_skip(ts), indent, heads, Con{kt("Row", "", 0, 1, [kt("Patterns", "", 0, 1, pats), n]), rows}), u => f_err(ts, "one pattern is required per match scrutinee"))

# Module: src/front/validate.bend:134
@unsafe
def f_alias_valid(s):
  (Char.is_alpha(f_head(s)) || Char.is_eq(f_head(s), '_')) && f_alias_chars(s) && Bool.not(f_reserved(s))

# Module: src/front/validate.bend:138
@unsafe
def f_alias_chars(s):
  f_choose(Bool, String.is_empty(s), u => True{}, u => (Char.is_alpha(f_head(s)) || Char.is_digit(f_head(s)) || Char.is_eq(f_head(s), '_')) && f_alias_chars(f_tail(s)))

# Module: src/front/validate.bend:142
@unsafe
def f_import_alias(ts, path, book, imports):
  f_choose(FResult, String.ends_with(path, ".bend") && f_alias_valid(f_tx(f_tl(ts))), u => f_tops(f_tl(f_tl(ts)), book, Con{kt("Import", path, 0, 0, [kt("Alias", f_tx(f_tl(ts)), 0, 0, Nil{})]), imports}, False{}), u => f_result(book, "an import requires a .bend path and a valid alias", imports))

# Module: src/front/validate.bend:146
@unsafe
def f_validate_param(ts, end, acc):
  f_choose(FParsed, f_eq(f_tx(ts), "~") && Bool.not(f_eq(end, ")")), u => f_err(ts, "~ is only allowed on def or law template parameters"), u => f_choose(FParsed, Bool.not(f_valid_name(f_tx(f_unmark(ts)))), u => f_err(ts, "reserved parameter name"), u => f_choose(FParsed, f_eq(f_tx(ts), "~") && U32.is_lt(f_templates(acc), f_len(acc)), u => f_err(ts, "only leading parameters may use ~"), u => f_tele_binder(f_tx(f_unmark(ts)), f_atid(ts), f_quant(ts), f_eq(f_tx(ts), "~"), f_tl(f_unmark(ts)), end, acc))))

# Module: src/front/validate.bend:159
@unsafe
def f_valid_name(s):
  (Char.is_alpha(f_head(s)) || Char.is_eq(f_head(s), '_')) && f_name_chars(s) && Bool.not(f_reserved(s)) && Bool.not(String.ends_with(s, "."))

# Module: src/front/validate.bend:163
@unsafe
def f_name_chars(s):
  f_choose(Bool, String.is_empty(s), u => True{}, u => f_ident(f_head(s)) && f_name_chars(f_tail(s)))

# Module: src/front/validate.bend:180
@unsafe
def f_bare_params(params):
  match params:
    case Nil{}:
      True{}
    case Con{+p, rest}:
      f_eq(tg(kid(p, 0)), "Qnt") && Bool.not(f_eq(tg(p), "Template")) && f_bare_params(rest)

# Module: src/front/validate.bend:188
@unsafe
def f_def_prior(name, p, book, imports, unsafe, old):
  f_choose(FResult, f_eq(dk(old), "Missing"), u => f_def_base(name, p, book, imports, unsafe), u => f_choose(FResult, f_eq(dk(old), "Def") && f_eq(tg(dv(old)), "Absent") && f_bare_params(ks(f_pn(p))) && U32.is_ge(f_len(ks(f_pn(p))), dx(old)), u => f_def_base(name, p, book, imports, unsafe), u => f_result(book, "a definition must uniquely fill its law with plain parameter names", imports)))

# Module: src/front/validate.bend:202
@unsafe
def f_bang(n, ts, min):
  f_choose(FParsed, f_eq(tg(n), "Ref") && f_eq(f_tx(f_tl(ts)), "("), u => f_grow(FParsed{kt("Ref", nm(n), ix(n), 3, ks(n)), f_tl(ts)}, min), u => f_err(ts, "! must follow a named definition and precede call parentheses"))

# Module: src/front/validate.bend:206
@unsafe
def f_foreign_path_valid(ts):
  U32.is_eq(f_kind(f_tl(ts)), 2) && Char.is_eq(f_head(f_tx(f_tl(ts))), '"') && (String.ends_with(f_unquote(f_tx(f_tl(ts))), ".c") || String.ends_with(f_unquote(f_tx(f_tl(ts))), ".js"))


# Row quantity is internal flattening metadata: zero proves the body contains
# no Var nodes, so every later column substitution is the identity. Open rows
# remain conservatively marked even if their remaining variables disappear.

# Module: src/front/validate.bend:227
@unsafe
def f_scoped_row(pats, body):
  kt("Row", "", 0, f_choose(U32, f_contains_var(body), u => 1, u => 0), [kt("Patterns", "", 0, 1, pats), body])

# Module: src/front/validate.bend:231
@unsafe
def f_contains_var(t):
  f_eq(tg(t), "Var") || f_contains_var_terms(ks(t))

# Module: src/front/validate.bend:235
@unsafe
def f_contains_var_terms(ts):
  match ts:
    case Nil{}:
      False{}
    case Con{+t, rest}:
      f_contains_var(t) || f_contains_var_terms(rest)

# Module: src/load/imports.bend:11
@unsafe
def f_import_path(ts, path, book, imports):
  f_choose(FResult, f_eq(f_tx(ts), "as"), u => f_import_alias(ts, path, book, imports), u => f_choose(FResult, f_eq(f_tx(ts), "\n") || f_eq(f_tx(ts), "<eof>"), u => f_choose(FResult, f_eq(path, "Base"), u => f_tops(ts, book, Con{kt("Import", path, 0, 0, Nil{}), imports}, False{}), u => f_result(book, "a module import requires as followed by an alias", imports)), u => f_import_path(f_tl(ts), path ++ f_tx(ts), book, imports)))

# Module: src/load/graph.bend:155
@unsafe
def f_path_normal(s):
  f_path_parts(s, "", Nil{}, Char.is_eq(f_head(s), '/'))

# Module: src/load/graph.bend:159
@unsafe
def f_path_parts(s, part, parts, abs):
  f_choose(String, String.is_empty(s), u => f_path_join_parts(List.reverse(&2, String, f_path_push(part, parts)), f_choose(String, abs, u => "/", u => "")), u => f_choose(String, Char.is_eq(f_head(s), '/'), u => f_path_parts(f_tail(s), "", f_path_push(part, parts), abs), u => f_path_parts(f_tail(s), part ++ SCon{f_head(s), ""}, parts, abs)))

# Module: src/load/graph.bend:163
@unsafe
def f_path_push(part, parts):
  f_choose(List<&2,String>, String.is_empty(part) || f_eq(part, "."), u => parts, u => f_choose(List<&2,String>, f_eq(part, ".."), u => f_path_parent(parts), u => Con{part, parts}))

# Module: src/load/graph.bend:167
@unsafe
def f_path_parent(parts):
  match parts:
    case Nil{}:
      [".."]
    case Con{+p, rest}:
      f_choose(List<&2,String>, f_eq(p, ".."), u => Con{"..", Con{p, rest}}, u => rest)

# Module: src/load/graph.bend:175
@unsafe
def f_path_join_parts(parts, acc):
  match parts:
    case Nil{}:
      acc
    case Con{part, rest}:
      f_path_join_parts(rest, acc ++ f_choose(String, String.is_empty(acc) || f_eq(acc, "/"), u => "", u => "/") ++ part)

# Module: src/load/graph.bend:183
@unsafe
def f_drop_chars(s, n):
  f_choose(String, U32.is_eq(n, 0), u => s, u => f_drop_chars(f_tail(s), U32.sub(n, 1)))

# Module: src/load/graph.bend:187
@unsafe
def f_strip_bend(s):
  String.reverse(f_drop_chars(String.reverse(s), 5))

# Module: src/load/graph.bend:191
@unsafe
def f_graph_source(path, sources):
  match sources:
    case Nil{}:
      FSource{"", "", ""}
    case Con{+s, rest}:
      f_choose(FSource, f_eq(path, f_source_name(s)) || f_eq(path, f_source_path(s)), u => s, u => f_graph_source(path, rest))

# Module: src/load/graph.bend:199
@unsafe
def f_load_graph(main, sources):
  f_graph_result(f_graph_load(main, "", sources, FGraph{Nil{}, "", Nil{}}, Nil{}))

# Module: src/load/graph.bend:203
@unsafe
def f_graph_result(g):
  match g:
    case FGraph{book, err, done}:
      f_fresh_result(f_validate_result(FResult{book, err, Nil{}}))

# Module: src/load/graph.bend:209
@unsafe
def f_graph_load(path, ns, sources, g, stack):
  f_graph_source_load(f_graph_source(path, sources), ns, sources, g, stack)

# Module: src/load/graph.bend:213
@unsafe
def f_graph_source_load(s, ns, sources, g, stack):
  match g:
    case FGraph{book, +err, +done}:
      f_choose(FGraph, Bool.not(String.is_empty(err)), u => FGraph{book, err, done}, u => f_choose(FGraph, String.is_empty(f_source_path(s)), u => FGraph{book, "module source was not supplied", done}, u => f_choose(FGraph, has_name(stack, f_source_path(s)), u => FGraph{book, "cyclic import through " ++ f_source_path(s), done}, u => f_graph_cached(s, ns, sources, FGraph{book, err, done}, stack, f_env(f_source_path(s), done)))))

# Module: src/load/graph.bend:219
@unsafe
def f_graph_cached(s, ns, sources, g, stack, entry):
  f_choose(FGraph, f_eq(tg(entry), "Absent"), u => f_graph_parsed(s, ns, sources, g, Con{f_source_path(s), stack}, f_parse_source(s)), u => f_choose(FGraph, f_eq(nm(kid(entry, 0)), ns), u => g, u => f_graph_error(g, "one namespace per source file: " ++ f_source_path(s))))

# Module: src/load/graph.bend:223
@unsafe
def f_graph_error(g, err):
  match g:
    case FGraph{book, old, done}:
      FGraph{book, err, done}

# Module: src/load/graph.bend:229
@unsafe
def f_graph_parsed(s, ns, sources, g, stack, r):
  match r:
    case FResult{book, +err, imports}:
      f_choose(FGraph, String.is_empty(err), u => f_graph_imports(s, ns, book, imports, imports, sources, g, stack), u => f_graph_error(g, err))

# Module: src/load/graph.bend:235
@unsafe
def f_import_namespace(im, ns):
  f_choose(String, f_eq(nm(im), "Base"), u => "", u => f_strip_bend(f_path_normal(f_path_join(f_path_dir(ns), nm(im)))))

# Module: src/load/graph.bend:239
@unsafe
def f_import_pathname(im, s, sources):
  f_choose(String, f_eq(nm(im), "Base"), u => f_source_path(f_source("Base", sources)), u => f_path_normal(f_path_join(f_path_dir(f_source_path(s)), nm(im))))

# Module: src/load/graph.bend:243
@unsafe
def f_graph_imports(s, ns, book, allimports, imports, sources, g, stack):
  match imports:
    case Nil{}:
      f_graph_finish(s, ns, book, f_graph_aliases(allimports, ns), g)
    case Con{+im, rest}:
      f_graph_imports(s, ns, book, allimports, rest, sources, f_graph_load(f_import_pathname(im, s, sources), f_import_namespace(im, ns), sources, g, stack), stack)

# Module: src/load/graph.bend:251
@unsafe
def f_graph_aliases(imports, ns):
  match imports:
    case Nil{}:
      Nil{}
    case Con{+im, rest}:
      Con{kt("Import", f_import_namespace(im, ns), 0, 0, ks(im)), f_graph_aliases(rest, ns)}

# Module: src/load/graph.bend:259
@unsafe
def f_alias_term(t, imports):
  KTerm{tg(t), f_choose(String, f_eq(tg(t), "Ref") || f_eq(tg(t), "ADT") || f_eq(tg(t), "Ctr") || f_eq(tg(t), "Mat"), u => f_alias(nm(t), imports), u => nm(t)), ix(t), qt(t), f_alias_terms(ks(t), imports), rm(t)}

# Module: src/load/graph.bend:263
@unsafe
def f_alias_terms(ts, imports):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      Con{f_alias_term(t, imports), f_alias_terms(rest, imports)}

# Module: src/load/graph.bend:271
@unsafe
def f_alias_defs(ds, imports):
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      Con{KDef{dn(d), dk(d), da(d), dx(d), f_alias_term(dt(d), imports), f_alias_term(dv(d), imports), f_alias_defs(dc(d), imports), db(d), du(d)}, f_alias_defs(rest, imports)}

# Module: src/load/graph.bend:279
@unsafe
def f_graph_finish(s, ns, book, imports, g):
  match g:
    case FGraph{prior, err, done}:
      f_graph_finish_alias(s, ns, f_alias_defs(book, imports), imports, prior, err, done)

# Module: src/load/graph.bend:285
@unsafe
def f_graph_finish_alias(s, ns, book, imports, prior, err, done):
  FGraph{f_defs_append(prior, f_path_defs(f_module_defs(book, Nil{}, f_family_book(prior), ns, imports), f_path_dir(f_source_path(s)), f_eq(f_source_name(s), "Base"))), err, Con{kt("Loaded", f_source_path(s), 0, 0, [ref(ns)]), done}}

# Module: src/load/graph.bend:307
@unsafe
def f_module_defs(todo, visible, scope, ns, imports):
  match todo:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      f_module_def(d, rest, Con{d, visible}, f_choose(List<&2,KDef>, f_eq(dk(d), "ADT") || U32.is_gt(dx(d), 0), u => Con{d, scope}, u => scope), ns, imports)

# Module: src/load/graph.bend:315
@unsafe
def f_module_def(d, rest, visible, scope, ns, imports):
  Con{f_choose(KDef, String.is_empty(ns), u => f_elab_def(d, scope), u => f_qual_def(f_elab_def(d, scope), visible, ns, imports)), f_module_defs(rest, visible, scope, ns, imports)}

# Reporting uses the main module's declaration events, excluding dependencies.
# Upstream appends to book.order only for def/type/law declarations; constructors
# remain nested and lowering introduces terms rather than declaration events.
# Thus this source selection exactly recovers order.slice(n0), without rerunning
# imported modules or changing FResult's stable ABI. Call after a successful load.

# Module: src/load/graph.bend:343
@unsafe
def f_main_names(main, sources):
  f_main_result_names(f_parse_source(f_graph_source(main, sources)))

# Module: src/load/graph.bend:347
@unsafe
def f_main_result_names(r):
  match r:
    case FResult{book, error, imports}:
      f_choose(List<&2,String>, String.is_empty(error), u => f_main_order(book, Nil{}), u => Nil{})

# Module: src/load/graph.bend:353
@unsafe
def f_main_order(book, seen):
  match book:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      f_choose(List<&2,String>, f_main_seen(dn(d), seen), u => f_main_order(rest, seen), u => Con{dn(d), f_main_order(rest, Con{dn(d), seen})})

# Module: src/load/graph.bend:361
@unsafe
def f_main_seen(name, seen):
  match seen:
    case Nil{}:
      False{}
    case Con{head, rest}:
      String.eq(name, head) || f_main_seen(name, rest)

# Module: src/load/seed.bend:87
@unsafe
def f_load_graph_seed(main, sources, seedPath, seedText, seedBook):
  f_choose(FResult, f_seed_matches(f_source("Base", sources), seedPath, seedText), u => f_graph_result(fs_load(main, "", sources, FGraph{Nil{}, "", Nil{}}, Nil{}, FSeed{seedPath, seedBook})), u => f_load_graph(main, sources))

# Module: src/load/seed.bend:91
@unsafe
def f_seed_matches(source, path, text):
  Bool.not(String.is_empty(path)) && f_eq(f_source_name(source), "Base") && f_eq(f_source_path(source), path) && f_seed_text_equal(f_source_text(source), text)

# Module: src/load/seed.bend:95
@unsafe
def fs_path(seed):
  match seed:
    case FSeed{path, book}:
      path

# Module: src/load/seed.bend:101
@unsafe
def fs_book(seed):
  match seed:
    case FSeed{path, book}:
      book

# Module: src/load/seed.bend:107
@unsafe
def fs_load(path, ns, sources, g, stack, seed):
  fs_source(f_graph_source(path, sources), ns, sources, g, stack, seed)

# Module: src/load/seed.bend:111
@unsafe
def fs_source(s, ns, sources, g, stack, seed):
  match g:
    case FGraph{book, +err, +done}:
      f_choose(FGraph, Bool.not(String.is_empty(err)), u => FGraph{book, err, done}, u => f_choose(FGraph, String.is_empty(f_source_path(s)), u => FGraph{book, "module source was not supplied", done}, u => f_choose(FGraph, has_name(stack, f_source_path(s)), u => FGraph{book, "cyclic import through " ++ f_source_path(s), done}, u => fs_cached(s, ns, sources, FGraph{book, err, done}, stack, f_env(f_source_path(s), done), seed))))

# Module: src/load/seed.bend:117
@unsafe
def fs_cached(s, ns, sources, g, stack, entry, seed):
  f_choose(FGraph, f_eq(tg(entry), "Absent"), u => f_choose(FGraph, String.is_empty(ns) && f_eq(f_source_name(s), "Base") && f_eq(f_source_path(s), fs_path(seed)), u => fs_inject(g, seed), u => fs_parsed(s, ns, sources, g, Con{f_source_path(s), stack}, f_parse_source(s), seed)), u => f_choose(FGraph, f_eq(nm(kid(entry, 0)), ns), u => g, u => f_graph_error(g, "one namespace per source file: " ++ f_source_path(s))))

# Module: src/load/seed.bend:121
@unsafe
def fs_inject(g, seed):
  match g:
    case FGraph{book, err, done}:
      FGraph{f_defs_append(book, fs_book(seed)), err, Con{kt("Loaded", fs_path(seed), 0, 0, [ref("")]), done}}

# Module: src/load/seed.bend:127
@unsafe
def fs_parsed(s, ns, sources, g, stack, r, seed):
  match r:
    case FResult{book, +err, imports}:
      f_choose(FGraph, String.is_empty(err), u => fs_imports(s, ns, book, imports, imports, sources, g, stack, seed), u => f_graph_error(g, err))

# Module: src/load/seed.bend:133
@unsafe
def fs_imports(s, ns, book, allimports, imports, sources, g, stack, seed):
  match imports:
    case Nil{}:
      f_graph_finish(s, ns, book, f_graph_aliases(allimports, ns), g)
    case Con{+im, rest}:
      fs_imports(s, ns, book, allimports, rest, sources, fs_load(f_import_pathname(im, s, sources), f_import_namespace(im, ns), sources, g, stack, seed), stack, seed)


# Base is larger than the call-stack limit of the library's recursive compare.
# This equality scan is tail-recursive and compares the entire source exactly.

# Module: src/load/seed.bend:149
@unsafe
def f_seed_text_equal(a, b):
  match a b:
    case SNil{} SNil{}:
      True{}
    case SCon{x, xs} SCon{y, ys}:
      f_choose(Bool, Char.is_eq(x, y), u => f_seed_text_equal(xs, ys), u => False{})
    case _ _:
      False{}

# Module: src/load/modules.bend:153
@unsafe
def f_parse_at(source, namespace):
  f_qual_result(f_elaborate(f_parse(source)), namespace)

# Module: src/load/modules.bend:157
@unsafe
def f_qual_result(r, ns):
  match r:
    case FResult{+book, err, +imports}:
      FResult{f_qual_optional(book, book, ns, imports), err, imports}

# Module: src/load/modules.bend:163
@unsafe
def f_qual_name(name, ns):
  f_choose(String, String.is_empty(ns), u => name, u => ns ++ "." ++ name)

# Module: src/load/modules.bend:167
@unsafe
def f_prefix(s, prefix):
  f_choose(Bool, String.is_empty(prefix), u => True{}, u => f_choose(Bool, String.is_empty(s), u => False{}, u => Char.is_eq(f_head(s), f_head(prefix)) && f_prefix(f_tail(s), f_tail(prefix))))

# Module: src/load/modules.bend:171
@unsafe
def f_drop_prefix(s, prefix):
  f_choose(String, String.is_empty(prefix), u => s, u => f_drop_prefix(f_tail(s), f_tail(prefix)))

# Module: src/load/modules.bend:175
@unsafe
def f_alias(name, imports):
  match imports:
    case Nil{}:
      name
    case Con{+im, rest}:
      f_choose(String, U32.is_gt(f_len(ks(im)), 0) && f_prefix(name, nm(kid(im, 0)) ++ "."), u => nm(im) ++ "." ++ f_drop_prefix(name, nm(kid(im, 0)) ++ "."), u => f_alias(name, rest))

# Module: src/load/modules.bend:183
@unsafe
def f_declared(name, book):
  match book:
    case Nil{}:
      False{}
    case Con{+d, ds}:
      f_eq(name, f_dn(d)) || f_declared(name, dc(d)) || f_declared(name, ds)

# Module: src/load/modules.bend:191
@unsafe
def f_resolve_name(name, book, ns, imports):
  f_choose(String, f_declared(name, book), u => f_qual_name(name, ns), u => f_alias(name, imports))

# Module: src/load/modules.bend:195
@unsafe
def f_qual_term(t, book, ns, imports):
  KTerm{tg(t), f_choose(String, f_eq(tg(t), "Ref") || f_eq(tg(t), "ADT") || f_eq(tg(t), "Ctr") || f_eq(tg(t), "Mat"), u => f_resolve_name(nm(t), book, ns, imports), u => nm(t)), ix(t), qt(t), f_qual_terms(ks(t), book, ns, imports), rm(t)}

# Module: src/load/modules.bend:199
@unsafe
def f_qual_terms(ts, book, ns, imports):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      Con{f_qual_term(t, book, ns, imports), f_qual_terms(rest, book, ns, imports)}

# Module: src/load/modules.bend:207
@unsafe
def f_qual_defs(ds, book, ns, imports):
  match ds:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      Con{f_qual_def(d, book, ns, imports), f_qual_defs(rest, book, ns, imports)}

# Module: src/load/modules.bend:215
@unsafe
def f_qual_def(d, book, ns, imports):
  match d:
    case KDef{name, kind, arity, templates, ty, value, ctors, native, unsafe}:
      KDef{f_qual_name(name, ns), kind, arity, templates, f_qual_term(ty, book, ns, imports), f_qual_term(value, book, ns, imports), f_qual_defs(ctors, book, ns, imports), native, unsafe}

# Module: src/load/modules.bend:221
@unsafe
def f_source(name, sources):
  match sources:
    case Nil{}:
      FSource{"", "", ""}
    case Con{+source, rest}:
      f_choose(FSource, f_eq(name, f_source_name(source)), u => source, u => f_source(name, rest))

# Module: src/load/modules.bend:229
@unsafe
def f_source_name(source):
  match source:
    case FSource{name, path, text}:
      name
    case FParsedSource{name, path, text, parsed}:
      name

# Module: src/load/modules.bend:237
@unsafe
def f_source_text(source):
  match source:
    case FSource{name, path, text}:
      text
    case FParsedSource{name, path, text, parsed}:
      text

# Module: src/load/modules.bend:245
@unsafe
def f_source_path(source):
  match source:
    case FSource{name, path, text}:
      path
    case FParsedSource{name, path, text, parsed}:
      path

# Module: src/load/modules.bend:253
@unsafe
def f_load(main, sources):
  f_loaded_result(f_load_module(main, "", sources, Nil{}, Nil{}))

# Module: src/load/modules.bend:257
@unsafe
def f_loaded_result(r):
  match r:
    case FLoaded{book, err, seen}:
      f_fresh_result(FResult{book, err, Nil{}})

# Module: src/load/modules.bend:263
@unsafe
def f_load_module(name, ns, sources, seen, stack):
  f_choose(FLoaded, has_name(stack, name), u => FLoaded{Nil{}, "cyclic import: " ++ name, seen}, u => f_choose(FLoaded, has_name(seen, name), u => FLoaded{Nil{}, "", seen}, u => f_load_source(name, ns, f_source(name, sources), sources, seen, stack)))

# Module: src/load/modules.bend:267
@unsafe
def f_load_source(name, ns, source, sources, seen, stack):
  f_choose(FLoaded, String.is_empty(f_source_name(source)), u => FLoaded{Nil{}, "module source not supplied: " ++ name, seen}, u => f_load_parsed(name, f_path_result(f_parse_at(f_source_text(source), ns), f_source_path(source), f_eq(name, "Base")), sources, seen, stack))

# Module: src/load/modules.bend:271
@unsafe
def f_load_parsed(name, r, sources, seen, stack):
  match r:
    case FResult{book, +err, imports}:
      f_choose(FLoaded, String.is_empty(err), u => f_load_imports(imports, sources, Con{name, seen}, Con{name, stack}, book), u => FLoaded{book, err, seen})

# Module: src/load/modules.bend:277
@unsafe
def f_defs_append(xs, ys):
  match xs:
    case Nil{}:
      ys
    case Con{x, xt}:
      Con{x, f_defs_append(xt, ys)}

# Module: src/load/modules.bend:285
@unsafe
def f_load_imports(imports, sources, seen, stack, book):
  match imports:
    case Nil{}:
      FLoaded{book, "", seen}
    case Con{+im, rest}:
      f_load_import_next(rest, sources, stack, book, f_load_module(nm(im), f_choose(String, f_eq(nm(im), "Base"), u => "", u => nm(im)), sources, seen, stack))

# Module: src/load/modules.bend:293
@unsafe
def f_load_import_next(imports, sources, stack, book, r):
  match r:
    case FLoaded{defs, +err, seen}:
      f_choose(FLoaded, String.is_empty(err), u => f_load_imports(imports, sources, seen, stack, f_defs_append(defs, book)), u => FLoaded{book, err, seen})

# Module: src/load/modules.bend:307
@unsafe
def f_qual_optional(defs, book, ns, imports):
  f_choose(List<&2, KDef>, String.is_empty(ns), u => defs, u => f_qual_defs(defs, book, ns, imports))

# Invocation-local parse handoff. The driver supplies the unqualified result of
# this compiler's parser; graph elaboration and validation still run normally.

# Module: src/load/modules.bend:324
@unsafe
def f_source_parsed(name, path, text, parsed):
  FParsedSource{name, path, text, parsed}

# Module: src/load/modules.bend:328
@unsafe
def f_parse_source(source):
  match source:
    case FSource{name, path, text}:
      f_parse(text)
    case FParsedSource{name, path, text, parsed}:
      parsed

# Module: src/diagnostic/render.bend:111
@unsafe
def dg_units(c):
  kc(U32, U32.is_gt(Char.to_u32(c), 65535), u => 2, u => 1)

# Module: src/diagnostic/render.bend:115
@unsafe
def dg_width(s):
  match s:
    case SNil{}: 0
    case SCon{c, rest}: U32.add(dg_units(c), dg_width(rest))

# Module: src/diagnostic/render.bend:121
@unsafe
def dg_line_at(s, offset, line):
  match s:
    case SNil{}: line
    case SCon{c, rest}:
      kc(U32, U32.is_lt(offset, dg_units(c)), u => line, u => dg_line_at(rest, U32.sub(offset, dg_units(c)), kc(U32, Char.is_eq(c, '\n'), u => U32.add(line, 1), u => line)))

# Module: src/diagnostic/render.bend:128
@unsafe
def dg_padding(n):
  kc(String, U32.is_eq(n, 0), u => "", u => " " ++ dg_padding(U32.sub(n, 1)))

# Module: src/diagnostic/render.bend:132
@unsafe
def dg_lpad(s, width):
  dg_padding(kc(U32, U32.is_gt(width, dg_width(s)), u => U32.sub(width, dg_width(s)), u => 0)) ++ s

# Module: src/diagnostic/render.bend:136
@unsafe
def dg_rpad(s, width):
  s ++ dg_padding(kc(U32, U32.is_gt(width, dg_width(s)), u => U32.sub(width, dg_width(s)), u => 0))

# Module: src/diagnostic/render.bend:140
@unsafe
def dg_lines_count(lines):
  match lines:
    case Nil{}: 0
    case Con{h, rest}: U32.add(1, dg_lines_count(rest))

# Module: src/diagnostic/render.bend:146
@unsafe
def dg_snippet(span):
  match span:
    case DNoSpan{}: ""
    case DSpan{source, begin, end}: dg_snippet_at(String.lines(source), dg_line_at(source, begin, 1))

# Module: src/diagnostic/render.bend:152
@unsafe
def dg_snippet_at(lines, at):
  dg_snippet_lines(lines, at, kc(U32, U32.is_lt(dg_lines_count(lines), U32.add(at, 1)), u => dg_lines_count(lines), u => U32.add(at, 1)), 1)

# Module: src/diagnostic/render.bend:156
@unsafe
def dg_snippet_lines(lines, at, end, line):
  match lines:
    case Nil{}: ""
    case Con{h, rest}:
      kc(String, U32.is_gt(line, end), u => "", u => kc(String, U32.is_lt(U32.add(line, 1), at), u => "", u => "\n" ++ dg_lpad(U32.show(line), dg_width(U32.show(end))) ++ kc(String, U32.is_eq(line, at), u => ">| ", u => " | ") ++ h) ++ dg_snippet_lines(rest, at, end, U32.add(line, 1)))

# Module: src/diagnostic/render.bend:163
@unsafe
def dg_scope(ctx, env):
  match ctx:
    case Nil{}: env
    case Con{h, rest}: dg_scope(rest, kp_bind(env, h))

# Module: src/diagnostic/render.bend:169
@unsafe
def dg_context_width(ctx):
  match ctx:
    case Nil{}: 0
    case Con{h, rest}: norm_max(dg_width(nm(h)), dg_context_width(rest))

# Module: src/diagnostic/render.bend:175
@unsafe
def dg_expr(book, expr, env):
  match expr:
    case DText{text}: text
    case DTerm{term}: kp_go(strong(book, term), 0, env)

# Module: src/diagnostic/render.bend:181
@unsafe
def dg_context(book, ctx, env, width):
  match ctx:
    case Nil{}: ""
    case Con{h, rest}: "\n- " ++ dg_rpad(nm(h), width) ++ " : " ++ dg_expr(book, DTerm{kid(h, 0)}, env) ++ dg_context(book, rest, kp_bind(env, h), width)

# Module: src/diagnostic/render.bend:187
@unsafe
def dg_location(name, span):
  dg_location_text(name, dg_snippet(span))

# Module: src/diagnostic/render.bend:191
@unsafe
def dg_location_text(name, snippet):
  kc(String, String.eq(name, "") && String.eq(snippet, ""), u => "", u => "\nLocation:" ++ kc(String, String.eq(name, ""), u => "", u => " " ++ name) ++ snippet)

# Module: src/diagnostic/render.bend:195
@unsafe
def dg_render(book, diagnostic):
  match diagnostic:
    case DDiagnostic{expected, observed, has_observed, context, definition, span, note, trail}:
      dg_render_parts(book, expected, observed, has_observed, List.reverse(&2, KTerm, context), definition, span, note)

# Module: src/diagnostic/render.bend:201
@unsafe
def dg_render_parts(book, expected, observed, has_observed, ctx, name, span, note):
  "Error:" ++ kc(String, has_observed, u => "\n- expected : " ++ dg_expr(book, expected, dg_scope(ctx, Nil{})) ++ "\n- observed : " ++ dg_expr(book, observed, dg_scope(ctx, Nil{})), u => "\n- message  : " ++ dg_expr(book, expected, dg_scope(ctx, Nil{}))) ++ kc(String, U32.is_eq(terms_len(ctx), 0), u => "", u => "\nContext:" ++ dg_context(book, ctx, Nil{}, dg_context_width(ctx))) ++ dg_location(name, span) ++ kc(String, String.eq(note, ""), u => "", u => "\n" ++ note)

# Module: src/diagnostic/render.bend:205
@unsafe
def diagnostic_render(result):
  match result:
    case DResult{error, book, diagnostic}: kc(String, String.eq(error, ""), u => "", u => dg_render_checked(book, diagnostic, error))

# Module: src/diagnostic/render.bend:210
@unsafe
def dg_render_checked(book, diagnostic, error):
  match diagnostic:
    case DDiagnostic{expected, observed, has_observed, context, definition, span, note, trail}:
      kc(String, U32.is_eq(terms_len(trail), 0), u => "Error: " ++ error, u => dg_render(book, diagnostic))

# Module: src/diagnostic/trace.bend:74
@unsafe
def dg_text(s):
  kt("DText", s, 0, 0, Nil{})

# Module: src/diagnostic/trace.bend:78
@unsafe
def dg_bad_detail(message, expected, observed):
  KChecked{kt("DDetail", "", 0, 1, [expected, observed]), atom("Error"), Nil{}, message}

# Module: src/diagnostic/trace.bend:82
@unsafe
def dg_bad_message(message, expected):
  KChecked{kt("DDetail", "", 0, 0, [expected, atom("Absent")]), atom("Error"), Nil{}, message}

# Module: src/diagnostic/trace.bend:86
@unsafe
def dg_pair(expected, observed):
  kt("DDetail", "", 0, 1, [expected, observed])

# Module: src/diagnostic/trace.bend:90
@unsafe
def dg_family(book, name):
  match book:
    case Nil{}: ""
    case Con{d, rest}: kc(String, String.eq(dk(d), "ADT") && Bool.not(String.eq(dk(lookup(dc(d), name)), "Absent")), u => dn(d), u => dg_family(rest, name))

# Module: src/diagnostic/trace.bend:96
@unsafe
def dg_typeless(book, ctx, t):
  dg_text("non-inferrable term '" ++ dg_expr(book, DTerm{t}, dg_scope(List.reverse(&2, KTerm, ctx), Nil{})) ++ "'")

# Module: src/diagnostic/trace.bend:100
@unsafe
def dg_trace(e, ctx, t, ty, r):
  kc(KChecked, good(r), u => r, u => kc(KChecked, String.eq(tg(ct(r)), "DTrace"), u => KChecked{kt("DTrace", nm(ct(r)), ix(ct(r)), qt(ct(r)), [kid(ct(r), 0), kid(ct(r), 1), kid(ct(r), 2), kid(ct(r), 3), kt("DTrail", "", 0, 0, norm_join(ks(kid(ct(r), 4)), [t]))]), cy(r), cs(r), ce(r)}, u => dg_trace_detail(e, ctx, t, r, kc(KTerm, String.eq(tg(ct(r)), "DDetail"), u => ct(r), u => dg_reason(e, ctx, t, ty, ce(r))))))

# Module: src/diagnostic/trace.bend:104
@unsafe
def dg_trace_detail(e, ctx, t, r, detail):
  KChecked{kt("DTrace", cn(e), 0, qt(detail), [kid(detail, 0), kid(detail, 1), kt("DCtx", "", 0, 0, ctx), t, kt("DTrail", "", 0, 0, [t])]), cy(r), cs(r), ce(r)}

# Module: src/diagnostic/trace.bend:108
@unsafe
def dg_reason(e, ctx, t, ty, code):
  kc(KTerm, String.eq(code, "undefined name"), u => dg_pair(dg_text("a defined name"), t),
   u => kc(KTerm, String.eq(code, "unbound variable"), u => dg_pair(dg_text("a bound variable"), t),
   u => kc(KTerm, String.eq(code, "nondecreasing self-call"), u => dg_pair(dg_text("a decreasing self-call (arguments are read left to right: each passed unchanged until one shrinks)"), t),
   u => kc(KTerm, String.eq(code, "live use of an unfilled law"), u => dg_pair(dg_text("a filled definition (an unfilled law is a dead claim: live code cannot use it)"), t),
   u => kc(KTerm, String.eq(code, "a family requires angle-bracket parameters"), u => dg_pair(dg_text("a family instance (write " ++ nm(t) ++ "<..>)"), t),
   u => kc(KTerm, String.eq(code, "unresolved hole"), u => dg_pair(ty, t),
   u => kc(KTerm, String.eq(code, "cannot infer: annotation required"), u => dg_pair(dg_text("an annotated term (cannot infer)"), t),
   u => kc(KTerm, String.eq(code, "lambda requires a function type") || String.eq(code, "matcher requires a function type") || String.eq(code, "reflexivity requires equality goal"), u => dg_pair(ty, dg_typeless(cb(e), ctx, t)),
   u => kc(KTerm, String.eq(code, "constructor requires a datatype goal"), u => dg_pair(ty, kc(KTerm, String.eq(dg_family(cb(e), nm(t)), ""), u => dg_typeless(cb(e), ctx, t), u => ref(dg_family(cb(e), nm(t))))),
   u => kt("DDetail", "", 0, 0, [dg_text(code), atom("Absent")]))))))))))

# Module: src/diagnostic/trace.bend:121
@unsafe
def dg_as_expr(t):
  kc(DExpr, String.eq(tg(t), "DText"), u => DText{nm(t)}, u => DTerm{t})

# Module: src/diagnostic/trace.bend:125
@unsafe
def dg_no_report(name, message):
  DDiagnostic{DText{message}, DText{""}, False{}, Nil{}, name, DNoSpan{}, "", Nil{}}

# Module: src/diagnostic/trace.bend:129
@unsafe
def dg_report(r, name):
  kc(DDiagnostic, String.eq(tg(ct(r)), "DTrace"), u => DDiagnostic{dg_as_expr(kid(ct(r), 0)), dg_as_expr(kid(ct(r), 1)), U32.is_eq(qt(ct(r)), 1), ks(kid(ct(r), 2)), nm(ct(r)), DNoSpan{}, "", ks(kid(ct(r), 4))}, u => dg_no_report(name, ce(r)))

# Module: src/diagnostic/produce.bend:151
@unsafe
def dg_span_same(a, b):
  match a:
    case DNoSpan{}: False{}
    case DSpan{s, b0, e0}: dg_span_fields(s, b0, e0, b)

# Module: src/diagnostic/produce.bend:157
@unsafe
def dg_span_fields(s, b0, e0, b):
  match b:
    case DNoSpan{}: False{}
    case DSpan{t, b1, e1}: String.eq(s, t) && U32.is_eq(b0, b1) && U32.is_eq(e0, e1)

# Module: src/diagnostic/produce.bend:163
@unsafe
def dg_has_span(s):
  match s:
    case DNoSpan{}: False{}
    case DSpan{source, begin, end}: True{}

# Module: src/diagnostic/produce.bend:169
@unsafe
def dg_origin_scan(origins, name, t, found):
  match origins:
    case Nil{}: found
    case Con{DOrigin{definition, term, source, begin, end, path}, rest}:
      kc(DSpan, String.eq(name, definition) && norm_exact(t, term), u => kc(DSpan, Bool.not(dg_has_span(found)) || dg_span_same(found, DSpan{source, begin, end}), u => dg_origin_scan(rest, name, t, DSpan{source, begin, end}), u => DNoSpan{}), u => dg_origin_scan(rest, name, t, found))

# Module: src/diagnostic/produce.bend:176
@unsafe
def dg_origin_trail(origins, name, trail):
  match trail:
    case Nil{}: DNoSpan{}
    case Con{h, rest}: dg_origin_found(origins, name, rest, dg_origin_scan(origins, name, h, DNoSpan{}))

# Module: src/diagnostic/produce.bend:182
@unsafe
def dg_origin_found(origins, name, rest, found):
  kc(DSpan, dg_has_span(found), u => found, u => dg_origin_trail(origins, name, rest))

# Module: src/diagnostic/produce.bend:186
@unsafe
def diagnostic_locate(diagnostic, origins):
  match diagnostic:
    case DDiagnostic{expected, observed, has_observed, context, definition, span, note, trail}:
      DDiagnostic{expected, observed, has_observed, context, definition, kc(DSpan, dg_has_span(span), u => span, u => dg_origin_trail(origins, definition, trail)), note, trail}

# Module: src/diagnostic/produce.bend:192
@unsafe
def diagnostic_result_locate(result, origins):
  match result:
    case DResult{error, book, diagnostic}: DResult{error, book, diagnostic_locate(diagnostic, origins)}

# Module: src/diagnostic/produce.bend:197
@unsafe
def dg_finish(error, book, diagnostic, origins):
  DResult{error, book, diagnostic_locate(diagnostic, origins)}

# Module: src/diagnostic/produce.bend:201
@unsafe
def check_book_diagnostic(book, origins):
  dg_book_checked(book, origins, check_book(book))

# Module: src/diagnostic/produce.bend:205
@unsafe
def dg_book_checked(book, origins, error):
  kc(DResult, String.eq(error, ""), u => DResult{"", book, dg_no_report("", "")}, u => dg_events(book, book_cached(Nil{}, norm_max_book(book)), origins, error))

# Module: src/diagnostic/produce.bend:209
@unsafe
def dg_events(todo, done, origins, error):
  match todo:
    case Nil{}: dg_finish(error, done, dg_no_report("", error), origins)
    case Con{d, rest}: dg_event_guard(rest, done, d, origins, error, event_error(done, d, lookup(done, dn(d))))

# Module: src/diagnostic/produce.bend:215
@unsafe
def dg_event_guard(rest, done, d, origins, error, guard):
  kc(DResult, String.eq(guard, ""), u => dg_event_check(rest, done, d, origins, error, check_definition(book_put(done, declared(d)), signature_mode(d, rest))), u => dg_finish(error, done, dg_no_report(dn(d), guard), origins))

# Module: src/diagnostic/produce.bend:219
@unsafe
def dg_event_check(rest, done, d, origins, error, checked):
  kc(DResult, String.eq(checked, ""), u => dg_events(rest, book_put(done, d), origins, error), u => dg_finish(error, book_put(done, declared(d)), dg_report(dg_definition(book_put(done, declared(d)), signature_mode(d, rest)), dn(d)), origins))

# Module: src/diagnostic/produce.bend:223
@unsafe
def dg_definition(book, d):
  dg_definition_type(book, d, check(KEnv{book, dn(d), ref(dn(d)), 0, Nil{}, du(d)}, Nil{}, dt(d), 0, typ(1)))

# Module: src/diagnostic/produce.bend:227
@unsafe
def dg_definition_type(book, d, r):
  kc(KChecked, Bool.not(good(r)), u => r, u => kc(KChecked, String.eq(dk(d), "ADT") || String.eq(tg(dv(d)), "Absent") || String.eq(tg(dv(d)), "Foreign"), u => bad(check_definition(book, d)), u => dg_template(book, d, dt(d), dv(d), ref(dn(d)), dx(d))))

# Module: src/diagnostic/produce.bend:231
@unsafe
def dg_template(book, d, ty, body, lhs, n):
  kc(KChecked, U32.is_eq(n, 0), u => check(KEnv{book, dn(d), lhs, self_pending(d, body), tele_quantities(book, dt(d), da(d)), du(d)}, Nil{}, body, 1, ty), u => dg_template_binder(book, d, wnf(book, ty), body, lhs, n))

# Module: src/diagnostic/produce.bend:235
@unsafe
def dg_template_binder(book, d, ty, body, lhs, n):
  kc(KChecked, String.eq(tg(ty), "All"), u => dg_template_open(book, d, ty, body, lhs, n, dn(d) ++ "~" ++ nm(ty) ++ U32.show(ix(ty))), u => bad("template telescope is too short"))

# Module: src/diagnostic/produce.bend:239
@unsafe
def dg_template_open(book, d, ty, body, lhs, n, name):
  dg_template(book_put(book, KDef{name, "Def", 0, 0, kid(ty, 0), atom("Absent"), Nil{}, True{}, False{}}), d, subst(kid(ty, 1), ix(ty), ref(name)), kapply(body, ref(name)), app(lhs, ref(name)), U32.sub(n, 1))

# Module: src/diagnostic/produce.bend:243
@unsafe
def dg_quant_error(message, name, allowed, used):
  dg_bad_detail(message, dg_text(kp_quant(allowed) ++ name), dg_text(kc(String, U32.is_eq(used, 2), u => name ++ " (consumed more than once)", u => kp_quant(used) ++ name)))

# Module: src/diagnostic/produce.bend:247
@unsafe
def dg_constructor_names(ds):
  match ds:
    case Nil{}: ""
    case Con{d, rest}: dn(d) ++ kc(String, defs_empty(rest), u => "", u => ", " ++ dg_constructor_names(rest))

# Module: src/diagnostic/produce.bend:253
@unsafe
def dg_ctor_error(e, t, ty, ctr):
  kc(KChecked, Bool.not(String.eq(dk(ctr), "Absent")) && Bool.not(has_name(rm(ty), nm(t))), u => dg_bad_detail("constructor does not belong to goal or field count differs", dg_text(nm(t) ++ " with " ++ U32.show(da(ctr)) ++ kc(String, U32.is_eq(da(ctr), 1), u => " field", u => " fields")), t), u => kc(KChecked, String.eq(dg_family(cb(e), nm(t)), ""), u => dg_bad_detail("constructor does not belong to goal or field count differs", dg_text("a declared constructor (" ++ nm(ty) ++ " declares " ++ dg_constructor_names(dc(lookup(cb(e), nm(ty)))) ++ ")"), t), u => dg_bad_detail("constructor does not belong to goal or field count differs", ty, ref(dg_family(cb(e), nm(t))))))

# Module: src/diagnostic/frontend.bend:114
@unsafe
def f_load_origins(main, sources):
  fp_graph(f_graph_load(main, "", sources, FGraph{Nil{}, "", Nil{}}, Nil{}), sources)

# Module: src/diagnostic/frontend.bend:117
@unsafe
def fp_graph(graph, sources):
  match graph:
    case FGraph{book, error, done}:
      fp_result(f_graph_result(graph), done, sources)

# Module: src/diagnostic/frontend.bend:122
@unsafe
def fp_result(result, done, sources):
  match result:
    case FResult{book, error, imports}:
      FProvenance{result, f_choose(List<&2,DOrigin>, String.is_empty(error), u => fp_defs(book, fp_modules(done, sources)), u => Nil{})}

# Module: src/diagnostic/frontend.bend:127
@unsafe
def fp_modules(done, sources):
  match done:
    case Nil{}:
      Nil{}
    case Con{entry, rest}:
      fp_join(fp_modules(rest, sources), fp_module(f_graph_source(nm(entry), sources)))

# Module: src/diagnostic/frontend.bend:134
@unsafe
def fp_module(source):
  fp_module_parsed(f_source_text(source), f_lex(f_source_text(source), 1, 0, 0, Nil{}), f_parse(f_source_text(source)))

# Module: src/diagnostic/frontend.bend:137
@unsafe
def fp_module_parsed(text, tokens, parsed):
  match parsed:
    case FResult{book, error, imports}:
      fp_event_sources(book, FPSource{text, tokens})

# Module: src/diagnostic/frontend.bend:142
@unsafe
def fp_event_sources(book, source):
  match book:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      Con{source, fp_event_sources(rest, source)}

# Module: src/diagnostic/frontend.bend:149
@unsafe
def fp_join(left, right):
  match left:
    case Nil{}:
      right
    case Con{head, tail}:
      Con{head, fp_join(tail, right)}

# Module: src/diagnostic/frontend.bend:156
@unsafe
def fp_defs(book, sources):
  match book:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      fp_defs_source(d, rest, sources)

# Module: src/diagnostic/frontend.bend:163
@unsafe
def fp_defs_source(d, rest, sources):
  match sources:
    case Nil{}:
      Nil{}
    case Con{source, tail}:
      List.append(&2,DOrigin, fp_def(d, source), fp_defs(rest, tail))

# Module: src/diagnostic/frontend.bend:170
@unsafe
def fp_def(d, source):
  List.append(&2,DOrigin, fp_term(dt(d), dn(d), source, [0]), List.append(&2,DOrigin, fp_term(dv(d), dn(d), source, [1]), fp_ctors(dc(d), dn(d), source, 0)))

# Module: src/diagnostic/frontend.bend:173
@unsafe
def fp_ctors(ctors, definition, source, index):
  match ctors:
    case Nil{}:
      Nil{}
    case Con{ctor, rest}:
      List.append(&2,DOrigin, fp_term(dt(ctor), definition, source, [2,index,0]), fp_ctors(rest, definition, source, U32.add(index, 1)))

# Module: src/diagnostic/frontend.bend:180
@unsafe
def fp_term(t, definition, source, route):
  List.append(&2,DOrigin, fp_origin(t, definition, source, route), fp_children(ks(t), definition, source, route, 0))

# Module: src/diagnostic/frontend.bend:183
@unsafe
def fp_children(terms, definition, source, route, index):
  match terms:
    case Nil{}:
      Nil{}
    case Con{term, rest}:
      List.append(&2,DOrigin, fp_term(term, definition, source, List.append(&2,U32, route, [index])), fp_children(rest, definition, source, route, U32.add(index, 1)))

# Module: src/diagnostic/frontend.bend:190
@unsafe
def fp_origin(t, definition, source, route):
  match source:
    case FPSource{text, tokens}:
      f_choose(List<&2,DOrigin>, (String.eq(tg(t), "Ref") || String.eq(tg(t), "ADT") || String.eq(tg(t), "Ctr")) && U32.is_ge(ix(t), 65536), u => fp_at_token(t, definition, text, fp_find_token(tokens, U32.div(ix(t), 65536), U32.mod(ix(t), 65536)), route), u => Nil{})

# Module: src/diagnostic/frontend.bend:195
@unsafe
def fp_find_token(tokens, line, column):
  match tokens:
    case Nil{}:
      Nil{}
    case Con{token, rest}:
      f_choose(List<&2,FToken>, U32.is_eq(f_line(tokens), line) && U32.is_eq(f_col(tokens), column), u => tokens, u => fp_find_token(rest, line, column))

# Module: src/diagnostic/frontend.bend:202
@unsafe
def fp_at_token(t, definition, text, tokens, route):
  match tokens:
    case Nil{}:
      Nil{}
    case Con{token, rest}:
      fp_token_origin(t, definition, text, token, route)

# Module: src/diagnostic/frontend.bend:209
@unsafe
def fp_token_origin(t, definition, text, token, route):
  match token:
    case FToken{word, line, column, kind}:
      +begin = fp_offset(text, 1, 0, line, column, 0)
      [DOrigin{definition, t, text, begin, U32.add(begin, fp_utf16(word)), route}]

# Module: src/diagnostic/frontend.bend:215
@unsafe
def fp_utf16(text):
  f_choose(U32, String.is_empty(text), u => 0, u => U32.add(f_choose(U32, U32.is_gt(Char.to_u32(f_head(text)), 65535), u => 2, u => 1), fp_utf16(f_tail(text))))

# Module: src/diagnostic/frontend.bend:218
@unsafe
def fp_offset(text, line, column, targetLine, targetColumn, offset):
  f_choose(U32, String.is_empty(text) || (U32.is_eq(line, targetLine) && U32.is_eq(column, targetColumn)), u => offset, u => fp_offset(f_tail(text), f_choose(U32, Char.is_eq(f_head(text), '\n'), u => U32.add(line, 1), u => line), f_choose(U32, Char.is_eq(f_head(text), '\n'), u => 0, u => U32.add(column, 1)), targetLine, targetColumn, U32.add(offset, f_choose(U32, U32.is_gt(Char.to_u32(f_head(text)), 65535), u => 2, u => 1))))

# Rejection-only lookup limits expensive source mapping to the definition named
# by the structured checker event. No diagnostic text is parsed or interpreted.

# Module: src/diagnostic/frontend.bend:252
@unsafe
def f_load_origins_for(main, sources, definition):
  fp_graph_for(f_graph_load(main, "", sources, FGraph{Nil{}, "", Nil{}}, Nil{}), sources, definition)

# Module: src/diagnostic/frontend.bend:255
@unsafe
def fp_graph_for(graph, sources, definition):
  match graph:
    case FGraph{book, error, done}:
      fp_result_for(f_graph_result(graph), done, sources, definition)

# Module: src/diagnostic/frontend.bend:260
@unsafe
def fp_result_for(result, done, sources, definition):
  match result:
    case FResult{book, error, imports}:
      FProvenance{result, f_choose(List<&2,DOrigin>, String.is_empty(error), u => fp_defs_for(book, fp_modules(done, sources), definition), u => Nil{})}

# Module: src/diagnostic/frontend.bend:265
@unsafe
def fp_defs_for(book, sources, definition):
  match book:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      fp_defs_source_for(d, rest, sources, definition)

# Module: src/diagnostic/frontend.bend:272
@unsafe
def fp_defs_source_for(d, rest, sources, definition):
  match sources:
    case Nil{}:
      Nil{}
    case Con{source, tail}:
      List.append(&2,DOrigin, f_choose(List<&2,DOrigin>, String.eq(dn(d), definition), u => fp_def(d, source), u => Nil{}), fp_defs_for(rest, tail, definition))

# Module: src/back/js/foreign.bend:9
@unsafe
def j_foreign_path(paths):
  match paths:
    case Nil{}:
      ""
    case Con{h, rest}:
      kc(String, String.ends_with(nm(h), ".js\"") || String.ends_with(nm(h), ".js"), u => nm(h), u => j_foreign_path(rest))

# Module: src/back/js/foreign.bend:21
@unsafe
def j_foreign_name(name):
  j_foreign_chars(String.to_lower(name))

# Module: src/back/js/foreign.bend:29
@unsafe
def j_foreign_chars(name):
  match name:
    case SNil{}:
      ""
    case SCon{h, rest}:
      kc(String, Char.is_eq(h, '.') || Char.is_eq(h, '/'), u => "_", u => Char.show(h)) ++ j_foreign_chars(rest)

# Module: src/back/js/foreign.bend:42
@unsafe
def j_foreign_def(book, d):
  kc(String, j_builtin_effect(dn(d)), u => "if(!Object.hasOwn(G," ++ j_quote(dn(d)) ++ "))", u => "") ++ "G[" ++ j_quote(dn(d)) ++ "]=fn(" ++ U32.show(da(d)) ++ ",function(a){const v=scope(null);return {io:()=>foreignCall(" ++ j_quote(j_foreign_path(ks(dv(d)))) ++ "," ++ j_quote(dn(d)) ++ ",a,[" ++ j_foreign_args(book, dt(d), da(d)) ++ "]," ++ j_descriptor(book, j_io_result(book, j_foreign_return(book, dt(d), da(d))), 64) ++ ")};});\n"

# Module: src/back/js/foreign.bend:52
@unsafe
def j_foreign_args(book, ty, n):
  kc(String, U32.is_eq(n, 0), u => "", u => "[" ++ U32.show(qt(ty)) ++ "," ++ j_descriptor(book, kid(ty, 0), 64) ++ "]," ++ j_foreign_args(book, kid(ty, 1), U32.sub(n, 1)))

# Module: src/back/js/foreign.bend:62
@unsafe
def j_foreign_return(book, ty, n):
  kc(KTerm, U32.is_eq(n, 0), u => wnf(book, ty), u => j_foreign_return(book, kid(ty, 1), U32.sub(n, 1)))

# Module: src/back/js/foreign.bend:71
@unsafe
def j_io_result(book, ty):
  kid(wnf(book, kid(wnf(book, kid(ty, 1)), 0)), 0)

# Module: src/back/js/foreign.bend:80
@unsafe
def j_modules(book, sources):
  match sources:
    case Nil{}:
      ""
    case Con{source, rest}:
      "foreignModules[" ++ j_quote(nm(source)) ++ "]=(()=>{\n" ++ nm(kid(source, 0)) ++ "\nreturn {" ++ j_module_exports(book, nm(source)) ++ "};})();\n" ++ j_modules(book, rest)

# Module: src/back/js/foreign.bend:93
@unsafe
def j_module_exports(book, path):
  match book:
    case Nil{}:
      ""
    case Con{d, rest}:
      kc(String, String.eq(tg(dv(d)), "Foreign") && String.eq(j_foreign_path(ks(dv(d))), path), u => j_module_export(dn(d), j_foreign_name(kc(String, String.eq(nm(dv(d)), ""), u => dn(d), u => nm(dv(d))))), u => "") ++ j_module_exports(rest, path)

# Module: src/back/js/foreign.bend:106
@unsafe
def j_module_export(name, implementation):
  j_quote(name) ++ ":typeof " ++ implementation ++ "===\"function\"?" ++ implementation ++ ":undefined,"

# Module: src/back/js/foreign.bend:114
@unsafe
def j_ctor_metadata(defs):
  match defs:
    case Nil{}:
      ""
    case Con{d, rest}:
      j_ctor_keys(dc(d), da(d)) ++ j_ctor_metadata(rest)

# Module: src/back/js/foreign.bend:127
@unsafe
def j_ctor_keys(ctors, params):
  match ctors:
    case Nil{}:
      ""
    case Con{d, rest}:
      "constructorNative[" ++ j_quote(dn(d)) ++ "]=" ++ kc(String, db(d), u => "true", u => "false") ++ ";constructorOwn[" ++ j_quote(dn(d)) ++ "]=" ++ j_quote(kc(String, String.eq(nm(dv(d)), ""), u => dn(d), u => nm(dv(d)))) ++ ";constructors[" ++ j_quote(dn(d)) ++ "]=[" ++ j_field_keys(dt(d), params) ++ "];\n" ++ j_ctor_keys(rest, params)

# Module: src/back/js/foreign.bend:140
@unsafe
def j_field_keys(ty, skip):
  kc(String, String.eq(tg(ty), "All"), u => kc(String, U32.is_eq(skip, 0), u => j_quote(nm(ty)) ++ "," ++ j_field_keys(kid(ty, 1), 0), u => j_field_keys(kid(ty, 1), U32.sub(skip, 1))), u => "")

# Called after reachability: the host reads exactly these foreign source bytes.

# Module: src/back/js/foreign.bend:149
@unsafe
def j_foreign_paths(book):
  match book:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      kc(List<&2, String>, String.eq(tg(j_strip(dv(d))), "Foreign") && Bool.not(j_builtin_effect(dn(d))), u => Con{j_foreign_path(ks(j_strip(dv(d)))), j_foreign_paths(rest)}, u => j_foreign_paths(rest))

# Module: src/back/js/foreign.bend:161
@unsafe
def j_foreign_error(book):
  match book:
    case Nil{}:
      ""
    case Con{d, rest}:
      kc(String, String.eq(tg(j_strip(dv(d))), "Foreign") && Bool.not(j_builtin_effect(dn(d))) && String.eq(j_foreign_path(ks(j_strip(dv(d)))), ""), u => "a foreign def without a .js import: " ++ dn(d), u => j_foreign_error(rest))

# Module: src/back/js/foreign.bend:173
@unsafe
def j_builtin_effect(name):
  String.contains("|IO.print|IO.write|IO.print_err|IO.get_env|IO.args|IO.random_u32|IO.spawn|IO.sleep|IO.now|Chan.new|Chan.send|Chan.recv|Chan.close|File.open|File.read|File.read_bytes|File.read_at|File.size|File.write|File.write_bytes|File.close|TCP.listen|TCP.accept|TCP.connect|TCP.send|TCP.recv|TCP.poll|UDP.bind|UDP.send_to|UDP.recv_from|UDP.poll|Socket.close|Listener.close|Window.open|Window.frame|Window.set_title|Window.close|Audio.open|Audio.write|Audio.close|", "|" ++ name ++ "|")

# Module: src/back/js/literals.bend:9
@unsafe
def j_strip(t):
  kc(KTerm, String.eq(tg(t), "Ann"), u => j_strip(kid(t, 0)), u => t)

# Module: src/back/js/literals.bend:17
@unsafe
def j_literal(t):
  j_literal_node(j_strip(t))

# Module: src/back/js/literals.bend:25
@unsafe
def j_literal_node(t):
  kc(String, String.eq(tg(t), "Ctr"), u => j_literal_ctor(t), u => "")

# Module: src/back/js/literals.bend:33
@unsafe
def j_literal_ctor(t):
  kc(String, String.eq(nm(t), "U32"), u => j_word_text(j_word(j_strip(kid(t, 0)), 0, 0), False{}), u => kc(String, String.eq(nm(t), "F32"), u => j_word_text(j_word(j_strip(kid(t, 0)), 0, 0), True{}), u => kc(String, String.eq(nm(t), "Chr"), u => j_char_text(j_u32(kid(t, 0))), u => kc(String, String.eq(nm(t), "Zero") || String.eq(nm(t), "Succ"), u => j_nat_text(j_nat(t, 0n)), u => kc(String, String.eq(nm(t), "SNil") || String.eq(nm(t), "SCon"), u => j_string_text(j_string(t, "")), u => "")))))

# Module: src/back/js/literals.bend:41
@unsafe
def j_u32(t):
  j_u32_node(j_strip(t))

# Module: src/back/js/literals.bend:49
@unsafe
def j_u32_node(t):
  kc(Maybe<&2, U32>, String.eq(tg(t), "Ctr") && String.eq(nm(t), "U32"), u => j_word(j_strip(kid(t, 0)), 0, 0), u => None{})

# Module: src/back/js/literals.bend:59
@unsafe
def j_word(t, at, acc):
  kc(Maybe<&2, U32>, String.eq(tg(t), "Ctr"), u => kc(Maybe<&2, U32>, String.eq(nm(t), "WNil"), u => kc(Maybe<&2, U32>, U32.is_eq(at, 32), u => Some{acc}, u => None{}), u => kc(Maybe<&2, U32>, String.eq(nm(t), "WCon") && U32.is_lt(at, 32), u => j_word_bit(j_strip(kid(t, 0)), j_strip(kid(t, 1)), at, acc), u => None{})), u => None{})

# Module: src/back/js/literals.bend:70
@unsafe
def j_word_bit(bit, rest, at, acc):
  kc(Maybe<&2, U32>, String.eq(tg(bit), "Ctr") && (String.eq(nm(bit), "True") || String.eq(nm(bit), "False")), u => j_word(rest, U32.add(at, 1), U32.or(acc, kc(U32, String.eq(nm(bit), "True"), u => U32.shln(1, U32.to_nat(at)), u => 0))), u => None{})

# Module: src/back/js/literals.bend:79
@unsafe
def j_word_text(value, float):
  match value:
    case None{}:
      ""
    case Some{n}:
      kc(String, float, u => "bitsFloat(" ++ U32.show(n) ++ ")", u => U32.show(n))

# Module: src/back/js/literals.bend:91
@unsafe
def j_char_text(value):
  match value:
    case None{}:
      ""
    case Some{n}:
      "checkedChar(" ++ U32.show(n) ++ ")"

# Module: src/back/js/literals.bend:104
@unsafe
def j_nat(t, acc):
  kc(Maybe<&2, Nat>, String.eq(tg(t), "Ctr"), u => kc(Maybe<&2, Nat>, String.eq(nm(t), "Zero"), u => Some{acc}, u => kc(Maybe<&2, Nat>, String.eq(nm(t), "Succ"), u => j_nat(j_strip(kid(t, 0)), Nat.add(acc, 1n)), u => None{})), u => None{})

# Module: src/back/js/literals.bend:112
@unsafe
def j_nat_text(value):
  match value:
    case None{}:
      ""
    case Some{n}:
      Nat.show(n) ++ "n"

# Module: src/back/js/literals.bend:125
@unsafe
def j_string(t, acc):
  kc(Maybe<&2, String>, String.eq(tg(t), "Ctr"), u => kc(Maybe<&2, String>, String.eq(nm(t), "SNil"), u => Some{String.reverse(acc)}, u => kc(Maybe<&2, String>, String.eq(nm(t), "SCon"), u => j_string_head(j_strip(kid(t, 0)), j_strip(kid(t, 1)), acc), u => None{})), u => None{})

# Module: src/back/js/literals.bend:135
@unsafe
def j_string_head(head, tail, acc):
  kc(Maybe<&2, String>, String.eq(tg(head), "Ctr") && String.eq(nm(head), "Chr"), u => j_string_char(j_u32(kid(head, 0)), tail, acc), u => None{})

# Module: src/back/js/literals.bend:145
@unsafe
def j_string_char(value, tail, acc):
  match value:
    case None{}:
      None{}
    case Some{n}:
      kc(Maybe<&2, String>, U32.is_le(n, 1114111) && (U32.is_lt(n, 55296) || U32.is_gt(n, 57343)), u => j_string(tail, SCon{Char.from_u32(n), acc}), u => None{})

# Module: src/back/js/literals.bend:157
@unsafe
def j_string_text(value):
  match value:
    case None{}:
      ""
    case Some{s}:
      j_quote(s)


# Literal compression follows checked type provenance, so ordinary constructors
# named Zero, Succ, SNil, etc. keep their user-defined layout in libraries.

# Module: src/back/js/literals.bend:180
@unsafe
def j_literal_typed(book, t, ty):
  +literal = j_literal(t)
  kc(String, String.eq(literal, ""), u => "", u => j_literal_provenance(book, wnf(book, ty), literal))

# Module: src/back/js/literals.bend:185
@unsafe
def j_literal_provenance(book, ty, literal):
  +d = lookup(book, nm(ty))
  kc(String, String.eq(tg(ty), "ADT") && String.eq(dk(d), "ADT") && Bool.not(db(d)), u => "", u => literal)

# Module: src/back/js/validate.bend:10
@unsafe
def j_compile_error(book):
  kc(String, String.eq(dk(lookup(book, "IO")), "Absent"), u => "a build needs import Base", u => j_main_error(book, lookup(book, "main")))

# Module: src/back/js/validate.bend:19
@unsafe
def j_main_error(book, main):
  kc(String, Bool.not(String.eq(dk(main), "Def")) || String.eq(tg(j_strip(dv(main))), "Absent"), u => "no main to run", u => kc(String, j_io_type(book, dt(main)), u => kc(String, String.eq(tg(j_strip(dv(main))), "Foreign"), u => "main must be a filled def: a foreign main cannot anchor IO", u => ""), u => kc(String, j_printable(book, dt(main), Nil{}, 0), u => "", u => "main's type " ++ kp_show(dt(main)) ++ " cannot be printed (a function, a Type, an erased or dependent field)")))

# Module: src/back/js/validate.bend:30
@unsafe
def j_printable(book, ty, seen, fuel):
  j_printable_head(book, wnf(book, ty), seen, fuel)

# Module: src/back/js/validate.bend:41
@unsafe
def j_printable_head(book, ty, seen, fuel):
  kc(Bool, String.eq(tg(ty), "Eql"), u => True{}, u => kc(Bool, String.eq(tg(ty), "ADT") && Bool.not(String.eq(nm(ty), "IO.OP")) && String.eq(dk(lookup(book, nm(ty))), "ADT"), u => j_printable_adt(book, ty, seen, fuel), u => False{}))

# Module: src/back/js/validate.bend:52
@unsafe
def j_printable_adt(book, ty, seen, fuel):
  kc(Bool, String.contains("|U32|F32|Nat|Char|String|", "|" ++ nm(ty) ++ "|") || has_name(seen, kp_show(ty)), u => True{}, u => kc(Bool, String.eq(nm(ty), "Array"), u => j_printable(book, kid(ty, 0), seen, fuel), u => j_printable_ctors(book, dc(lookup(book, nm(ty))), ks(ty), Con{kp_show(ty), seen}, fuel)))

# Module: src/back/js/validate.bend:64
@unsafe
def j_printable_ctors(book, ctors, params, seen, fuel):
  match ctors:
    case Nil{}:
      True{}
    case Con{d, rest}:
      j_printable_fields(book, j_specialize(book, dt(d), params), seen, fuel) && j_printable_ctors(book, rest, params, seen, fuel)

# Module: src/back/js/validate.bend:79
@unsafe
def j_printable_fields(book, ty, seen, fuel):
  kc(Bool, String.eq(tg(ty), "All"), u => Bool.not(U32.is_eq(qt(ty), 0)) && j_printable(book, kid(ty, 0), seen, fuel) && j_printable_fields(book, kid(ty, 1), seen, fuel), u => True{})

# Layout validation follows executable references, not type dependencies or
# erased expressions. An Array representation is needed at elimination,
# construction, and element-sensitive native operations.

# Module: src/back/js/validate.bend:93
@unsafe
def j_layout_error(book, defs, roots, stops):
  kc(String, j_layout_visit(book_context(book), book_cached(defs, 0), roots, Nil{}, stops), u => "an open Array element type", u => "")

# Module: src/back/js/validate.bend:105
@unsafe
def j_layout_visit(book, defs, todo, seen, stops):
  match todo:
    case Nil{}: False{}
    case Con{h, rest}:
      kc(Bool, String.eq(h, "$layout.open-array"), u => True{}, u => kc(Bool, has_name(seen, h) || has_name(stops, h), u => j_layout_visit(book, defs, rest, seen, stops), u => j_layout_def(book, defs, lookup(defs, h), rest, Con{h, seen}, stops)))

# Module: src/back/js/validate.bend:121
@unsafe
def j_layout_def(book, defs, d, todo, seen, stops):
  j_layout_visit(book, defs, kc(List<&2, String>, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0), u => j_layout_term(book, Nil{}, dv(d), dt(d), todo), u => todo), seen, stops)

# Module: src/back/js/validate.bend:130
@unsafe
def j_layout_mark(bad, todo):
  kc(List<&2, String>, bad, u => Con{"$layout.open-array", todo}, u => todo)

# Module: src/back/js/validate.bend:139
@unsafe
def j_layout_open(book, ty):
  j_layout_open_head(book, wnf(book, ty))

# Module: src/back/js/validate.bend:148
@unsafe
def j_layout_open_head(book, ty):
  kc(Bool, String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Array"), u => Bool.not(String.eq(tg(wnf(book, kid(ty, 0))), "ADT")), u => False{})

# Module: src/back/js/validate.bend:160
@unsafe
def j_layout_term(book, env, t, ty, todo):
  j_layout_kind(book, env, t, ty, todo, tg(t))

# Module: src/back/js/validate.bend:173
@unsafe
def j_layout_kind(book, env, t, ty, todo, key):
  kc(List<&2, String>, String.eq(key, "Ann"), u => j_layout_term(book, env, kid(t, 0), kid(t, 1), todo), u =>
  kc(List<&2, String>, String.eq(key, "Ref"), u => j_layout_mark(j_layout_array_intrinsic(book, t), Con{nm(t), todo}), u =>
  kc(List<&2, String>, String.eq(key, "App"), u => j_layout_app(book, env, t, wnf(book, j_type(book, env, kid(t, 0))), todo), u =>
  kc(List<&2, String>, String.eq(key, "Lam"), u => j_layout_lam(book, env, t, wnf(book, ty), todo), u =>
  kc(List<&2, String>, String.eq(key, "Mat"), u => j_layout_match(book, env, t, wnf(book, ty), todo), u =>
  kc(List<&2, String>, String.eq(key, "Ctr"), u => kc(List<&2, String>, Bool.not(String.eq(j_literal_typed(book, t, ty), "")), u => todo, u => j_layout_mark(j_layout_open(book, ty), j_layout_fields(book, env, ks(t), j_specialize(book, dt(j_find_ctor(book, nm(t))), ks(wnf(book, ty))), todo))), u =>
  kc(List<&2, String>, String.eq(key, "Let"), u => j_layout_let(book, env, ks(t), ty, todo), u =>
  kc(List<&2, String>, String.eq(key, "Rwt"), u => j_layout_term(book, env, kid(t, 2), ty, todo), u => todo))))))))

# Module: src/back/js/validate.bend:192
@unsafe
def j_layout_lam(book, env, t, ty, todo):
  j_layout_term(book, Con{kt("Env", "", ix(t), 0, Con{kid(ty, 0), Nil{}}), env}, kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))), todo)

# Module: src/back/js/validate.bend:204
@unsafe
def j_layout_match(book, env, t, ty, todo):
  j_layout_mark(j_layout_open(book, kid(ty, 0)), j_layout_term(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), kc(List<&2, String>, U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1), u => todo, u => j_layout_term(book, env, kid(t, 1), ty, todo))))

# Module: src/back/js/validate.bend:216
@unsafe
def j_layout_app(book, env, t, fty, todo):
  j_layout_mark(j_layout_intrinsic(book, j_strip(kid(t, 0)), kid(t, 1)), j_layout_function(book, env, kid(t, 0), fty, kc(List<&2, String>, String.eq(tg(fty), "All") && U32.is_eq(qt(fty), 0), u => todo, u => j_layout_term(book, env, kid(t, 1), kid(fty, 0), todo))))

# Module: src/back/js/validate.bend:228
@unsafe
def j_layout_function(book, env, t, ty, todo):
  kc(List<&2, String>, String.eq(tg(j_strip(t)), "Ref"), u => Con{nm(j_strip(t)), todo}, u => j_layout_term(book, env, t, ty, todo))

# Module: src/back/js/validate.bend:237
@unsafe
def j_layout_array_intrinsic(book, f):
  String.eq(tg(f), "Ref") && db(lookup(book, nm(f))) && String.contains("|Array.new|Array.set|Array.get|Array.swap|Array.size|", "|" ++ nm(f) ++ "|")

# Module: src/back/js/validate.bend:247
@unsafe
def j_layout_intrinsic(book, f, element):
  kc(Bool, j_layout_array_intrinsic(book, f), u => Bool.not(String.eq(tg(wnf(book, j_strip(element))), "ADT")), u => False{})

# Module: src/back/js/validate.bend:259
@unsafe
def j_layout_fields(book, env, args, tel, todo):
  match args:
    case Nil{}: todo
    case Con{h, rest}:
      j_layout_fields(book, env, rest, j_app_type(tel, h), kc(List<&2, String>, String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 0), u => todo, u => j_layout_term(book, env, h, kid(tel, 0), todo)))

# Module: src/back/js/validate.bend:274
@unsafe
def j_layout_let(book, env, xs, ty, todo):
  j_layout_bindings(book, env, xs, j_layout_term(book, j_context(book, env, xs), j_body(xs), ty, todo))

# Module: src/back/js/validate.bend:285
@unsafe
def j_layout_bindings(book, env, xs, todo):
  match xs:
    case Nil{}: todo
    case Con{h, Nil{}}: todo
    case Con{h, rest}:
      j_layout_bindings(book, env, rest, kc(List<&2, String>, U32.is_eq(qt(h), 0), u => todo, u => j_layout_term(book, env, kid(h, 0), j_type(book, env, kid(h, 0)), todo)))

# Module: src/back/js/choice.bend:60
@unsafe
def j_choice_call(book, spine):
  kc(Bool, String.eq(tg(spine), "Call") && U32.is_eq(terms_len(ks(spine)), 4), u =>
    kc(Bool, String.eq(tg(j_strip(kid(spine, 2))), "Lam") && String.eq(tg(j_strip(kid(spine, 3))), "Lam") && String.eq(j_l_name(j_strip(kid(spine, 2))), "") && String.eq(j_l_name(j_strip(kid(spine, 3))), ""), u => j_choice_definition(book, lookup(book, nm(spine))), u => False{}), u => False{})

# Module: src/back/js/choice.bend:65
@unsafe
def j_choice_definition(book, d):
  kc(Bool, db(lookup(book, "Bool")) && db(lookup(book, "Unit")) && String.eq(tg(dt(d)), "All") && U32.is_eq(qt(dt(d)), 0) && String.eq(tg(j_strip(dv(d))), "Lam"),
    u => j_choice_match(j_strip(kid(j_strip(dv(d)), 0))), u => False{})

# Module: src/back/js/choice.bend:70
@unsafe
def j_choice_match(t):
  String.eq(tg(t), "Mat") && String.eq(nm(t), "True") && j_choice_arm(j_strip(kid(t, 0)), True{}) &&
  String.eq(tg(j_strip(kid(t, 1))), "Mat") && String.eq(nm(j_strip(kid(t, 1))), "False") &&
  j_choice_arm(j_strip(kid(j_strip(kid(t, 1)), 0)), False{}) && String.eq(tg(j_strip(kid(j_strip(kid(t, 1)), 1))), "Efq")

# Module: src/back/js/choice.bend:76
@unsafe
def j_choice_arm(t, first):
  String.eq(tg(t), "Lam") && String.eq(tg(j_strip(kid(t, 0))), "Lam") &&
  j_choice_leaf(j_strip(kid(j_strip(kid(t, 0)), 0)), kc(U32, first, u => ix(t), u => ix(j_strip(kid(t, 0)))))

# Module: src/back/js/choice.bend:81
@unsafe
def j_choice_leaf(t, binder):
  String.eq(tg(t), "App") && String.eq(tg(j_strip(kid(t, 0))), "Var") && U32.is_eq(ix(j_strip(kid(t, 0))), binder) &&
  String.eq(tg(j_strip(kid(t, 1))), "Ctr") && String.eq(nm(j_strip(kid(t, 1))), "Unit") && U32.is_eq(terms_len(ks(j_strip(kid(t, 1)))), 0)

# Module: src/back/js/choice.bend:86
@unsafe
def j_choice_emit(book, env, spine, tail):
  j_choice_after_type(book, env, ks(spine), tail, wnf(book, j_app_type(wnf(book, dt(lookup(book, nm(spine)))), kid(spine, 0))))

# Module: src/back/js/choice.bend:90
@unsafe
def j_choice_after_type(book, env, args, tail, ty):
  j_choice_after_bool(book, env, args, tail, j_expr(book, env, terms_at(args, 1), kid(ty, 0), False{}), wnf(book, j_app_type(ty, terms_at(args, 1))))

# Module: src/back/js/choice.bend:94
@unsafe
def j_choice_after_bool(book, env, args, tail, condition, ty):
  "(/* choice */" ++ condition ++ "?" ++ j_choice_branch(book, env, j_strip(terms_at(args, 2)), wnf(book, kid(ty, 0)), tail) ++ ":" ++
  j_choice_branch(book, env, j_strip(terms_at(args, 3)), wnf(book, kid(wnf(book, j_app_type(ty, terms_at(args, 2))), 0)), tail) ++ ")"

# Module: src/back/js/choice.bend:99
@unsafe
def j_choice_branch(book, env, t, ty, tail):
  "((" ++ j_local(ix(t)) ++ ")=>" ++ j_expr(book, Con{kt("Env", "", ix(t), 0, [kid(ty, 0)]), env}, kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))), tail) ++ ")(" ++
  kc(String, U32.is_eq(qt(ty), 0), u => "null", u => "ctor(\"Unit\",[])") ++ ")"

# Module: src/back/js/projection.bend:41
@unsafe
def j_projection_worker(book, t, ty):
  kc(String, String.eq(tg(j_strip(t)), "Mat"), u => j_projection_match(book, j_strip(t), wnf(book, ty)), u => "")

# Module: src/back/js/projection.bend:45
@unsafe
def j_projection_match(book, t, ty):
  kc(String, String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)) && U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1),
    u => j_projection_code(nm(t), j_projection_arm(j_strip(kid(t, 0)), j_specialize(book, dt(j_find_ctor(book, nm(t))), ks(wnf(book, kid(ty, 0)))), Nil{}, 0)), u => "")

# Module: src/back/js/projection.bend:50
@unsafe
def j_projection_arm(t, tel, slots, at):
  kc(String, String.eq(tg(tel), "All"),
    u => kc(String, String.eq(tg(t), "Lam") && Bool.not(U32.is_eq(qt(tel), 0)),
      u => j_projection_arm(j_strip(kid(t, 0)), kid(tel, 1), Con{kt("Slot", "", ix(t), at, Nil{}), slots}, U32.inc(at)), u => ""),
    u => kc(String, String.eq(tg(t), "Var"), u => j_projection_slot(ix(t), slots), u => ""))

# Module: src/back/js/projection.bend:57
@unsafe
def j_projection_slot(id, slots):
  match slots:
    case Nil{}: ""
    case Con{s, rest}: kc(String, U32.is_eq(id, ix(s)), u => U32.show(qt(s)), u => j_projection_slot(id, rest))

# Module: src/back/js/projection.bend:63
@unsafe
def j_projection_code(name, slot):
  kc(String, String.eq(slot, ""), u => "", u => "fn(1,function(a){return project(" ++ j_quote(name) ++ ",a[0]).slice()[" ++ slot ++ "];})")

# Module: src/back/js/projection.bend:67
@unsafe
def j_l_global_worker(book, d, t, worker):
  "G[" ++ j_quote(dn(d)) ++ "]=" ++ kc(String, Bool.not(String.eq(worker, "")), u => worker,
    u => kc(String, (String.eq(tg(j_strip(t)), "Lam") || String.eq(tg(j_strip(t)), "Mat")), u => j_expr(book, Nil{}, t, dt(d), False{}), u => "fn(0,function(){return " ++ j_expr(book, Nil{}, t, dt(d), True{}) ++ ";})")) ++ ";\n"

# Module: src/back/js/emit.bend:107
@unsafe
def j_escape(s):
  match s:
    case SNil{}:
      ""
    case SCon{c, t}:
      j_escape_char(c) ++ j_escape(t)

# Module: src/back/js/emit.bend:119
@unsafe
def j_escape_char(c):
  j_escape_char_on(c, Char.to_u32(c))

# Module: src/back/js/emit.bend:128
@unsafe
def j_escape_char_on(c, key):
  match key:
    case 34:
      "\\\""
    case 92:
      "\\\\"
    case 10:
      "\\n"
    case 13:
      "\\r"
    case 9:
      "\\t"
    case 0:
      "\\x00"
    case n:
      Char.show(Char.from_u32(n))

# Module: src/back/js/emit.bend:150
@unsafe
def j_quote(s):
  "\"" ++ j_escape(s) ++ "\""

# Module: src/back/js/emit.bend:158
@unsafe
def j_local(id):
  "x" ++ U32.show(id)

# Module: src/back/js/emit.bend:167
@unsafe
def j_env(env, id):
  match env:
    case Nil{}:
      atom("Absent")
    case Con{h, rest}:
      kc(KTerm, U32.is_eq(ix(h), id), u => kid(h, 0), u => j_env(rest, id))

# Module: src/back/js/emit.bend:181
@unsafe
def j_type(book, env, t):
  j_type_on(book, env, t, tg(t))

# Module: src/back/js/emit.bend:192
@unsafe
def j_type_on(book, env, t, key):
  kc(KTerm, String.eq(key, "Ann"), u => kid(t, 1), u => kc(KTerm, String.eq(key, "Var"), u => j_env(env, ix(t)), u => kc(KTerm, String.eq(key, "Ref"), u => dt(lookup(book, nm(t))), u => kc(KTerm, String.eq(key, "App"), u => j_app_type(wnf(book, j_type(book, env, kid(t, 0))), kid(t, 1)), u => atom("Absent")))))

# Module: src/back/js/emit.bend:201
@unsafe
def j_app_type(ty, arg):
  kc(KTerm, String.eq(tg(ty), "All"), u => subst(kid(ty, 1), ix(ty), arg), u => atom("Absent"))

# Module: src/back/js/emit.bend:211
@unsafe
def j_exprs(book, env, xs):
  match xs:
    case Nil{}:
      ""
    case Con{h, rest}:
      j_expr(book, env, h, atom("Absent"), False{}) ++ j_exprs_tail(book, env, rest)

# Module: src/back/js/emit.bend:225
@unsafe
def j_exprs_tail(book, env, xs):
  match xs:
    case Nil{}:
      ""
    case Con{h, rest}:
      "," ++ j_expr(book, env, h, atom("Absent"), False{}) ++ j_exprs_tail(book, env, rest)

# Module: src/back/js/emit.bend:241
@unsafe
def j_expr(book, env, t, ty, tail):
  kc(String, (String.eq(tg(t), "Lam") || String.eq(tg(t), "Mat")) && Bool.not(String.eq(j_l_name(t), "")), u => "F[" ++ j_quote(j_l_name(t)) ++ "](" ++ j_l_capture(env, Nil{}) ++ ")", u => j_expr_on(book, env, t, ty, tail, tg(t)))

# Module: src/back/js/emit.bend:254
@unsafe
def j_expr_on(book, env, t, ty, tail, key):
  kc(String, String.eq(key, "Var"), u => j_local(ix(t)), u => kc(String, String.eq(key, "Ref"), u => "get(G," ++ j_quote(nm(t)) ++ ")", u => kc(String, String.eq(key, "App"), u => j_apply(book, env, t, tail, wnf(book, j_type(book, env, kid(t, 0)))), u => kc(String, String.eq(key, "Ctr"), u => j_constructor_mode(book, env, t, ty, tail), u => kc(String, String.eq(key, "Ann"), u => j_expr(book, env, kid(t, 0), kid(t, 1), tail), u => kc(String, String.eq(key, "Lam"), u => j_lambda(book, env, t, wnf(book, ty)), u => kc(String, String.eq(key, "Mat"), u => j_match(book, env, t, wnf(book, ty)), u => kc(String, String.eq(key, "Let"), u => j_let(book, env, ks(t), ty, tail), u => kc(String, String.eq(key, "Rwt"), u => j_expr(book, env, kid(t, 2), ty, tail), u => kc(String, String.eq(key, "Efq"), u => "fn(1,()=>bad(\"an absurd elimination\"))", u => kc(String, String.eq(key, "Hol"), u => "bad(\"cannot compile a hole\")", u => kc(String, String.eq(key, "ADT"), u => "({typeName:" ++ j_quote(nm(t)) ++ ",typeArgs:[" ++ j_exprs(book, env, ks(t)) ++ "]})", u => kc(String, String.eq(key, "Qua"), u => "({typeName:" ++ j_quote("&" ++ U32.show(qt(t))) ++ "})", u => kc(String, String.eq(key, "Typ"), u => "({typeName:\"Type\"})", u => kc(String, String.eq(key, "Rfl"), u => "({proof:true})", u => "null")))))))))))))))

# Module: src/back/js/emit.bend:265
@unsafe
def j_lambda(book, env, t, ty):
  "fn(" ++ U32.show(j_lambda_count(t)) ++ ",function(a){" ++ j_lambda_code(book, env, t, ty, 0) ++ "})"

# Module: src/back/js/emit.bend:273
@unsafe
def j_lambda_count(t):
  kc(U32, String.eq(tg(t), "Ann"), u => j_lambda_count(kid(t, 0)), u => kc(U32, String.eq(tg(t), "Lam"), u => U32.add(1, j_lambda_count(kid(t, 0))), u => 0))

# Module: src/back/js/emit.bend:285
@unsafe
def j_lambda_code(book, env, t, ty, at):
  kc(String, String.eq(tg(t), "Ann"), u => j_lambda_code(book, env, kid(t, 0), kid(t, 1), at), u => kc(String, String.eq(tg(t), "Lam"), u => j_lambda_bind(book, env, t, wnf(book, ty), at), u => "return " ++ j_expr(book, env, t, ty, True{}) ++ ";"))

# Module: src/back/js/emit.bend:297
@unsafe
def j_lambda_bind(book, env, t, ty, at):
  "const " ++ j_local(ix(t)) ++ "=" ++ kc(String, U32.is_eq(qt(ty), 0) && String.eq(tg(ty), "All"), u => "null", u => "a[" ++ U32.show(at) ++ "]") ++ ";" ++ j_lambda_code(book, Con{kt("Env", "", ix(t), 0, Con{kid(ty, 0), Nil{}}), env}, kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))), U32.add(at, 1))

# Module: src/back/js/emit.bend:309
@unsafe
def j_apply(book, env, t, tail, fty):
  j_apply_spine(book, env, t, tail, fty, j_call_spine(t, Nil{}))

# Module: src/back/js/emit.bend:321
@unsafe
def j_apply_one(book, env, t, tail, fty):
  kc(String, tail, u => "jump(", u => "call(") ++ j_expr(book, env, kid(t, 0), fty, False{}) ++ ",[" ++ kc(String, String.eq(tg(fty), "All") && U32.is_eq(qt(fty), 0), u => "null", u => j_expr(book, env, kid(t, 1), kid(fty, 0), False{})) ++ "])"

# Module: src/back/js/emit.bend:330
@unsafe
def j_call_spine(t, args):
  kc(KTerm, String.eq(tg(t), "Ann"), u => j_call_spine(kid(t, 0), args), u => kc(KTerm, String.eq(tg(t), "App"), u => j_call_spine(kid(t, 0), Con{kid(t, 1), args}), u => kc(KTerm, String.eq(tg(t), "Ref"), u => kt("Call", nm(t), 0, 0, args), u => atom("Absent"))))

# Module: src/back/js/emit.bend:343
@unsafe
def j_apply_spine(book, env, t, tail, fty, spine):
  kc(String, j_choice_call(book, spine), u => j_choice_emit(book, env, spine, tail), u => j_apply_regular(book, env, t, tail, fty, spine))

# Module: src/back/js/emit.bend:356
@unsafe
def j_apply_regular(book, env, t, tail, fty, spine):
  kc(String, String.eq(tg(spine), "Call") && U32.is_gt(terms_len(ks(spine)), 1) && U32.is_le(terms_len(ks(spine)), j_call_arity(lookup(book, nm(spine)))), u => kc(String, tail, u => "jump(", u => "call(") ++ "get(G," ++ j_quote(nm(spine)) ++ "),[" ++ j_apply_args(book, env, ks(spine), dt(lookup(book, nm(spine)))) ++ "])", u => j_apply_one(book, env, t, tail, fty))

# Module: src/back/js/emit.bend:364
@unsafe
def j_call_arity(d):
  kc(U32, db(d) && j_intrinsic(dn(d)), u => da(d), u => j_lambda_count(dv(d)))

# Module: src/back/js/emit.bend:375
@unsafe
def j_apply_args(book, env, args, ty):
  j_apply_args_head(book, env, args, wnf(book, ty))

# Module: src/back/js/emit.bend:386
@unsafe
def j_apply_args_head(book, env, args, ty):
  match args:
    case Nil{}: ""
    case Con{h, rest}:
      kc(String, String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 0), u => "null", u => j_expr(book, env, h, kid(ty, 0), False{})) ++ "," ++ j_apply_args(book, env, rest, j_app_type(ty, h))

# Module: src/back/js/emit.bend:399
@unsafe
def j_descriptor(book, ty, fuel):
  j_desc_kind(book, wnf(book, ty), fuel)

# Module: src/back/js/emit.bend:409
@unsafe
def j_desc_head(book, ty, fuel):
  j_desc_head_on(book, ty, fuel, nm(ty))

# Module: src/back/js/emit.bend:420
@unsafe
def j_desc_head_on(book, ty, fuel, key):
  kc(String, String.eq(key, "Char"), u => "[\"Char\"]", u => kc(String, String.eq(key, "F32"), u => "[\"F32\"]", u => kc(String, String.eq(key, "List"), u => "[\"List\"," ++ j_descriptor(book, kid(ty, 1), fuel) ++ "]", u => kc(String, String.eq(key, "Array"), u => "[\"Array\"," ++ j_descriptor(book, kid(ty, 0), fuel) ++ "]", u => kc(String, String.eq(key, "Sigma"), u => "[\"Tuple\"," ++ j_descriptor(book, kid(ty, 2), fuel) ++ "," ++ j_descriptor(book, kid(kid(ty, 3), 0), fuel) ++ "]", u => kc(String, String.eq(tg(ty), "Var"), u => "(typeof " ++ j_local(ix(ty)) ++ "===\"undefined\"?null:" ++ j_local(ix(ty)) ++ ")", u => kc(String, String.eq(tg(ty), "ADT"), u => "[\"Named\"," ++ j_quote(nm(ty)) ++ ",[" ++ j_desc_args(book, ks(ty), fuel) ++ "]]", u => "null")))))))

# Module: src/back/js/emit.bend:428
@unsafe
def j_intrinsic(name):
  String.contains("|U32.add|U32.sub|U32.and|U32.or|U32.xor|U32.is_eq|U32.is_ne|U32.is_lt|U32.is_le|U32.is_gt|U32.is_ge|U32.mul|U32.div|U32.mod|U32.inc|U32.shl|U32.shr|U32.shln|U32.shrn|U32.not|U32.is_zero|U32.cmp|U32.to_f32|U32.to_nat|U32.from_nat|F32.add|F32.sub|F32.mul|F32.div|F32.neg|F32.is_eq|F32.is_ne|F32.is_lt|F32.is_le|F32.is_gt|F32.is_ge|F32.sqrt|F32.exp|F32.log|F32.log2|F32.log10|F32.sin|F32.cos|F32.tan|F32.asin|F32.acos|F32.atan|F32.sinh|F32.cosh|F32.tanh|F32.floor|F32.ceil|F32.trunc|F32.abs|F32.pow|F32.atan2|F32.mod|F32.to_u32|F32.bits|F32.show|F32.read|Nat.add|Nat.sub|Nat.mul|Nat.double|Nat.cmp|Nat.is_lt|Nat.divmod|Array.new|Array.set|Array.get|Array.swap|Array.size|Array.clone|IO.pure|IO.bind|IO.try|IO.pass|IO.die|IO.args|IO.print|IO.write|IO.print_err|IO.get_env|IO.now|IO.sleep|IO.random_u32|IO.spawn|IO.fork|IO.join|String.append|String.length|String.eq|String.contains|String.starts_with|String.reverse|String.is_empty|Bool.or|Bool.xor|", "|" ++ name ++ "|")

# Module: src/back/js/emit.bend:437
@unsafe
def j_def(book, d):
  kc(String, String.eq(tg(dv(d)), "Foreign"), u => j_foreign_def(book, d), u => kc(String, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(String.eq(tg(dv(d)), "Absent")) && Bool.not(String.eq(tg(dv(d)), "Foreign")),
    u => kc(String, db(d) && j_intrinsic(dn(d)), u => "if(!Object.hasOwn(G," ++ j_quote(dn(d)) ++ "))", u => "") ++ j_l_def(book, d),
    u => ""))

# Module: src/back/js/emit.bend:448
@unsafe
def j_defs(book, defs):
  match defs:
    case Nil{}:
      ""
    case Con{d, rest}:
      j_def(book, d) ++ j_defs(book, rest)

# Module: src/back/js/emit.bend:460
@unsafe
def j_program(book):
  j_program_selected(book, book)

# Module: src/back/js/emit.bend:469
@unsafe
def j_program_selected(book, defs):
  j_program_context(book_context(book), defs)

# Module: src/back/js/emit.bend:478
@unsafe
def j_program_context(book, defs):
  j_ctor_metadata(defs) ++ j_schemas(book, defs) ++ j_defs(book, defs) ++ "\nawait runmain(" ++ j_descriptor(book, dt(lookup(book, "main")), 64) ++ "," ++ kc(String, j_io_type(book, dt(lookup(book, "main"))), u => "true", u => "false") ++ ");\n"

# Module: src/back/js/emit.bend:490
@unsafe
def j_let(book, env, xs, ty, tail):
  "((" ++ j_bindings(book, env, xs) ++ ")=>" ++ j_expr(book, j_context(book, env, xs), j_body(xs), ty, tail) ++ ")(" ++ j_let_values(book, env, xs) ++ ")"

# Module: src/back/js/emit.bend:500
@unsafe
def j_bindings(book, env, xs):
  match xs:
    case Nil{}:
      ""
    case Con{h, Nil{}}:
      ""
    case Con{h, rest}:
      j_local(ix(h)) ++ "," ++ j_bindings(book, env, rest)

# Module: src/back/js/emit.bend:516
@unsafe
def j_context(book, env, xs):
  match xs:
    case Nil{}:
      env
    case Con{h, Nil{}}:
      env
    case Con{h, rest}:
      Con{kt("Env", "", ix(h), 0, Con{j_type(book, env, kid(h, 0)), Nil{}}), j_context(book, env, rest)}

# Module: src/back/js/emit.bend:530
@unsafe
def j_body(xs):
  match xs:
    case Nil{}:
      atom("Absent")
    case Con{h, Nil{}}:
      h
    case Con{h, rest}:
      j_body(rest)
# Constructor telescopes specialize ADT parameters before entering match arms.

# Module: src/back/js/emit.bend:545
@unsafe
def j_find_ctor(book, name):
  match book:
    case Nil{}:
      missing()
    case Con{d, rest}:
      j_found_ctor(lookup(dc(d), name), rest, name)

# Module: src/back/js/emit.bend:559
@unsafe
def j_found_ctor(found, rest, name):
  kc(KDef, String.eq(dk(found), "Absent"), u => j_find_ctor(rest, name), u => found)

# Module: src/back/js/emit.bend:569
@unsafe
def j_specialize(book, tel, args):
  match args:
    case Nil{}:
      tel
    case Con{h, rest}:
      j_specialize(book, j_app_type(wnf(book, tel), h), rest)

# Module: src/back/js/emit.bend:583
@unsafe
def j_arm_type(book, ty, name):
  j_arm_tel(book, j_specialize(book, dt(j_find_ctor(book, name)), ks(wnf(book, kid(ty, 0)))), kid(ty, 1))

# Module: src/back/js/emit.bend:593
@unsafe
def j_arm_tel(book, tel, ret):
  kc(KTerm, String.eq(tg(tel), "All"), u => all(qt(tel), nm(tel), ix(tel), kid(tel, 0), j_arm_tel(book, kid(tel, 1), ret)), u => ret)
# Readback schemas are finite graphs. Recursive ADTs refer to schema names;
# neither the compiler nor the runtime expands recursive types eagerly.

# Module: src/back/js/emit.bend:603
@unsafe
def j_schemas(book, defs):
  match defs:
    case Nil{}:
      ""
    case Con{d, rest}:
      kc(String, String.eq(dk(d), "ADT"), u => "showSchemas[" ++ j_quote(dn(d)) ++ "]=(p)=>[\"ADT\",{" ++ j_schema_ctors(book, dc(d), da(d)) ++ "}];\n", u => "") ++ j_schemas(book, rest)

# Module: src/back/js/emit.bend:617
@unsafe
def j_schema_ctors(book, ctors, params):
  match ctors:
    case Nil{}:
      ""
    case Con{d, rest}:
      j_quote(dn(d)) ++ ":(()=>{" ++ j_schema_params(book, dt(d), params, 0) ++ "})()," ++ j_schema_ctors(book, rest, params)

# Module: src/back/js/emit.bend:632
@unsafe
def j_schema_params(book, ty, left, index):
  kc(String, U32.is_eq(left, 0), u => "return [" ++ j_schema_fields(book, ty) ++ "];", u => "const " ++ j_local(ix(ty)) ++ "=p[" ++ U32.show(index) ++ "];" ++ j_schema_params(book, kid(ty, 1), U32.sub(left, 1), U32.add(index, 1)))

# Module: src/back/js/emit.bend:641
@unsafe
def j_schema_fields(book, ty):
  kc(String, String.eq(tg(ty), "All"), u => kc(String, U32.is_eq(qt(ty), 0), u => "[\"Erased\"]", u => j_descriptor(book, kid(ty, 0), 64)) ++ "," ++ j_schema_fields(book, kid(ty, 1)), u => "")

# Module: src/back/js/emit.bend:651
@unsafe
def j_desc_args(book, args, fuel):
  match args:
    case Nil{}:
      ""
    case Con{h, rest}:
      j_descriptor(book, h, fuel) ++ "," ++ j_desc_args(book, rest, fuel)

# Module: src/back/js/emit.bend:665
@unsafe
def j_ctor_args(book, env, args, tel):
  match args:
    case Nil{}:
      ""
    case Con{h, rest}:
      kc(String, String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 0), u => "null", u => j_expr(book, env, h, kid(tel, 0), False{})) ++ "," ++ j_ctor_args(book, env, rest, j_app_type(tel, h))

# Module: src/back/js/emit.bend:680
@unsafe
def j_constructor(book, env, t, ty):
  j_constructor_literal(book, env, t, ty, j_literal_typed(book, t, ty))

# Constructor fields in return position are evaluated by the application
# trampoline, retaining source order without growing the host call stack.

# Module: src/back/js/emit.bend:694
@unsafe
def j_constructor_mode(book, env, t, ty, tail):
  kc(String, tail && String.eq(j_literal_typed(book, t, ty), ""), u => "build(" ++ j_quote(nm(t)) ++ ",[" ++ j_ctor_thunks(book, env, ks(t), j_specialize(book, dt(j_find_ctor(book, nm(t))), ks(wnf(book, ty)))) ++ "])", u => j_constructor(book, env, t, ty))

# Module: src/back/js/emit.bend:705
@unsafe
def j_ctor_thunks(book, env, args, tel):
  match args:
    case Nil{}:
      ""
    case Con{h, rest}:
      "()=>" ++ kc(String, String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 0), u => "null", u => j_expr(book, env, h, kid(tel, 0), True{})) ++ "," ++ j_ctor_thunks(book, env, rest, j_app_type(tel, h))

# Module: src/back/js/emit.bend:721
@unsafe
def j_constructor_literal(book, env, t, ty, literal):
  kc(String, String.eq(literal, ""), u => "ctor(" ++ j_quote(nm(t)) ++ ",[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(j_find_ctor(book, nm(t))), ks(wnf(book, ty)))) ++ "])", u => literal)

# Module: src/back/js/emit.bend:730
@unsafe
def j_io_type(book, ty):
  kc(Bool, String.eq(dk(lookup(book, "IO")), "Def") && db(lookup(book, "IO")), u => j_io_spine(wnf(j_io_shadow(book), ty), 0), u => False{})

# Module: src/back/js/emit.bend:738
@unsafe
def j_io_shadow(book):
  j_io_shadow_def(book, lookup(book, "IO"))

# Module: src/back/js/emit.bend:747
@unsafe
def j_io_shadow_def(book, d):
  book_put(book, KDef{dn(d), dk(d), da(d), dx(d), dt(d), atom("Absent"), dc(d), db(d), du(d)})

# Module: src/back/js/emit.bend:756
@unsafe
def j_io_spine(t, args):
  kc(Bool, String.eq(tg(t), "App"), u => j_io_spine(kid(t, 0), U32.add(args, 1)), u => String.eq(tg(t), "Ref") && String.eq(nm(t), "IO") && U32.is_eq(args, 1))

# Library output exposes the same primitive ABI as generated executables;
# callers may use G/call/list/ctor without invoking main.

# Module: src/back/js/emit.bend:766
@unsafe
def j_library(book):
  j_library_selected(book, book)

# Module: src/back/js/emit.bend:775
@unsafe
def j_library_selected(book, defs):
  j_library_context(book_context(book), defs)

# Module: src/back/js/emit.bend:784
@unsafe
def j_library_context(book, defs):
  j_ctor_metadata(defs) ++ j_schemas(book, defs) ++ j_defs(book, defs) ++ "\nexport {G,call,list,ctor};\nexport default Object.fromEntries(Object.keys(G).map(k=>[k,(...args)=>call(get(G,k),args)]));\n"

# Module: src/back/js/emit.bend:794
@unsafe
def j_desc_kind(book, ty, fuel):
  kc(String, String.eq(tg(ty), "All"), u => "[\"Fun\"," ++ U32.show(qt(ty)) ++ "," ++ j_descriptor(book, kid(ty, 0), fuel) ++ "," ++ j_descriptor(book, kid(ty, 1), fuel) ++ "]", u => j_desc_head(book, ty, fuel))
# Roots and intrinsic stops for the shared dependency reachability pass.

# Module: src/back/js/emit.bend:803
@unsafe
def j_roots(book, library):
  kc(List<&2, String>, library, u => j_library_roots(book), u => ["main"])

# Module: src/back/js/emit.bend:811
@unsafe
def j_library_roots(book):
  match book:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      kc(List<&2, String>, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(String.eq(tg(dv(d)), "Absent")) && (Bool.not(db(d)) || String.eq(tg(dv(d)), "Foreign")), u => Con{dn(d), j_library_roots(rest)}, u => j_library_roots(rest))

# Module: src/back/js/emit.bend:823
@unsafe
def j_stops(book):
  match book:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      kc(List<&2, String>, db(d) && j_intrinsic(dn(d)), u => Con{dn(d), j_stops(rest)}, u => j_stops(rest))
# A checked residual datatype with one remaining constructor needs projection,
# not another tag test. This also preserves the foreign JS lane's trusted values.

# Module: src/back/js/emit.bend:839
@unsafe
def j_match(book, env, t, ty):
  kc(String, U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1),
    u => "matcher1(" ++ j_quote(nm(t)) ++ ",()=>" ++ j_expr(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), False{}) ++ ")",
    u => "matcher(" ++ j_quote(nm(t)) ++ ",()=>" ++ j_expr(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), False{}) ++ ",()=>" ++ j_expr(book, env, kid(t, 1), ty, False{}) ++ ")")

# Module: src/back/js/emit.bend:850
@unsafe
def j_constructor_count(book, ty):
  j_count_constructors(dc(lookup(book, nm(ty))), rm(ty))

# Module: src/back/js/emit.bend:859
@unsafe
def j_count_constructors(ctors, removed):
  match ctors:
    case Nil{}:
      0
    case Con{d, rest}:
      U32.add(kc(U32, has_name(removed, dn(d)), u => 0, u => 1), j_count_constructors(rest, removed))

# Parallel RHSs are evaluated outside the scope introducing their binders.

# Module: src/back/js/emit.bend:874
@unsafe
def j_let_values(book, env, xs):
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: ""
    case Con{h, rest}:
      kc(String, U32.is_eq(qt(h), 0), u => "null", u => j_expr(book, env, kid(h, 0), atom("Absent"), False{})) ++ "," ++ j_let_values(book, env, rest)

# Deep closures use flat factories with explicit lexical captures.

# Module: src/back/js/emit.bend:883
@unsafe
def j_l_name(t):
  j_l_names(rm(t))

# Module: src/back/js/emit.bend:887
@unsafe
def j_l_names(names):
  match names:
    case Nil{}: ""
    case Con{h, rest}: kc(String, String.starts_with(h, "$js."), u => h, u => "")

# Module: src/back/js/emit.bend:893
@unsafe
def j_l_capture(env, seen):
  match env:
    case Nil{}: ""
    case Con{h, rest}:
      kc(String, has_name(seen, j_local(ix(h))), u => j_l_capture(rest, seen), u => j_local(ix(h)) ++ "," ++ j_l_capture(rest, Con{j_local(ix(h)), seen}))

# Module: src/back/js/emit.bend:900
@unsafe
def j_l_deep(t, depth):
  kc(Bool, String.eq(tg(t), "Ann"), u => j_l_deep(kid(t, 0), depth), u =>
  kc(Bool, String.eq(tg(t), "Var") || String.eq(tg(t), "Ref"), u => False{}, u =>
  kc(Bool, String.eq(tg(t), "Lam") || String.eq(tg(t), "Mat"), u => kc(Bool, U32.is_ge(depth, 32), u => True{}, u => j_l_deeps(ks(t), U32.inc(depth))), u => j_l_deeps(ks(t), depth))))

# Module: src/back/js/emit.bend:906
@unsafe
def j_l_deeps(ts, depth):
  match ts:
    case Nil{}: False{}
    case Con{h, rest}: kc(Bool, j_l_deep(h, depth), u => True{}, u => j_l_deeps(rest, depth))

# Module: src/back/js/emit.bend:912
@unsafe
def j_l_mark(t, path, depth):
  kc(KTerm, String.eq(tg(t), "Ann"), u => KTerm{tg(t), nm(t), ix(t), qt(t), [j_l_mark(kid(t, 0), path, depth), kid(t, 1)], rm(t)}, u =>
  kc(KTerm, String.eq(tg(t), "Var") || String.eq(tg(t), "Ref"), u => t, u =>
  kc(KTerm, String.eq(tg(t), "Lam") || String.eq(tg(t), "Mat"), u =>
    kc(KTerm, U32.is_ge(depth, 32), u => KTerm{tg(t), nm(t), ix(t), qt(t), j_l_marks(ks(t), path, 0, 0), ["$js." ++ path]}, u => KTerm{tg(t), nm(t), ix(t), qt(t), j_l_marks(ks(t), path, U32.inc(depth), 0), rm(t)}), u =>
    KTerm{tg(t), nm(t), ix(t), qt(t), j_l_marks(ks(t), path, depth, 0), rm(t)})))

# Module: src/back/js/emit.bend:920
@unsafe
def j_l_marks(ts, path, depth, at):
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_l_mark(h, path ++ "_" ++ U32.show(at), depth), j_l_marks(rest, path, depth, U32.inc(at))}

# Module: src/back/js/emit.bend:926
@unsafe
def j_l_def(book, d):
  kc(String, j_l_deep(dv(d), 0), u => j_l_definition(book, d, j_l_mark(dv(d), "r", 0)), u => j_l_global(book, d, dv(d)))

# Module: src/back/js/emit.bend:930
@unsafe
def j_l_definition(book, d, t):
  "{const F=Object.create(null);\n" ++ j_l_walk(book, Nil{}, t, dt(d)) ++ j_l_global(book, d, t) ++ "}\n"

# Module: src/back/js/emit.bend:934
@unsafe
def j_l_walk(book, env, t, ty):
  kc(String, String.eq(tg(t), "Ann"), u => j_l_walk(book, env, kid(t, 0), kid(t, 1)), u =>
  kc(String, String.eq(j_l_name(t), ""), u => "", u => "F[" ++ j_quote(j_l_name(t)) ++ "]=function(" ++ j_l_capture(env, Nil{}) ++ "){return " ++ j_expr_on(book, env, t, ty, False{}, tg(t)) ++ ";};\n") ++ j_l_children(book, env, t, ty))

# Module: src/back/js/emit.bend:939
@unsafe
def j_l_children(book, env, t, ty):
  kc(String, String.eq(tg(t), "Lam"), u => j_l_lam(book, env, t, wnf(book, ty)), u =>
  kc(String, String.eq(tg(t), "Mat"), u => j_l_mat(book, env, t, wnf(book, ty)), u =>
  kc(String, String.eq(tg(t), "App"), u => j_l_app(book, env, t, wnf(book, j_type(book, env, kid(t, 0)))), u =>
  kc(String, String.eq(tg(t), "Let"), u => j_l_bindings(book, env, ks(t)) ++ j_l_walk(book, j_context(book, env, ks(t)), j_body(ks(t)), ty), u =>
  kc(String, String.eq(tg(t), "Ctr"), u => kc(String, String.eq(j_literal_typed(book, t, ty), ""), u => j_l_fields(book, env, ks(t), j_specialize(book, dt(j_find_ctor(book, nm(t))), ks(wnf(book, ty)))), u => ""), u =>
  kc(String, String.eq(tg(t), "Rwt"), u => j_l_walk(book, env, kid(t, 2), ty), u => ""))))))

# Module: src/back/js/emit.bend:948
@unsafe
def j_l_lam(book, env, t, ty):
  j_l_walk(book, Con{kt("Env", "", ix(t), 0, [kid(ty, 0)]), env}, kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))))

# Module: src/back/js/emit.bend:952
@unsafe
def j_l_mat(book, env, t, ty):
  j_l_walk(book, env, kid(t, 0), j_arm_type(book, ty, nm(t))) ++ kc(String, U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1), u => "", u => j_l_walk(book, env, kid(t, 1), ty))

# Module: src/back/js/emit.bend:956
@unsafe
def j_l_app(book, env, t, ty):
  j_l_walk(book, env, kid(t, 0), ty) ++ kc(String, String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 0), u => "", u => j_l_walk(book, env, kid(t, 1), kid(ty, 0)))

# Module: src/back/js/emit.bend:960
@unsafe
def j_l_fields(book, env, ts, ty):
  match ts:
    case Nil{}: ""
    case Con{h, rest}: kc(String, String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 0), u => "", u => j_l_walk(book, env, h, kid(ty, 0))) ++ j_l_fields(book, env, rest, j_app_type(ty, h))

# Module: src/back/js/emit.bend:966
@unsafe
def j_l_bindings(book, env, ts):
  match ts:
    case Nil{}: ""
    case Con{h, Nil{}}: ""
    case Con{h, rest}: kc(String, U32.is_eq(qt(h), 0), u => "", u => j_l_walk(book, env, kid(h, 0), j_type(book, env, kid(h, 0)))) ++ j_l_bindings(book, env, rest)

# Leading lambdas and matchers are pure closure initializers; their bodies stay delayed.

# Module: src/back/js/emit.bend:980
@unsafe
def j_l_global(book, d, t):
  j_l_global_worker(book, d, t, j_projection_worker(book, t, dt(d)))

# Module: src/back/native/text.bend:2
@unsafe
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# Module: src/back/native/text.bend:8
@unsafe
def nt_join_go(xs: List<&2, String>, +sep: String, +acc: String, +first: Bool) -> String:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_join_go(t, sep, acc ++ nt_choose(String, first, u => "", u => sep) ++ h, False{})

# Module: src/back/native/text.bend:14
@unsafe
def nt_join(xs: List<&2, String>, sep: String) -> String:
  nt_join_go(xs, sep, "", True{})

# Module: src/back/native/text.bend:18
@unsafe
def nt_count_go(-A: Data, xs: List<&2, A>, +n: U32) -> U32:
  match xs:
    case Nil{}: n
    case Con{h, t}: nt_count_go(A, t, U32.inc(n))

# Module: src/back/native/text.bend:24
@unsafe
def nt_count(-A: Data, xs: List<&2, A>) -> U32:
  nt_count_go(A, xs, 0)

# Module: src/back/native/text.bend:28
@unsafe
def nt_reverse(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_reverse(A, t, Con{h, acc})

# Module: src/back/native/text.bend:34
@unsafe
def nt_append(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:
  nt_reverse(A, nt_reverse(A, xs, Nil{}), ys)

# Module: src/back/native/text.bend:38
@unsafe
def nt_clean(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, t}:
      nt_choose(String, Char.is_alpha(h) || Char.is_digit(h) || Char.is_eq(h, '_'), u => SCon{h, ""}, u => "_") ++ nt_clean(t)

# Module: src/back/native/text.bend:45
@unsafe
def nt_fid(k: String) -> String:
  "FID_" ++ String.to_upper(nt_clean(k))

# Module: src/back/native/text.bend:49
@unsafe
def nt_cid(k: String) -> String:
  "CID_" ++ String.to_upper(nt_clean(k))

# Module: src/back/native/text.bend:53
@unsafe
def nt_local(k: String, n: U32) -> String:
  nt_clean(k) ++ "_" ++ U32.show(n)

# Module: src/back/native/text.bend:57
@unsafe
def nt_bool(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

# Module: src/back/native/text.bend:77
@unsafe
def nt_replace_step(s, key, value, acc):
  match s:
    case SNil{}: acc
    case SCon{h, t}: nt_replace_go(t, key, value, acc ++ SCon{h, ""})

# Module: src/back/native/text.bend:83
@unsafe
def nt_replace_go(s, key, value, acc):
  nt_choose(String, String.starts_with(s, key), u => acc ++ value ++ String.drop(s, String.length(key)), u => nt_replace_step(s, key, value, acc))

# Module: src/back/native/text.bend:87
@unsafe
def nt_replace(s: String, key: String, value: String) -> String:
  nt_replace_go(s, key, value, "")

# Module: src/back/native/text.bend:91
@unsafe
def nt_lines_go(s: String, +acc: String) -> String:
  match s:
    case SNil{}: acc
    case SCon{+h, t}:
      nt_lines_go(t, acc ++ nt_choose(String, Char.is_eq(h, '\n'), u => "\n    ", u => SCon{h, ""}))

# Module: src/back/native/text.bend:98
@unsafe
def nt_lines(s: String) -> String:
  nt_lines_go(s, "")

# Module: src/back/native/text.bend:102
@unsafe
def nt_indent(s: String) -> String:
  "    " ++ nt_lines(s)

# Module: src/back/native/identity.bend:46
@unsafe
def nc_ctor_identity(book, name):
  kc(String, nc_ctor_owned(book, name), u => name, u => nc_ctor_encode(name))

# Module: src/back/native/identity.bend:50
@unsafe
def nc_ctor_owned(book, name):
  match book:
    case Nil{}:
      False{}
    case Con{d, rest}:
      kc(Bool, String.eq(dk(d), "ADT"),
        u => kc(Bool, String.eq(dk(lookup(dc(d), name)), "Ctr"), u => db(d), u => nc_ctor_owned(rest, name)),
        u => nc_ctor_owned(rest, name))

# Module: src/back/native/identity.bend:60
@unsafe
def nc_ctor_encode(name):
  "$ctor." ++ nc_ctor_codes(name)

# Module: src/back/native/identity.bend:64
@unsafe
def nc_ctor_codes(name):
  match name:
    case SNil{}:
      ""
    case SCon{h, rest}:
      U32.show(Char.to_u32(h)) ++ "_" ++ nc_ctor_codes(rest)

# Module: src/back/native/identity.bend:72
@unsafe
def nc_ctor_display(name):
  kc(String, String.starts_with(name, "$ctor."),
    u => nc_ctor_decode(String.drop(name, String.length("$ctor.")), 0, 0, "", name),
    u => name)

# Module: src/back/native/identity.bend:78
@unsafe
def nc_ctor_decode(rest, acc, digits, out, original):
  match rest:
    case SNil{}:
      kc(String, U32.is_eq(digits, 0) && String.eq(nc_ctor_encode(out), original), u => out, u => original)
    case SCon{h, tail}:
      nc_ctor_decode_step(h, tail, acc, digits, out, original)

# Module: src/back/native/identity.bend:86
@unsafe
def nc_ctor_decode_step(h, rest, acc, digits, out, original):
  kc(String, Char.is_eq(h, '_'),
    u => kc(String, U32.is_gt(digits, 0) && U32.is_le(acc, 1114111) && Bool.not(U32.is_ge(acc, 55296) && U32.is_le(acc, 57343)),
      u => nc_ctor_decode(rest, 0, 0, out ++ Char.show(Char.from_u32(acc)), original),
      u => original),
    u => kc(String, U32.is_ge(Char.to_u32(h), 48) && U32.is_le(Char.to_u32(h), 57) && U32.is_lt(digits, 7),
      u => nc_ctor_decode(rest, U32.add(U32.mul(acc, 10), U32.sub(Char.to_u32(h), 48)), U32.add(digits, 1), out, original),
      u => original))

# Module: src/back/native/layout.bend:2
@unsafe
def nl_word() -> N_Layout:
  N_Layout{Con{N_W32{}, Nil{}}, Nil{}}

# Module: src/back/native/layout.bend:6
@unsafe
def nl_wide() -> N_Layout:
  N_Layout{Con{N_W64{}, Nil{}}, Nil{}}

# Module: src/back/native/layout.bend:10
@unsafe
def nl_box() -> N_Layout:
  N_Layout{Con{N_Box{}, Nil{}}, Nil{}}

# Module: src/back/native/layout.bend:14
@unsafe
def nl_c_type(+k: N_WordKind) -> String:
  match k:
    case N_W32{}: "u32"
    case N_W64{}: "Term"
    case N_Box{}: "Term"

# Module: src/back/native/layout.bend:21
@unsafe
def nl_merge_word(+a: N_WordKind, +b: N_WordKind) -> N_WordKind:
  match a, b:
    case N_Box{}, _: N_Box{}
    case _, N_Box{}: N_Box{}
    case N_W64{}, _: N_W64{}
    case _, N_W64{}: N_W64{}
    case _, _: N_W32{}

# Module: src/back/native/layout.bend:30
@unsafe
def nl_merge(+a: List<&2, N_WordKind>, +b: List<&2, N_WordKind>) -> List<&2, N_WordKind>:
  match a, b:
    case Nil{}, _: b
    case _, Nil{}: a
    case Con{h, t}, Con{j, u}: Con{nl_merge_word(h, j), nl_merge(t, u)}

# Module: src/back/native/layout.bend:37
@unsafe
def nl_pad(+n: U32) -> List<&2, N_WordKind>:
  match n:
    case 0: Nil{}
    case _: Con{N_W32{}, nl_pad(U32.sub(n, 1))}

# Module: src/back/native/layout.bend:43
@unsafe
def nl_field_words(+fs: List<&2, N_Field>) -> List<&2, N_WordKind>:
  match fs:
    case Nil{}: Nil{}
    case Con{N_Field{at, ws}, t}:
      nl_merge(List.append(&2, N_WordKind, nl_pad(at), ws), nl_field_words(t))

# Module: src/back/native/layout.bend:50
@unsafe
def nl_arm_words(+xs: List<&2, N_Arm>) -> List<&2, N_WordKind>:
  match xs:
    case Nil{}: Nil{}
    case Con{N_Arm{k, fs}, t}: nl_merge(nl_field_words(fs), nl_arm_words(t))

# Module: src/back/native/layout.bend:56
@unsafe
def nl_shift_fields(+xs: List<&2, N_Field>, +tag: U32) -> List<&2, N_Field>:
  match xs:
    case Nil{}: Nil{}
    case Con{N_Field{at, ws}, t}: Con{N_Field{U32.add(at, tag), ws}, nl_shift_fields(t, tag)}

# Module: src/back/native/layout.bend:62
@unsafe
def nl_shift_arms(+xs: List<&2, N_Arm>, +tag: U32) -> List<&2, N_Arm>:
  match xs:
    case Nil{}: Nil{}
    case Con{N_Arm{k, fs}, t}: Con{N_Arm{k, nl_shift_fields(fs, tag)}, nl_shift_arms(t, tag)}

# Module: src/back/native/layout.bend:68
@unsafe
def nl_pack(+arms: List<&2, N_Arm>) -> N_Layout:
  +tag = nt_choose(U32, U32.is_gt(nt_count(N_Arm, arms), 1), u => 1, u => 0)
  +shifted = nl_shift_arms(arms, tag)
  N_Layout{nl_merge(nl_pad(tag), nl_arm_words(shifted)), shifted}

# Module: src/back/native/layout.bend:74
@unsafe
def nl_size(+x: N_Layout) -> U32:
  match x:
    case N_Layout{ws, arms}: nt_count(N_WordKind, ws)

# Module: src/back/native/layout.bend:79
@unsafe
def nl_fits(+x: N_Layout) -> Bool:
  U32.is_le(nl_size(x), 256)

# Module: src/back/native/layout.bend:83
@unsafe
def nl_cls_go(+n: U32, +acc: U32) -> U32:
  match n:
    case 0: acc
    case _: nl_cls_go(U32.shr(n), U32.inc(acc))

# Module: src/back/native/layout.bend:89
@unsafe
def nl_cls_fit(+n: U32) -> U32:
  nt_choose(U32, U32.is_le(n, 1), u => 0, u => nl_cls_go(U32.sub(n, 1), 0))

# Module: src/back/native/layout.bend:93
@unsafe
def nl_has_box(+xs: List<&2, N_WordKind>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{N_W32{}, t}: nl_has_box(t)
    case Con{_, t}: True{}

# Module: src/back/native/intrinsic.bend:5
@unsafe
def ni_templates() -> List<&2, ni_Op>:
  Con{ni_Op{"u32_add", "U32_BIN($0, +, $1)"}, Con{ni_Op{"u32_sub", "U32_BIN($0, -, $1)"}, Con{ni_Op{"u32_and", "U32_BIN($0, &, $1)"}, Con{ni_Op{"u32_or", "U32_BIN($0, |, $1)"}, Con{ni_Op{"u32_xor", "U32_BIN($0, ^, $1)"}, Con{ni_Op{"u32_mul", "U32_BIN($0, *, $1)"}, Con{ni_Op{"u32_is_eq", "U32_BIN($0, ==, $1)"}, Con{ni_Op{"u32_is_ne", "U32_BIN($0, !=, $1)"}, Con{ni_Op{"u32_is_lt", "U32_BIN($0, <, $1)"}, Con{ni_Op{"u32_is_le", "U32_BIN($0, <=, $1)"}, Con{ni_Op{"u32_is_gt", "U32_BIN($0, >, $1)"}, Con{ni_Op{"u32_is_ge", "U32_BIN($0, >=, $1)"}, Con{ni_Op{"u32_inc", "U32_BIN($0, +, 1)"}, Con{ni_Op{"u32_shl", "U32_BIN($0, <<, 1)"}, Con{ni_Op{"u32_shr", "U32_BIN($0, >>, 1)"}, Con{ni_Op{"u32_shln", "($1 >= 32 ? 0 : U32_BIN($0, <<, $1))"}, Con{ni_Op{"u32_shrn", "($1 >= 32 ? 0 : U32_BIN($0, >>, $1))"}, Con{ni_Op{"u32_div", "((u32)($1) == 0 ? 0 : (u64)U32_QUO((u32)($0), (u32)($1)))"}, Con{ni_Op{"u32_mod", "((u32)($1) == 0 ? $0 : U32_BIN($0, -, U32_QUO((u32)($0), (u32)($1)) * $1))"}, Con{ni_Op{"u32_not", "((u64)~(u32)($0))"}, Con{ni_Op{"u32_is_zero", "U32_BIN($0, ==, 0)"}, Con{ni_Op{"u32_cmp", "(U32_BIN($0, >, $1) + U32_BIN($0, >=, $1))"}, Con{ni_Op{"u32_to_f32", "f32_rewrap((f32)(u32)($0))"}, Con{ni_Op{"u32_to_nat", "$0"}, Con{ni_Op{"u32_from_nat", "((u64)(u32)($0))"}, Con{ni_Op{"f32_add", "f32_rewrap(f32_unbox($0) + f32_unbox($1))"}, Con{ni_Op{"f32_sub", "f32_rewrap(f32_unbox($0) - f32_unbox($1))"}, Con{ni_Op{"f32_mul", "f32_rewrap(f32_unbox($0) * f32_unbox($1))"}, Con{ni_Op{"f32_div", "f32_rewrap(f32_unbox($0) / f32_unbox($1))"}, Con{ni_Op{"f32_is_eq", "((u64)(f32_unbox($0) == f32_unbox($1)))"}, Con{ni_Op{"f32_is_ne", "((u64)(f32_unbox($0) != f32_unbox($1)))"}, Con{ni_Op{"f32_is_lt", "((u64)(f32_unbox($0) < f32_unbox($1)))"}, Con{ni_Op{"f32_is_le", "((u64)(f32_unbox($0) <= f32_unbox($1)))"}, Con{ni_Op{"f32_is_gt", "((u64)(f32_unbox($0) > f32_unbox($1)))"}, Con{ni_Op{"f32_is_ge", "((u64)(f32_unbox($0) >= f32_unbox($1)))"}, Con{ni_Op{"f32_sqrt", "f32_rewrap((f32)sqrt(f32_unbox($0)))"}, Con{ni_Op{"f32_exp", "f32_rewrap((f32)exp(f32_unbox($0)))"}, Con{ni_Op{"f32_log", "f32_rewrap((f32)log(f32_unbox($0)))"}, Con{ni_Op{"f32_log2", "f32_rewrap((f32)log2(f32_unbox($0)))"}, Con{ni_Op{"f32_log10", "f32_rewrap((f32)log10(f32_unbox($0)))"}, Con{ni_Op{"f32_sin", "f32_rewrap((f32)sin(f32_unbox($0)))"}, Con{ni_Op{"f32_cos", "f32_rewrap((f32)cos(f32_unbox($0)))"}, Con{ni_Op{"f32_tan", "f32_rewrap((f32)tan(f32_unbox($0)))"}, Con{ni_Op{"f32_asin", "f32_rewrap((f32)asin(f32_unbox($0)))"}, Con{ni_Op{"f32_acos", "f32_rewrap((f32)acos(f32_unbox($0)))"}, Con{ni_Op{"f32_atan", "f32_rewrap((f32)atan(f32_unbox($0)))"}, Con{ni_Op{"f32_sinh", "f32_rewrap((f32)sinh(f32_unbox($0)))"}, Con{ni_Op{"f32_cosh", "f32_rewrap((f32)cosh(f32_unbox($0)))"}, Con{ni_Op{"f32_tanh", "f32_rewrap((f32)tanh(f32_unbox($0)))"}, Con{ni_Op{"f32_floor", "f32_rewrap((f32)floor(f32_unbox($0)))"}, Con{ni_Op{"f32_ceil", "f32_rewrap((f32)ceil(f32_unbox($0)))"}, Con{ni_Op{"f32_trunc", "f32_rewrap((f32)trunc(f32_unbox($0)))"}, Con{ni_Op{"f32_abs", "f32_rewrap((f32)fabs(f32_unbox($0)))"}, Con{ni_Op{"f32_pow", "f32_rewrap((f32)pow(f32_unbox($0), f32_unbox($1)))"}, Con{ni_Op{"f32_atan2", "f32_rewrap((f32)atan2(f32_unbox($0), f32_unbox($1)))"}, Con{ni_Op{"f32_mod", "f32_rewrap((f32)fmod(f32_unbox($0), f32_unbox($1)))"}, Con{ni_Op{"f32_neg", "f32_rewrap(-f32_unbox($0))"}, Con{ni_Op{"f32_to_u32", "f32_to_u32($0)"}, Con{ni_Op{"f32_bits", "$0"}, Con{ni_Op{"f32_show", "f32_show(e, $0)"}, Con{ni_Op{"f32_read", "f32_read(e, $0)"}, Con{ni_Op{"nat_add", "nat_chk(e, $0 + $1)"}, Con{ni_Op{"nat_sub", "($0 < $1 ? 0 : $0 - $1)"}, Con{ni_Op{"nat_mul", "nat_mul(e, $0, $1)"}, Con{ni_Op{"nat_double", "nat_chk(e, $0 + $0)"}, Con{ni_Op{"nat_cmp", "(($0 > $1) + ($0 >= $1))"}, Con{ni_Op{"nat_is_lt", "($0 < $1)"}, Con{ni_Op{"bool_or", "(native_bool($0) | native_bool($1))"}, Con{ni_Op{"bool_xor", "(native_bool($0) ^ native_bool($1))"}, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

# Module: src/back/native/intrinsic.bend:9
@unsafe
def ni_find(+k: String, ops: List<&2, ni_Op>) -> String:
  match ops:
    case Nil{}: ""
    case Con{ni_Op{n, +t}, +rest}: nt_choose(String, String.eq(k, n), u => t, u => ni_find(k, rest))

# Module: src/back/native/intrinsic.bend:15
@unsafe
def ni_replace_all(+s: String, +key: String, +value: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, +t}:
      nt_choose(String, String.starts_with(s, key), u => value ++ ni_replace_all(String.drop(s, String.length(key)), key, value), u => SCon{h, ni_replace_all(t, key, value)})

# Module: src/back/native/intrinsic.bend:22
@unsafe
def ni_fill(+s: String, xs: List<&2, String>, +i: U32) -> String:
  match xs:
    case Nil{}: s
    case Con{h, t}: ni_fill(ni_replace_all(s, "$" ++ U32.show(i), h), t, U32.inc(i))

# Module: src/back/native/intrinsic.bend:28
@unsafe
def ni_emit(k: String, xs: List<&2, String>) -> String:
  ni_fill(ni_find(k, ni_templates()), xs, 0)

# Module: src/back/native/tables.bend:2
@unsafe
def nb_max(+a: U32, +b: U32) -> U32:
  nt_choose(U32, U32.is_gt(a, b), u => a, u => b)

# Module: src/back/native/tables.bend:6
@unsafe
def nb_width_go(ss: List<&2, N_Segment>, +acc: U32) -> U32:
  match ss:
    case Nil{}: acc
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_width_go(t, nb_max(acc, nb_max(nt_count(N_Param, ps), r)))

# Module: src/back/native/tables.bend:12
@unsafe
def nb_width(ss: List<&2, N_Segment>) -> U32:
  nb_width_go(ss, 2)

# Module: src/back/native/tables.bend:16
@unsafe
def nb_returns_go(ss: List<&2, N_Segment>, +acc: U32) -> U32:
  match ss:
    case Nil{}: acc
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_returns_go(t, nb_max(acc, r))

# Module: src/back/native/tables.bend:22
@unsafe
def nb_returns(ss: List<&2, N_Segment>) -> U32:
  nb_returns_go(ss, 1)

# Module: src/back/native/tables.bend:26
@unsafe
def nb_bangs_go(ss: List<&2, N_Segment>, +acc: U32) -> U32:
  match ss:
    case Nil{}: acc
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_bangs_go(t, U32.add(acc, nt_bool(bang)))

# Module: src/back/native/tables.bend:32
@unsafe
def nb_bangs(ss: List<&2, N_Segment>) -> U32:
  nb_bangs_go(ss, 0)

# Module: src/back/native/tables.bend:36
@unsafe
def nb_regs(+n: U32, +i: U32) -> List<&2, String>:
  match n:
    case 0: Nil{}
    case _: Con{"r" ++ U32.show(i), nb_regs(U32.sub(n, 1), U32.inc(i))}

# Module: src/back/native/tables.bend:42
@unsafe
def nb_pad(+rs: List<&2, String>, +i: U32) -> List<&2, String>:
  match rs:
    case Nil{}: Nil{}
    case Con{+h, +t}: nt_choose(List<&2, String>, U32.is_eq(i, 6), u => Con{"rp", Con{h, t}}, u => Con{h, nb_pad(t, U32.inc(i))})

# Module: src/back/native/tables.bend:48
@unsafe
def nb_typed(+rs: List<&2, String>) -> List<&2, String>:
  match rs:
    case Nil{}: Nil{}
    case Con{+h, +t}: Con{"Term " ++ h, nb_typed(t)}

# Module: src/back/native/tables.bend:54
@unsafe
def nb_load(+rs: List<&2, String>, +i: U32) -> String:
  match rs:
    case Nil{}: ""
    case Con{+h, +t}: "    if ((N) <= " ++ U32.show(i) ++ ") break; " ++ h ++ " = e.mem[(A) + " ++ U32.show(i) ++ "]; \\\n" ++ nb_load(t, U32.inc(i))

# Module: src/back/native/tables.bend:60
@unsafe
def nb_last(+rs: List<&2, String>, +i: U32) -> String:
  match rs:
    case Nil{}: ""
    case Con{+h, +t}: "    case " ++ U32.show(i) ++ ": " ++ h ++ " = (X); break; \\\n" ++ nb_last(t, U32.inc(i))

# Module: src/back/native/tables.bend:66
@unsafe
def nb_save(+rs: List<&2, String>, +i: U32) -> String:
  match rs:
    case Nil{}: ""
    case Con{+h, +t}: "(V)[" ++ U32.show(i) ++ "] = " ++ h ++ "; " ++ nb_save(t, U32.inc(i))

# Module: src/back/native/tables.bend:72
@unsafe
def nb_take(+rs: List<&2, String>, +i: U32) -> String:
  match rs:
    case Nil{}: ""
    case Con{+h, +t}: h ++ " = (V)[" ++ U32.show(i) ++ "]; " ++ nb_take(t, U32.inc(i))

# Module: src/back/native/tables.bend:78
@unsafe
def nb_bank(+ss: List<&2, N_Segment>) -> String:
  +n = nb_width(ss)
  +r = nb_returns(ss)
  +rs = nb_regs(n, 0)
  +ws = nb_pad(rs, 0)
  "#define WL_RESW " ++ U32.show(r) ++ "\n#define BANGS " ++ U32.show(nb_bangs(ss)) ++ "\n#define WL_BANK Term " ++ nt_join(ws, ", ") ++ ";\n"
    ++ "#define WL_LOAD(A, N) \\\n  do { \\\n" ++ nb_load(rs, 0) ++ "  } while (0);\n"
    ++ "#define WL_LAST(X) \\\n  switch (war) { \\\n" ++ nb_last(rs, 0) ++ "  }\n"
    ++ "#define WL_SAVE(V) " ++ nb_save(nb_regs(r, 0), 0) ++ "\n"
    ++ "#define WL_TAKE(V) " ++ nb_take(nb_regs(r, 0), 0) ++ "\n"
    ++ "#define WL_SIG Env e, Stk sp, u32 seq, u32 rn, " ++ nt_join(nb_typed(ws), ", ") ++ "\n"
    ++ "#define WL_ALL e, sp, seq, rn, " ++ nt_join(ws, ", ") ++ "\n"

# Module: src/back/native/tables.bend:92
@unsafe
def nb_seg_ids_go(ss: List<&2, N_Segment>, +i: U32, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "#define FID_IO_EMIT " ++ U32.show(i) ++ "\n#define FID_CLO_APPLY " ++ U32.show(U32.add(i, 1)) ++ "\n#define FID_EXIT " ++ U32.show(U32.add(i, 2)) ++ "\n#define FID_ENTER " ++ U32.show(U32.add(i, 3)) ++ "\n"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_seg_ids_go(t, U32.inc(i), acc ++ "#define " ++ nt_fid(k) ++ " " ++ U32.show(i) ++ "\n")

# Module: src/back/native/tables.bend:98
@unsafe
def nb_seg_ids(ss: List<&2, N_Segment>, i: U32) -> String:
  nb_seg_ids_go(ss, i, "")

# Module: src/back/native/tables.bend:102
@unsafe
def nb_ctr_ids(+cs: List<&2, N_Constructor>, +i: U32) -> String:
  match cs:
    case Nil{}: ""
    case Con{N_Constructor{+k, +a, +h}, +t}: "#define " ++ nt_cid(k) ++ " " ++ U32.show(i) ++ "\n" ++ nb_ctr_ids(t, U32.inc(i))

# Module: src/back/native/tables.bend:108
@unsafe
def nb_frame_results(+f: N_Frame, +n: U32) -> U32:
  match f:
    case N_Direct{}: 0
    case N_Frame{+pop, +at}: U32.sub(n, nt_count(String, at))

# Module: src/back/native/tables.bend:114
@unsafe
def nb_arities_go(ss: List<&2, N_Segment>, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "1, 2"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_arities_go(t, acc ++ U32.show(nt_count(N_Param, ps)) ++ ", ")

# Module: src/back/native/tables.bend:120
@unsafe
def nb_arities(ss: List<&2, N_Segment>) -> String:
  nb_arities_go(ss, "")

# Module: src/back/native/tables.bend:124
@unsafe
def nb_result_words_go(ss: List<&2, N_Segment>, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "0, 0"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_result_words_go(t, acc ++ U32.show(nb_frame_results(f, nt_count(N_Param, ps))) ++ ", ")

# Module: src/back/native/tables.bend:130
@unsafe
def nb_result_words(ss: List<&2, N_Segment>) -> String:
  nb_result_words_go(ss, "")

# Module: src/back/native/tables.bend:134
@unsafe
def nb_contains(+xs: List<&2, String>, +k: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{+h, +t}: String.eq(h, k) || nb_contains(t, k)

# Module: src/back/native/tables.bend:140
@unsafe
def nb_fork_roots_go(ss: List<&2, N_Segment>, +acc: List<&2, String>) -> List<&2, String>:
  match ss:
    case Nil{}: acc
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_fork_roots_go(t, nt_choose(List<&2, String>, fork, u => Con{k, acc}, u => acc))

# Module: src/back/native/tables.bend:146
@unsafe
def nb_fork_roots(ss: List<&2, N_Segment>) -> List<&2, String>:
  nb_fork_roots_go(ss, Nil{})

# Module: src/back/native/tables.bend:150
@unsafe
def nb_reaches(+xs: List<&2, String>, +roots: List<&2, String>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{+h, +t}: nb_contains(roots, h) || nb_reaches(t, roots)

# Module: src/back/native/tables.bend:156
@unsafe
def nb_fork_step(+ss: List<&2, N_Segment>, +roots: List<&2, String>) -> List<&2, String>:
  match ss:
    case Nil{}: roots
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, +t}:
      nb_fork_step(t, nt_choose(List<&2, String>, fork, u => roots, u => nt_choose(List<&2, String>, Bool.not(nb_contains(roots, k)) && nb_reaches(refs, roots), u => Con{k, roots}, u => roots)))

# Module: src/back/native/tables.bend:170
@unsafe
def nb_fork_close(+ss: List<&2, N_Segment>, +roots: List<&2, String>, +fuel: U32) -> List<&2, String>:
  match fuel:
    case 0: roots
    case _: nb_fork_next(ss, roots, nb_fork_step(ss, roots), U32.sub(fuel, 1))

# Module: src/back/native/tables.bend:176
@unsafe
def nb_fork_next(ss, roots, next, fuel):
  nt_choose(List<&2, String>, U32.is_eq(nt_count(String, roots), nt_count(String, next)), u => next, u => nb_fork_close(ss, next, fuel))

# Module: src/back/native/tables.bend:180
@unsafe
def nb_flags_go(ss: List<&2, N_Segment>, +forks: List<&2, String>, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "2, 0"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}:
      nb_flags_go(t, forks, acc ++ U32.show(U32.add(nt_bool(bang), U32.mul(2, nt_bool(nt_choose(Bool, fork, u => False{}, u => Bool.not(nb_contains(forks, k))))))) ++ ", ")

# Module: src/back/native/tables.bend:187
@unsafe
def nb_flags(ss: List<&2, N_Segment>, forks: List<&2, String>) -> String:
  nb_flags_go(ss, forks, "")

# Module: src/back/native/tables.bend:191
@unsafe
def nb_ctr_arity(+cs: List<&2, N_Constructor>) -> String:
  match cs:
    case Nil{}: "0"
    case Con{N_Constructor{+k, +a, +h}, +t}: U32.show(a) ++ ", " ++ nb_ctr_arity(t)

# Module: src/back/native/tables.bend:197
@unsafe
def nb_ctr_hot(+cs: List<&2, N_Constructor>) -> String:
  match cs:
    case Nil{}: "0"
    case Con{N_Constructor{+k, +a, +h}, +t}: U32.show(nt_bool(h)) ++ ", " ++ nb_ctr_hot(t)

# Module: src/back/native/tables.bend:203
@unsafe
def nb_dispatch_go(ss: List<&2, N_Segment>, +acc: String) -> String:
  match ss:
    case Nil{}: acc ++ "WL_X(FID_IO_EMIT) WL_X(FID_CLO_APPLY) WL_X(FID_EXIT)"
    case Con{N_Segment{+k, +ps, +r, +f, +b, +refs, +h, +s, +fork, +bang}, t}: nb_dispatch_go(t, acc ++ "WL_X(" ++ nt_fid(k) ++ ") ")

# Module: src/back/native/tables.bend:209
@unsafe
def nb_dispatch(ss: List<&2, N_Segment>) -> String:
  nb_dispatch_go(ss, "")

# Module: src/back/native/tables.bend:213
@unsafe
def nb_emit(+ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, +image_size: U32, +pure: Bool) -> String:
  nb_seg_ids(ss, 0) ++ nb_ctr_ids(cs, 0) ++ nb_bank(ss)
    ++ "CONSTV u8 FID_ARITY_T[] = { " ++ nb_arities(ss) ++ " };\n"
    ++ "CONSTV u8 FID_FLAG_T[] = { " ++ nb_flags(ss, nb_fork_close(ss, nb_fork_roots(ss), nt_count(N_Segment, ss))) ++ " };\n"
    ++ "CONSTV u8 FID_RESW_T[] = { " ++ nb_result_words(ss) ++ " };\n"
    ++ "CONSTV u8 CID_ARITY_T[] = { " ++ nb_ctr_arity(cs) ++ " };\n"
    ++ "CONSTV u8 CID_HOT_T[] = { " ++ nb_ctr_hot(cs) ++ " };\n"
    ++ "#define STAT_LEN " ++ U32.show(image_size) ++ "\n#define WL_TABLE " ++ nb_dispatch(ss)
    ++ "\n#define MAIN_FID FID_MAIN\n#define MAIN_PURE " ++ U32.show(nt_bool(pure)) ++ "\n"

# Module: src/back/native/emit.bend:2
@unsafe
def ne_stores(+base: String, +ws: List<&2, String>, +i: U32, +seal: Bool) -> String:
  match ws:
    case Nil{}: ""
    case Con{+h, +t}: "e.mem[" ++ base ++ " + " ++ U32.show(i) ++ "] = " ++ nt_choose(String, seal, u => "rfc_seal(e, " ++ h ++ ")", u => h) ++ ";\n" ++ ne_stores(base, t, U32.inc(i), seal)

# Module: src/back/native/emit.bend:8
@unsafe
def ne_node(+prefix: String, +alloc: String, +ws: List<&2, String>, +n: U32, +seal: Bool) -> N_Emitted:
  +name = nt_local(prefix, n)
  N_Emitted{"u64 " ++ name ++ " = " ++ alloc ++ ";\n" ++ ne_stores(name, ws, 0, seal), name, U32.inc(n)}

# Module: src/back/native/emit.bend:13
@unsafe
def ne_wrap_ctor(+k: String, +x: N_Emitted) -> N_Emitted:
  match x:
    case N_Emitted{+code, +value, +n}: N_Emitted{code, "term_ctr(" ++ nt_cid(k) ++ ", " ++ value ++ ")", n}

# Module: src/back/native/emit.bend:18
@unsafe
def ne_constructor(+k: String, +ws: List<&2, String>, +packed: Bool, +n: U32, +hot: Bool) -> N_Emitted:
  match ws:
    case Nil{}: N_Emitted{"", "term_pak(" ++ nt_cid(k) ++ ", 0)", n}
    case Con{+h, +t}:
      nt_choose(N_Emitted, packed,
        u => N_Emitted{"", "term_pak(" ++ nt_cid(k) ++ ", " ++ h ++ ")", n},
        u => ne_wrap_ctor(k, ne_node("nd", "heap_alloc(e, cls_fit(" ++ U32.show(nt_count(String, ws)) ++ "))", ws, n, hot)))

# Module: src/back/native/emit.bend:27
@unsafe
def ne_closure_wrap(+k: String, +x: N_Emitted) -> N_Emitted:
  match x:
    case N_Emitted{+code, +value, +n}: N_Emitted{code, "term_clo(" ++ nt_fid(k) ++ ", " ++ value ++ ")", n}

# Module: src/back/native/emit.bend:32
@unsafe
def ne_closure(+k: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match ws:
    case Nil{}: N_Emitted{"", "term_clo(" ++ nt_fid(k) ++ ", 0)", n}
    case Con{+h, +t}: ne_closure_wrap(k, ne_node("cl", "heap_alloc(e, cls_fit(" ++ U32.show(nt_count(String, ws)) ++ "))", ws, n, False{}))

# Module: src/back/native/emit.bend:38
@unsafe
def ne_frame_stores(+ws: List<&2, String>, +i: U32) -> String:
  match ws:
    case Nil{}: ""
    case Con{+h, +t}: "STK(" ++ U32.show(i) ++ ") = " ++ h ++ ";\n" ++ ne_frame_stores(t, U32.inc(i))

# Module: src/back/native/emit.bend:44
@unsafe
def ne_frame(+ws: List<&2, String>, +next: String) -> String:
  +n = U32.inc(nt_count(String, ws))
  "WL_ROOM(" ++ U32.show(n) ++ ");\n" ++ ne_frame_stores(List.append(&2, String, ws, Con{nt_fid(next), Nil{}}), 0) ++ "WL_PUSHN(" ++ U32.show(n) ++ ");\n"

# Module: src/back/native/emit.bend:49
@unsafe
def ne_registers(+ws: List<&2, String>, +i: U32) -> String:
  match ws:
    case Nil{}: ""
    case Con{+h, +t}: "r" ++ U32.show(i) ++ " = " ++ h ++ ";\n" ++ ne_registers(t, U32.inc(i))

# Module: src/back/native/emit.bend:55
@unsafe
def ne_jump(+ws: List<&2, String>, +k: String) -> String:
  ne_registers(ws, 0) ++ "WL_JMP(" ++ nt_fid(k) ++ ");\n"

# Module: src/back/native/emit.bend:59
@unsafe
def ne_ret(+ws: List<&2, String>) -> String:
  ne_registers(ws, 0) ++ "WL_RETN(" ++ U32.show(nt_count(String, ws)) ++ ");\n"

# Module: src/back/native/emit.bend:63
@unsafe
def ne_task(+k: String, +rem: U32, +ws: List<&2, String>, +cont: String, +idx: String, +n: U32) -> N_Emitted:
  ne_node("task", "task_node(e, " ++ nt_fid(k) ++ ", " ++ cont ++ ", " ++ idx ++ ", " ++ U32.show(rem) ++ ")", ws, n, False{})

# Module: src/back/native/emit.bend:67
@unsafe
def ne_take_params(+ps: List<&2, N_Param>, +slots: List<&2, String>, +i: U32) -> String:
  match ps, slots:
    case Nil{}, _: ""
    case Con{N_Param{+name, +kind}, +t}, Nil{}: "    " ++ nl_c_type(kind) ++ " " ++ name ++ " = r" ++ U32.show(i) ++ ";\n" ++ ne_take_params(t, Nil{}, U32.inc(i))
    case Con{N_Param{+name, +kind}, +t}, Con{+at, +rest}: "    " ++ nl_c_type(kind) ++ " " ++ name ++ " = STK(" ++ at ++ ");\n" ++ ne_take_params(t, rest, i)

# Module: src/back/native/emit.bend:74
@unsafe
def ne_take(+ps: List<&2, N_Param>, +f: N_Frame) -> String:
  match f:
    case N_Direct{}: ne_take_params(ps, Nil{}, 0)
    case N_Frame{+pop, +at}: nt_choose(String, U32.is_eq(pop, 0), u => "", u => "    WL_POPN(" ++ U32.show(pop) ++ ");\n") ++ ne_take_params(ps, at, 0)

# Module: src/back/native/emit.bend:80
@unsafe
def ne_segment(+seg: N_Segment) -> String:
  match seg:
    case N_Segment{+k, +ps, +r, +f, +body, +refs, +host, +spin, +fork, +bang}:
      nt_choose(String, host, u => "#if !DEVICE\n", u => "")
        ++ "  WL_CASE(" ++ nt_fid(k) ++ ")\n  {\n" ++ ne_take(ps, f) ++ "    WL_OPEN\n"
        ++ nt_choose(String, spin, u => "    WL_SPIN\n", u => "")
        ++ nt_indent(body) ++ "\n"
        ++ nt_choose(String, spin, u => "    WL_SPUN\n", u => "") ++ "  }}\n"
        ++ nt_choose(String, host, u => "#endif\n", u => "")

# Module: src/back/native/emit.bend:91
@unsafe
def ne_segments_go(ss: List<&2, N_Segment>, acc: String) -> String:
  match ss:
    case Nil{}: acc
    case Con{h, t}: ne_segments_go(t, acc ++ ne_segment(h) ++ "\n")

# Module: src/back/native/emit.bend:97
@unsafe
def ne_segments(+ss: List<&2, N_Segment>) -> String:
  ne_segments_go(ss, "")

# Module: src/back/native/emit.bend:101
@unsafe
def ne_fill(+src: String, +mark: String, +text: String) -> String:
  nt_replace(src, mark, mark ++ "\n\n" ++ text)

# Module: src/back/native/emit.bend:105
@unsafe
def ne_program(+src: String, +p: N_Program) -> String:
  match p:
    case N_Program{+ss, +cs, +image, +requests, +decls, +show, +pure}:
      a = ne_fill(src, "// Tables\n// ======", nb_emit(ss, cs, nt_count(String, image), pure) ++ show)
      b = ne_fill(a, "// Spins\n// =====", "CONSTV u64 STAT_IMG[] = { " ++ nt_choose(String, U32.is_eq(nt_count(String, image), 0), u => "0", u => nt_join(image, ", ")) ++ " };\n" ++ decls)
      c = ne_fill(b, "// Segments\n// ========", ne_segments(ss))
      ne_fill(c, "// Requests\n// ========", requests)

# Module: src/back/native/erase.bend:21
@unsafe
def nc_tele_fill(+book: List<&2, KDef>, +tel: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: tel
    case Con{h, rest}: nc_tele_fill(book, subst(kid(wnf(book, tel), 1), ix(wnf(book, tel)), h), rest)

# Module: src/back/native/erase.bend:27
@unsafe
def nc_live_count(+book: List<&2, KDef>, +tel: KTerm, +left: U32) -> U32:
  nt_choose(U32, U32.is_eq(left, 0), u => 0, u => U32.add(nt_bool(Bool.not(U32.is_eq(qt(wnf(book, tel)), 0))), nc_live_count(book, kid(wnf(book, tel), 1), U32.sub(left, 1))))

# Module: src/back/native/erase.bend:31
@unsafe
def nc_erase_args(book, tel, xs):
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      nt_choose(List<&2, KTerm>, U32.is_eq(qt(wnf(book, tel)), 0),
        u => nc_erase_args(book, subst(kid(wnf(book, tel), 1), ix(wnf(book, tel)), h), rest),
        u => Con{nc_erase(book, h), nc_erase_args(book, subst(kid(wnf(book, tel), 1), ix(wnf(book, tel)), h), rest)})

# Module: src/back/native/erase.bend:40
@unsafe
def nc_erase_mat(+book: List<&2, KDef>, +t: KTerm, +adt: KTerm) -> KTerm:
  +ctr = lookup(dc(lookup(book, nm(adt))), nm(t))
  +count = nc_live_count(book, nc_tele_fill(book, dt(ctr), ks(adt)), da(ctr))
  kt("Mat", nt_choose(String, db(lookup(book, nm(adt))), u => nm(t), u => nc_ctor_identity(book, nm(t))), U32.inc(count), qt(t), nc_erase_list(book, ks(t)))

# Module: src/back/native/erase.bend:46
@unsafe
def nc_erase_annotated(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(ty), "Eql"), u => atom("Rfl"), u =>
  nt_choose(KTerm, String.eq(tg(t), "Ctr"),
    u => kt("Ctr", nt_choose(String, db(lookup(book, nm(ty))), u => nm(t), u => nc_ctor_identity(book, nm(t))), ix(t), qt(t), nc_erase_args(book, nc_tele_fill(book, dt(lookup(dc(lookup(book, nm(ty))), nm(t))), ks(ty)), ks(t))),
    u => nt_choose(KTerm, String.eq(tg(t), "Mat"),
      u => nc_erase_mat(book, t, wnf(book, kid(ty, 0))),
      u => nc_erase(book, t))))

# Module: src/back/native/erase.bend:55
@unsafe
def nc_erase_list(book, ts):
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nc_erase(book, h), nc_erase_list(book, rest)}

# Module: src/back/native/erase.bend:61
@unsafe
def nc_erase_app(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(kid(t, 0)), "Ann"),
    u => nt_choose(KTerm, U32.is_eq(qt(wnf(book, kid(kid(t, 0), 1))), 0), u => nc_erase(book, kid(t, 0)), u => kt(tg(t), nm(t), ix(t), qt(t), nc_erase_list(book, ks(t)))),
    u => kt(tg(t), nm(t), ix(t), qt(t), nc_erase_list(book, ks(t))))

# Module: src/back/native/erase.bend:67
@unsafe
def nc_erase(book, t):
  nt_choose(KTerm, String.eq(tg(t), "Var"), u => var(nm(t), ix(t)), u =>
  nt_choose(KTerm, String.eq(tg(t), "Ann"), u => nc_erase_annotated(book, kid(t, 0), wnf(book, kid(t, 1))), u =>
  nt_choose(KTerm, String.eq(tg(t), "Lam") && U32.is_eq(qt(t), 0), u => nc_erase(book, kid(t, 0)), u =>
  nt_choose(KTerm, String.eq(tg(t), "App"), u => nc_erase_app(book, t), u =>
    kt(tg(t), nt_choose(String, String.eq(tg(t), "Ctr") || String.eq(tg(t), "Mat"), u => nc_ctor_identity(book, nm(t)), u => nm(t)), ix(t), qt(t), nc_erase_list(book, ks(t)))))))

# Module: src/back/native/bridge.bend:22
@unsafe
def nc_word(+id: U32, +env: List<&2, NC_Binding>) -> String:
  match env:
    case Nil{}: "NATIVE_UNBOUND_VARIABLE"
    case Con{NC_Binding{+at, +word}, +rest}:
      nt_choose(String, U32.is_eq(id, at), u => word, u => nc_word(id, rest))

# Module: src/back/native/bridge.bend:29
@unsafe
def nc_words(+env: List<&2, NC_Binding>) -> List<&2, String>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word}, +rest}: Con{word, nc_words(rest)}

# Module: src/back/native/bridge.bend:35
@unsafe
def nc_params(+env: List<&2, NC_Binding>) -> List<&2, N_Param>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word}, +rest}: Con{N_Param{word, N_W64{}}, nc_params(rest)}

# Module: src/back/native/bridge.bend:41
@unsafe
def nc_slots(+env: List<&2, NC_Binding>, +i: U32) -> List<&2, String>:
  match env:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{U32.show(i), nc_slots(rest, U32.inc(i))}

# Module: src/back/native/bridge.bend:47
@unsafe
def nc_body(+x: NC_Code) -> String:
  match x:
    case NC_Code{+body, +segs, +n, +err}: body

# Module: src/back/native/bridge.bend:52
@unsafe
def nc_segs(+x: NC_Code) -> List<&2, N_Segment>:
  match x:
    case NC_Code{+body, +segs, +n, +err}: segs

# Module: src/back/native/bridge.bend:57
@unsafe
def nc_fresh(+x: NC_Code) -> U32:
  match x:
    case NC_Code{+body, +segs, +n, +err}: n

# Module: src/back/native/bridge.bend:62
@unsafe
def nc_error(+x: NC_Code) -> String:
  match x:
    case NC_Code{+body, +segs, +n, +err}: err

# Module: src/back/native/bridge.bend:67
@unsafe
def nc_first_error(+a: NC_Code, +b: NC_Code) -> String:
  nt_choose(String, String.eq(nc_error(a), ""), u => nc_error(b), u => nc_error(a))

# Module: src/back/native/bridge.bend:71
@unsafe
def nc_return(+w: String, +n: U32) -> NC_Code:
  NC_Code{ne_ret([w]), Nil{}, n, ""}

# Module: src/back/native/bridge.bend:75
@unsafe
def nc_fail(+msg: String, +n: U32) -> NC_Code:
  NC_Code{"", Nil{}, n, msg}

# Module: src/back/native/bridge.bend:79
@unsafe
def nc_name(+n: U32) -> String:
  "native_k_" ++ U32.show(n)

# Module: src/back/native/bridge.bend:83
@unsafe
def nc_id(+n: U32) -> U32:
  U32.sub(4294967295, n)

# Module: src/back/native/bridge.bend:87
@unsafe
def nc_binding(+id: U32) -> NC_Binding:
  NC_Binding{id, "v_" ++ U32.show(id)}

# Module: src/back/native/bridge.bend:91
@unsafe
def nc_cut_task(+next: String, +ws: List<&2, String>, emitted: N_Emitted) -> String:
  match emitted:
    case N_Emitted{code, word, n}:
      code ++ "WL_CONT = term_tsk(" ++ nt_fid(next) ++ ", " ++ word ++ ");\nWL_IDX = " ++ U32.show(nt_count(String, ws)) ++ ";\n"

# Module: src/back/native/bridge.bend:97
@unsafe
def nc_cut(+ws: List<&2, String>, +next: String, +n: U32) -> String:
  "if (seq) {\n" ++ ne_frame(ws, next) ++ "} else {\n" ++ nc_cut_task(next, ws, ne_task(next, 1, ws, "WL_CONT", "WL_IDX", n)) ++ "}\n"

# Module: src/back/native/bridge.bend:118
@unsafe
def nc_occurs_list(ts, id):
  match ts:
    case Nil{}: False{}
    case Con{h, t}: nc_occurs(h, id) || nc_occurs_list(t, id)

# Module: src/back/native/bridge.bend:124
@unsafe
def nc_occurs(t, id):
  nt_choose(Bool, String.eq(tg(t), "Var"), u => U32.is_eq(ix(t), id), u => nc_occurs_list(ks(t), id))

# Module: src/back/native/bridge.bend:128
@unsafe
def nc_live_env(env: List<&2, NC_Binding>, +t: KTerm) -> List<&2, NC_Binding>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word}, +rest}:
      nt_choose(List<&2, NC_Binding>, nc_occurs(t, id), u => Con{NC_Binding{id, word}, nc_live_env(rest, t)}, u => nc_live_env(rest, t))

# Module: src/back/native/bridge.bend:135
@unsafe
def nc_remove_env(env: List<&2, NC_Binding>, +id: U32) -> List<&2, NC_Binding>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+at, +word}, +rest}:
      nt_choose(List<&2, NC_Binding>, U32.is_eq(at, id), u => rest, u => Con{NC_Binding{at, word}, nc_remove_env(rest, id)})

# Module: src/back/native/bridge.bend:142
@unsafe
def nc_drop_dead(env: List<&2, NC_Binding>, +t: KTerm) -> String:
  match env:
    case Nil{}: ""
    case Con{NC_Binding{+id, +word}, rest}:
      nt_choose(String, nc_occurs(t, id), u => "", u => "term_sink(e, " ++ word ++ ");\n") ++ nc_drop_dead(rest, t)

# Module: src/back/native/bridge.bend:149
@unsafe
def nc_share_env(env: List<&2, NC_Binding>, +a: KTerm, +b: KTerm) -> String:
  match env:
    case Nil{}: ""
    case Con{NC_Binding{+id, +word}, rest}:
      nt_choose(String, nc_occurs(a, id) && nc_occurs(b, id), u => word ++ " = term_keep(e, " ++ word ++ ");\n", u => "") ++ nc_share_env(rest, a, b)

# Module: src/back/native/bridge.bend:156
@unsafe
def nc_prepend(code: String, x: NC_Code) -> NC_Code:
  match x:
    case NC_Code{body, segs, fresh, err}: NC_Code{code ++ body, segs, fresh, err}

# Module: src/back/native/bridge.bend:161
@unsafe
def nc_lower(book, t, env, n):
  nc_prepend(nc_drop_dead(env, t), nc_lower_live(book, t, nc_live_env(env, t), n))

# Module: src/back/native/bridge.bend:165
@unsafe
def nc_let(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> NC_Code:
  +next = nc_name(n)
  +held = nc_live_env(env, body)
  +newenv = List.append(&2, NC_Binding, held, [nc_binding(id)])
  +rest = nc_lower(book, body, newenv, U32.inc(n))
  +val = nc_lower(book, value, nc_live_env(env, value), nc_fresh(rest))
  +seg : N_Segment = N_Segment{next, nc_params(newenv), 1, N_Frame{nt_count(NC_Binding, held), nc_slots(held, 0)}, nc_body(rest), Nil{}, False{}, False{}, False{}, False{}}
  NC_Code{nc_share_env(env, value, body) ++ nc_cut(nc_words(held), next, nc_fresh(val)) ++ nc_body(val), Con{seg, nt_append(N_Segment, nc_segs(rest), nc_segs(val))}, nc_fresh(val), nc_first_error(rest, val)}

# Module: src/back/native/bridge.bend:175
@unsafe
def nc_closure_result(+s: N_Segment, +body: NC_Code, +emitted: N_Emitted) -> NC_Code:
  match emitted:
    case N_Emitted{+code, +word, +fresh}:
      NC_Code{code ++ ne_ret([word]), Con{s, nc_segs(body)}, fresh, nc_error(body)}

# Module: src/back/native/bridge.bend:181
@unsafe
def nc_lambda(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  +name = nc_name(n)
  +params = List.append(&2, NC_Binding, env, [nc_binding(ix(t))])
  +body = nc_lower(book, kid(t, 0), params, U32.inc(n))
  +s : N_Segment = N_Segment{name, nc_params(params), 1, N_Direct{}, nc_body(body), Nil{}, False{}, False{}, False{}, False{}}
  nc_closure_result(s, body, ne_closure(name, nc_words(env), nc_fresh(body)))

# Module: src/back/native/bridge.bend:189
@unsafe
def nc_mklet(+id: U32, +val: KTerm, +body: KTerm) -> KTerm:
  kt("Let", "", 0, 0, [kt("Bind", "", id, 1, [val]), body])

# Module: src/back/native/bridge.bend:193
@unsafe
def nc_app_slow(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  +f = nc_id(n)
  +a = nc_id(U32.inc(n))
  nc_lower(book, nc_mklet(f, kid(t, 0), nc_mklet(a, kid(t, 1), kt("NApply", "", 0, 0, [var("", f), var("", a)]))), env, U32.add(n, 2))

# Module: src/back/native/bridge.bend:199
@unsafe
def nc_values(+xs: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> List<&2, String>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, +t}: Con{nc_word(ix(h), env), nc_values(t, env)}

# Module: src/back/native/bridge.bend:205
@unsafe
def nc_sequence(+tag: String, +name: String, +xs: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32) -> KTerm:
  match xs:
    case Nil{}: kt(tag, name, 0, 0, List.reverse(&2, KTerm, acc))
    case Con{+h, +t}: nc_mklet(nc_id(n), h, nc_sequence(tag, name, t, Con{var("", nc_id(n)), acc}, U32.inc(n)))

# Module: src/back/native/bridge.bend:211
@unsafe
def nc_head(+xs: List<&2, String>) -> String:
  match xs:
    case Nil{}: "0"
    case Con{+h, +t}: h

# Module: src/back/native/bridge.bend:217
@unsafe
def nc_tail(+xs: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, +t}: t

# Module: src/back/native/bridge.bend:223
@unsafe
def nc_ctor_result(+x: N_Emitted) -> NC_Code:
  match x:
    case N_Emitted{+code, +word, +n}: NC_Code{code ++ ne_ret([word]), Nil{}, n, ""}

# Module: src/back/native/bridge.bend:228
@unsafe
def nc_constructor(+name: String, +ws: List<&2, String>, +n: U32) -> NC_Code:
  nt_choose(NC_Code, String.eq(name, "Zero") || String.eq(name, "False"), u => nc_return("0", n), u =>
  nt_choose(NC_Code, String.eq(name, "True"), u => nc_return("1", n), u =>
  nt_choose(NC_Code, String.eq(name, "Succ"), u => nc_return("nat_chk(e, " ++ nc_head(ws) ++ " + 1)", n), u =>
  nt_choose(NC_Code, String.eq(name, "U32") || String.eq(name, "F32"), u => nc_return("term_word(e, " ++ nc_head(ws) ++ ")", n), u =>
  nt_choose(NC_Code, String.eq(name, "Chr"), u => nc_return(nc_head(ws), n), u =>
  nt_choose(NC_Code, String.eq(name, "ALeaf"), u => NC_Code{"Term init[1] = { " ++ nc_head(ws) ++ " };\n" ++ ne_ret(["blk_new(e, 1, 0, 0, 1, init)"]), Nil{}, n, ""}, u =>
  nt_choose(NC_Code, String.eq(name, "ANode"), u => nc_return("blk_node(e, " ++ nc_head(ws) ++ ", " ++ nc_head(nc_tail(ws)) ++ ")", n), u =>
  nc_ctor_result(ne_constructor(name, ws, False{}, n, True{})))))))))

# Module: src/back/native/bridge.bend:239
@unsafe
def nc_lets(+book: List<&2, KDef>, +xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  match xs:
    case Nil{}: nc_fail("empty native let", n)
    case Con{+h, Nil{}}: nc_lower(book, h, env, n)
    case Con{+h, +t}: nc_let(book, kid(h, 0), kt("NSeqLet", "", 0, 0, t), env, ix(h), n)

# Module: src/back/native/bridge.bend:246
@unsafe
def nc_find_ctor(+book: List<&2, KDef>, +name: String) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{+d, +rest}:
      nt_choose(KDef, String.eq(dn(d), name) && String.eq(dk(d), "Ctr"), u => d, u =>
        nt_choose(KDef, String.eq(dk(nc_find_ctor(dc(d), name)), "Absent"), u => nc_find_ctor(rest, name), u => nc_find_ctor(dc(d), name)))

# Module: src/back/native/bridge.bend:254
@unsafe
def nc_field_count(+book: List<&2, KDef>, +name: String) -> U32:
  nt_choose(U32, String.eq(name, "Succ") || String.eq(name, "Chr") || String.eq(name, "U32") || String.eq(name, "F32"), u => 1, u =>
    nt_choose(U32, String.eq(name, "Zero") || String.eq(name, "True") || String.eq(name, "False"), u => 0, u => da(nc_find_ctor(book, nc_ctor_display(name)))))

# Module: src/back/native/bridge.bend:259
@unsafe
def nc_condition(+name: String, +word: String) -> String:
  nt_choose(String, String.eq(name, "False"), u => "(!native_bool(" ++ word ++ "))", u =>
  nt_choose(String, String.eq(name, "True"), u => "native_bool(" ++ word ++ ")", u =>
  nt_choose(String, String.eq(name, "Zero"), u => "(" ++ word ++ " == 0)", u =>
  nt_choose(String, String.eq(name, "Succ"), u => "(" ++ word ++ " != 0)", u =>
  nt_choose(String, String.eq(name, "Chr") || String.eq(name, "U32") || String.eq(name, "F32"), u => "1", u =>
  nt_choose(String, String.eq(name, "ALeaf"), u => "(blk_cls(" ++ word ++ ") == 0)", u =>
  nt_choose(String, String.eq(name, "ANode"), u => "(blk_cls(" ++ word ++ ") != 0)", u =>
    "(term_aux(" ++ word ++ ") == " ++ nt_cid(name) ++ ")")))))))

# Module: src/back/native/bridge.bend:270
@unsafe
def nc_field_word(+name: String, +word: String, +i: U32) -> String:
  nt_choose(String, String.eq(name, "Succ"), u => "(" ++ word ++ " - 1)", u =>
  nt_choose(String, String.eq(name, "Chr"), u => word, u =>
  nt_choose(String, String.eq(name, "U32") || String.eq(name, "F32"), u => "native_word(e, (u32)" ++ word ++ ")", u =>
  nt_choose(String, String.eq(name, "ALeaf"), u => "blk_read(e.mem, 1, term_loc(" ++ word ++ "), 0)", u =>
  nt_choose(String, String.eq(name, "ANode"), u => "blk_half(e, " ++ word ++ ", " ++ U32.show(i) ++ ")", u =>
    "e.mem[term_peek(e, " ++ word ++ ") + " ++ U32.show(i) ++ "]")))))

# Module: src/back/native/bridge.bend:279
@unsafe
def nc_field_env(+name: String, +word: String, +count: U32, +i: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(i, count), u => Nil{}, u =>
    Con{nc_binding(nc_id(U32.add(n, i))), nc_field_env(name, word, count, U32.inc(i), n)})

# Module: src/back/native/bridge.bend:284
@unsafe
def nc_field_apps(+term: KTerm, +count: U32, +i: U32, +n: U32) -> KTerm:
  nt_choose(KTerm, U32.is_eq(i, count), u => term, u =>
    nc_field_apps(app(term, var("", nc_id(U32.add(n, i)))), count, U32.inc(i), n))

# Module: src/back/native/bridge.bend:289
@unsafe
def nc_field_decls(+name: String, +word: String, +count: U32, +i: U32, +n: U32, +boxed: Bool) -> String:
  nt_choose(String, U32.is_eq(i, count), u => "", u =>
    "Term v_" ++ U32.show(nc_id(U32.add(n, i))) ++ " = " ++ nt_choose(String, boxed, u => "fields[" ++ U32.show(i) ++ "]", u => nc_field_word(name, word, i)) ++ ";\n" ++ nc_field_decls(name, word, count, U32.inc(i), n, boxed))

# Module: src/back/native/bridge.bend:294
@unsafe
def nc_destructure(+name: String, +word: String, +count: U32, +n: U32) -> String:
  +boxed = Bool.not(String.eq(name, "Succ") || String.eq(name, "Zero") || String.eq(name, "True") || String.eq(name, "False") || String.eq(name, "Chr") || String.eq(name, "U32") || String.eq(name, "F32") || String.eq(name, "ALeaf") || String.eq(name, "ANode")) && U32.is_gt(count, 0)
  nt_choose(String, boxed,
    u => "Term fields[" ++ U32.show(count) ++ "];\n" ++ nt_choose(String, U32.is_eq(count, 1), u => "if (term_tag(" ++ word ++ ") == TAG_PAK) { fields[0] = term_loc(" ++ word ++ "); } else {\n", u => "") ++ "spare_free(e, cls_fit(" ++ U32.show(count) ++ "), ctr_take(e, " ++ word ++ ", " ++ U32.show(count) ++ ", fields));\n" ++ nt_choose(String, U32.is_eq(count, 1), u => "}\n", u => ""),
    u => "") ++ nc_field_decls(name, word, count, 0, n, boxed) ++ nt_choose(String, String.eq(name, "ALeaf"), u => "blk_free(e, " ++ word ++ ");\n", u => "")

# Module: src/back/native/bridge.bend:308
@unsafe
def nc_match_apply(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  nt_choose(NC_Code, np_can_match(kid(t, 0)), u => np_match_apply(book, t, env, n), u => nc_match_apply_slow(book, t, env, n))

# Module: src/back/native/bridge.bend:312
@unsafe
def nc_match_apply_slow(book, t, env, n):
  +mat = kid(t, 0)
  +arg = kid(t, 1)
  +word = nc_word(ix(arg), env)
  +count = nt_choose(U32, U32.is_eq(ix(mat), 0), u => nc_field_count(book, nm(mat)), u => U32.sub(ix(mat), 1))
  +hit = nc_lower(book, nc_field_apps(kid(mat, 0), count, 0, n), List.append(&2, NC_Binding, nc_remove_env(env, ix(arg)), nc_field_env(nm(mat), word, count, 0, n)), U32.add(n, count))
  +miss = nc_lower(book, app(kid(mat, 1), arg), env, nc_fresh(hit))
  +guard = nt_choose(String, String.eq(nm(mat), "Emit") || String.eq(nm(mat), "Halt"), u => "if (term_aux(" ++ word ++ ") != CID_EMIT && term_aux(" ++ word ++ ") != CID_HALT) { err_post(e.mem, ERR_TAGS); return 0; }\n", u => "")
  NC_Code{guard ++ "if (" ++ nc_condition(nm(mat), word) ++ ") {\n" ++ nc_destructure(nm(mat), word, count, n) ++ nc_body(hit) ++ "} else {\n" ++ nc_body(miss) ++ "}\n", nt_append(N_Segment, nc_segs(hit), nc_segs(miss)), nc_fresh(miss), nc_first_error(hit, miss)}

# Module: src/back/native/bridge.bend:323
@unsafe
def nc_match(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  nc_lambda(book, kt("Lam", "", nc_id(n), 1, [kt("NMatch", "", 0, 0, [t, var("", nc_id(n))])]), env, U32.inc(n))

# Module: src/back/native/bridge.bend:327
@unsafe
def nc_primitive_name(k: String) -> String:
  String.to_lower(nt_clean(k))

# Module: src/back/native/bridge.bend:335
@unsafe
def nc_native_def(+d: KDef) -> Bool:
  +prim = nc_primitive_name(dn(d))
  db(d) && Bool.not(String.eq(tg(nc_unann(dv(d))), "Foreign")) && (Bool.not(String.eq(ni_find(prim, ni_templates()), "")) || nc_array_known(prim) || String.eq(prim, "nat_divmod"))

# Module: src/back/native/bridge.bend:340
@unsafe
def nc_ref_name(+book: List<&2, KDef>, +name: String) -> String:
  nt_choose(String, nc_native_def(lookup(book, name)), u => "$native." ++ name, u => name)

# Module: src/back/native/bridge.bend:344
@unsafe
def nc_primitive_arity(+k: String) -> U32:
  +fmt = ni_find(k, ni_templates())
  nt_choose(U32, String.eq(k, "array_set") || String.eq(k, "array_swap"), u => 3, u =>
  nt_choose(U32, String.eq(k, "array_new") || String.eq(k, "array_get") || String.eq(k, "nat_divmod"), u => 2, u =>
  nt_choose(U32, String.eq(fmt, nt_replace(fmt, "$1", "?")), u => 1, u => 2)))

# Module: src/back/native/bridge.bend:351
@unsafe
def nc_prim_args(+n: U32, +i: U32) -> List<&2, KTerm>:
  nt_choose(List<&2, KTerm>, U32.is_eq(i, n), u => Nil{}, u => Con{var("", U32.add(4000000000, i)), nc_prim_args(n, U32.inc(i))})

# Module: src/back/native/bridge.bend:355
@unsafe
def nc_prim_lambdas(+k: String, +n: U32, +i: U32) -> KTerm:
  nt_choose(KTerm, U32.is_eq(i, n), u => kt("NOp", k, 0, 0, nc_prim_args(n, 0)), u => kt("Lam", "", U32.add(4000000000, i), 1, [nc_prim_lambdas(k, n, U32.inc(i))]))

# Module: src/back/native/bridge.bend:359
@unsafe
def nc_primitive_body(+k: String) -> KTerm:
  nc_prim_lambdas(k, nc_primitive_arity(k), 0)

# Module: src/back/native/bridge.bend:363
@unsafe
def nc_intrinsic(+k: String, +ws: List<&2, String>, +n: U32) -> NC_Code:
  nt_choose(NC_Code, nc_array_known(k), u => nc_array(k, ws, n), u =>
  nt_choose(NC_Code, String.eq(k, "nat_divmod"), u => nc_ctor_result(ne_constructor("Tuple", ["(" ++ nc_head(nc_tail(ws)) ++ " == 0 ? 0 : " ++ nc_head(ws) ++ " / " ++ nc_head(nc_tail(ws)) ++ ")", "(" ++ nc_head(nc_tail(ws)) ++ " == 0 ? " ++ nc_head(ws) ++ " : " ++ nc_head(ws) ++ " % " ++ nc_head(nc_tail(ws)) ++ ")"], False{}, n, True{})), u =>
  nt_choose(NC_Code, String.eq(k, "u32_cmp") || String.eq(k, "nat_cmp"), u => NC_Code{"Term cmp = " ++ ni_emit(k, ws) ++ ";\n" ++ ne_ret(["term_pak(cmp == 0 ? CID_LT : cmp == 1 ? CID_EQ : CID_GT, 0)"]), Nil{}, n, ""}, u =>
    nc_return(ni_emit(k, ws), n))))

# Module: src/back/native/bridge.bend:370
@unsafe
def nc_apply_code(+ws: List<&2, String>, +n: U32) -> NC_Code:
  NC_Code{ "{ Term fn = " ++ nc_head(ws) ++ "; Term arg = " ++ nc_head(nc_tail(ws)) ++ ";\n"
    ++ "Fid f = (Fid)term_aux(fn);\n"
    ++ "if (!seq && fid_bangs(f)) {\n  u32 war = fid_arity(f) - 1;\n  Loc src = term_loc(fn);\n  Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);\n  for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];\n  e.mem[dst + war] = arg;\n  spare_free(e, cls_fit(war), src);\n  return term_tsk(f, dst);\n}\nr0 = fn; r1 = arg; WL_JMP(FID_CLO_APPLY);\n}\n", Nil{}, n, ""}

# Module: src/back/native/bridge.bend:376
@unsafe
def nc_word_literal(+t: KTerm, +bit: U32, +value: U32) -> NC_Literal:
  nt_choose(NC_Literal, String.eq(tg(t), "Ctr") && String.eq(nm(t), "WNil"), u => NC_Literal{True{}, value}, u =>
  nt_choose(NC_Literal, String.eq(tg(t), "Ctr") && String.eq(nm(t), "WCon") && U32.is_lt(bit, 32) && String.eq(tg(kid(t, 0)), "Ctr") && (String.eq(nm(kid(t, 0)), "True") || String.eq(nm(kid(t, 0)), "False")),
    u => nc_word_literal(kid(t, 1), U32.inc(bit), U32.or(value, nt_choose(U32, String.eq(nm(kid(t, 0)), "True"), u => U32.shln(1, U32.to_nat(bit)), u => 0))),
    u => NC_Literal{False{}, 0}))

# Module: src/back/native/bridge.bend:383
@unsafe
def nc_nat_literal(+t: KTerm, +value: U32) -> NC_Literal:
  nt_choose(NC_Literal, String.eq(tg(t), "Ctr") && String.eq(nm(t), "Zero"), u => NC_Literal{True{}, value}, u =>
    nt_choose(NC_Literal, String.eq(tg(t), "Ctr") && String.eq(nm(t), "Succ"), u => nc_nat_literal(kid(t, 0), U32.inc(value)), u => NC_Literal{False{}, 0}))

# Module: src/back/native/bridge.bend:388
@unsafe
def nc_literal(+t: KTerm) -> NC_Literal:
  nt_choose(NC_Literal, String.eq(nm(t), "U32") || String.eq(nm(t), "F32"), u => nc_word_literal(kid(t, 0), 0, 0), u => nc_nat_literal(t, 0))

# Module: src/back/native/bridge.bend:399
@unsafe
def nc_compact_list(ts):
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nc_compact(h), nc_compact_list(rest)}

# Module: src/back/native/bridge.bend:405
@unsafe
def nc_compact_ctor(+t: KTerm, lit: NC_Literal) -> KTerm:
  match lit:
    case NC_Literal{valid, value}:
      nt_choose(KTerm, valid, u => kt("NWord", U32.show(value), 0, 0, Nil{}), u => kt(tg(t), nm(t), ix(t), qt(t), nc_compact_list(ks(t))))

# Module: src/back/native/bridge.bend:411
@unsafe
def nc_compact(t):
  nt_choose(KTerm, String.eq(tg(t), "Ctr"), u => nc_compact_ctor(t, nc_literal(t)), u => kt(tg(t), nm(t), ix(t), qt(t), nc_compact_list(ks(t))))

# Module: src/back/native/bridge.bend:415
@unsafe
def nc_lower_ctor(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, lit: NC_Literal) -> NC_Code:
  match lit:
    case NC_Literal{+valid, +value}:
      nt_choose(NC_Code, valid, u => nc_return(U32.show(value) ++ "ull", n), u => nc_lower(book, nc_sequence("NCtr", nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t)))))

# Module: src/back/native/bridge.bend:421
@unsafe
def nc_lower_live(book, t, env, n):
  +tag = tg(t)
  nt_choose(NC_Code, String.eq(tag, "NWord"), u => nc_return(nm(t) ++ "ull", n), u =>
  nt_choose(NC_Code, String.eq(tag, "Var"), u => nt_choose(NC_Code, String.eq(nc_word(ix(t), env), "NATIVE_UNBOUND_VARIABLE"), u => nc_fail("native unbound variable " ++ U32.show(ix(t)), n), u => nc_return(nc_word(ix(t), env), n)), u =>
  nt_choose(NC_Code, String.eq(tag, "Ref"), u => NC_Code{ne_jump(Nil{}, nc_ref_name(book, nm(t))), Nil{}, n, ""}, u =>
  nt_choose(NC_Code, String.eq(tag, "Ann") || String.eq(tag, "Loc") || String.eq(tag, "Src") || String.eq(tag, "Cut") || String.eq(tag, "Slf") || String.eq(tag, "Ins"), u => nc_lower(book, kid(t, 0), env, n), u =>
  nt_choose(NC_Code, String.eq(tag, "Lam"), u => nc_lambda(book, t, env, n), u =>
  nt_choose(NC_Code, String.eq(tag, "App"), u => nd_app(book, t, env, n), u =>
  nt_choose(NC_Code, String.eq(tag, "Let"), u => nt_choose(NC_Code, U32.is_gt(terms_len(ks(t)), 2), u => nc_parallel(book, ks(t), env, n), u => nc_lets(book, ks(t), env, n)), u =>
  nt_choose(NC_Code, String.eq(tag, "NSeqLet"), u => nc_lets(book, ks(t), env, n), u =>
  nt_choose(NC_Code, String.eq(tag, "Ctr"), u => nc_lower_ctor(book, t, env, n, nc_literal(t)), u =>
  nt_choose(NC_Code, String.eq(tag, "NCtr"), u => nc_constructor(nm(t), nc_values(ks(t), env), n), u =>
  nt_choose(NC_Code, String.eq(tag, "NApply"), u => nc_apply_code(nc_values(ks(t), env), n), u =>
  nt_choose(NC_Code, String.eq(tag, "NCall"), u => NC_Code{ne_jump(nc_values(ks(t), env), nm(t)), Nil{}, n, ""}, u =>
  nt_choose(NC_Code, String.eq(tag, "Rfl") || String.eq(tag, "Typ") || String.eq(tag, "All") || String.eq(tag, "Qua") || String.eq(tag, "ADT") || String.eq(tag, "Eql"), u => nc_return("0", n), u =>
  nt_choose(NC_Code, String.eq(tag, "Mat"), u => nc_match(book, t, env, n), u =>
  nt_choose(NC_Code, String.eq(tag, "NMatch"), u => nc_match_apply(book, t, env, n), u =>
  nt_choose(NC_Code, String.eq(tag, "NOp"), u => nc_intrinsic(nm(t), nc_values(ks(t), env), n), u =>
  nt_choose(NC_Code, String.eq(tag, "Efq"), u => NC_Code{"err_post(e.mem, ERR_FIDS); return 0;\n", Nil{}, n, ""}, u =>
  nt_choose(NC_Code, String.eq(tag, "Rwt"), u => nc_lower(book, kid(t, 2), env, n), u =>
  nc_fail("native lowering does not support core node " ++ tag, n)))))))))))))))))))

# Module: src/back/native/direct.bend:11
@unsafe
def nd_name(name: String) -> String:
  "$direct." ++ name

# Module: src/back/native/direct.bend:15
@unsafe
def nd_head(+t: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(t), "App"), u => nd_head(kid(t, 0)), u => t)

# Module: src/back/native/direct.bend:19
@unsafe
def nd_args(+t: KTerm, +acc: List<&2, KTerm>) -> List<&2, KTerm>:
  nt_choose(List<&2, KTerm>, String.eq(tg(t), "App"), u => nd_args(kid(t, 0), Con{kid(t, 1), acc}), u => acc)

# Module: src/back/native/direct.bend:23
@unsafe
def nd_leading(+t: KTerm, +n: U32) -> U32:
  nt_choose(U32, String.eq(tg(t), "Ann"), u => nd_leading(kid(t, 0), n), u =>
    nt_choose(U32, String.eq(tg(t), "Lam"), u => nd_leading(kid(t, 0), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(t), 0))))), u => n))

# Module: src/back/native/direct.bend:28
@unsafe
def nd_foreign_arity(+book: List<&2, KDef>, +ty: KTerm, +n: U32) -> U32:
  +tel = wnf(book, ty)
  nt_choose(U32, String.eq(tg(tel), "All"), u => nd_foreign_arity(book, kid(tel, 1), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(tel), 0))))), u => n)

# Module: src/back/native/direct.bend:33
@unsafe
def nd_arity(+book: List<&2, KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  nt_choose(U32, nc_native_def(d), u => nc_primitive_arity(nc_primitive_name(name)), u =>
    nt_choose(U32, String.eq(tg(nc_unann(dv(d))), "Foreign"), u => nd_foreign_arity(book, dt(d), 0), u => nd_leading(dv(d), 0)))

# Module: src/back/native/direct.bend:39
@unsafe
def nd_reapply(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{h, rest}: nd_reapply(app(head, h), rest)

# Module: src/back/native/direct.bend:45
@unsafe
def nd_beta(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{+arg, +rest}:
      nt_choose(KTerm, String.eq(tg(head), "Lam"),
        u => nt_choose(KTerm, String.eq(tg(arg), "Var"),
          u => nd_beta(subst(kid(head, 0), ix(head), arg), rest),
          u => nc_mklet(ix(head), arg, nd_beta(kid(head, 0), rest))),
        u => nd_reapply(head, Con{arg, rest}))

# Module: src/back/native/direct.bend:56
@unsafe
def nd_match(+book: List<&2, KDef>, +head: KTerm, +arg: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  nt_choose(NC_Code, String.eq(tg(arg), "Var"),
    u => nc_lower(book, kt("NMatch", "", 0, 0, [head, arg]), env, n),
    u => nc_lower(book, nc_mklet(nc_id(n), arg, kt("NMatch", "", 0, 0, [head, var("", nc_id(n))])), env, U32.inc(n)))

# Module: src/back/native/direct.bend:62
@unsafe
def nd_app(book, t, env, n):
  +head = nd_head(t)
  +args = nd_args(t, Nil{})
  nt_choose(NC_Code, String.eq(tg(head), "Lam"), u => nc_lower(book, nd_beta(head, args), env, n), u =>
    nt_choose(NC_Code, String.eq(tg(head), "Mat") && U32.is_eq(terms_len(args), 1), u => nd_match(book, head, kid(t, 1), env, n), u =>
    nt_choose(NC_Code, String.eq(tg(head), "Ref"), u =>
    nt_choose(NC_Code, Bool.not(U32.is_eq(qt(head), 3)) && U32.is_gt(terms_len(args), 0) && U32.is_eq(nd_arity(book, nm(head)), terms_len(args)),
      u => nc_lower(book, nc_sequence("NCall", nd_name(nc_ref_name(book, nm(head))), args, Nil{}, n), env, U32.add(n, terms_len(args))),
      u => nc_app_slow(book, t, env, n)), u => nc_app_slow(book, t, env, n))))

# Module: src/back/native/direct.bend:73
@unsafe
def nd_body(+t: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(t), "Lam"), u => nd_body(kid(t, 0)), u => t)

# Module: src/back/native/direct.bend:77
@unsafe
def nd_bindings(+t: KTerm, +acc: List<&2, NC_Binding>) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, String.eq(tg(t), "Lam"), u => nd_bindings(kid(t, 0), Con{nc_binding(ix(t)), acc}), u => nt_reverse(NC_Binding, acc, Nil{}))

# Module: src/back/native/direct.bend:81
@unsafe
def nd_join(+base: NC_Code, +body: NC_Code, name: String, params: List<&2, NC_Binding>) -> NC_Code:
  NC_Code{nc_body(base), nt_append(N_Segment, nc_segs(base), Con{N_Segment{nd_name(name), nc_params(params), 1, N_Direct{}, nc_body(body), Nil{}, False{}, False{}, False{}, False{}}, nc_segs(body)}), nc_fresh(body), nc_first_error(base, body)}

# Module: src/back/native/direct.bend:85
@unsafe
def nd_extend(+book: List<&2, KDef>, +body: KTerm, +base: NC_Code, +name: String) -> NC_Code:
  +params = nd_bindings(body, Nil{})
  nt_choose(NC_Code, U32.is_eq(nt_count(NC_Binding, params), 0), u => base, u =>
    nd_join(base, nc_lower(book, nd_body(body), params, nc_fresh(base)), nc_ref_name(book, name), params))

# Module: src/back/native/pattern.bend:86
@unsafe
def np_supported(term):
  String.eq(tg(term), "Mat") && ((String.eq(nm(term), "Zero") && (U32.is_eq(ix(term), 0) || U32.is_eq(ix(term), 1))) || (String.eq(nm(term), "Succ") && (U32.is_eq(ix(term), 0) || U32.is_eq(ix(term), 2))))

# Module: src/back/native/pattern.bend:89
@unsafe
def np_level(term, zero, successor, hasZero, hasSucc):
  nt_choose(NPLevel, String.eq(tg(term), "Mat"), u => np_level_mat(term, zero, successor, hasZero, hasSucc), u => NPLevel{zero, successor, term, hasZero, hasSucc, True{}})

# Module: src/back/native/pattern.bend:92
@unsafe
def np_level_mat(term, zero, successor, hasZero, hasSucc):
  nt_choose(NPLevel, np_supported(term) && String.eq(nm(term), "Zero") && Bool.not(hasZero), u => np_level(kid(term, 1), kid(term, 0), successor, True{}, hasSucc), u =>
    nt_choose(NPLevel, np_supported(term) && String.eq(nm(term), "Succ") && Bool.not(hasSucc), u => np_level(kid(term, 1), zero, kid(term, 0), hasZero, True{}), u => NPLevel{zero, successor, term, hasZero, hasSucc, False{}}))

# Module: src/back/native/pattern.bend:96
@unsafe
def np_collect(term, depth, built):
  np_collect_level(term, depth, built, np_level(term, atom("Efq"), atom("Efq"), False{}, False{}))

# Module: src/back/native/pattern.bend:99
@unsafe
def np_collect_level(term, depth, built, level):
  match level:
    case NPLevel{+zero, +successor, +fallback, +hasZero, +hasSucc, valid}:
      nt_choose(List<&2,NPRow>, valid && (hasZero || hasSucc),
        u => np_collect(nt_choose(KTerm, hasSucc, u => successor, u => fallback), nt_choose(U32, hasSucc, u => U32.inc(depth), u => depth), Con{NPRow{depth, nt_choose(KTerm, hasZero, u => zero, u => fallback), depth, Bool.not(hasZero), False{}}, built}),
        u => nt_reverse(NPRow, Con{NPRow{depth, term, depth, True{}, True{}}, built}, Nil{}))

# Module: src/back/native/pattern.bend:106
@unsafe
def np_match_apply(book, term, env, next):
  np_emit(book, np_collect(kid(term, 0), 0, Nil{}), nc_word(ix(kid(term, 1)), env), nc_remove_env(env, ix(kid(term, 1))), next)

# Module: src/back/native/pattern.bend:109
@unsafe
def np_emit(book, rows, word, env, next):
  match rows:
    case Nil{}:
      nc_fail("empty Nat pattern chain", next)
    case Con{row, rest}:
      np_emit_row(book, row, rest, word, env, next)

# Module: src/back/native/pattern.bend:116
@unsafe
def np_emit_row(book, row, rest, word, env, next):
  match row:
    case NPRow{index, body, residual, apply, last}:
      np_emit_done(book, index, last, rest, word, env, np_row_code(book, body, residual, apply, word, env, next))

# Module: src/back/native/pattern.bend:121
@unsafe
def np_emit_done(book, index, last, rest, word, env, code):
  nt_choose(NC_Code, last, u => NC_Code{"{\n" ++ nc_body(code) ++ "}\n", nc_segs(code), nc_fresh(code), nc_error(code)}, u => np_emit_join(index, last, word, code, np_emit(book, rest, word, env, nc_fresh(code))))

# Module: src/back/native/pattern.bend:124
@unsafe
def np_emit_join(index, last, word, code, tail):
  NC_Code{"if (" ++ word ++ " == " ++ U32.show(index) ++ "ull) {\n" ++ nc_body(code) ++ "} else " ++ nc_body(tail), nt_append(N_Segment, nc_segs(code), nc_segs(tail)), nc_fresh(tail), nc_first_error(code, tail)}

# Module: src/back/native/pattern.bend:127
@unsafe
def np_row_code(book, body, residual, apply, word, env, next):
  nt_choose(NC_Code, apply,
    u => nc_prepend("Term v_" ++ U32.show(nc_id(next)) ++ " = (" ++ word ++ " - " ++ U32.show(residual) ++ "ull);\n", nc_lower(book, app(body, var("", nc_id(next))), Con{nc_binding(nc_id(next)), env}, U32.inc(next))),
    u => nc_lower(book, body, env, next))

# Module: src/back/native/pattern.bend:140
@unsafe
def np_level_valid(level):
  match level:
    case NPLevel{zero, successor, fallback, hasZero, hasSucc, valid}:
      valid && (hasZero || hasSucc)

# Module: src/back/native/pattern.bend:145
@unsafe
def np_can_match(term):
  np_supported(term) && np_level_valid(np_level(term, atom("Efq"), atom("Efq"), False{}, False{}))

# Module: src/back/native/show.bend:50
@unsafe
def nc_show_find(+book: List<&2, KDef>, +ty: KTerm, types: List<&2, KTerm>, +i: U32) -> U32:
  match types:
    case Nil{}: 4294967295
    case Con{h, +rest}: nt_choose(U32, norm_compare(book, ty, h, False{}, 4000000000), u => i, u => nc_show_find(book, ty, rest, U32.inc(i)))

# Module: src/back/native/show.bend:56
@unsafe
def nc_show_ref(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> NC_Desc:
  +id = nc_show_find(book, ty, types, 0)
  nt_choose(NC_Desc, U32.is_eq(id, 4294967295),
    u => NC_Desc{["SD_" ++ U32.show(terms_len(types))], List.append(&2, KTerm, types, [ty]), ""},
    u => NC_Desc{["SD_" ++ U32.show(id)], types, ""})

# Module: src/back/native/show.bend:63
@unsafe
def nc_desc_cells(d: NC_Desc) -> List<&2, String>:
  match d:
    case NC_Desc{cells, types, err}: cells

# Module: src/back/native/show.bend:68
@unsafe
def nc_desc_types(d: NC_Desc) -> List<&2, KTerm>:
  match d:
    case NC_Desc{cells, types, err}: types

# Module: src/back/native/show.bend:73
@unsafe
def nc_desc_error(d: NC_Desc) -> String:
  match d:
    case NC_Desc{cells, types, err}: err

# Module: src/back/native/show.bend:78
@unsafe
def nc_desc_join(+a: NC_Desc, +b: NC_Desc) -> NC_Desc:
  NC_Desc{List.append(&2, String, nc_desc_cells(a), nc_desc_cells(b)), nc_desc_types(b), nt_choose(String, String.eq(nc_desc_error(a), ""), u => nc_desc_error(b), u => nc_desc_error(a))}

# Module: src/back/native/show.bend:82
@unsafe
def nc_show_fields(book, tel, left, i, types):
  nt_choose(NC_Desc, U32.is_eq(left, 0), u => NC_Desc{Nil{}, types, ""}, u =>
    nt_choose(NC_Desc, U32.is_eq(qt(wnf(book, tel)), 0), u => NC_Desc{Nil{}, types, "native readback cannot print an erased field"}, u =>
      nc_show_field(book, wnf(book, tel), left, i, nc_show_ref(book, kid(wnf(book, tel), 0), types))))

# Module: src/back/native/show.bend:88
@unsafe
def nc_show_field(book, tel, left, i, d):
  nc_desc_join(NC_Desc{Con{U32.show(i), nc_desc_cells(d)}, nc_desc_types(d), nc_desc_error(d)}, nc_show_fields(book, kid(tel, 1), U32.sub(left, 1), U32.inc(i), nc_desc_types(d)))

# Module: src/back/native/show.bend:92
@unsafe
def nc_show_arms(book, cs, args, types):
  match cs:
    case Nil{}: NC_Desc{Nil{}, types, ""}
    case Con{+c, rest}: nc_show_arm(book, c, rest, args, nc_show_fields(book, nc_tele_fill(book, dt(c), args), da(c), 0, types))

# Module: src/back/native/show.bend:98
@unsafe
def nc_show_arm(book, c, rest, args, d):
  nc_desc_join(NC_Desc{Con{nt_cid(nc_ctor_identity(book, dn(c))), Con{nt_cid(nc_ctor_identity(book, dn(c))), Con{U32.show(da(c)), nc_desc_cells(d)}}}, nc_desc_types(d), nc_desc_error(d)}, nc_show_arms(book, rest, args, nc_desc_types(d)))

# Module: src/back/native/show.bend:102
@unsafe
def nc_show_data(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> NC_Desc:
  +cs = dc(lookup(book, nm(ty)))
  +d = nc_show_arms(book, cs, ks(ty), types)
  NC_Desc{Con{"7", Con{"1", Con{U32.show(nt_count(KDef, cs)), nc_desc_cells(d)}}}, nc_desc_types(d), nc_desc_error(d)}

# Module: src/back/native/show.bend:108
@unsafe
def nc_show_array(+d: NC_Desc) -> NC_Desc:
  NC_Desc{Con{"6", List.append(&2, String, nc_desc_cells(d), ["0"])}, nc_desc_types(d), nc_desc_error(d)}

# Module: src/back/native/show.bend:112
@unsafe
def nc_show_node(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> NC_Desc:
  +k = nt_choose(String, db(lookup(book, nm(ty))), u => nm(ty), u => "")
  nt_choose(NC_Desc, String.eq(k, "U32"), u => NC_Desc{["0"], types, ""}, u =>
  nt_choose(NC_Desc, String.eq(k, "F32"), u => NC_Desc{["1"], types, ""}, u =>
  nt_choose(NC_Desc, String.eq(k, "Nat"), u => NC_Desc{["2"], types, ""}, u =>
  nt_choose(NC_Desc, String.eq(k, "Char"), u => NC_Desc{["3", "0"], types, ""}, u =>
  nt_choose(NC_Desc, String.eq(k, "String"), u => NC_Desc{["4"], types, ""}, u =>
  nt_choose(NC_Desc, String.eq(k, "Bool"), u => NC_Desc{["7", "0", "2", "CID_FALSE", "CID_FALSE", "0", "CID_TRUE", "CID_TRUE", "0"], types, ""}, u =>
  nt_choose(NC_Desc, String.eq(tg(ty), "Eql"), u => NC_Desc{["5"], types, ""}, u =>
  nt_choose(NC_Desc, String.eq(k, "Array"), u => nc_show_array(nc_show_ref(book, kid(ty, 0), types)), u =>
  nt_choose(NC_Desc, String.eq(tg(ty), "ADT") && String.eq(dk(lookup(book, nm(ty))), "ADT") && Bool.not(String.eq(k, "IO.OP")), u => nc_show_data(book, ty, types), u =>
    NC_Desc{Nil{}, types, "native readback cannot print a function, type, or dependent field"})))))))))

# Module: src/back/native/show.bend:126
@unsafe
def nc_show_step(+book: List<&2, KDef>, +i: U32, +offset: U32, +defs: String, +cells: List<&2, String>, +d: NC_Desc) -> NC_Show:
  nt_choose(NC_Show, String.eq(nc_desc_error(d), ""),
    u => nc_show_nodes(book, nc_desc_types(d), U32.inc(i), U32.add(offset, nt_count(String, nc_desc_cells(d))), defs ++ "#define SD_" ++ U32.show(i) ++ " " ++ U32.show(offset) ++ "\n", List.append(&2, String, cells, nc_desc_cells(d))),
    u => NC_Show{"", nc_desc_error(d)})

# Module: src/back/native/show.bend:132
@unsafe
def nc_show_nodes(book, types, i, offset, defs, cells):
  nt_choose(NC_Show, U32.is_eq(i, terms_len(types)), u => NC_Show{defs ++ "static const u32 SHOW_DESC[] = { " ++ nt_join(cells, ", ") ++ " };\n", ""}, u =>
    nt_choose(NC_Show, U32.is_gt(i, 4096), u => NC_Show{"", "native readback type graph exceeds 4096 nodes"}, u =>
      nc_show_step(book, i, offset, defs, cells, nc_show_node(book, wnf(book, terms_at(types, i)), types))))

# Module: src/back/native/show.bend:138
@unsafe
def nc_quote_chars(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, t}: nt_choose(String, Char.is_eq(h, '"'), u => "\\\"", u => nt_choose(String, Char.is_eq(h, '\\'), u => "\\\\", u => SCon{h, ""})) ++ nc_quote_chars(t)

# Module: src/back/native/show.bend:144
@unsafe
def nc_show_names(cs: List<&2, N_Constructor>) -> List<&2, String>:
  match cs:
    case Nil{}: Nil{}
    case Con{N_Constructor{k, a, h}, rest}: Con{"\"" ++ nc_quote_chars(nc_ctor_display(k)) ++ "\"", nc_show_names(rest)}

# Module: src/back/native/show.bend:150
@unsafe
def nc_show_finish(cs: List<&2, N_Constructor>, d: NC_Show) -> NC_Show:
  match d:
    case NC_Show{src, err}: NC_Show{"#if !DEVICE\n" ++ src ++ "static const char* SHOW_NAMES[] = { " ++ nt_join(nc_show_names(cs), ", ") ++ " };\n#endif\n", err}

# Module: src/back/native/show.bend:155
@unsafe
def nc_show_program(+book: List<&2, KDef>, ty: KTerm, cs: List<&2, N_Constructor>) -> NC_Show:
  nc_show_finish(cs, nc_show_nodes(book, [ty], 0, 0, "", Nil{}))

# Module: src/back/native/parallel.bend:11
@unsafe
def nc_last_term(xs: List<&2, KTerm>) -> KTerm:
  match xs:
    case Nil{}: atom("Absent")
    case Con{h, Nil{}}: h
    case Con{h, rest}: nc_last_term(rest)

# Module: src/back/native/parallel.bend:18
@unsafe
def nc_parallel_binds(xs: List<&2, KTerm>) -> List<&2, NC_Binding>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, Nil{}}: Nil{}
    case Con{h, rest}: Con{nc_binding(ix(h)), nc_parallel_binds(rest)}

# Module: src/back/native/parallel.bend:25
@unsafe
def nc_parallel_uses(xs: List<&2, KTerm>, +id: U32) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h, rest}: U32.add(nt_bool(nc_occurs(h, id)), nc_parallel_uses(rest, id))

# Module: src/back/native/parallel.bend:31
@unsafe
def nc_keeps(+word: String, +n: U32) -> String:
  nt_choose(String, U32.is_le(n, 1), u => "", u => word ++ " = term_keep(e, " ++ word ++ ");\n" ++ nc_keeps(word, U32.sub(n, 1)))

# Module: src/back/native/parallel.bend:35
@unsafe
def nc_parallel_share(env: List<&2, NC_Binding>, +xs: List<&2, KTerm>) -> String:
  match env:
    case Nil{}: ""
    case Con{NC_Binding{id, word}, rest}: nc_keeps(word, nc_parallel_uses(xs, id)) ++ nc_parallel_share(rest, xs)

# Module: src/back/native/parallel.bend:41
@unsafe
def nc_child_task(+fid: String, +join: String, +idx: U32, +em: N_Emitted) -> String:
  match em:
    case N_Emitted{code, word, fresh}: code ++ "e.mem[" ++ join ++ " + " ++ U32.show(idx) ++ "] = term_tsk(" ++ nt_fid(fid) ++ ", " ++ word ++ ");\n"

# Module: src/back/native/parallel.bend:46
@unsafe
def nc_local_calls(+book: List<&2, KDef>, refs: List<&2, String>) -> List<&2, String>:
  match refs:
    case Nil{}: ["$local"]
    case Con{h, rest}: Con{nc_ref_name(book, h), nc_local_calls(book, rest)}

# Module: src/back/native/parallel.bend:52
@unsafe
def nc_local_segments(ss: List<&2, N_Segment>, +calls: List<&2, String>, +forked: Bool, acc: List<&2, N_Segment>) -> List<&2, N_Segment>:
  match ss:
    case Nil{}: nt_reverse(N_Segment, acc, Nil{})
    case Con{N_Segment{k, ps, r, f, b, +refs, host, spin, fork, bang}, rest}:
      nc_local_segments(rest, calls, forked, Con{N_Segment{k, ps, r, f, b, nt_choose(List<&2, String>, nb_contains(refs, "$local"), u => refs, u => calls), host, spin, nt_choose(Bool, nb_contains(refs, "$local"), u => fork, u => forked), bang}, acc})

# Module: src/back/native/parallel.bend:59
@unsafe
def nc_children(+book: List<&2, KDef>, xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +joinname: String, +joinword: String, +idx: U32, +n: U32) -> NC_Code:
  match xs:
    case Nil{}: NC_Code{"", Nil{}, n, ""}
    case Con{h, Nil{}}: NC_Code{"", Nil{}, n, ""}
    case Con{+h, rest}:
      +name = nc_name(n)
      +caps = nc_live_env(env, kid(h, 0))
      +code = nc_lower(book, kid(h, 0), caps, U32.inc(n))
      +calls = nc_local_calls(book, nc_refs(kid(h, 0)))
      +forked = nc_term_fork(kid(h, 0))
      +task = ne_task(name, 0, nc_words(caps), "term_tsk(" ++ nt_fid(joinname) ++ ", " ++ joinword ++ ")", U32.show(idx), nc_fresh(code))
      +next = nc_children(book, rest, env, joinname, joinword, U32.inc(idx), U32.inc(nc_fresh(code)))
      NC_Code{nc_child_task(name, joinword, idx, task) ++ nc_body(next), Con{N_Segment{name, nc_params(caps), 1, N_Direct{}, nc_body(code), calls, False{}, False{}, forked, False{}}, nt_append(N_Segment, nc_local_segments(nc_segs(code), calls, forked, Nil{}), nc_segs(next))}, nc_fresh(next), nc_first_error(code, next)}

# Module: src/back/native/parallel.bend:74
@unsafe
def nc_parallel_finish(+env: List<&2, NC_Binding>, +xs: List<&2, KTerm>, +name: String, +join: NC_Code, +seq: NC_Code, +children: NC_Code, em: N_Emitted, +params: List<&2, NC_Binding>) -> NC_Code:
  match em:
    case N_Emitted{code, +word, n}:
      NC_Code{"if (!seq) {\n" ++ nc_parallel_share(env, xs) ++ code ++ nc_body(children) ++ "return term_tsk(" ++ nt_fid(name) ++ ", " ++ word ++ ");\n}\n" ++ nc_body(seq), Con{N_Segment{name, nc_params(params), 1, N_Direct{}, nc_body(join), Nil{}, False{}, False{}, True{}, False{}}, nt_append(N_Segment, nc_segs(join), nt_append(N_Segment, nc_segs(seq), nc_segs(children)))}, nc_fresh(children), nt_choose(String, String.eq(nc_first_error(seq, join), ""), u => nc_error(children), u => nc_first_error(seq, join))}

# Module: src/back/native/parallel.bend:80
@unsafe
def nc_parallel_task(+book: List<&2, KDef>, +xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +name: String, +join: NC_Code, +seq: NC_Code, +task: N_Emitted, +params: List<&2, NC_Binding>, +idx: U32) -> NC_Code:
  match task:
    case N_Emitted{code, +word, +n}: nc_parallel_finish(env, xs, name, join, seq, nc_children(book, xs, env, name, word, idx, n), task, params)

# Module: src/back/native/parallel.bend:85
@unsafe
def nc_parallel(book, xs, env, n):
  +seq = nc_lets(book, xs, env, n)
  +name = nc_name(nc_fresh(seq))
  +body = nc_last_term(xs)
  +held = nc_live_env(env, body)
  +params = List.append(&2, NC_Binding, held, nc_parallel_binds(xs))
  +join = nc_lower(book, body, params, U32.inc(nc_fresh(seq)))
  +task = ne_task(name, U32.sub(terms_len(xs), 1), nc_words(held), "WL_CONT", "WL_IDX", nc_fresh(join))
  nc_parallel_task(book, xs, env, name, join, seq, task, params, nt_count(NC_Binding, held))

# Module: src/back/native/array.bend:10
@unsafe
def nc_array_known(k):
  String.eq(k, "array_new") || String.eq(k, "array_get") || String.eq(k, "array_set") || String.eq(k, "array_swap") || String.eq(k, "array_size") || String.eq(k, "array_clone")

# Module: src/back/native/array.bend:14
@unsafe
def nc_array_pair(code: String, a: String, b: String, n: U32) -> NC_Code:
  nc_prepend(code, nc_ctor_result(ne_constructor("Tuple", [a, b], False{}, n, True{})))

# Module: src/back/native/array.bend:18
@unsafe
def nc_array(k, ws, n):
  +a = nc_head(ws)
  +i = nc_head(nc_tail(ws))
  +v = nc_head(nc_tail(nc_tail(ws)))
  nt_choose(NC_Code, String.eq(k, "array_new"), u => NC_Code{"Term init[1] = { " ++ i ++ " };\n" ++ ne_ret(["blk_new(e, 1, " ++ a ++ ", 0, 1, init)"]), Nil{}, n, ""}, u =>
  nt_choose(NC_Code, String.eq(k, "array_size"), u => nc_array_pair("", a, "(1ull << blk_cls(" ++ a ++ "))", n), u =>
  nt_choose(NC_Code, String.eq(k, "array_clone"), u => nc_array_pair("", "blk_copy(e, " ++ a ++ ")", a, n), u =>
  nt_choose(NC_Code, String.eq(k, "array_get"), u => nc_array_pair("u32 at = blk_at(" ++ a ++ ", " ++ i ++ ", 0);\n", a, "blk_keep(e, term_loc(" ++ a ++ ") + at)", n), u =>
  nt_choose(NC_Code, String.eq(k, "array_swap"), u => nc_array_pair("u32 at = blk_at(" ++ a ++ ", " ++ i ++ ", 0);\nTerm old = blk_read(e.mem, 1, term_loc(" ++ a ++ "), at);\nblk_write(e.mem, 1, term_loc(" ++ a ++ "), at, rfc_seal(e, " ++ v ++ "));\n", a, "old", n), u =>
    NC_Code{"u32 at = blk_at(" ++ a ++ ", " ++ i ++ ", 0);\nterm_sink(e, blk_read(e.mem, 1, term_loc(" ++ a ++ "), at));\nblk_write(e.mem, 1, term_loc(" ++ a ++ "), at, rfc_seal(e, " ++ v ++ "));\n" ++ ne_ret([a]), Nil{}, n, ""})))))

# Module: src/back/native/validate.bend:3
@unsafe
def nv_owned(book: List<&2, KDef>) -> String:
  match book:
    case Nil{}: ""
    case Con{+d, +rest}:
      nt_choose(String, Bool.not(db(d)) && nb_contains(["Clo.apply", "IO", "Sigma", "String", "Word.Con", "IO.OP", "Result", "Maybe", "Bool", "Unit", "Nat", "U32", "F32", "Char", "Array"], dn(d)),
        u => dn(d) ++ " is a name the compiler encodes itself: name yours apart",
        u => nv_owned(rest))

# Module: src/back/native/validate.bend:12
@unsafe
def nv_ctor_names(cs: List<&2, N_Constructor>) -> List<&2, String>:
  match cs:
    case Nil{}: Nil{}
    case Con{N_Constructor{k, a, h}, rest}: Con{nt_cid(k), nv_ctor_names(rest)}

# Module: src/back/native/validate.bend:18
@unsafe
def nv_seg_names_go(ss: List<&2, N_Segment>, acc: List<&2, String>) -> List<&2, String>:
  match ss:
    case Nil{}: nt_reverse(String, acc, ["FID_IO_EMIT", "FID_CLO_APPLY", "FID_EXIT", "FID_ENTER"])
    case Con{N_Segment{k, ps, r, f, b, refs, host, spin, fork, bang}, rest}: nv_seg_names_go(rest, Con{nt_fid(k), acc})

# Module: src/back/native/validate.bend:24
@unsafe
def nv_seg_names(ss: List<&2, N_Segment>) -> List<&2, String>:
  nv_seg_names_go(ss, Nil{})

# Module: src/back/native/validate.bend:28
@unsafe
def nv_id(name: String) -> KDef:
  KDef{name, "NativeId", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}

# Module: src/back/native/validate.bend:32
@unsafe
def nv_unique_index(xs: List<&2, String>, +seen: KDef) -> String:
  match xs:
    case Nil{}: ""
    case Con{+h, +rest}:
      +hash = index_hash(h, 2166136261)
      nt_choose(String, String.eq(dk(index_find(seen, h, hash, 32)), "Absent"), u => nv_unique_index(rest, index_set(seen, nv_id(h), hash, 32)), u => "native identifier collision: " ++ h)

# Module: src/back/native/validate.bend:40
@unsafe
def nv_unique(xs: List<&2, String>, seen: List<&2, String>) -> String:
  nv_unique_index(List.append(&2, String, seen, xs), missing())

# Module: src/back/native/validate.bend:44
@unsafe
def nv_ctors(cs: List<&2, N_Constructor>) -> String:
  match cs:
    case Nil{}: ""
    case Con{N_Constructor{+k, +a, h}, +rest}: nt_choose(String, U32.is_gt(a, 255), u => "native constructor arity exceeds 255: " ++ k, u => nv_ctors(rest))

# Module: src/back/native/validate.bend:50
@unsafe
def nv_segs(ss: List<&2, N_Segment>) -> String:
  match ss:
    case Nil{}: ""
    case Con{N_Segment{+k, +ps, +r, f, b, refs, host, spin, fork, bang}, +rest}: nt_choose(String, U32.is_gt(nt_count(N_Param, ps), 255) || U32.is_gt(r, 255), u => "native segment arity exceeds 255: " ++ k, u => nv_segs(rest))

# Module: src/back/native/validate.bend:56
@unsafe
def nv_first(+a: String, +b: String) -> String:
  nt_choose(String, String.eq(a, ""), u => b, u => a)

# Module: src/back/native/validate.bend:60
@unsafe
def nv_program(+ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>) -> String:
  nt_choose(String, U32.is_gt(nt_count(N_Segment, ss), 65532) || U32.is_gt(nt_count(N_Constructor, cs), 65536), u => "native identifier exceeds 65535", u =>
    nv_first(nv_unique(nv_ctor_names(cs), ["CID_ARITY_T", "CID_HOT_T", "FID_ARITY_T", "FID_FLAG_T", "FID_RESW_T"]), nv_first(nv_unique(nv_seg_names(ss), Nil{}), nv_first(nv_ctors(cs), nv_segs(ss)))))

# Module: src/back/native/foreign.bend:4
@unsafe
def nc_foreign_has(paths: List<&2, KTerm>, +path: String) -> Bool:
  match paths:
    case Nil{}: False{}
    case Con{h, rest}: String.eq(nm(h), path) || nc_foreign_has(rest, path)

# Module: src/back/native/foreign.bend:10
@unsafe
def nc_source_has_id(+source: String, +name: String) -> Bool:
  String.contains(source, name ++ ",") || String.contains(source, name ++ ")") || String.contains(source, name ++ " ") || String.contains(source, name ++ "\n") || String.contains(source, name ++ "\t") || String.contains(source, name ++ ";") || String.contains(source, name ++ "]")

# Module: src/back/native/foreign.bend:14
@unsafe
def nc_source_namespace(+parts: List<&2, String>, +prefix: String, +source: String) -> String:
  match parts:
    case Nil{}: ""
    case Con{+h, +rest}:
      nt_choose(String, nc_source_has_id(source, nt_cid(nt_join(parts, "."))), u => prefix, u => nc_source_namespace(rest, prefix ++ h ++ ".", source))

# Module: src/back/native/foreign.bend:21
@unsafe
def nc_foreign_namespace(ds: List<&2, KDef>, +path: String, +source: String) -> String:
  match ds:
    case Nil{}: ""
    case Con{+d, +rest}:
      nt_choose(String, nc_foreign_has(ks(nc_unann(dv(d))), path),
        u => nt_choose(String, String.eq(nm(nc_unann(dv(d))), ""), u => nc_source_namespace(String.split(dn(d), '.'), "", source), u => String.take(dn(d), Nat.sub(String.length(dn(d)), String.length(nm(nc_unann(dv(d))))))),
        u => nc_foreign_namespace(rest, path, source))

# Module: src/back/native/foreign.bend:30
@unsafe
def nc_foreign_aliases(cs: List<&2, N_Constructor>, +ns: String, +open: Bool) -> String:
  match cs:
    case Nil{}: ""
    case Con{N_Constructor{+name, a, h}, rest}:
      nt_choose(String, String.starts_with(nc_ctor_display(name), ns) && Bool.not(String.eq(nt_cid(String.drop(nc_ctor_display(name), String.length(ns))), nt_cid(name))),
        u => nt_choose(String, open,
          u => "#pragma push_macro(\"" ++ nt_cid(String.drop(nc_ctor_display(name), String.length(ns))) ++ "\")\n#define " ++ nt_cid(String.drop(nc_ctor_display(name), String.length(ns))) ++ " " ++ nt_cid(name) ++ "\n",
          u => "#pragma pop_macro(\"" ++ nt_cid(String.drop(nc_ctor_display(name), String.length(ns))) ++ "\")\n"),
        u => "") ++ nc_foreign_aliases(rest, ns, open)

# Module: src/back/native/foreign.bend:41
@unsafe
def nc_foreign_wrap(+cs: List<&2, N_Constructor>, +ns: String, +source: String) -> String:
  nc_foreign_aliases(cs, ns, True{}) ++ source ++ "\n" ++ nc_foreign_aliases(cs, ns, False{})

# Module: src/back/native/foreign.bend:45
@unsafe
def nc_foreign_base(ds: List<&2, KDef>, +path: String) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{+d, +rest}:
      nt_choose(Bool, nc_foreign_has(ks(nc_unann(dv(d))), path), u => db(d), u => nc_foreign_base(rest, path))

# Module: src/back/native/foreign.bend:52
@unsafe
def nc_foreign_source(+book: List<&2, KDef>, +path: String, +source: String) -> String:
  nt_choose(String, nc_foreign_base(book, path), u => source, u => nc_foreign_wrap(nc_constructors(book, book), nc_foreign_namespace(book, path, source), source))

# Module: src/back/native/book.bend:41
@unsafe
def nc_refs_go(todo: List<&2, KTerm>, +acc: List<&2, String>) -> List<&2, String>:
  match todo:
    case Nil{}: nt_reverse(String, acc, Nil{})
    case Con{+h, +rest}:
      nc_refs_go(nt_append(KTerm, ks(h), rest), nt_choose(List<&2, String>, String.eq(tg(h), "Ref"), u => Con{nm(h), acc}, u => acc))

# Module: src/back/native/book.bend:48
@unsafe
def nc_refs_list(ts):
  nc_refs_go(ts, Nil{})

# Module: src/back/native/book.bend:52
@unsafe
def nc_refs(t):
  nc_refs_go([t], Nil{})

# Module: src/back/native/book.bend:56
@unsafe
def nc_foreign_tel(+book: List<&2, KDef>, +ty: KTerm, +name: String, +args: List<&2, KTerm>, +n: U32) -> KTerm:
  +tel = wnf(book, ty)
  nt_choose(KTerm, String.eq(tg(tel), "All"),
    u => nt_choose(KTerm, U32.is_eq(qt(tel), 0),
      u => nc_foreign_tel(book, subst(kid(tel, 1), ix(tel), atom("Typ")), name, args, U32.inc(n)),
      u => kt("Lam", "", nc_id(n), 1, [nc_foreign_tel(book, subst(kid(tel, 1), ix(tel), var("", nc_id(n))), name, List.append(&2, KTerm, args, [var("", nc_id(n))]), U32.inc(n))])),
    u => kt("NCtr", name, 0, 0, args))

# Module: src/back/native/book.bend:65
@unsafe
def nc_unann(t):
  nt_choose(KTerm, String.eq(tg(t), "Ann"), u => nc_unann(kid(t, 0)), u => t)

# Module: src/back/native/book.bend:69
@unsafe
def nc_foreign(+d: KDef) -> Bool:
  String.eq(tg(nc_unann(dv(d))), "Foreign") || String.eq(tg(nc_unann(dv(d))), "Absent")

# Module: src/back/native/book.bend:73
@unsafe
def nc_definition(+book: List<&2, KDef>, +d: KDef, +n: U32) -> KTerm:
  +prim = nc_primitive_name(dn(d))
  nt_choose(KTerm, nc_native_def(d),
    u => nc_primitive_body(prim),
    u => nt_choose(KTerm, nc_foreign(d),
      u => nc_foreign_tel(book, dt(d), dn(d), Nil{}, n),
      u => nc_erase(book, dv(d))))

# Module: src/back/native/book.bend:92
@unsafe
def nc_terms_bang(ts, name):
  match ts:
    case Nil{}: False{}
    case Con{h, rest}: nc_term_bang(h, name) || nc_terms_bang(rest, name)

# Module: src/back/native/book.bend:98
@unsafe
def nc_term_bang(t, name):
  (String.eq(tg(t), "Ref") && U32.is_eq(qt(t), 3) && String.eq(nm(t), name)) || nc_terms_bang(ks(t), name)

# Module: src/back/native/book.bend:102
@unsafe
def nc_book_bang(ds: List<&2, KDef>, +name: String) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{d, rest}: nc_term_bang(dv(d), name) || nc_book_bang(rest, name)

# Module: src/back/native/book.bend:108
@unsafe
def nc_call_head(+t: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(t), "App"), u => nc_call_head(kid(t, 0)), u => t)

# Module: src/back/native/book.bend:112
@unsafe
def nc_terms_fork(ts):
  match ts:
    case Nil{}: False{}
    case Con{+h, +rest}:
      nt_choose(Bool, (String.eq(tg(h), "Let") && U32.is_gt(terms_len(ks(h)), 2)) || (String.eq(tg(h), "App") && String.eq(tg(nc_call_head(h)), "Var")),
        u => True{}, u => nc_terms_fork(nt_append(KTerm, ks(h), rest)))

# Module: src/back/native/book.bend:120
@unsafe
def nc_term_fork(t):
  nc_terms_fork([t])

# Module: src/back/native/book.bend:124
@unsafe
def nc_mapped_refs(+book: List<&2, KDef>, refs: List<&2, String>) -> List<&2, String>:
  match refs:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nc_ref_name(book, h), nc_mapped_refs(book, rest)}

# Module: src/back/native/book.bend:130
@unsafe
def nc_mark_segments_go(ss: List<&2, N_Segment>, +bang: Bool, +forked: Bool, +calls: List<&2, String>, acc: List<&2, N_Segment>) -> List<&2, N_Segment>:
  match ss:
    case Nil{}: nt_reverse(N_Segment, acc, Nil{})
    case Con{N_Segment{k, ps, r, f, b, +refs, host, spin, fork, old}, rest}:
      nc_mark_segments_go(rest, bang, forked, calls, Con{N_Segment{k, ps, r, f, b, nt_choose(List<&2, String>, nb_contains(refs, "$local"), u => refs, u => calls), host, spin, nt_choose(Bool, nb_contains(refs, "$local"), u => fork, u => forked), bang}, acc})

# Module: src/back/native/book.bend:137
@unsafe
def nc_mark_segments(ss: List<&2, N_Segment>, +bang: Bool, +forked: Bool, +calls: List<&2, String>) -> List<&2, N_Segment>:
  nc_mark_segments_go(ss, bang, forked, calls, Nil{})

# Module: src/back/native/book.bend:141
@unsafe
def nc_mark_code(c: NC_Code, bang: Bool, forked: Bool, calls: List<&2, String>) -> NC_Code:
  match c:
    case NC_Code{body, ss, n, err}: NC_Code{body, nc_mark_segments(ss, bang, forked, calls), n, err}

# Module: src/back/native/book.bend:146
@unsafe
def nc_append_book(+code: NC_Code, name: String, calls: List<&2, String>, forked: Bool, rest: NC_Book) -> NC_Book:
  match rest:
    case NC_Book{segs, fresh, +err}:
      NC_Book{Con{N_Segment{name, Nil{}, 1, N_Direct{}, nc_body(code), calls, False{}, False{}, forked, False{}}, nt_append(N_Segment, nc_segs(code), segs)}, fresh, nt_choose(String, String.eq(nc_error(code), ""), u => err, u => nc_error(code))}

# Module: src/back/native/book.bend:152
@unsafe
def nc_compile_def(+book: List<&2, KDef>, +name: String, +todo: List<&2, String>, +done: List<&2, String>, +n: U32, +bangs: List<&2, String>) -> NC_Book:
  +d = lookup(book, name)
  +body = nc_compact(nc_definition(book, d, n))
  +refs = nc_refs(body)
  +calls = nc_mapped_refs(book, refs)
  +forked = nc_term_fork(body)
  +code = nc_mark_code(nd_extend(book, body, nc_lower(book, body, Nil{}, U32.add(n, 1024)), name), nb_contains(bangs, name), forked, calls)
  nt_choose(NC_Book, String.eq(dk(d), "Absent"), u => NC_Book{Nil{}, n, "native definition not found: " ++ name}, u =>
    nc_append_book(code, nc_ref_name(book, name), calls, forked, nc_compile_defs(book, List.append(&2, String, refs, todo), Con{name, done}, nc_fresh(code), bangs)))

# Module: src/back/native/book.bend:163
@unsafe
def nc_compile_defs(book, todo, done, n, bangs):
  match todo:
    case Nil{}: NC_Book{Nil{}, n, ""}
    case Con{name, rest}:
      nt_choose(NC_Book, nb_contains(done, name), u => nc_compile_defs(book, rest, done, n, bangs), u => nc_compile_def(book, name, rest, done, n, bangs))

# Module: src/back/native/book.bend:170
@unsafe
def nc_skip_tel(+book: List<&2, KDef>, +tel: KTerm, +n: U32) -> KTerm:
  nt_choose(KTerm, U32.is_eq(n, 0), u => tel, u => nc_skip_tel(book, kid(wnf(book, tel), 1), U32.sub(n, 1)))

# Module: src/back/native/book.bend:174
@unsafe
def nc_ctor_specs(+book: List<&2, KDef>, cs: List<&2, KDef>, +params: U32) -> List<&2, N_Constructor>:
  match cs:
    case Nil{}: Nil{}
    case Con{+c, rest}: Con{N_Constructor{nc_ctor_identity(book, dn(c)), nc_live_count(book, nc_skip_tel(book, dt(c), params), da(c)), True{}}, nc_ctor_specs(book, rest, params)}

# Module: src/back/native/book.bend:180
@unsafe
def nc_all_args(+book: List<&2, KDef>, +ty: KTerm) -> U32:
  +tel = wnf(book, ty)
  nt_choose(U32, String.eq(tg(tel), "All"), u => U32.add(nt_bool(Bool.not(U32.is_eq(qt(tel), 0))), nc_all_args(book, kid(tel, 1))), u => 0)

# Module: src/back/native/book.bend:185
@unsafe
def nc_constructors(book, ds):
  match ds:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, N_Constructor>, String.eq(dk(d), "ADT"),
        u => List.append(&2, N_Constructor, nc_ctor_specs(book, dc(d), da(d)), nc_constructors(book, rest)),
        u => nt_choose(List<&2, N_Constructor>, String.eq(dk(d), "Def") && nc_foreign(d),
          u => Con{N_Constructor{dn(d), nc_all_args(book, dt(d)), True{}}, nc_constructors(book, rest)},
          u => nc_constructors(book, rest)))

# Module: src/back/native/book.bend:196
@unsafe
def nc_default_ctors() -> List<&2, N_Constructor>:
  [N_Constructor{"Tuple", 2, True{}}, N_Constructor{"SNil", 0, True{}}, N_Constructor{"SCon", 2, True{}}, N_Constructor{"WCon", 2, True{}}, N_Constructor{"WNil", 0, True{}}, N_Constructor{"Emit", 1, True{}}, N_Constructor{"Halt", 2, True{}}, N_Constructor{"Done", 1, True{}}, N_Constructor{"Fail", 1, True{}}, N_Constructor{"Some", 1, True{}}, N_Constructor{"None", 0, True{}}, N_Constructor{"True", 0, True{}}, N_Constructor{"False", 0, True{}}, N_Constructor{"Unit", 0, True{}}, N_Constructor{"LT", 0, True{}}, N_Constructor{"EQ", 0, True{}}, N_Constructor{"GT", 0, True{}}]

# Module: src/back/native/book.bend:200
@unsafe
def nc_has_ctor(cs: List<&2, N_Constructor>, +key: String) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{N_Constructor{k, a, h}, rest}: String.eq(k, key) || nc_has_ctor(rest, key)

# Module: src/back/native/book.bend:206
@unsafe
def nc_add_ctors(cs: List<&2, N_Constructor>, +acc: List<&2, N_Constructor>) -> List<&2, N_Constructor>:
  match cs:
    case Nil{}: acc
    case Con{N_Constructor{+k, +a, +h}, rest}: nc_add_ctors(rest, nt_choose(List<&2, N_Constructor>, nc_has_ctor(acc, k), u => acc, u => List.append(&2, N_Constructor, acc, [N_Constructor{k, a, h}])))

# Module: src/back/native/book.bend:212
@unsafe
def nc_show_cells(+ty: KTerm) -> String:
  +k = nm(ty)
  nt_choose(String, String.eq(k, "U32"), u => "0", u =>
  nt_choose(String, String.eq(k, "F32"), u => "1", u =>
  nt_choose(String, String.eq(k, "Nat"), u => "2", u =>
  nt_choose(String, String.eq(k, "Char"), u => "3, 0", u =>
  nt_choose(String, String.eq(k, "String"), u => "4", u =>
  nt_choose(String, String.eq(k, "Bool"), u => "7, 0, 2, 0, CID_FALSE, 0, 1, CID_TRUE, 0", u =>
  nt_choose(String, String.eq(k, "Unit"), u => "7, 1, 1, 2, CID_UNIT, 0", u =>
  nt_choose(String, String.eq(tg(ty), "Eql"), u => "5", u => ""))))))))

# Module: src/back/native/book.bend:224
@unsafe
def nc_show(+cells: String) -> String:
  "#if !DEVICE\nstatic const u32 SHOW_DESC[] = { " ++ cells ++ " };\nstatic const char* SHOW_NAMES[] = {\"False\", \"True\", \"Unit\"};\n#endif\n"

# Module: src/back/native/book.bend:228
@unsafe
def nc_is_io(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +io = lookup(book, "IO")
  +shadow = book_put(book, KDef{dn(io), dk(io), da(io), dx(io), dt(io), atom("Absent"), dc(io), db(io), du(io)})
  +head = wnf(shadow, ty)
  String.eq(dk(io), "Def") && db(io) && String.eq(tg(head), "App") && String.eq(tg(kid(head, 0)), "Ref") && String.eq(nm(kid(head, 0)), "IO")

# Module: src/back/native/book.bend:235
@unsafe
def nc_helpers() -> String:
  "INLINE bool native_bool(Term t) { return t == 1 || (term_tag(t) == TAG_PAK && term_aux(t) == CID_TRUE); }\nINLINE Term native_word(Env e, u32 x) {\n  Term w = term_pak(CID_WNIL, 0);\n  for (u32 i = 32; i > 0; i--) {\n    Loc p = heap_alloc(e, 1);\n    e.mem[p] = (x >> (i - 1)) & 1;\n    e.mem[p + 1] = rfc_seal(e, w);\n    w = term_ctr(CID_WCON, p);\n  }\n  return w;\n}\n"

# Module: src/back/native/book.bend:239
@unsafe
def nc_with_show(+ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, d: NC_Show) -> NC_Result:
  match d:
    case NC_Show{+src, +err}: nt_choose(NC_Result, String.eq(nv_first(err, nv_program(ss, cs)), ""), u => NC_Result{ne_program(runtime, N_Program{ss, cs, Nil{}, requests, nc_helpers(), src, pure}), ""}, u => NC_Result{"", nv_first(err, nv_program(ss, cs))})

# Module: src/back/native/book.bend:244
@unsafe
def nc_finish(+book: List<&2, KDef>, +runtime: String, +requests: String, compiled: NC_Book) -> NC_Result:
  match compiled:
    case NC_Book{+ss, n, +error}:
      +ty = dt(lookup(book, "main"))
      +pure = Bool.not(nc_is_io(book, ty))
      +cs = nc_add_ctors(nc_default_ctors(), nc_constructors(book, book))
      nt_choose(NC_Result, Bool.not(String.eq(error, "")), u => NC_Result{"", error}, u =>
        nc_with_show(ss, cs, runtime, requests, pure, nt_choose(NC_Show, pure, u => nc_show_program(book, ty, cs), u => NC_Show{nc_show("0"), ""})))

# Module: src/back/native/book.bend:262
@unsafe
def nc_bangs_terms(ts):
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: List.append(&2, String, nc_bangs_term(h), nc_bangs_terms(rest))

# Module: src/back/native/book.bend:268
@unsafe
def nc_bangs_term(t):
  nt_choose(List<&2, String>, String.eq(tg(t), "Var"), u => Nil{}, u => nt_choose(List<&2, String>, String.eq(tg(t), "Ref") && U32.is_eq(qt(t), 3), u => [nm(t)], u => nt_choose(List<&2, String>, String.eq(tg(t), "Ann"), u => nc_bangs_term(kid(t, 0)), u => nc_bangs_terms(ks(t)))))

# Module: src/back/native/book.bend:272
@unsafe
def nc_bangs_book(book: List<&2, KDef>) -> List<&2, String>:
  match book:
    case Nil{}: Nil{}
    case Con{d, rest}: List.append(&2, String, nc_bangs_term(dv(d)), nc_bangs_book(rest))

# Module: src/back/native/book.bend:278
@unsafe
def nc_compile(+book: List<&2, KDef>, runtime: String, requests: String) -> NC_Result:
  +main = lookup(book, "main")
  +owned = nv_owned(book)
  nt_choose(NC_Result, Bool.not(String.eq(owned, "")), u => NC_Result{"", owned}, u =>
  nt_choose(NC_Result, Bool.not(String.eq(dk(main), "Def")) || String.eq(tg(nc_unann(dv(main))), "Absent"), u => NC_Result{"", "no main to run"}, u =>
  nt_choose(NC_Result, nc_is_io(book, dt(main)) && String.eq(tg(nc_unann(dv(main))), "Foreign"), u => NC_Result{"", "main must be a filled def: a foreign main cannot anchor IO"}, u =>
  nt_choose(NC_Result, U32.is_ge(norm_max_book(book), 4000000000), u => NC_Result{"", "native source binder IDs overlap the compiler temporary range"}, u => nc_finish(book, runtime, requests, nc_compile_defs(book, ["main"], Nil{}, 0, nc_bangs_book(book)))))))

# Module: src/back/native/book.bend:287
@unsafe
def nc_live_names(+book: List<&2, KDef>, todo: List<&2, String>, +done: List<&2, String>) -> List<&2, String>:
  match todo:
    case Nil{}: done
    case Con{+name, +rest}:
      nt_choose(List<&2, String>, nb_contains(done, name), u => nc_live_names(book, rest, done), u => nc_live_names(book, List.append(&2, String, nc_refs(nc_definition(book, lookup(book, name), 0)), rest), Con{name, done}))

# Module: src/back/native/book.bend:294
@unsafe
def nc_c_paths(paths: List<&2, KTerm>) -> List<&2, String>:
  match paths:
    case Nil{}: Nil{}
    case Con{+h, +rest}: nt_choose(List<&2, String>, String.ends_with(nm(h), ".c"), u => Con{nm(h), nc_c_paths(rest)}, u => nc_c_paths(rest))

# Module: src/back/native/book.bend:300
@unsafe
def nc_paths_of(+book: List<&2, KDef>, names: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{name, rest}: List.append(&2, String, nc_c_paths(ks(nc_unann(dv(lookup(book, name))))), nc_paths_of(book, rest))

# Module: src/back/native/book.bend:306
@unsafe
def nc_foreign_paths(+book: List<&2, KDef>) -> List<&2, String>:
  nc_paths_of(book, nc_live_names(book, ["main"], Nil{}))

# Selective annotation keeps all original type-level definitions in scope.
# The host asks reach_book for main's closure, annotates it in the original
# context, and replaces only those entries before native emission.

# Module: src/back/native/book.bend:313
@unsafe
def nc_annotation_stops(book: List<&2, KDef>) -> List<&2, String>:
  match book:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, String>, nc_native_def(d),
        u => Con{dn(d), nc_annotation_stops(rest)},
        u => nc_annotation_stops(rest))

# Module: src/back/native/book.bend:322
@unsafe
def nc_context_defs(book: List<&2, KDef>, +annotated: List<&2, KDef>) -> List<&2, KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, KDef>, String.eq(dk(d), "BookCache"),
        u => nc_context_defs(rest, annotated),
        u => Con{nt_choose(KDef, String.eq(dk(lookup(annotated, dn(d))), "Absent"), u => d, u => lookup(annotated, dn(d))), nc_context_defs(rest, annotated)})

# Module: src/back/native/book.bend:331
@unsafe
def nc_annotated_context(+book: List<&2, KDef>, +annotated: List<&2, KDef>) -> List<&2, KDef>:
  +merged = nc_context_defs(book, annotated)
  book_cached(merged, norm_max_book(merged))

# Module: src/driver/report.bend:39
@unsafe
def driver_report(book, names):
  dr_verdict(dr_bad_names(book_cached(book, norm_max_book(book)), names))

# Module: src/driver/report.bend:43
@unsafe
def dr_bad_names(book, names):
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      kc(List<&2,String>, dr_relies(book, [name], Nil{}),
        u => Con{name, dr_bad_names(book, rest)}, u => dr_bad_names(book, rest))

# Module: src/driver/report.bend:51
@unsafe
def dr_relies(book, todo, seen):
  match todo:
    case Nil{}: False{}
    case Con{+name, +rest}:
      kc(Bool, has_name(seen, name),
        u => dr_relies(book, rest, seen),
        u => dr_relies_def(book, rest, Con{name, seen}, kr_resolve(book, name)))

# Module: src/driver/report.bend:60
@unsafe
def dr_relies_def(book, todo, seen, d):
  kc(Bool, du(d) || (String.eq(tg(dv(d)), "Foreign") && Bool.not(db(d))),
    u => True{},
    u => dr_relies(book, kr_dependencies(d, Nil{}, todo), seen))

# Module: src/driver/report.bend:66
@unsafe
def dr_verdict(names):
  match names:
    case Nil{}: "All terms check.\n"
    case Con{+name, +rest}:
      "All terms check, but " ++ U32.show(dr_count(names)) ++
      kc(String, U32.is_eq(dr_count(names), 1), u => " def relies", u => " defs rely") ++
      " on unsafe or foreign code:\n" ++ dr_lines(names)

# Module: src/driver/report.bend:75
@unsafe
def dr_count(names):
  match names:
    case Nil{}: 0
    case Con{+name, +rest}: U32.add(1, dr_count(rest))

# Module: src/driver/report.bend:81
@unsafe
def dr_lines(names):
  match names:
    case Nil{}: ""
    case Con{+name, +rest}: "- " ++ name ++ "\n" ++ dr_lines(rest)

# Module: src/driver/api.bend:7
@unsafe
def driver_has_main(book):
  Bool.not(String.eq(tg(dv(lookup(book, "main"))), "Absent"))

# Module: src/driver/api.bend:15
@unsafe
def driver_is_io(book):
  j_io_type(book, dt(lookup(book, "main")))

# Module: src/driver/api.bend:28
@unsafe
def driver_final(book, done):
  match book:
    case Nil{}: done
    case Con{d, rest}: driver_final(rest, Con{d, book_without(done, dn(d))})

# Module: src/driver/api.bend:34
@unsafe
def driver_interpret(book):
  +final = driver_final(book, Nil{})
  kp_show(strong(final, dv(lookup(final, "main"))))

# Module: src/driver/api.bend:43
@unsafe
def driver_todos(book):
  driver_count_todos(driver_final(book, Nil{}))

# Module: src/driver/api.bend:51
@unsafe
def driver_count_todos(book):
  match book:
    case Nil{}: 0
    case Con{d, rest}:
      U32.add(kc(U32, String.eq(dk(d), "Def") && String.eq(tg(dv(d)), "Absent") && Bool.not(db(d)), u => 1, u => U32.add(driver_holes(dt(d)), driver_holes(dv(d)))), U32.add(driver_count_todos(dc(d)), driver_count_todos(rest)))

# Module: src/driver/api.bend:62
@unsafe
def driver_holes(t):
  U32.add(kc(U32, String.eq(tg(t), "Hol"), u => 1, u => 0), driver_holes_terms(ks(t)))

# Module: src/driver/api.bend:70
@unsafe
def driver_holes_terms(ts):
  match ts:
    case Nil{}: 0
    case Con{t, rest}: U32.add(driver_holes(t), driver_holes_terms(rest))

# This synthesized closure dispatcher name is reserved even in check-only mode.
# It is a compiler-name gate after checking, not a type/proof inference rule.

# Module: src/driver/api.bend:82
@unsafe
def driver_owned(book):
  match book:
    case Nil{}: ""
    case Con{d, rest}:
      kc(String, String.eq(dn(d), "Clo.apply") && Bool.not(db(d)),
        u => "Clo.apply is a name the compiler encodes itself: name yours apart",
        u => driver_owned(rest))

# Exact pinned compiler OWNED datatype set. User definitions remain valid for
# pure checking/normalization but cannot use the runtime's intrinsic layouts.

# Module: src/driver/api.bend:107
@unsafe
def driver_emit_owned(book):
  driver_owned_names(book, ["Clo.apply", "IO", "Sigma", "String", "Word.Con", "IO.OP", "Result", "Maybe", "Bool", "Unit", "Nat", "U32", "F32", "Char", "Array"])

# Module: src/driver/api.bend:111
@unsafe
def driver_owned_names(book, names):
  match names:
    case Nil{}: ""
    case Con{name, rest}:
      kc(String, driver_owned_name(book, name),
        u => name ++ " is a name the compiler encodes itself: name yours apart",
        u => driver_owned_names(book, rest))

# Module: src/driver/api.bend:120
@unsafe
def driver_owned_name(book, name):
  match book:
    case Nil{}: False{}
    case Con{d, rest}:
      (String.eq(dn(d), name) && Bool.not(db(d))) || driver_owned_name(rest, name)
