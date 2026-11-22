import Base

# Phase88 native-host-only consuming string helpers.
# Consuming compiler-host helpers. No reconstructed input pair or host closure.
# Deliberately safe: checked ownership must suffice without @unsafe.
def p88_string_eq(+a: String, +b: String) -> Bool:
  String.eq(a, b)

@unsafe
def agy_str_eq(+a: String, +b: String) -> Bool:
  String.eq(a, b)

# Core syntax, declarations, and structural term operations.

# Module: src/core/term.bend:25
type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

# Module: src/core/term.bend:30
type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}
  KIndexLeaf{+hash: U32, +bucket: List<&2,KDef>}
  KIndexNode{+hash: U32, +mask: U32, +left: KDef, +right: KDef}

# Module: src/core/normalize.bend:474
type KNormCmp is Data:
  KNormCmp{+a: KTerm, +b: KTerm, +le: Bool, +fresh: U32}
  KNormShare{+left: U32, +right: U32}

# Module: src/core/normalize.bend:478
type KNormAlt is Data:
  KNormAlt{+todo: List<&2, KNormCmp>}

# Module: src/core/graph.bend:6
type GHeap is Data:
  GEmpty{}
  GNode{+value: KTerm, +left: GHeap, +right: GHeap}

# Equality classes are separate from evaluation values. Absent entries are
# singleton roots; stored roots name themselves and carry union-by-rank height.
type GClassEntry is Data:
  GClassEntry{+parent: U32, +rank: U32}

type GClasses is Data:
  GClassesEmpty{}
  GClassesNode{+entry: Maybe<&2,GClassEntry>, +left: GClasses, +right: GClasses}

# Module: src/core/graph.bend:10
type GState is Data:
  GState{+heap: GHeap, +next: U32}
  GCompared{+heap: GHeap, +next: U32, +classes: GClasses}

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
  KPFile{+namespace: String, +aliases: List<&2,KTerm>}

# Module: src/core/pretty.bend:7
type KPChain is Data:
  KPChain{items: List<&2, KTerm>, tail: KTerm}

# Module: src/check/quantity.bend:4
type KDescent is Data:
  KDescent{order: U32, bad: U32}

# Module: src/check/kernel.bend:4
type KChecking is Data:
  KChecking{+term: KTerm, +typ: KTerm, +uses: List<&2, KTerm>, +error: String, +world: KWorld, +consumed: U32}

# Module: src/check/kernel.bend:7
type KEnv is Data:
  KEnv{+world: KWorld, +name: String, +lhs: KTerm, +pending: U32, +quantities: List<&2, KTerm>, +unsafe: Bool, +depth: U32}

# Module: src/check/kernel.bend:1197
type KWorldFresh is Data:
  KFreshKnown{+next: U32}
  KFreshDeferred{+roots: List<&2,KTerm>}

# Module: src/check/kernel.bend:1201
type KWorld is Data:
  KWorld{+book: List<&2,KDef>, +memo: List<&2,KSpecMemo>, +fresh: KWorldFresh, +checked: List<&2,KDef>}

# Module: src/check/env-telescope.bend:7
type KTelescopeBinding is Data:
  KTelescopeBinding{+id: U32, +value: KTerm}

# Module: src/check/specialize.bend:11
type KSpecMemo is Data:
  KSpecMemo{+template: String, +key: String, +name: String, +active: Bool}

# Module: src/check/prefix-state.bend:72
type KBasePrefixState is Data:
  KBasePrefixState{+bound: U32, +delta: U32, +stamp: U32, +patches: List<&2,KDef>, +ready: Bool}

# Module: src/check/prefix-state.bend:213
type KBasePrefixTail is Data:
  KBasePrefixTail{+suffix: List<&2,KDef>, +matched: Bool}

# Module: src/check/prefix-state.bend:271
type KBasePreparedWorld is Data:
  KBasePreparedWorld{+state: KBasePrefixState, +prefix: List<&2,KDef>, +final: List<&2,KDef>, +book: List<&2,KDef>, +checked: List<&2,KDef>, +seen: List<&2,KDef>, +todos: U32, +checkedBound: U32}

# Module: src/check/annotate.bend:261
type KAnnotatedSpine is Data:
  KAnnotatedSpine{+node: KTerm, +typ: KTerm}

# Module: src/front/lexer.bend:2
type FToken is Data:
  FToken{+text: String, f_line: U32, f_col: U32, f_kind: U32, begin: U32, end: U32, previousEnd: U32}

# Module: src/front/lexer.bend:5
type FScanned is Data:
  FScanned{+word: String, +rest: String, size: U32}

# Module: src/front/lexer.bend:323
type FParseContext is Data:
  FParseContext{+scope: FParseScope, +env: List<&2,KTerm>, next: U32}

# Module: src/front/lexer.bend:325
type FInput is Data:
  FInput{+tokens: List<&2,FToken>, +context: FParseContext}

# Module: src/front/parser.bend:3
type FParsed is Data:
  FParsed{+term: KTerm, +rest: FInput}

# Module: src/front/declarations.bend:2
type FResult is Data:
  FResult{+book: List<&2, KDef>, +error: String, +imports: List<&2, KTerm>}

# Internal parser transport only; public FResult remains unchanged.

# Module: src/front/declarations.bend:6
type FRawResult is Data:
  FRawResult{+book: List<&2, KDef>, +error: KTerm, +imports: List<&2, KTerm>}

# Module: src/front/declarations.bend:673
type FParseScope is Data:
  FParseScope{+prior: List<&2,KDef>, +index: KDef, +ctors: KDef, +ns: String, +aliases: List<&2,KTerm>, +priorView: Maybe<&2,KDef>}

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
  FFOrigin{begin: U32, end: U32}

# Module: src/front/fresh_work.bend:138
type FFDefFrame is Data:
  FFDefFrame{+definition: KDef, +pending: List<&2,KDef>, +built: List<&2,KDef>, +typ: KTerm, +value: KTerm}

# Module: src/front/freshen.bend:2
type FFresh is Data:
  FFresh{+term: KTerm, next: U32}

# Module: src/front/freshen.bend:5
type FFreshDefs is Data:
  FFreshDefs{+defs: List<&2, KDef>, next: U32}

# Module: src/load/graph.bend:4
type FGraph is Data:
  FGraph{+book: List<&2, KDef>, +error: String, +done: List<&2, KTerm>}

# Module: src/load/seed.bend:6
type FSeed is Data:
  FSeed{+path: String, +book: List<&2, KDef>, +root: String}

# Module: src/load/modules.bend:3
type FSource is Data:
  FSource{+name: String, +path: String, +text: String}
  FCompletedSource{+name: String, +path: String, +text: String, +parsed: FResult}
  FLocatedSource{+source: FSource, begin: U32, end: U32}

# The load trace is part of the loader API, also usable without diagnostics.

# Module: src/load/modules.bend:9
type FLoadTrace is Data:
  FLoadTrace{+result: FResult, +done: List<&2,KTerm>, +sources: List<&2,FSource>}

# Module: src/load/modules.bend:143
type FHeader is Data:
  FHeader{+imports: List<&2,KTerm>, +error: String, +body: String, line: U32, offset: U32}

# Module: src/load/modules.bend:146
type FCompletion is Data:
  FCompletion{+graph: FGraph, +parsed: FResult}

# The private ready loader retains the fragment it has just completed.

# Module: src/load/modules.bend:150
type FIndexedCompletion is Data:
  FIndexedCompletion{+graph: FGraph, +parsed: FResult, +fragment: List<&2,KDef>}

# Module: src/load/prefix.bend:3
type FFreshPrefixState is Data:
  FFreshPrefixState{+next: U32, +ready: Bool}

# Module: src/load/prefix.bend:6
type FFreshPrefixTail is Data:
  FFreshPrefixTail{+suffix: List<&2,KDef>, +matched: Bool}

# Module: src/load/prefix.bend:101
type FPrefixGraph is Data:
  FPrefixGraph{+graph: FGraph, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +count: U32, +ready: Bool}
  FReadyPrefixGraph{+graph: FGraph, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +count: U32, +ready: Bool, +names: KDef, +ctors: KDef, +baseNames: KDef}

# Private immutable parser scope, prepared only for the exact admitted Base.
# Names retain the latest declaration event; constructors retain the first DFS.

# Module: src/load/prefix.bend:107
type FReadyPrefixState is Data:
  FReadyPrefixState{+names: KDef, +ctors: KDef, +count: U32, +ready: Bool}

# Module: src/load/prefix.bend:114
type FPrefixCompletion is Data:
  FPrefixCompletion{+carrier: FPrefixGraph, +parsed: FResult}

# Module: src/load/prefix.bend:117
type FPrefixLoad is Data:
  FPrefixLoad{+trace: FLoadTrace, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool}

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
  DSourceOrigin{+source: String, begin: U32, end: U32}

# Module: src/diagnostic/model.bend:15
type DDiagnostic is Data:
  DDiagnostic{+expected: DExpr, +observed: DExpr, has_observed: Bool, +context: List<&2, KTerm>, +definition: String, +span: DSpan, +note: String, +trail: List<&2, KTerm>}

# Module: src/diagnostic/model.bend:18
type DResult is Data:
  DResult{+error: String, +book: List<&2, KDef>, +diagnostic: DDiagnostic}

# Module: src/diagnostic/produce.bend:99
type DChecking is Data:
  DChecking{+result: KChecking, +diagnostic: DDiagnostic}

# Module: src/back/native/ir.bend:3
type N_WordKind is Data:
  N_W32{}
  N_W64{}
  N_Box{}
  N_Imm64{}

type N_Param is Data:
  N_Param{+name: String, +kind: N_WordKind}

# Module: src/back/native/ir.bend:11
type N_Frame is Data:
  N_Direct{}
  N_Frame{+pop: U32, +slots: List<&2, String>}

# Module: src/back/native/ir.bend:15
type N_Segment is Data:
  N_Segment{+name: String, +params: List<&2, N_Param>, +result: U32, +frame: N_Frame, +body: String, +refs: List<&2, String>, +host: Bool, +spin: Bool, +fork: Bool, +bang: Bool}

# Module: src/back/native/ir.bend:18
type N_Constructor is Data:
  N_Constructor{+name: String, +arity: U32, +hot: Bool}

# Module: src/back/native/ir.bend:24
type N_Emitted is Data:
  N_Emitted{+code: String, +value: String, +fresh: U32}

# Module: src/back/native/uses.bend:3
type NU_Set is Data:
  NU_Empty{}
  NU_Leaf{key: U32}
  NU_Node{mask: U32, +left: NU_Set, +right: NU_Set}

# Module: src/back/native/bridge.bend:5
type NC_Literal is Data:
  NC_Literal{+valid: Bool, +value: U32}

# Module: src/back/native/bridge.bend:8
type NC_Binding is Data:
  NC_Binding{+id: U32, +word: String, +kind: N_WordKind}

# Module: src/back/native/bridge.bend:15
type NC_Text is Data:
  NC_Empty{}
  NC_Leaf{+text: String}
  NC_Join{+left: NC_Text, +right: NC_Text}

type NC_Code is Data:
  NC_Code{+body: NC_Text, +segments: List<&2, N_Segment>, +fresh: U32, +error: String, +calls: List<&2, String>}

# Module: src/back/native/flat.bend:4
type NC_Target is Data:
  NC_Scheduler{}
  NC_Destination{+words: List<&2, String>, +shape: KTerm, +join: String, +owner: String, +params: List<&2, NC_Binding>, +tail: Bool, +signatures: List<&2, KDef>}

# Module: src/back/native/product.bend:351
type NQ_Entry is Data:
  NQ_Entry{+params: List<&2, NC_Binding>, +args: List<&2, KTerm>, +fresh: U32}

# Module: src/back/native/word-pattern.bend:4
type NW_Rows is Data:
  NW_Rows{+valid: Bool, +rows: List<&2, KTerm>}

# Module: src/back/native/word-pattern.bend:7
type NW_Arms is Data:
  NW_Arms{+zero: KTerm, +one: KTerm, +end: KTerm, +hasZero: Bool, +hasOne: Bool, +valid: Bool}

# Module: src/back/native/word-pattern.bend:10
type NW_Cover is Data:
  NW_None{}
  NW_Cover{+body: KTerm, +bits: List<&2, KTerm>, +fields: U32}

# Module: src/back/native/request.bend:3
type NR_Closure is Data:
  NR_Closure{+names: List<&2, String>, +facts: List<&2, KDef>}

# Module: src/back/native/request.bend:6
type NR_Request is Data:
  NR_Request{+source: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +paths: List<&2, String>, +scope: List<&2, KDef>, +bound: Maybe<&2, U32>}

# Module: src/back/native/observer-emitter.bend:5
type NO_Layout is Data:
  NO_Layout{+key: String, +ctor: String, +storage: String, +width: U32}

# Module: src/back/native/observer-layout.bend:6
type NO_Spec is Data:
  NO_Spec{+layout: NO_Layout, +owner: String, +fields: List<&2, String>}

# Module: src/back/native/observer-layout.bend:9
type NO_Schema is Data:
  NO_Schema{+params: List<&2, KTerm>, +roots: List<&2, U32>, +wrapper: KTerm, +result: U32, +observation: String, +specs: List<&2, NO_Spec>, +fresh: U32, +error: String}

# Module: src/back/native/observer-layout.bend:12
type NOL_Wrap is Data:
  NOL_Wrap{+term: KTerm, +roots: List<&2, U32>, +shells: U32, +observation: String, +error: String}

# Module: src/back/native/observer-analysis.bend:5
type NO_Context is Data:
  NO_Context{+book: List<&2,KDef>, +owner: String, +schema: NO_Schema, +helpers: List<&2,P128BRHelper>}

type NO_Input is Data:
  NO_Input{+value: KTerm, +facts: List<&2, KTerm>, +fresh: U32, +fuel: U32}

# Module: src/back/native/observer-analysis.bend:11
type NO_Analysis is Data:
  NO_Analysis{+body: KTerm, +fresh: U32, +fuel: U32, +error: String}

# Symbolic branches reuse the remaining computation. Store its environment as
# Data: native affine closures cannot be shared by ordinary reference counting.
# The analysis context is constant and stays outside these continuation frames.

# Module: src/back/native/observer-analysis.bend:17
type NO_Cont is Data:
  NO_KFinish{}
  NO_KEvalArgs{+terms: List<&2, KTerm>, +env: List<&2, KTerm>, +stack: List<&2, String>, +acc: List<&2, KTerm>, +next: NO_Cont}
  NO_KApplyArgs{+args: List<&2, KTerm>, +next: NO_Cont}
  NO_KAppFunction{+arg: KTerm, +env: List<&2, KTerm>, +stack: List<&2, String>, +next: NO_Cont}
  NO_KAppArgument{+fn: KTerm, +next: NO_Cont}
  NO_KConstructor{+name: String, +next: NO_Cont}
  NO_KLetBody{+body: KTerm, +id: U32, +env: List<&2, KTerm>, +stack: List<&2, String>, +next: NO_Cont}
  NO_KApplyOne{+arg: KTerm, +next: NO_Cont}

# Module: src/back/native/observer-plan.bend:3
type NO_Plan is Data:
  NO_Plan{+owner: String, +schema: NO_Schema, +analysis: NO_Analysis, +error: String}

# Module: src/driver/report.bend:104
type DR_Report is Data:
  DR_Report{+verdict: String, +names: List<&2, String>}

# Module: src/driver/report.bend:115
type DR_Closure is Data:
  DR_Closure{+bad: Bool, +seen: List<&2, String>}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:8
type P88Node is Data:
  P88Bad{}
  P88Empty{}
  P88Word{+value: U32}
  P88Bool{+value: Bool}
  P88String{+value: String}
  P88Term{+value: KTerm}
  P88Def{+value: KDef}
  P88Terms{+value: List<&2,KTerm>}
  P88Defs{+value: List<&2,KDef>}
  P88Strings{+value: List<&2,String>}
  P88Checked{+value: KBasePrefixState}
  P88Fresh{+value: FFreshPrefixState}
  P88World{+value: KBasePreparedWorld}
  P88Frontend{+value: FReadyPrefixState}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:24
type P88Cursor is Data:
  P88Cursor{+text: String, +mode: U32}

type P88Number is Data:
  P88Number{+cursor: P88Cursor, +value: U32}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:28
type P88TextRead is Data:
  P88TextRead{+cursor: P88Cursor, +value: String}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:30
type P88State is Type:
  P88State{cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:32
type P88Step is Type:
  P88Step{state: P88State, value: P88Node}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:34
type P88Products is Data:
  P88Products{+book: List<&2,KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +world: KBasePreparedWorld}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:36
type P88Decoded is Data:
  P88DecodeError{+error: String}
  P88DecodeReady{+products: P88Products}

# Bounded decimal integers, canonical spelling, no arithmetic wraparound.

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:396
type P86Seed is Data:
  P86Seed{+source: FSource, +book: List<&2,KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +world: KBasePreparedWorld}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:399
type P86Preparation is Data:
  P86PreparationError{+error: String}
  P86PreparationReady{+seed: P86Seed}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:403
type P86Plan is Data:
  P86PlanError{+error: String}
  P86PlanReady{+request: NR_Request, +verdict: String}

# The ordinary host supplies JS UTF-16 lengths. This tail loop computes the
# same transport metadata in either execution backend, without dg_width's
# diagnostic-sized recursion on the entire75KiB Base source.

# Module: src/core/term.bend:337
law subst_terms:
  for +ts: List<&2, KTerm>
  for +id: U32
  for +v: KTerm
  List<&2, KTerm>

# Module: src/core/term.bend:347
law core_subst_stable_terms:
  for +ts: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:421
law core_subst_stable_app:
  for +kids: List<&2, KTerm>
  for +removed: List<&2, String>
  Bool

# Module: src/core/term.bend:450
law core_subst_stable_app_kids:
  for +kids: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:454
law core_subst_stable_app_tail:
  for +f: KTerm
  for +tail: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:459
law core_subst_stable_app_last:
  for +f: KTerm
  for +x: KTerm
  for +rest: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:501
law norm_defs_join:
  for +a: List<&2, KDef>
  for +b: List<&2, KDef>
  List<&2, KDef>

# Module: src/core/index.bend:4
law index_child_list:
  for +ds: List<&2, KDef>
  for +right: Bool
  KDef

# Module: src/core/index.bend:9
law index_first:
  for +ds: List<&2, KDef>
  KDef

# Module: src/core/index.bend:13
law index_bucket:
  for +ds: List<&2, KDef>
  for +name: String
  KDef

# Compressed persistent binary trie. Internal nodes carry one discriminating
# hash bit; leaves retain exact-name buckets for complete 32-bit collisions.

# Module: src/core/index.bend:20
law index_lookup:
  for +cache: KDef
  for +name: String
  KDef

# Module: src/core/index.bend:308
law norm_eval:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:131
law norm_ref:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +d: KDef
  KTerm

# Module: src/core/normalize.bend:141
law norm_args:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:156
law norm_dec:
  for +n: U32
  U32

# Module: src/core/normalize.bend:163
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

# Module: src/core/normalize.bend:178
law norm_stuck:
  for +t: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:189
law norm_min:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:199
law norm_min_left:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:208
law norm_min_right:
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:235
law norm_max_book:
  for +book: List<&2, KDef>
  U32

# Module: src/core/normalize.bend:252
law norm_let:
  for +ts: List<&2, KTerm>
  KTerm

# Module: src/core/normalize.bend:294
law norm_let_tail:
  for +h: KTerm
  for +rest: List<&2, KTerm>
  KTerm

# Module: src/core/normalize.bend:312
law norm_var:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +values: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:329
law norm_names_len:
  for +names: List<&2, String>
  U32

# Module: src/core/normalize.bend:343
law norm_book_bound:
  for +book: List<&2, KDef>
  U32

# Module: src/core/normalize.bend:347
law norm_bound_found:
  for +book: List<&2, KDef>
  for +stamp: KDef
  U32

# Module: src/core/normalize.bend:370
law norm_max_walk:
  for +todo: List<&2, KTerm>
  for +bound: U32
  U32

# Module: src/core/normalize.bend:375
law norm_max_defs:
  for +todo: List<&2, KDef>
  for +bound: U32
  U32

# Module: src/core/normalize.bend:405
law norm_exact:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:410
law norm_exact_lists:
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  Bool

# Module: src/core/normalize.bend:415
law norm_exact_head:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:420
law norm_exact_names:
  for +as: List<&2, String>
  for +bs: List<&2, String>
  Bool

# Module: src/core/normalize.bend:458
law norm_convert:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:480
law norm_cmp_loop:
  for +book: List<&2, KDef>
  for +st: GState
  for +todo: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:487
law norm_cmp_quick:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:492
law norm_cmp_heads:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:503
law norm_cmp_same:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:514
law norm_cmp_plain:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:525
law norm_cmp_fields:
  for +book: List<&2, KDef>
  for +st: GState
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:535
law norm_cmp_zip:
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  List<&2, KNormCmp>

# Module: src/core/normalize.bend:542
law norm_cmp_kind:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +g: KTerm
  for +h: KTerm
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/graph.bend:26
law g_put_node:
  for +old: KTerm
  for +left: GHeap
  for +right: GHeap
  for +id: U32
  for +value: KTerm
  GHeap

# Module: src/core/graph.bend:34
law g_shared_term:
  for +rest: List<&2, KTerm>
  for +done: List<&2, KTerm>
  for +r: GResult
  GTerms

# Module: src/core/graph.bend:40
law g_shared_head:
  for +t: KTerm
  for +r: GTerms
  GResult

# Module: src/core/graph.bend:45
law g_eval:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:55
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

# Module: src/core/graph.bend:66
law g_app:
  for +book: List<&2, KDef>
  for +fn: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:76
law g_ref:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +stack: List<&2, GFrame>
  for +d: KDef
  GResult

# Module: src/core/graph.bend:85
law g_args:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:95
law g_return:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:102
law g_resume:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +frame: GFrame
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:110
law g_filled:
  for +book: List<&2, KDef>
  for +id: U32
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:120
law g_min_left:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +args: List<&2, KTerm>
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:129
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

# Module: src/core/graph.bend:142
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

# Module: src/core/graph.bend:153
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

# Module: src/core/graph.bend:165
law g_let_sub:
  for +t: KTerm
  for +bindings: List<&2, KTerm>
  KTerm

# Module: src/core/reach.bend:7
law kp_digit:
  for +n: U32
  String

# Module: src/core/pretty.bend:27
law descend_go:
  for +a: KTerm
  for +p: KTerm
  U32

# Module: src/check/quantity.bend:12
law descend_fields:
  for +a: List<&2, KTerm>
  for +p: List<&2, KTerm>
  for +ord: U32
  for +index: U32
  KDescent

# Module: src/check/quantity.bend:19
law descend_field:
  for +a: List<&2, KTerm>
  for +p: List<&2, KTerm>
  for +ord: U32
  for +index: U32
  for +field: U32
  KDescent

# Module: src/check/quantity.bend:27
law terms_tail:
  for +ts: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/quantity.bend:31
law descend_ctr:
  for +a: KTerm
  for +p: KTerm
  for +result: KDescent
  U32

# Module: src/check/quantity.bend:37
law descend_sub:
  for +a: KTerm
  for +ps: List<&2, KTerm>
  for +bad: U32
  for +index: U32
  U32

# Module: src/check/quantity.bend:44
law descend_step:
  for +ord: U32
  for +qs: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +cols: List<&2, KTerm>
  Bool

# Module: src/check/kernel.bend:10
law infer_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  KChecking

# Module: src/check/kernel.bend:18
law infer_var:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  KChecking

# Module: src/check/kernel.bend:25
law infer_ref:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  for +d: KDef
  KChecking

# Module: src/check/kernel.bend:34
law infer_app:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:42
law infer_app_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +r: KChecking
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:51
law infer_adt:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +d: KDef
  KChecking

# Module: src/check/kernel.bend:59
law infer_adt_done:
  for +t: KTerm
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:64
law tele_check:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  for +dem: U32
  KChecking

# Module: src/check/kernel.bend:72
law tele_check_done:
  for +a: KChecking
  for +b: KChecking
  KChecking

# Module: src/check/kernel.bend:84
law check:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:92
law check_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:100
law check_fits:
  for +e: KEnv
  for +r: KChecking
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:106
law check_lam:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:114
law check_lam_q:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +q: U32
  KChecking

# Module: src/check/kernel.bend:123
law check_lam_done:
  for +t: KTerm
  for +ty: KTerm
  for +q: U32
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:130
law check_ctr:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:138
law check_ctr_found:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +ctr: KDef
  KChecking

# Module: src/check/kernel.bend:147
law check_rfl:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  KChecking

law check_rfl_graph:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:153
law check_let:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +dem: U32
  for +ty: KTerm
  for +bindings: List<&2, KTerm>
  for +us: List<&2, KTerm>
  for +site: KTerm
  for +out: List<&2,KTerm>
  KChecking

# Module: src/check/kernel.bend:166
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
  for +site: KTerm
  for +out: List<&2,KTerm>
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:181
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
  for +site: KTerm
  for +out: List<&2,KTerm>
  for +r: KChecking
  for +k: KChecking
  KChecking

# Module: src/check/kernel.bend:197
law let_cells:
  for +body: KTerm
  for +bs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:202
law check_let_done:
  for +e: KEnv
  for +ctx: List<&2,KTerm>
  for +r: KChecking
  for +bs: List<&2, KTerm>
  for +us: List<&2, KTerm>
  for +site: KTerm
  KChecking

# Module: src/check/kernel.bend:211
law dead_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/check/kernel.bend:216
law check_mat:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:224
law check_mat_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +a: KTerm
  KChecking

# Module: src/check/kernel.bend:233
law check_mat_ctr:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +a: KTerm
  for +ctr: KDef
  KChecking

# Module: src/check/kernel.bend:243
law mat_goal:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:252
law mat_goal_head:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:269
law check_rwt:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:278
law check_rwt_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +r: KChecking
  for +eq: KTerm
  KChecking

# Module: src/check/kernel.bend:288
law check_rwt_goal:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +r: KChecking
  for +eq: KTerm
  for +fresh: U32
  KChecking

# Module: src/check/kernel.bend:299
law tele_quantities_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +n: U32
  List<&2, KTerm>

# Module: src/check/kernel.bend:305
law infer_template:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  for +d: KDef
  KChecking

# Module: src/check/kernel.bend:405
law template_args:
  for +e: KEnv
  for +ty: KTerm
  for +sp: List<&2, KTerm>
  for +n: U32
  KChecking

# Module: src/check/kernel.bend:412
law template_arg_head:
  for +e: KEnv
  for +ty: KTerm
  for +sp: List<&2, KTerm>
  for +n: U32
  KChecking

# Module: src/check/kernel.bend:419
law template_arg_done:
  for +e: KEnv
  for +ty: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +n: U32
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:428
law contains_self:
  for +todo: List<&2, KTerm>
  for +name: String
  Bool

# Module: src/check/kernel.bend:433
law check_template_definition:
  for +world: KWorld
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  for +depth: U32
  KChecking

# Module: src/check/kernel.bend:443
law check_template_binder:
  for +world: KWorld
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  for +depth: U32
  KChecking

# Module: src/check/kernel.bend:453
law check_template_open:
  for +world: KWorld
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  for +name: String
  for +depth: U32
  KChecking

# Module: src/check/kernel.bend:1127
law tele_check_cached_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  KChecking

# A failed fact uses the original remaining traversal, avoiding repeated scans
# of dependent tails. The public tele_check_head retains its existing behavior.

# Module: src/check/kernel.bend:1138
law tele_check_legacy_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  KChecking

# Module: src/check/kernel.bend:1177
law tele_check_after_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  for +checked_head: KChecking
  KChecking

# Module: src/check/env-telescope.bend:10
law env_tele_safe_terms:
  for +ts: List<&2,KTerm>
  Bool

# Module: src/check/env-telescope.bend:43
law env_tele_fill_loop:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  for +bindings: List<&2,KTelescopeBinding>
  for +count: U32
  KTerm

# Module: src/check/env-telescope.bend:51
law env_tele_fill_eager:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  KTerm

# Module: src/check/env-telescope.bend:92
law env_tele_check_loop:
  for +e: KEnv
  for +ctx: List<&2,KTerm>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  for +dem: U32
  for +bindings: List<&2,KTelescopeBinding>
  for +count: U32
  KChecking

# Module: src/check/env-substitution.bend:7
law env_subst_term:
  for +t: KTerm
  for +bindings: List<&2,KTelescopeBinding>
  KTerm

# Module: src/check/env-substitution.bend:12
law env_subst_terms:
  for +ts: List<&2,KTerm>
  for +bindings: List<&2,KTelescopeBinding>
  List<&2,KTerm>

# Module: src/check/env-substitution.bend:17
law env_subst_find:
  for +t: KTerm
  for +bindings: List<&2,KTelescopeBinding>
  KTerm

# Module: src/check/specialize.bend:14
law sp_keys:
  for +ts: List<&2, KTerm>
  String

# Module: src/check/specialize.bend:18
law sp_take_next:
  for +ts: List<&2, KTerm>
  for +n: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:23
law sp_drop_next:
  for +ts: List<&2, KTerm>
  for +n: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:28
law sp_shifts:
  for +ts: List<&2, KTerm>
  for +offset: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:33
law sp_apply_template:
  for +body: KTerm
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/prefix-state.bend:10
law ka_def:
  for +book: List<&2, KDef>
  for +d: KDef
  KDef

# Module: src/check/annotate.bend:27
law annotate:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:34
law ka_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:41
law ka_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:47
law ka_type_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:53
law ka_type_app:
  for +e: KEnv
  for +t: KTerm
  for +fty: KTerm
  KTerm

# Module: src/check/annotate.bend:59
law ka_lam:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:66
law ka_app:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +fty: KTerm
  KTerm

# Module: src/check/annotate.bend:73
law ka_args_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/annotate.bend:81
law ka_mat:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +a: KTerm
  KTerm

# Module: src/check/annotate.bend:89
law ka_mat_ctr:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +a: KTerm
  for +c: KDef
  KTerm

# Module: src/check/annotate.bend:98
law ka_let:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +ty: KTerm
  List<&2, KTerm>

# Module: src/check/annotate.bend:106
law ka_let_head:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +ty: KTerm
  for +vty: KTerm
  List<&2, KTerm>

# Module: src/check/annotate.bend:116
law ka_rwt:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +eq: KTerm
  KTerm

# Module: src/check/annotate.bend:264
law ka_spine_eligible:
  for +t: KTerm
  Bool

# Module: src/check/annotate.bend:268
law ka_spine_finish:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +arg: KTerm
  for +r: KAnnotatedSpine
  KAnnotatedSpine

# Module: src/check/annotate.bend:275
law ka_spine_step:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +arg: KTerm
  for +node: KTerm
  for +fty: KTerm
  KAnnotatedSpine

# Module: src/check/annotate.bend:283
law ka_app_spine:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:289
law ka_app_spine_root:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +arg: KTerm
  for +node: KTerm
  for +fty: KTerm
  KTerm

# Module: src/check/annotate.bend:322
law ka_app_spine_finish:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +arg: KTerm
  for +r: KAnnotatedSpine
  KTerm

# Module: src/check/annotate.bend:340
law ka_args_cached:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/annotate.bend:347
law ka_args_cached_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/annotate.bend:382
law ka_args_after_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +annotated: KTerm
  List<&2, KTerm>

# Module: src/front/lexer.bend:22
law f_ascii_char_eq:
  for +a: Char
  for +b: Char
  Bool

# Module: src/front/lexer.bend:27
law f_ascii_alpha:
  for +c: Char
  Bool

# Module: src/front/lexer.bend:31
law f_ascii_digit:
  for +c: Char
  Bool

# Module: src/front/lexer.bend:35
law f_ascii_ident_code:
  for +code: U32
  Bool

# Module: src/front/lexer.bend:43
law f_ascii_space_code:
  for +code: U32
  Bool

# Module: src/front/parser.bend:6
law dg_text:
  for +s: String
  KTerm

# Module: src/diagnostic/trace.bend:8
law dg_bad_detail:
  for +world: KWorld
  for +message: String
  for +expected: KTerm
  for +observed: KTerm
  KChecking

# Module: src/diagnostic/trace.bend:15
law dg_bad_message:
  for +world: KWorld
  for +message: String
  for +expected: KTerm
  KChecking

# Module: src/diagnostic/trace.bend:21
law dg_trace:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +r: KChecking
  KChecking

# Module: src/diagnostic/trace.bend:29
law dg_trace_detail:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +r: KChecking
  for +detail: KTerm
  KChecking

# Module: src/diagnostic/trace.bend:37
law dg_reason:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +code: String
  KTerm

# Module: src/diagnostic/produce.bend:4
law dg_quant_error:
  for +world: KWorld
  for +message: String
  for +name: String
  for +allowed: U32
  for +used: U32
  KChecking

# Module: src/diagnostic/produce.bend:24
law dg_constructor_names:
  for +ds: List<&2, KDef>
  String

# Module: src/diagnostic/produce.bend:28
law dg_ctor_error:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  for +ctr: KDef
  KChecking

# Module: src/diagnostic/produce.bend:35
law dg_adt_error:
  for +world: KWorld
  for +t: KTerm
  for +d: KDef
  KChecking

# Module: src/diagnostic/produce.bend:116
@unsafe
def kc(
  -A: Type,
  +b: Bool,
  yes: Unit -> A,
  no: Unit -> A,
) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# Module identity uses ns:name; only external output replaces its first colon.

# Module: src/core/term.bend:18
@unsafe
def name_key(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{c, rest}: kc(String, Char.is_eq(c, ':'), u => "." ++ rest, u => SCon{c, name_key(rest)})

# First-order trusted core. Binder identifiers are globally unique.
# Quantities: 0 erased, 1 affine, 2 unrestricted. No function-valued fields.

# Module: src/core/term.bend:36
@unsafe
def kt(
  +tag: String,
  +name: String,
  +id: U32,
  +quant: U32,
  +kids: List<&2, KTerm>,
) -> KTerm:
  KTerm{tag, name, id, quant, kids, Nil{}, 0, 0}

# Module: src/core/term.bend:46
@unsafe
def tg(
  +t: KTerm,
) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      tag
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      "Lam"
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      "Lit"

# Module: src/core/term.bend:64
@unsafe
def nm(
  +t: KTerm,
) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      name
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      name
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      kind

# Module: src/core/term.bend:76
@unsafe
def ix(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      id
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      id
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0

# Module: src/core/term.bend:88
@unsafe
def qt(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      quant
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      quant
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0

# Module: src/core/term.bend:100
@unsafe
def ks(
  +t: KTerm,
) -> List<&2, KTerm>:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      kids
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      kids
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      Nil{}

# Module: src/core/term.bend:112
@unsafe
def rm(
  +t: KTerm,
) -> List<&2, String>:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      removed
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      removed
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      Nil{}

# AGY-W5B-C2-IR
# Module: src/core/term.bend:124
law terms_at:
  for +ts: List<&2, KTerm>
  for +n: U32
  KTerm

@unsafe
def w5c2_terms_at_if(z: Bool, +h: KTerm, +t: List<&2, KTerm>, +n: U32) -> KTerm:
  match z:
    case True{}: h
    case False{}: terms_at(t, U32.sub(n, 1))

@unsafe
def terms_at(ts, n):
  match ts:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, t}:
      w5c2_terms_at_if(U32.is_eq(n, 0), h, t, n)

# Module: src/core/term.bend:135
@unsafe
def kid(
  +t: KTerm,
  +n: U32,
) -> KTerm:
  terms_at(ks(t), n)

# Module: src/core/term.bend:142
@unsafe
def var(
  +name: String,
  +id: U32,
) -> KTerm:
  kt("Var", name, id, 0, Nil{})

# Module: src/core/term.bend:149
@unsafe
def ref(
  +name: String,
) -> KTerm:
  kt("Ref", name, 0, 0, Nil{})

# Module: src/core/term.bend:155
@unsafe
def qua(
  +q: U32,
) -> KTerm:
  kt("Qua", "", 0, q, Nil{})

# Module: src/core/term.bend:161
@unsafe
def typ(
  +q: U32,
) -> KTerm:
  kt("Typ", "", 0, 0, Con{qua(q), Nil{}})

# Module: src/core/term.bend:167
@unsafe
def app(
  +f: KTerm,
  +x: KTerm,
) -> KTerm:
  kt("App", "", 0, 0, Con{f, Con{x, Nil{}}})

# Module: src/core/term.bend:174
@unsafe
def all(
  +q: U32,
  +name: String,
  +id: U32,
  +a: KTerm,
  +b: KTerm,
) -> KTerm:
  kt("All", name, id, q, Con{a, Con{b, Nil{}}})

# Module: src/core/term.bend:184
@unsafe
def dn(
  +d: KDef,
) -> String:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      name
    case KIndexLeaf{hash, bucket}: ""
    case KIndexNode{hash, mask, left, right}: ""

# Module: src/core/term.bend:194
@unsafe
def dk(
  +d: KDef,
) -> String:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      kind
    case KIndexLeaf{hash, bucket}: "IndexLeaf"
    case KIndexNode{hash, mask, left, right}: "IndexNode"

# Module: src/core/term.bend:204
@unsafe
def da(
  +d: KDef,
) -> U32:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      arity
    case KIndexLeaf{hash, bucket}: hash
    case KIndexNode{hash, mask, left, right}: hash

# Module: src/core/term.bend:214
@unsafe
def dx(
  +d: KDef,
) -> U32:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      templates
    case KIndexLeaf{hash, bucket}: 0
    case KIndexNode{hash, mask, left, right}: mask

# Module: src/core/term.bend:224
@unsafe
def dt(
  +d: KDef,
) -> KTerm:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      typ
    case KIndexLeaf{hash, bucket}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case KIndexNode{hash, mask, left, right}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

# Module: src/core/term.bend:234
@unsafe
def dv(
  +d: KDef,
) -> KTerm:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      value
    case KIndexLeaf{hash, bucket}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case KIndexNode{hash, mask, left, right}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

# Module: src/core/term.bend:244
@unsafe
def dc(
  +d: KDef,
) -> List<&2, KDef>:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      ctors
    case KIndexLeaf{hash, bucket}: bucket
    case KIndexNode{hash, mask, left, right}: Con{left, Con{right, Nil{}}}

# Module: src/core/term.bend:254
@unsafe
def db(
  +d: KDef,
) -> Bool:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      native
    case KIndexLeaf{hash, bucket}: True{}
    case KIndexNode{hash, mask, left, right}: True{}

# Module: src/core/term.bend:264
@unsafe
def du(
  +d: KDef,
) -> Bool:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      unsafe
    case KIndexLeaf{hash, bucket}: False{}
    case KIndexNode{hash, mask, left, right}: False{}

# Module: src/core/term.bend:274
@unsafe
def missing() -> KDef:
  KDef{"", "Absent", 0, 0,
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    Nil{}, False{}, False{}}

law lookup:
  for +book: List<&2,KDef>
  for +name: String
  KDef

@unsafe
def w5c2_lookup_eq(hit: Bool, +d: KDef, +rest: List<&2,KDef>, +name: String) -> KDef:
  match hit:
    case True{}: d
    case False{}: lookup(rest, name)

@unsafe
def w5c2_lookup_cache(is_c: Bool, +d: KDef, +dname: String, +rest: List<&2,KDef>, +name: String) -> KDef:
  match is_c:
    case True{}: index_lookup(d, name)
    case False{}: w5c2_lookup_eq(String.eq(dname, name), d, rest, name)

@unsafe
def w5c2_lookup_head(+d: KDef, +rest: List<&2,KDef>, +name: String) -> KDef:
  match d:
    case KDef{dname, kind, _, _, _, _, _, _, _}:
      w5c2_lookup_cache(String.eq(kind, "BookCache"), d, dname, rest, name)
    case KIndexLeaf{_, _}:
      w5c2_lookup_eq(String.eq("", name), d, rest, name)
    case KIndexNode{_, _, _, _}:
      w5c2_lookup_eq(String.eq("", name), d, rest, name)

@unsafe
def lookup(book, name):
  match book:
    case Nil{}: missing()
    case Con{+d, +rest}: w5c2_lookup_head(d, rest, name)

# Module: src/core/term.bend:311
@unsafe
def terms_len(
  +ts: List<&2, KTerm>,
) -> U32:
  match ts:
    case Nil{}:
      0
    case Con{h, t}:
      U32.add(1, terms_len(t))

# Module: src/core/term.bend:321
@unsafe
def has_name(
  +ns: List<&2, String>,
  +name: String,
) -> Bool:
  match ns:
    case Nil{}:
      False{}
    case Con{h, t}:
      has_name_next(t, name, p88_string_eq(h, name))

# Module: src/core/term.bend:332
@unsafe
def has_name_next(+rest: List<&2,String>, +name: String, +same: Bool) -> Bool:
  match same:
    case True{}: True{}
    case False{}: has_name(rest, name)
law p177s_entry:
  for t: KTerm
  for id: U32
  for value: KTerm
  KTerm

@unsafe
def subst(+t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  p177s_entry(t,id,v)

# Module: src/core/term.bend:379
@unsafe
def subst_terms(ts, id, v):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{subst(h, id, v), subst_terms(t, id, v)}

# Module: src/core/term.bend:388
@unsafe
def core_force(
  +t: KTerm,
) -> KTerm:
  kc(KTerm, p98_tag_eq(t, "Ann"), u => core_force(kid(t, 0)),
    u => kc(KTerm, p98_tag_eq(t, "Var") && U32.is_gt(terms_len(ks(t)), 0), u => core_force(kid(t, 0)), u => t))

# Module: src/core/term.bend:399
@unsafe
def core_apply_span(+f: KTerm, +x: KTerm, +begin: U32, +end: U32) -> KTerm:
  kc(KTerm, p98_tag_eq(f, "Lam"), u => subst(kid(f, 0), ix(f), x), u => kt_span("App", "", 0, 0, [f, x], begin, end))

# Module: src/core/term.bend:407
@unsafe
def core_beta(
  +t: KTerm,
) -> KTerm:
  kc(KTerm, p98_tag_eq(t, "App"), u => core_apply_span(core_beta(kid(t, 0)), kid(t, 1), kb(t), ke(t)), u => t)

# Scan in substitution order: Var test, children, then App rebuilding.
# A false fact returns to ordinary substitution, preserving its work and errors.
# A canonical App also survives substitution unchanged if both children do and
# its unchanged function is not Lam. Every metadata/arity check is necessary
# because core_rebuild canonicalizes App nodes even without beta reduction.

# Module: src/core/term.bend:427
@unsafe
def core_subst_stable(
  +t: KTerm,
) -> Bool:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      kc(Bool, p88_string_eq(tag, "Var"), u => False{},
        u => kc(Bool, core_subst_stable_terms(kids),
          u => kc(Bool, p88_string_eq(tag, "App"),
            u => kc(Bool, p88_string_eq(name, "") && U32.is_eq(id, 0) && U32.is_eq(quant, 0), u => core_subst_stable_app(kids, removed), u => False{}),
            u => True{}),
          u => False{}))
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      core_subst_stable_terms(kids)
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      True{}

# Module: src/core/term.bend:444
@unsafe
def core_subst_stable_terms(ts):
  match ts:
    case Nil{}: True{}
    case Con{h, rest}:
      kc(Bool, core_subst_stable(h), u => core_subst_stable_terms(rest), u => False{})

# Module: src/core/term.bend:466
@unsafe
def core_subst_stable_app(kids, removed):
  match removed:
    case Con{h, rest}: False{}
    case Nil{}: core_subst_stable_app_kids(kids)

# Module: src/core/term.bend:472
@unsafe
def core_subst_stable_app_kids(kids):
  match kids:
    case Nil{}: False{}
    case Con{f, tail}: core_subst_stable_app_tail(f, tail)

# Module: src/core/term.bend:478
@unsafe
def core_subst_stable_app_tail(f, tail):
  match tail:
    case Nil{}: False{}
    case Con{x, rest}: core_subst_stable_app_last(f, x, rest)

# Module: src/core/term.bend:484
@unsafe
def core_subst_stable_app_last(f, x, rest):
  match rest:
    case Con{h, tail}: False{}
    case Nil{}:
      Bool.not(p98_tag_eq(f, "Lam"))

# Module: src/core/term.bend:491
@unsafe
def norm_join(
  +a: List<&2, KTerm>,
  +b: List<&2, KTerm>,
) -> List<&2, KTerm>:
  match a:
    case Nil{}:
      b
    case Con{h, t}:
      Con{h, norm_join(t, b)}

# Module: src/core/term.bend:507
@unsafe
def norm_defs_join(a, b):
  match a:
    case Nil{}:
      b
    case Con{h, rest}:
      Con{h, norm_defs_join(rest, b)}


# Numeric and string values retain source literal identity until demanded.

# Module: src/core/term.bend:517
@unsafe
def core_literal_type(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), nm(t)) && List.is_empty(&2, String, rm(ty)) && db(lookup(book, nm(t)))

# Module: src/core/term.bend:529
@unsafe
def core_literal_word(+n: U32, +bits: U32, +begin: U32, +end: U32) -> KTerm:
  kc(KTerm, U32.is_eq(bits, 0), u => kt_span("Ctr", "WNil", 0, 1, Nil{}, begin, end),
    u => kt_span("Ctr", "WCon", 0, 1, [kt_span("Ctr", kc(String, U32.is_eq(U32.and(n, 1), 0), u => "False", u => "True"), 0, 1, Nil{}, begin, end), core_literal_word(U32.shrn(n, 1n), U32.sub(bits, 1), begin, end)], begin, end))

# Module: src/core/term.bend:534
@unsafe
def core_literal_step(+t: KTerm) -> KTerm:
  kc(KTerm, p88_string_eq(nm(t), "Nat"),
    u => kc(KTerm, U32.is_eq(kl_number(t), 0), u => kt_span("Ctr", "Zero", 0, 1, Nil{}, kb(t), ke(t)), u => kt_span("Ctr", "Succ", 0, 1, [KLiteral{"Nat", U32.sub(kl_number(t), 1), "", kb(t), ke(t)}], kb(t), ke(t))),
    u => kc(KTerm, p88_string_eq(nm(t), "String"), u => core_literal_string(kl_text(t), kb(t), ke(t)),
      u => kt_span("Ctr", nm(t), 0, 1, [core_literal_word(kl_number(t), 32, kb(t), ke(t))], kb(t), ke(t))))

# Module: src/core/term.bend:541
@unsafe
def core_literal_string(+s: String, +begin: U32, +end: U32) -> KTerm:
  match s:
    case SNil{}: kt_span("Ctr", "SNil", 0, 1, Nil{}, begin, end)
    case SCon{c, rest}: kt_span("Ctr", "SCon", 0, 1, [kt_span("Ctr", "Chr", 0, 1, [KLiteral{"U32", Char.to_u32(c), "", begin, end}], begin, end), KLiteral{"String", 0, rest, begin, end}], begin, end)

# Module: src/core/term.bend:547
@unsafe
def core_literal_same(+a: KTerm, +b: KTerm) -> Bool:
  p88_string_eq(nm(a), nm(b)) && U32.is_eq(kl_number(a), kl_number(b)) && p88_string_eq(kl_text(a), kl_text(b))

# Source ranges are non-semantic metadata. Zero/zero is absent; positive
# inclusive-start/exclusive-end coordinates belong to one source interval.

# Module: src/core/term.bend:557
@unsafe
def kb(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      originBegin
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      begin
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      literalBegin

# Module: src/core/term.bend:567
@unsafe
def ke(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      originEnd
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      end
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      literalEnd

# Replace only semantic children; every other immutable field is preserved.

# Module: src/core/term.bend:582
@unsafe
def k_with_children(+t: KTerm, +newKids: List<&2,KTerm>) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, oldKids, removed, originBegin, originEnd}:
      KTerm{tag, name, id, quant, newKids, removed, originBegin, originEnd}

# Explicit replacement does not guess or inherit an occurrence.
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      KLambda{name, id, quant, newKids, removed, begin, end, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      t

# Module: src/core/term.bend:594
@unsafe
def kt_span(+tag: String, +name: String, +id: U32, +quant: U32,
  +kids: List<&2,KTerm>, +begin: U32, +end: U32) -> KTerm:
  KTerm{tag, name, id, quant, kids, Nil{}, begin, end}

# Interpreted literal leaves are closed; payload is never a binder or quantity.

# Module: src/core/term.bend:610
@unsafe
def core_literal(+t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: False{}
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      False{}
    case KLiteral{kind, number, text, begin, end}: True{}

# Module: src/core/term.bend:618
@unsafe
def kl_number(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      0
    case KLiteral{kind, number, text, begin, end}: number

# Module: src/core/term.bend:626
@unsafe
def kl_text(+t: KTerm) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: ""
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      ""
    case KLiteral{kind, number, text, begin, end}: text

# Module: src/core/term.bend:634
@unsafe
def k_lam(+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +begin: U32, +end: U32, +present: Bool) -> KTerm:
  KLambda{name, id, quant, kids, Nil{}, begin, end, present}

# Module: src/core/term.bend:644
@unsafe
def k_quantity_present(+t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: p88_string_eq(tag, "Lam")
    case KLambda{name, id, quant, kids, removed, begin, end, present}: present
    case KLiteral{kind, number, text, begin, end}: False{}

# Field-changing structural rebuilds retain the input variant and syntax fact.

# Module: src/core/term.bend:652
@unsafe
def k_rebuild(+t: KTerm, +name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, oldName, oldId, oldQuant, oldKids, oldRemoved, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, kids, removed, begin, end}
    case KLambda{oldName, oldId, oldQuant, oldKids, oldRemoved, oldBegin, oldEnd, present}:
      KLambda{name, id, quant, kids, removed, begin, end, present}
    case KLiteral{kind, number, text, oldBegin, oldEnd}: t

# Module: src/core/index.bend:26
@unsafe
def index_hash(
  +name: String,
  +acc: U32,
) -> U32:
  match name:
    case SNil{}:
      acc
    case SCon{h, rest}:
      index_hash(rest, U32.mul(U32.xor(acc, Char.to_u32(h)), 16777619))

# Module: src/core/index.bend:37
@unsafe
def index_child(
  +tree: KDef,
  +right: Bool,
) -> KDef:
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      index_child_list(ctors, right)
    case KIndexLeaf{hash, bucket}: index_child_list(bucket, right)
    case KIndexNode{hash, mask, left, next}:
      match right:
        case False{}: left
        case True{}: next

# Module: src/core/index.bend:51
@unsafe
def index_child_list(ds, right):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      match right:
        case True{}: index_first(rest)
        case False{}: h

# Module: src/core/index.bend:61
@unsafe
def index_first(ds):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      h

# The public callers supply complete 32-bit hashes. `bits` remains in this
# internal ABI for the native identifier validator; paths use stored masks.

# Module: src/core/index.bend:71
law index_find:
  for +tree: KDef
  for +name: String
  for +hash: U32
  for +bits: U32
  KDef

@unsafe
def w5_idx_bucket_if(ok: Bool, bucket: List<&2, KDef>, +name: String) -> KDef:
  match ok:
    case True{}: index_bucket(bucket, name)
    case False{}: missing()

@unsafe
def w5c_idx_find_lr(bit: U32, left: KDef, right: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match bit:
    case 0: index_find(left, name, hash, bits)
    case _: index_find(right, name, hash, bits)

@unsafe
def w5_idx_find_kdef_t(isLeaf: Bool, +arity: U32, +templates: U32, +ctors: List<&2, KDef>, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isLeaf:
    case True{}: w5_idx_bucket_if(U32.is_eq(arity, hash), ctors, name)
    case False{}: index_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)

@unsafe
def w5_idx_find_kdef(isAbs: Bool, +arity: U32, +templates: U32, +ctors: List<&2, KDef>, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isAbs:
    case True{}: missing()
    case False{}: w5_idx_find_kdef_t(U32.is_eq(templates, 0), arity, templates, ctors, name, hash, bits)

@unsafe
def index_find(tree, name, hash, bits):
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      w5_idx_find_kdef(String.eq(kind, "Absent"), arity, templates, ctors, name, hash, bits)
    case KIndexLeaf{stored, bucket}:
      w5_idx_bucket_if(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, mask, left, right}:
      w5c_idx_find_lr(U32.and(hash, mask), left, right, name, hash, bits)

@unsafe
def w5_idx_bkt_hit(hit: Bool, h: KDef, rest: List<&2, KDef>, +name: String) -> KDef:
  match hit:
    case True{}: h
    case False{}: index_bucket(rest, name)

# Module: src/core/index.bend:126
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{+h, rest}:
      w5_idx_bkt_hit(String.eq(dn(h), name), h, rest, name)

# Module: src/core/index.bend:134
@unsafe
def index_remove(
  +ds: List<&2, KDef>,
  +name: String,
) -> List<&2, KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      index_remove_step(h, rest, name, agy_str_eq(dn(h), name))

# Module: src/core/index.bend:145
@unsafe
def index_remove_step(
  +h: KDef, +rest: List<&2, KDef>, +name: String, +same: Bool,
) -> List<&2, KDef>:
  match same:
    case True{}: index_remove(rest, name)
    case False{}: Con{h, index_remove(rest, name)}

# Module: src/core/index.bend:153
law index_tip:
  for +tree: KDef
  for +hash: U32
  KDef

@unsafe
def w5_idx_tip_br(goLeft: Bool, left: KDef, right: KDef, +hash: U32) -> KDef:
  match goLeft:
    case True{}: index_tip(left, hash)
    case False{}: index_tip(right, hash)

@unsafe
def w5_idx_tip_node(isLeaf: Bool, +tree: KDef, +mask: U32, left: KDef, right: KDef, +hash: U32) -> KDef:
  match isLeaf:
    case True{}: tree
    case False{}: w5_idx_tip_br(U32.is_eq(U32.and(hash, mask), 0), left, right, hash)

@unsafe
def w5_idx_tip_kdef(isLeaf: Bool, +tree: KDef, +templates: U32, +hash: U32) -> KDef:
  match isLeaf:
    case True{}: tree
    case False{}: index_tip(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), hash)

@unsafe
def index_tip(tree, hash):
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      w5_idx_tip_kdef(U32.is_eq(templates, 0), tree, templates, hash)
    case KIndexLeaf{stored, bucket}: tree
    case KIndexNode{stored, mask, left, right}:
      w5_idx_tip_node(U32.is_eq(mask, 0), tree, mask, left, right, hash)

# U32 subtraction wraps: x & (0 - x) isolates its lowest set bit, or 0.

# Module: src/core/index.bend:169
@unsafe
def index_split_bit(
  +diff: U32,
) -> U32:
  U32.and(diff, U32.sub(0, diff))

# Module: src/core/index.bend:175
@unsafe
def index_leaf(
  +d: KDef,
  +hash: U32,
  +ds: List<&2, KDef>,
) -> KDef:
  KIndexLeaf{hash, Con{d, index_remove(ds, dn(d))}}

# Module: src/core/index.bend:183
@unsafe
def index_node(
  +hash: U32,
  +mask: U32,
  +left: KDef,
  +right: KDef,
) -> KDef:
  KIndexNode{hash, mask, left, right}

# Module: src/core/index.bend:192
@unsafe
def w5_idx_join_if(goLeft: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match goLeft:
    case True{}: index_node(da(tree), mask, index_leaf(d, hash, Nil{}), tree)
    case False{}: index_node(da(tree), mask, tree, index_leaf(d, hash, Nil{}))

@unsafe
def index_join(
  +tree: KDef,
  +d: KDef,
  +hash: U32,
  +mask: U32,
) -> KDef:
  w5_idx_join_if(U32.is_eq(U32.and(hash, mask), 0), tree, d, hash, mask)

law index_insert:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +mask: U32
  KDef

law index_insert_legacy:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +mask: U32
  KDef

@unsafe
def w5_idx_ins_leaf(isZero: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32, bucket: List<&2, KDef>) -> KDef:
  match isZero:
    case True{}: index_leaf(d, hash, bucket)
    case False{}: index_join(tree, d, hash, mask)

@unsafe
def w5_idx_ins_br(goLeft: Bool, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match goLeft:
    case True{}: index_node(stored, split, index_insert(left, d, hash, mask), right)
    case False{}: index_node(stored, split, left, index_insert(right, d, hash, mask))

@unsafe
def w5_idx_ins_split(doJoin: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match doJoin:
    case True{}: index_join(tree, d, hash, mask)
    case False{}: w5_idx_ins_br(U32.is_eq(U32.and(hash, split), 0), stored, split, left, right, d, hash, mask)

@unsafe
def w5_idx_ins_node(isZero: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match isZero:
    case True{}: index_insert_legacy(tree, d, hash, mask)
    case False{}: w5_idx_ins_split(Bool.not(U32.is_eq(mask, 0)) && U32.is_lt(mask, split), tree, stored, split, left, right, d, hash, mask)

# Module: src/core/index.bend:203
@unsafe
def index_insert(tree, d, hash, mask):
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      index_insert_legacy(tree, d, hash, mask)
    case KIndexLeaf{stored, bucket}:
      w5_idx_ins_leaf(U32.is_eq(mask, 0), tree, d, hash, mask, bucket)
    case KIndexNode{stored, split, left, right}:
      w5_idx_ins_node(U32.is_eq(split, 0), tree, stored, split, left, right, d, hash, mask)

# Module: src/core/index.bend:224
@unsafe
def index_insert_legacy(tree, d, hash, mask):
  kc(KDef, Bool.not(U32.is_eq(mask, 0)) && (U32.is_eq(dx(tree), 0) || U32.is_lt(mask, dx(tree))),
    u => index_join(tree, d, hash, mask),
    u => kc(KDef, U32.is_eq(dx(tree), 0),
      u => index_leaf(d, hash, dc(tree)),
      u => kc(KDef, U32.is_eq(U32.and(hash, dx(tree)), 0),
        u => index_node(da(tree), dx(tree), index_insert(index_child(tree, False{}), d, hash, mask), index_child(tree, True{})),
        u => index_node(da(tree), dx(tree), index_child(tree, False{}), index_insert(index_child(tree, True{}), d, hash, mask)))))

# Module: src/core/index.bend:239
@unsafe
def index_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  p131i_insert(tree, d, hash)

@unsafe
def index_build(
  +book: List<&2, KDef>,
) -> KDef:
  match book:
    case Nil{}:
      missing()
    case Con{h, rest}:
      index_set(index_build(rest), h, index_hash(dn(h), 2166136261), 32)

# Module: src/core/index.bend:259
@unsafe
def index_lookup(cache, name):
  index_find(index_first(dc(cache)), name, index_hash(name, 2166136261), 32)

# Module: src/core/index.bend:263
@unsafe
def book_cached(
  +book: List<&2, KDef>,
  +bound: U32,
) -> List<&2, KDef>:
  Con{KDef{"$kernel.cache", "BookCache", bound, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_build(book), Nil{}}, True{}, False{}}, book}

# A cached name miss proves the declaration list contains nothing to remove.
# Missing definitions have the empty name. Preserve the generic empty-name case
# through filtering, even for malformed/duplicate books supplied through the API.

# Module: src/core/index.bend:273
@unsafe
def index_put_rest(
  +cache: KDef,
  +rest: List<&2, KDef>,
  +name: String,
) -> List<&2, KDef>:
  kc(List<&2, KDef>, Bool.not(p88_string_eq(name, "")) && p88_string_eq(dn(index_lookup(cache, name)), ""),
    u => rest, u => index_remove(rest, name))

# Module: src/core/index.bend:282
@unsafe
def book_put(
  +book: List<&2, KDef>,
  +d: KDef,
) -> List<&2, KDef>:
  match book:
    case Nil{}:
      Con{d, Nil{}}
    case Con{h, rest}:
      kc(List<&2, KDef>, p88_string_eq(dk(h), "BookCache"), u => Con{KDef{dn(h), dk(h), da(h), 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_set(index_first(dc(h)), d, index_hash(dn(d), 2166136261), 32), Nil{}}, True{}, False{}}, Con{d, index_put_rest(h, rest, dn(d))}}, u => Con{d, index_remove(book, dn(d))})


# An immutable context may be reused by several backend phases. Never nest the
# sentinel or recompute its maximum binder ID from the index's implementation.

# Module: src/core/index.bend:296
@unsafe
def norm_apply(
  +t: KTerm,
  +args: List<&2, KTerm>,
) -> KTerm:
  match args:
    case Nil{}:
      t
    case Con{h, rest}:
      norm_apply(app(t, h), rest)

# Module: src/core/normalize.bend:17
@unsafe
def wnf(
  +book: List<&2, KDef>,
  +t: KTerm,
) -> KTerm:
  norm_eval(book, t, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/core/normalize.bend:32
@unsafe
def norm_eval_node(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
) -> KTerm:
  norm_node_app(book, t, args, left, fallback, p98_tag_eq(t, "App"))

# Module: src/core/normalize.bend:42
@unsafe
def norm_node_app(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_eval(book, kid(t, 0), Con{kid(t, 1), args}, left, fallback)
    case False{}:
      norm_node_ann(book, t, args, left, fallback, p98_tag_eq(t, "Ann"))

# Module: src/core/normalize.bend:57
@unsafe
def norm_node_ann(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_eval(book, kid(t, 0), args, left, fallback)
    case False{}:
      norm_node_let(book, t, args, left, fallback, p98_tag_eq(t, "Let"))

# Module: src/core/normalize.bend:72
@unsafe
def norm_node_let(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_eval(book, norm_let(ks(t)), args, left, fallback)
    case False{}:
      norm_node_ref(book, t, args, left, fallback, p98_tag_eq(t, "Ref"))

# Module: src/core/normalize.bend:87
@unsafe
def norm_node_ref(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_ref(book, t, args, lookup(book, nm(t)))
    case False{}:
      norm_node_min(book, t, args, left, fallback, p98_tag_eq(t, "Min"))

# Module: src/core/normalize.bend:102
@unsafe
def norm_node_min(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_apply(norm_min(book, kid(t, 0), kid(t, 1)), args)
    case False{}:
      norm_node_rwt(book, t, args, left, fallback, p98_tag_eq(t, "Rwt"))

# Module: src/core/normalize.bend:117
@unsafe
def norm_node_rwt(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      kc(KTerm, p98_tag_eq(wnf(book, kid(t, 0)), "Rfl"), u => norm_eval(book, kid(t, 2), args, left, fallback), u => norm_apply(t, args))
    case False{}:
      norm_args(book, t, args, left, fallback)

# Module: src/core/normalize.bend:139
@unsafe
def norm_ref(book, t, args, d):
  kc(KTerm, p88_string_eq(dk(d), "ADT"), u => kc(KTerm, U32.is_eq(da(d), 0), u => norm_apply(kt_span("ADT", nm(t), 0, 0, Nil{}, kb(t), ke(t)), args), u => norm_apply(t, args)), u => kc(KTerm, Bool.and(Bool.not(p98_tag_eq(dv(d), "Absent") || p98_tag_eq(dv(d), "Foreign")), U32.is_le(da(d), terms_len(args))), u => norm_eval(book, dv(d), args, da(d), norm_apply(t, args)), u => norm_apply(t, args)))

# Module: src/core/normalize.bend:150
@unsafe
def norm_args(book, t, args, left, fallback):
  match args:
    case Nil{}:
      t
    case Con{x, rest}:
      kc(KTerm, p98_tag_eq(t, "Lam"), u => norm_eval(book, subst(kid(t, 0), ix(t), x), rest, norm_dec(left), fallback), u => kc(KTerm, p98_tag_eq(t, "Mat"), u => norm_match(book, t, t, x, wnf(book, x), rest, left, fallback), u => kc(KTerm, Bool.and(p98_tag_eq(t, "Efq"), Bool.not(U32.is_eq(left, 0))), u => fallback, u => norm_apply(t, args))))

# Module: src/core/normalize.bend:161
@unsafe
def norm_dec(n):
  kc(U32, U32.is_eq(n, 0), u => 0, u => U32.sub(n, 1))

# Module: src/core/normalize.bend:175
@unsafe
def norm_match(book, arm, original, raw, x, args, left, fallback):
  kc(KTerm, core_literal(x), u => norm_match(book, arm, original, raw, core_literal_step(x), args, left, fallback), u =>
  kc(KTerm, p98_tag_eq(x, "Ctr"), u => kc(KTerm, p98_tag_eq(arm, "Ann"), u => norm_match(book, kid(arm, 0), original, raw, x, args, left, fallback), u => kc(KTerm, p98_tag_eq(arm, "Mat"), u => kc(KTerm, p88_string_eq(nm(arm), nm(x)), u => kc(KTerm, U32.is_eq(left, 0), u => norm_eval(book, kid(arm, 0), norm_join(ks(x), args), 0, fallback), u => norm_eval(book, kid(arm, 0), norm_join(ks(x), args), U32.add(norm_dec(left), terms_len(ks(x))), fallback)), u => norm_match(book, kid(arm, 1), original, raw, x, args, left, fallback)), u => kc(KTerm, p98_tag_eq(arm, "Efq"), u => norm_stuck(original, raw, args, left, fallback), u => norm_eval(book, arm, Con{x, args}, left, fallback)))), u => norm_stuck(original, raw, args, left, fallback)))

# Module: src/core/normalize.bend:187
@unsafe
def norm_stuck(t, x, args, left, fallback):
  kc(KTerm, U32.is_eq(left, 0), u => norm_apply(app(t, x), args), u => fallback)

# Module: src/core/normalize.bend:196
@unsafe
def norm_min(book, a, b):
  norm_min_left(book, wnf(book, a), b)

# Module: src/core/normalize.bend:206
@unsafe
def norm_min_left(book, a, b):
  kc(KTerm, Bool.and(p98_tag_eq(a, "Qua"), U32.is_eq(qt(a), 2)), u => wnf(book, b), u => kc(KTerm, Bool.and(p98_tag_eq(a, "Qua"), U32.is_eq(qt(a), 0)), u => a, u => norm_min_right(a, wnf(book, b))))

# Module: src/core/normalize.bend:214
@unsafe
def norm_min_right(a, b):
  kc(KTerm, p98_tag_eq(b, "Qua"), u => kc(KTerm, U32.is_eq(qt(b), 2), u => a, u => kc(KTerm, Bool.and(U32.is_eq(qt(b), 1), Bool.not(p98_tag_eq(a, "Qua"))), u => kt("Min", "", 0, 0, Con{a, Con{b, Nil{}}}), u => b)), u => kt("Min", "", 0, 0, Con{a, Con{b, Nil{}}}))

# Module: src/core/normalize.bend:224
@unsafe
def norm_max(
  +a: U32,
  +b: U32,
) -> U32:
  U32.max(a, b)

# Module: src/core/normalize.bend:230
@unsafe
def norm_max_term(
  +t: KTerm,
) -> U32:
  norm_max_walk(Con{t, Nil{}}, 0)

# Module: src/core/normalize.bend:240
@unsafe
def norm_max_book(book):
  norm_max_defs(book, 0)

# Module: src/core/normalize.bend:244
@unsafe
def compare(
  +book: List<&2, KDef>,
  +a: KTerm,
  +b: KTerm,
  +le: Bool,
) -> Bool:
  kc(Bool, norm_exact(a, b), u => True{}, u => norm_convert(book, a, b, le, U32.add(1, norm_max(norm_book_bound(book), norm_max(norm_max_term(a), norm_max_term(b))))))

# Module: src/core/normalize.bend:261
@unsafe
def norm_subset(
  +as: List<&2, String>,
  +bs: List<&2, String>,
) -> Bool:
  match bs:
    case Nil{}:
      True{}
    case Con{h, t}:
      Bool.and(has_name(as, h), norm_subset(as, t))

# Module: src/core/normalize.bend:276
@unsafe
def norm_removed(
  +as: List<&2, String>,
  +bs: List<&2, String>,
  +le: Bool,
) -> Bool:
  kc(Bool, le, u => norm_subset(as, bs), u => Bool.and(U32.is_eq(norm_names_len(as), norm_names_len(bs)), norm_subset(as, bs)))

# Module: src/core/normalize.bend:287
@unsafe
def norm_let(ts):
  match ts:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, rest}:
      norm_let_tail(h, rest)

# Module: src/core/normalize.bend:300
@unsafe
def norm_let_tail(h, rest):
  match rest:
    case Nil{}:
      h
    case Con{x, xs}:
      subst(norm_let(rest), ix(h), kid(h, 0))

# Module: src/core/normalize.bend:309
@unsafe
def norm_eval(book, t, args, left, fallback):
  kc(KTerm, p98_tag_eq(t, "Var"), u => norm_var(book, t, ks(t), args, left, fallback), u => norm_eval_node(book, t, args, left, fallback))

# Module: src/core/normalize.bend:322
@unsafe
def norm_var(book, t, values, args, left, fallback):
  match values:
    case Nil{}:
      norm_apply(t, args)
    case Con{h, rest}:
      norm_eval(book, h, args, left, fallback)

# Module: src/core/normalize.bend:334
@unsafe
def norm_names_len(names):
  match names:
    case Nil{}:
      0
    case Con{h, rest}:
      U32.add(1, norm_names_len(rest))

# The book checker computes this immutable bound once per source book. Public
# callers without a stamp retain the complete scan, so fresh IDs stay sound.

# Module: src/core/normalize.bend:353
@unsafe
def norm_book_bound(book):
  match book:
    case Nil{}:
      0
    case Con{h, rest}:
      kc(U32, p88_string_eq(dk(h), "BookCache"), u => da(h), u => norm_bound_found(book, lookup(book, "$kernel.max-id")))

# Module: src/core/normalize.bend:361
@unsafe
def norm_bound_found(book, stamp):
  kc(U32, p88_string_eq(dk(stamp), "BookBound"), u => da(stamp), u => norm_max_book(book))

# Strong normalization uses an explicit traversal stack. Each opened binder
# receives a fresh identity even when the same recursive definition unfolds
# repeatedly underneath another copy of its binder.

# Module: src/core/normalize.bend:381
@unsafe
def norm_max_walk(todo, bound):
  match todo:
    case Nil{}:
      bound
    case Con{h, rest}:
      norm_max_walk(norm_join(ks(h), rest), norm_max(bound, ix(h)))

# Module: src/core/normalize.bend:389
@unsafe
def norm_max_defs(todo, bound):
  match todo:
    case Nil{}:
      bound
    case Con{h, rest}:
      norm_max_defs(norm_defs_join(dc(h), rest), norm_max(bound, norm_max(norm_max_term(dt(h)), norm_max_term(dv(h)))))

# Syntactic reflexivity precedes evaluation, as pointer reflexivity does in
# upstream. Cell contents are included; different stored values never match.

# Module: src/core/normalize.bend:426
@unsafe
def norm_exact(a, b):
  norm_exact_lists(Con{a, Nil{}}, Con{b, Nil{}})

# Module: src/core/normalize.bend:430
@unsafe
def norm_exact_lists(as, bs):
  match as bs:
    case Nil{} Nil{}:
      True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, norm_exact_head(a, b), u => norm_exact_lists(norm_join(ks(a), ar), norm_join(ks(b), br)), u => False{})
    case other_a other_b:
      False{}

# Module: src/core/normalize.bend:440
@unsafe
def norm_exact_head(a, b):
  p98_tag_eq(a, tg(b)) && kc(Bool, core_literal(a), u => core_literal_same(a, b), u => True{}) && p88_string_eq(nm(a), nm(b)) && U32.is_eq(ix(a), ix(b)) && U32.is_eq(qt(a), qt(b)) && U32.is_eq(terms_len(ks(a)), terms_len(ks(b))) && norm_exact_names(rm(a), rm(b))

# Module: src/core/normalize.bend:444
@unsafe
def norm_exact_names(as, bs):
  match as bs:
    case Nil{} Nil{}:
      True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, p88_string_eq(a, b), u => norm_exact_names(ar, br), u => False{})
    case other_a other_b:
      False{}

# Comparison is a worklist of conjunctions with explicit alternatives for
# the right-hand kind meet. Deep constructor equality does not grow the host stack.
# The empty-book pass proves symbolic copies before unfolding definitions.
# Each policy owns its heap. A failed rigid comparison cannot cache an opaque
# head in the full-book pass, or share cells across independent conversions.

# Module: src/core/normalize.bend:467
@unsafe
def norm_convert(book, a, b, le, fresh):
  kc(Bool, norm_cmp_loop(Nil{}, GState{GEmpty{}, 1}, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}),
    u => True{}, u => norm_cmp_loop(book, GState{GEmpty{}, 1}, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}))

# Endpoints exposed by graph evaluation belong to its heap. Both policies start
# from that same immutable input; failed rigid evaluation cannot enter the retry.
@unsafe
def norm_convert_state(+book: List<&2,KDef>, +st: GState, +a: KTerm,
  +b: KTerm, +le: Bool, +fresh: U32) -> Bool:
  kc(Bool, norm_cmp_loop(Nil{}, st, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}),
    u => True{}, u => norm_cmp_loop(book, st, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}))

# A sharing item runs only after its EQ obligations succeed. It joins separate
# equivalence classes; moving either value could make a cell name itself.
# Proven EQ classes discharge both EQ and LE comparisons. Directional LE alone
# never joins classes. Alternatives retain their continuation while proven
# equality and evaluation may persist inside this one heap identity.

@unsafe
def norm_cmp_shared(+st: GState, +a: KTerm, +b: KTerm) -> Bool:
  p98_tag_eq(a,"GCell") && p98_tag_eq(b,"GCell") && g_class_same(st,ix(a),ix(b))

# Module: src/core/normalize.bend:555
@unsafe
def norm_cmp_loop(book, st, todo, alts):
  match todo:
    case Nil{}:
      True{}
    case Con{KNormShare{left, right}, rest}:
      norm_cmp_loop(book, g_class_join(st,left,right), rest, alts)
    case Con{KNormCmp{a, b, le, fresh}, rest}:
      kc(Bool, norm_cmp_quick(a, b) || norm_cmp_shared(st,a,b), u => norm_cmp_loop(book, st, rest, alts),
        u => norm_cmp_left(book, b, le, fresh,
          kc(List<&2, KNormCmp>, Bool.not(le) && p98_tag_eq(a, "GCell") && p98_tag_eq(b, "GCell"),
            u => Con{KNormShare{ix(a), ix(b)}, rest}, u => rest), alts, g_wnf(book, st, a)))

# Module: src/core/normalize.bend:568
@unsafe
def norm_cmp_quick(a, b):
  kc(Bool, p98_tag_eq(a, "App") || p98_tag_eq(a, "Ref") || p98_tag_eq(a, "Var") || p98_tag_eq(a, "GCell"), u => norm_exact(a, b), u => False{})

# Module: src/core/normalize.bend:572
@unsafe
def norm_cmp_fail(
  +book: List<&2, KDef>,
  +st: GState,
  +alts: List<&2, KNormAlt>,
) -> Bool:
  match alts:
    case Nil{}:
      False{}
    case Con{KNormAlt{todo}, rest}:
      norm_cmp_loop(book, st, todo, rest)

# Module: src/core/normalize.bend:584
@unsafe
def norm_cmp_test(
  +book: List<&2, KDef>,
  +st: GState,
  +yes: Bool,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
) -> Bool:
  kc(Bool, yes, u => norm_cmp_loop(book, st, rest, alts), u => norm_cmp_fail(book, st, alts))

# Module: src/core/normalize.bend:594
@unsafe
def norm_cmp_heads(book, st, a, b, le, fresh, rest, alts):
  kc(Bool, p98_tag_eq(a, "Lam") || p98_tag_eq(b, "Lam"),
   u => norm_cmp_loop(book, st, Con{KNormCmp{app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.add(fresh, 1)}, rest}, alts),
   u => kc(Bool, core_literal(a) && p98_tag_eq(b, "Ctr"), u => norm_cmp_heads(book, st, core_literal_step(a), b, le, fresh, rest, alts),
   u => kc(Bool, core_literal(b) && p98_tag_eq(a, "Ctr"), u => norm_cmp_heads(book, st, a, core_literal_step(b), le, fresh, rest, alts),
   u => kc(Bool, p98_tag_eq(a, tg(b)), u => norm_cmp_same(book, st, a, b, le, fresh, rest, alts), u => norm_cmp_fail(book, st, alts)))))

# Module: src/core/normalize.bend:602
@unsafe
def norm_cmp_same(book, st, a, b, le, fresh, rest, alts):
  kc(Bool, p98_tag_eq(a, "Var"), u => norm_cmp_test(book, st, U32.is_eq(ix(a), ix(b)), rest, alts),
   u => kc(Bool, p98_tag_eq(a, "Typ"), u => kc(Bool, le,
     u => norm_cmp_kind_left(book, a, b, fresh, rest, alts, g_wnf(book, st, kid(a, 0))),
     u => norm_cmp_loop(book, st, Con{KNormCmp{kid(a, 0), kid(b, 0), False{}, fresh}, rest}, alts)),
   u => kc(Bool, p98_tag_eq(a, "All"), u => kc(Bool, U32.is_eq(qt(a), qt(b)),
     u => norm_cmp_loop(book, st, Con{KNormCmp{kid(b, 0), kid(a, 0), le, fresh}, Con{KNormCmp{subst(kid(a, 1), ix(a), var("_", fresh)), subst(kid(b, 1), ix(b), var("_", fresh)), le, U32.add(fresh, 1)}, rest}}, alts), u => norm_cmp_fail(book, st, alts)),
   u => kc(Bool, p98_tag_eq(a, "ADT"), u => kc(Bool, p88_string_eq(nm(a), nm(b)) && norm_removed(rm(a), rm(b), le), u => norm_cmp_fields(book, st, ks(a), ks(b), fresh, rest, alts), u => norm_cmp_fail(book, st, alts)),
   u => kc(Bool, p98_tag_eq(a, "Qua"), u => norm_cmp_test(book, st, U32.is_eq(qt(a), qt(b)), rest, alts),
   u => norm_cmp_plain(book, st, a, b, le, fresh, rest, alts))))))

# Module: src/core/normalize.bend:614
@unsafe
def norm_cmp_plain(book, st, a, b, le, fresh, rest, alts):
  kc(Bool, core_literal(a) && core_literal(b), u => norm_cmp_test(book, st, core_literal_same(a, b), rest, alts), u =>
  kc(Bool, p98_tag_eq(a, "Ref"), u => kc(Bool, p88_string_eq(nm(a), nm(b)), u => norm_cmp_loop(book, st, rest, alts), u => norm_cmp_ref(book, st, a, b, le, norm_max(da(lookup(book, nm(a))), da(lookup(book, nm(b)))), fresh, rest, alts)),
   u => kc(Bool, p98_tag_eq(a, "Hol"), u => norm_cmp_test(book, st, p88_string_eq(nm(a), nm(b)), rest, alts),
   u => kc(Bool, p98_tag_eq(a, "Ctr") || p98_tag_eq(a, "Mat"), u => kc(Bool, p88_string_eq(nm(a), nm(b)), u => norm_cmp_fields(book, st, ks(a), ks(b), fresh, rest, alts), u => norm_cmp_fail(book, st, alts)),
   u => kc(Bool, p98_tag_eq(a, "App") && p98_tag_eq(kid(a, 0), "Ref") && p98_tag_eq(kid(b, 0), "Ref"), u => kc(Bool, p88_string_eq(nm(kid(a, 0)), nm(kid(b, 0))), u => norm_cmp_loop(book, st, Con{KNormCmp{kid(a, 1), kid(b, 1), False{}, fresh}, rest}, alts), u => norm_cmp_fail(book, st, alts)),
   u => kc(Bool, p98_tag_eq(a, "App") || p98_tag_eq(a, "Min") || p98_tag_eq(a, "Eql") || p98_tag_eq(a, "Rwt"), u => norm_cmp_fields(book, st, ks(a), ks(b), fresh, rest, alts),
   u => norm_cmp_test(book, st, p98_tag_eq(a, "Qnt") || p98_tag_eq(a, "Rfl") || p98_tag_eq(a, "Efq"), rest, alts)))))))

# Only bare, under-applied definitions compare extensionally. Stuck App heads
# above stay nominal, avoiding repeated eta expansion of an opaque application.

# Module: src/core/normalize.bend:626
@unsafe
def norm_cmp_ref(
  +book: List<&2, KDef>,
  +st: GState,
  +a: KTerm,
  +b: KTerm,
  +le: Bool,
  +n: U32,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
) -> Bool:
  kc(Bool, U32.is_eq(n, 0), u => norm_cmp_fail(book, st, alts),
   u => kc(Bool, U32.is_eq(n, 1),
     u => norm_cmp_loop(book, st, Con{KNormCmp{app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.add(fresh, 1)}, rest}, alts),
     u => norm_cmp_ref(book, st, app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.sub(n, 1), U32.add(fresh, 1), rest, alts)))

# Module: src/core/normalize.bend:643
@unsafe
def norm_cmp_fields(book, st, as, bs, fresh, rest, alts):
  kc(Bool, U32.is_eq(terms_len(as), terms_len(bs)), u => norm_cmp_loop(book, st, norm_cmp_zip(as, bs, fresh, rest), alts), u => norm_cmp_fail(book, st, alts))

# Module: src/core/normalize.bend:647
@unsafe
def norm_cmp_zip(as, bs, fresh, rest):
  match as bs:
    case Con{a, ar} Con{b, br}:
      Con{KNormCmp{a, b, False{}, fresh}, norm_cmp_zip(ar, br, fresh, rest)}
    case other_a other_b:
      rest

# Module: src/core/normalize.bend:655
@unsafe
def norm_cmp_kind(book, st, a, b, g, h, fresh, rest, alts):
  kc(Bool, (p98_tag_eq(g, "Qua") && U32.is_eq(qt(g), 2)) || (p98_tag_eq(h, "Qua") && Bool.not(U32.is_eq(qt(h), 2))), u => norm_cmp_loop(book, st, rest, alts),
   u => kc(Bool, p98_tag_eq(g, "Min"),
     u => norm_cmp_loop(book, st, Con{KNormCmp{kt("Typ", "", 0, 0, Con{kid(g, 0), Nil{}}), b, True{}, fresh}, Con{KNormCmp{kt("Typ", "", 0, 0, Con{kid(g, 1), Nil{}}), b, True{}, fresh}, rest}}, alts),
   u => kc(Bool, p98_tag_eq(h, "Min"),
     u => norm_cmp_loop(book, st, Con{KNormCmp{a, kt("Typ", "", 0, 0, Con{kid(h, 0), Nil{}}), True{}, fresh}, rest}, Con{KNormAlt{Con{KNormCmp{a, kt("Typ", "", 0, 0, Con{kid(h, 1), Nil{}}), True{}, fresh}, rest}}, alts}),
     u => norm_cmp_loop(book, st, Con{KNormCmp{g, h, True{}, fresh}, rest}, alts))))

# Module: src/core/normalize.bend:665
@unsafe
def norm_cmp_left(
  +book: List<&2, KDef>,
  +b: KTerm,
  +le: Bool,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, a}:
      norm_cmp_right(book, a, le, fresh, rest, alts, g_wnf(book, st, b))

# Module: src/core/normalize.bend:679
@unsafe
def norm_cmp_right(
  +book: List<&2, KDef>,
  +a: KTerm,
  +le: Bool,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, b}:
      norm_cmp_heads(book, st, a, b, le, fresh, rest, alts)

# Module: src/core/normalize.bend:693
@unsafe
def norm_cmp_kind_left(
  +book: List<&2, KDef>,
  +a: KTerm,
  +b: KTerm,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, g}:
      norm_cmp_kind_right(book, a, b, g, fresh, rest, alts, g_wnf(book, st, kid(b, 0)))

# Module: src/core/normalize.bend:707
@unsafe
def norm_cmp_kind_right(
  +book: List<&2, KDef>,
  +a: KTerm,
  +b: KTerm,
  +g: KTerm,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, h}:
      norm_cmp_kind(book, st, a, b, g, h, fresh, rest, alts)

# Module: src/core/graph.bend:209
@unsafe
def g_heap(
  +st: GState,
) -> GHeap:
  match st:
    case GState{heap, next}:
      heap
    case GCompared{heap, next, classes}:
      heap

# Module: src/core/graph.bend:217
@unsafe
def g_next(
  +st: GState,
) -> U32:
  match st:
    case GState{heap, next}:
      next
    case GCompared{heap, next, classes}:
      next

# Every evaluation update preserves the comparison facts of this heap identity.
# Fresh GState constructors still start an independent, empty class relation.
@unsafe
def g_with_heap(+st: GState, +heap: GHeap, +next: U32) -> GState:
  match st:
    case GState{oldHeap,oldNext}: GState{heap,next}
    case GCompared{oldHeap,oldNext,classes}: GCompared{heap,next,classes}

@unsafe
def g_classes(+st: GState) -> GClasses:
  match st:
    case GState{heap,next}: GClassesEmpty{}
    case GCompared{heap,next,classes}: classes

@unsafe
def g_class_get(+classes: GClasses, +id: U32) -> Maybe<&2,GClassEntry>:
  match classes:
    case GClassesEmpty{}: None{}
    case GClassesNode{entry,left,right}:
      kc(Maybe<&2,GClassEntry>,U32.is_eq(id,0),u => entry,
        u => kc(Maybe<&2,GClassEntry>,U32.is_eq(U32.and(id,1),0),
          u => g_class_get(left,U32.shr(id)),u => g_class_get(right,U32.shr(id))))

@unsafe
def g_class_put(+classes: GClasses, +id: U32, +entry: GClassEntry) -> GClasses:
  match classes:
    case GClassesEmpty{}:
      g_class_put(GClassesNode{None{},GClassesEmpty{},GClassesEmpty{}},id,entry)
    case GClassesNode{old,left,right}:
      kc(GClasses,U32.is_eq(id,0),u => GClassesNode{Some{entry},left,right},
        u => kc(GClasses,U32.is_eq(U32.and(id,1),0),
          u => GClassesNode{old,g_class_put(left,U32.shr(id),entry),right},
          u => GClassesNode{old,left,g_class_put(right,U32.shr(id),entry)}))

law g_class_root:
  for +classes: GClasses
  for +id: U32
  U32

@unsafe
def g_class_root_entry(+classes: GClasses, +id: U32, +entry: Maybe<&2,GClassEntry>) -> U32:
  match entry:
    case None{}: id
    case Some{GClassEntry{parent,rank}}:
      kc(U32,U32.is_eq(parent,id),u => id,u => g_class_root(classes,parent))

@unsafe
def g_class_root(classes,id):
  g_class_root_entry(classes,id,g_class_get(classes,id))

@unsafe
def g_class_rank_entry(+entry: Maybe<&2,GClassEntry>) -> U32:
  match entry:
    case None{}: 0
    case Some{GClassEntry{parent,rank}}: rank

@unsafe
def g_class_raise(+classes: GClasses, +id: U32, +rank: U32, +raise: Bool) -> GClasses:
  kc(GClasses,raise,u => g_class_put(classes,id,GClassEntry{id,U32.add(rank,1)}),u => classes)

# Only distinct roots are linked. Rank strictly increases along every link,
# ruling out class cycles without inspecting or rewriting any term value.
@unsafe
def g_class_link(+classes: GClasses, +left: U32, +right: U32,
  +leftRank: U32, +rightRank: U32) -> GClasses:
  kc(GClasses,U32.is_eq(left,right),u => classes,
    u => kc(GClasses,U32.is_lt(leftRank,rightRank),
      u => g_class_put(classes,left,GClassEntry{right,leftRank}),
      u => g_class_put(g_class_raise(classes,left,leftRank,U32.is_eq(leftRank,rightRank)),
        right,GClassEntry{left,rightRank})))

@unsafe
def g_class_join_roots(+st: GState, +classes: GClasses, +left: U32, +right: U32) -> GState:
  kc(GState,U32.is_eq(left,right),u => st,
    u => GCompared{g_heap(st),g_next(st),g_class_link(classes,left,right,
      g_class_rank_entry(g_class_get(classes,left)),g_class_rank_entry(g_class_get(classes,right)))})

@unsafe
def g_class_join(+st: GState, +left: U32, +right: U32) -> GState:
  +classes = g_classes(st)
  g_class_join_roots(st,classes,g_class_root(classes,left),g_class_root(classes,right))

@unsafe
def g_class_same(+st: GState, +left: U32, +right: U32) -> Bool:
  +classes = g_classes(st)
  U32.is_eq(g_class_root(classes,left),g_class_root(classes,right))

# Module: src/core/graph.bend:225
@unsafe
def g_state(
  +r: GResult,
) -> GState:
  match r:
    case GResult{state, term}:
      state

# Module: src/core/graph.bend:233
@unsafe
def g_term(
  +r: GResult,
) -> KTerm:
  match r:
    case GResult{state, term}:
      term

# Module: src/core/graph.bend:241
@unsafe
def g_states(
  +r: GTerms,
) -> GState:
  match r:
    case GTerms{state, terms}:
      state

# Module: src/core/graph.bend:249
@unsafe
def g_terms(
  +r: GTerms,
) -> List<&2, KTerm>:
  match r:
    case GTerms{state, terms}:
      terms

# Module: src/core/graph.bend:257
@unsafe
def g_get(
  +heap: GHeap,
  +id: U32,
) -> KTerm:
  match heap:
    case GEmpty{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case GNode{value, left, right}:
      kc(KTerm, U32.is_eq(id, 0), u => value, u => kc(KTerm, U32.is_eq(U32.and(id, 1), 0), u => g_get(left, U32.shr(id)), u => g_get(right, U32.shr(id))))

# Module: src/core/graph.bend:268
@unsafe
def g_put(
  +heap: GHeap,
  +id: U32,
  +value: KTerm,
) -> GHeap:
  match heap:
    case GEmpty{}:
      g_put_node({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, GEmpty{}, GEmpty{}, id, value)
    case GNode{old, left, right}:
      g_put_node(old, left, right, id, value)

# Module: src/core/graph.bend:280
@unsafe
def g_put_node(old, left, right, id, value):
  kc(GHeap, U32.is_eq(id, 0), u => GNode{value, left, right}, u => kc(GHeap, U32.is_eq(U32.and(id, 1), 0), u => GNode{old, g_put(left, U32.shr(id), value), right}, u => GNode{old, left, g_put(right, U32.shr(id), value)}))

# Module: src/core/graph.bend:284
@unsafe
def g_share(
  +st: GState,
  +t: KTerm,
) -> GResult:
  kc(GResult, p98_tag_eq(t, "GCell"), u => GResult{st, t}, u => GResult{g_with_heap(st, g_put(g_heap(st), g_next(st), kt("GThunk", "", 0, 0, Con{t, Nil{}})), U32.add(g_next(st), 1)), kt("GCell", "", g_next(st), 0, Nil{})})

# Module: src/core/graph.bend:291
@unsafe
def g_share_terms(
  +st: GState,
  +ts: List<&2, KTerm>,
  +done: List<&2, KTerm>,
) -> GTerms:
  match ts:
    case Nil{}:
      GTerms{st, List.reverse(&2, KTerm, done)}
    case Con{h, rest}:
      g_shared_term(rest, done, g_share(st, h))

# Module: src/core/graph.bend:303
@unsafe
def g_shared_term(rest, done, r):
  g_share_terms(g_state(r), rest, Con{g_term(r), done})

# Module: src/core/graph.bend:307
@unsafe
def g_share_head(
  +st: GState,
  +t: KTerm,
) -> GResult:
  kc(GResult, p98_tag_eq(t, "All"), u => g_shared_domain(t, g_share(st, kid(t, 0))),
    u => kc(GResult, p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "ADT") || p98_tag_eq(t, "Mat") || p98_tag_eq(t, "Eql") || p98_tag_eq(t, "Min") || p98_tag_eq(t, "Typ"), u => g_shared_head(t, g_share_terms(st, ks(t), Nil{})), u => GResult{st, t}))

# Module: src/core/graph.bend:315
@unsafe
def g_shared_head(t, r):
  GResult{g_states(r), k_with_children(t, g_terms(r))}

# Module: src/core/graph.bend:319
@unsafe
def g_cache(
  +st: GState,
  +id: U32,
  +t: KTerm,
) -> GState:
  g_with_heap(st, g_put(g_heap(st), id, kt("GValue", "", 0, 0, Con{t, Nil{}})), g_next(st))

# Module: src/core/graph.bend:327
@unsafe
def g_wnf(
  +book: List<&2, KDef>,
  +st: GState,
  +t: KTerm,
) -> GResult:
  g_eval(book, st, t, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{})

# Module: src/core/graph.bend:335
@unsafe
def g_eval(book, st, t, args, pending, fallback, stack):
  kc(GResult, p98_tag_eq(t, "GCell"), u => g_cell(book, st, t, args, pending, fallback, stack, g_get(g_heap(st), ix(t))),
   u => kc(GResult, p98_tag_eq(t, "App"), u => g_app(book, kid(t, 0), args, pending, fallback, stack, g_share(st, kid(t, 1))),
   u => kc(GResult, p98_tag_eq(t, "Ann"), u => g_eval(book, st, kid(t, 0), args, pending, fallback, stack),
   u => kc(GResult, p98_tag_eq(t, "Var") && U32.is_gt(terms_len(ks(t)), 0), u => g_eval(book, st, kid(t, 0), args, pending, fallback, stack),
   u => kc(GResult, p98_tag_eq(t, "Let"), u => g_let(book, st, ks(t), Nil{}, args, pending, fallback, stack),
   u => kc(GResult, p98_tag_eq(t, "Ref"), u => g_ref(book, st, t, args, stack, lookup(book, nm(t))),
   u => kc(GResult, p98_tag_eq(t, "Min"), u => g_eval(book, st, kid(t, 0), Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GMinA{kid(t, 1), args}, stack}),
   u => kc(GResult, p98_tag_eq(t, "Rwt"), u => g_eval(book, st, kid(t, 0), Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GRewrite{t, args, pending, fallback}, stack}),
   u => g_args(book, st, t, args, pending, fallback, stack)))))))))

# Module: src/core/graph.bend:347
@unsafe
def g_cell(book, st, t, args, pending, fallback, stack, cell):
  kc(GResult, p98_tag_eq(cell, "GValue"), u => g_eval(book, st, kid(cell, 0), args, pending, fallback, stack), u => g_eval(book, st, kid(cell, 0), Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GFill{ix(t), args, pending, fallback}, stack}))

# Module: src/core/graph.bend:351
@unsafe
def g_app(book, fn, args, pending, fallback, stack, r):
  g_eval(book, g_state(r), fn, Con{g_term(r), args}, pending, fallback, stack)

# Module: src/core/graph.bend:355
@unsafe
def g_ref(book, st, t, args, stack, d):
  kc(GResult, p88_string_eq(dk(d), "ADT"), u => g_return(book, st, norm_apply(kc(KTerm, U32.is_eq(da(d), 0), u => kt("ADT", nm(t), 0, 0, Nil{}), u => t), args), stack),
   u => kc(GResult, Bool.not(p98_tag_eq(dv(d), "Absent") || p98_tag_eq(dv(d), "Foreign")) && U32.is_le(da(d), terms_len(args)), u => g_eval(book, st, dv(d), args, da(d), norm_apply(t, args), stack), u => g_return(book, st, norm_apply(t, args), stack)))

# Module: src/core/graph.bend:360
@unsafe
def g_args(book, st, t, args, pending, fallback, stack):
  match args:
    case Nil{}:
      g_return(book, st, t, stack)
    case Con{x, rest}:
      kc(GResult, p98_tag_eq(t, "Lam"), u => g_eval(book, st, subst(kid(t, 0), ix(t), x), rest, norm_dec(pending), fallback, stack),
       u => kc(GResult, p98_tag_eq(t, "Mat"), u => g_eval(book, st, x, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GMatch{t, x, rest, pending, fallback}, stack}),
       u => g_return(book, st, kc(KTerm, p98_tag_eq(t, "Efq") && U32.is_gt(pending, 0), u => fallback, u => norm_apply(t, args)), stack)))

# Module: src/core/graph.bend:370
@unsafe
def g_return(book, st, t, stack):
  match stack:
    case Nil{}:
      GResult{st, t}
    case Con{frame, rest}:
      g_resume(book, st, t, frame, rest)

# Module: src/core/graph.bend:378
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
      kc(GResult, p98_tag_eq(t, "Rfl"), u => g_eval(book, st, kid(original, 2), args, pending, fallback, stack), u => g_return(book, st, norm_apply(original, args), stack))

# Module: src/core/graph.bend:392
@unsafe
def g_filled(book, id, args, pending, fallback, stack, r):
  g_eval(book, g_cache(g_state(r), id, g_term(r)), g_term(r), args, pending, fallback, stack)

# Module: src/core/graph.bend:396
@unsafe
def g_min_left(book, st, a, b, args, stack):
  kc(GResult, p98_tag_eq(a, "Qua") && U32.is_eq(qt(a), 2), u => g_eval(book, st, b, args, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, stack),
   u => kc(GResult, p98_tag_eq(a, "Qua") && U32.is_eq(qt(a), 0), u => g_return(book, st, norm_apply(a, args), stack), u => g_eval(book, st, b, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GMinB{a, args}, stack})))

# Module: src/core/graph.bend:401
@unsafe
def g_match(book, st, arm, original, raw, x, args, pending, fallback, stack):
  kc(GResult, core_literal(x), u => g_match(book, st, arm, original, raw, core_literal_step(x), args, pending, fallback, stack), u =>
  kc(GResult, Bool.not(p98_tag_eq(x, "Ctr")), u => g_return(book, st, norm_stuck(original, raw, args, pending, fallback), stack),
   u => kc(GResult, p98_tag_eq(arm, "Ann"), u => g_match(book, st, kid(arm, 0), original, raw, x, args, pending, fallback, stack),
   u => kc(GResult, p98_tag_eq(arm, "Mat"), u => kc(GResult, p88_string_eq(nm(arm), nm(x)),
     u => g_eval(book, st, kid(arm, 0), norm_join(ks(x), args), kc(U32, U32.is_eq(pending, 0), u => 0, u => U32.add(norm_dec(pending), terms_len(ks(x)))), fallback, stack),
     u => g_match(book, st, kid(arm, 1), original, raw, x, args, pending, fallback, stack)),
   u => kc(GResult, p98_tag_eq(arm, "Efq"), u => g_return(book, st, norm_stuck(original, raw, args, pending, fallback), stack), u => g_eval(book, st, arm, Con{x, args}, pending, fallback, stack))))))

# Module: src/core/graph.bend:411
@unsafe
def g_let(book, st, ts, bindings, args, pending, fallback, stack):
  match ts:
    case Nil{}:
      g_return(book, st, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, stack)
    case Con{h, rest}:
      kc(GResult, p98_tag_eq(h, "Bind"), u => g_let_shared(book, h, rest, bindings, args, pending, fallback, stack, g_share(st, kid(h, 0))), u => g_eval(book, st, g_let_sub(h, bindings), args, pending, fallback, stack))

# Module: src/core/graph.bend:419
@unsafe
def g_let_shared(book, h, rest, bindings, args, pending, fallback, stack, r):
  g_let(book, g_state(r), rest, Con{kt("Bind", nm(h), ix(h), qt(h), Con{g_term(r), Nil{}}), bindings}, args, pending, fallback, stack)

# Module: src/core/graph.bend:423
@unsafe
def g_let_sub(t, bindings):
  match bindings:
    case Nil{}:
      t
    case Con{h, rest}:
      g_let_sub(subst(t, ix(h), kid(h, 0)), rest)

# A telescope domain is independent of its own binder; its deferred codomain
# stays outside the cell so opening that binder still substitutes the body.

# Module: src/core/graph.bend:482
@unsafe
def g_shared_domain(+t: KTerm, +r: GResult) -> GResult:
  match r:
    case GResult{state, term}:
      GResult{state, k_with_children(t, Con{term, Con{kid(t, 1), Nil{}}})}

# Module: src/core/reach.bend:70
@unsafe
def kp_eq(
  +a: String,
  +b: String,
) -> Bool:
  p88_string_eq(a, b)

# Module: src/core/pretty.bend:144
@unsafe
def kp_quant(
  +q: U32,
) -> String:
  kc(String, U32.is_eq(q, 0), u => "-", u => kc(String, U32.is_eq(q, 2), u => "+", u => ""))

# Module: src/core/pretty.bend:158
@unsafe
def kp_depth(
  env: List<&2, KPName>,
) -> U32:
  match env:
    case Nil{}: 0
    case Con{KPFile{ns, aliases}, t}: kp_depth(t)
    case Con{KPName{n, i, depth}, t}: U32.add(1, kp_depth(t))

# Module: src/core/pretty.bend:231
@unsafe
def kp_bound(
  env: List<&2, KPName>,
  +name: String,
) -> Bool:
  match env:
    case Nil{}: False{}
    case Con{KPFile{ns, aliases}, t}: kp_bound(t, name)
    case Con{KPName{n, i, depth}, t}: kp_eq(n, name) || kp_bound(t, name)

# Module: src/core/pretty.bend:241
@unsafe
def kp_bind(
  +env: List<&2, KPName>,
  +t: KTerm,
) -> List<&2, KPName>:
  Con{KPName{nm(t), ix(t), kp_depth(env)}, env}

# Module: src/core/pretty.bend:248
@unsafe
def kp_hex(
  +n: U32,
) -> String:
  kc(String, U32.is_lt(n, 16), u => kp_digit(n), u => kp_hex(U32.div(n, 16)) ++ kp_digit(U32.mod(n, 16)))

# Module: src/core/pretty.bend:349
@unsafe
def kp_digit(n):
  Char.show(Char.from_u32(kc(U32, U32.is_lt(n, 10), u => U32.add(n, 48), u => U32.add(n, 87))))

# Module: src/core/pretty.bend:353
@unsafe
def qadd(
  +a: U32,
  +b: U32,
) -> U32:
  kc(U32, U32.is_eq(a, 0), u => b, u => kc(U32, U32.is_eq(b, 0), u => a, u => 2))

# Module: src/check/quantity.bend:59
@unsafe
def qjoin(
  +a: U32,
  +b: U32,
) -> U32:
  kc(U32, U32.is_gt(a, b), u => a, u => b)

# Module: src/check/quantity.bend:66
@unsafe
def qdem(
  +q: U32,
  +d: U32,
) -> U32:
  kc(U32, U32.is_eq(q, 0), u => 0, u => d)

# Module: src/check/quantity.bend:73
@unsafe
def uses_get(
  +xs: List<&2, KTerm>,
  +id: U32,
) -> U32:
  match xs:
    case Nil{}:
      0
    case Con{h, t}:
      kc(U32, U32.is_eq(ix(h), id), u => qt(h), u => uses_get(t, id))

# Module: src/check/quantity.bend:84
@unsafe
def uses_del(
  +xs: List<&2, KTerm>,
  +id: U32,
) -> List<&2, KTerm>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      kc(List<&2, KTerm>, U32.is_eq(ix(h), id), u => uses_del(t, id), u => Con{h, uses_del(t, id)})

# Module: src/check/quantity.bend:95
@unsafe
def uses_merge(
  +a: List<&2, KTerm>,
  +b: List<&2, KTerm>,
  +join: Bool,
) -> List<&2, KTerm>:
  match a:
    case Nil{}:
      b
    case Con{h, t}:
      Con{kt("Use", "", ix(h), kc(U32, join, u => qjoin(qt(h), uses_get(b, ix(h))), u => qadd(qt(h), uses_get(b, ix(h)))), Nil{}), uses_merge(t, uses_del(b, ix(h)), join)}

# Module: src/check/quantity.bend:107
@unsafe
def strip(
  +t: KTerm,
) -> KTerm:
  core_force(t)

# Module: src/check/quantity.bend:113
@unsafe
def descend(
  +q: U32,
  +a: KTerm,
  +p: KTerm,
) -> U32:
  kc(U32, U32.is_eq(q, 0), u => 1, u => descend_go(strip(a), strip(p)))

# Module: src/check/quantity.bend:121
@unsafe
def descend_go(a, p):
  kc(U32, core_literal(a) && p98_tag_eq(p, "Ctr"), u => descend_go(core_literal_step(a), p), u =>
  kc(U32, p98_tag_eq(p, "Var"),
    u => kc(U32, p98_tag_eq(a, "Var") && U32.is_eq(ix(a), ix(p)), u => 1, u => 2),
    u => kc(U32, p98_tag_eq(p, "Ctr"),
      u => descend_ctr(a, p, kc(KDescent, p98_tag_eq(a, "Ctr") && p88_string_eq(nm(a), nm(p)) && U32.is_eq(terms_len(ks(a)), terms_len(ks(p))), u => descend_fields(ks(a), ks(p), 1, 0), u => KDescent{2, 4294967295})),
      u => 2)))

# Module: src/check/quantity.bend:130
@unsafe
def descend_fields(a, p, ord, index):
  match a:
    case Nil{}:
      KDescent{ord, 4294967295}
    case Con{h, t}:
      descend_field(t, terms_tail(p), ord, index, descend(1, h, terms_at(p, 0)))

# Module: src/check/quantity.bend:138
@unsafe
def descend_field(a, p, ord, index, field):
  kc(KDescent, U32.is_eq(field, 2), u => KDescent{2, index}, u => descend_fields(a, p, kc(U32, U32.is_eq(field, 1), u => ord, u => field), U32.inc(index)))

# Module: src/check/quantity.bend:142
@unsafe
def terms_tail(ts):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      t

# Module: src/check/quantity.bend:150
@unsafe
def descend_ctr(a, p, result):
  match result:
    case KDescent{ord, bad}:
      kc(U32, U32.is_eq(ord, 2), u => descend_sub(a, ks(p), bad, 0), u => ord)

# Module: src/check/quantity.bend:156
@unsafe
def descend_sub(a, ps, bad, index):
  match ps:
    case Nil{}:
      2
    case Con{h, t}:
      kc(U32, U32.is_eq(index, bad), u => descend_sub(a, t, bad, U32.inc(index)), u => kc(U32, U32.is_eq(descend(1, a, h), 2), u => descend_sub(a, t, bad, U32.inc(index)), u => 0))

# Module: src/check/quantity.bend:164
@unsafe
def descend_spine(
  +qs: List<&2, KTerm>,
  +args: List<&2, KTerm>,
  +cols: List<&2, KTerm>,
) -> Bool:
  match cols:
    case Nil{}:
      False{}
    case Con{h, t}:
      descend_step(descend(qt(terms_at(qs, 0)), terms_at(args, 0), h), terms_tail(qs), terms_tail(args), t)

# Module: src/check/quantity.bend:176
@unsafe
def descend_step(ord, qs, args, cols):
  kc(Bool, U32.is_eq(ord, 0), u => True{}, u => kc(Bool, U32.is_eq(ord, 1), u => descend_spine(qs, args, cols), u => False{}))

# Module: src/check/kernel.bend:465
@unsafe
def cb(
  +e: KEnv,
) -> List<&2, KDef>:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      kw_book(world)

# Module: src/check/kernel.bend:473
@unsafe
def cn(
  +e: KEnv,
) -> String:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      name

# Module: src/check/kernel.bend:481
@unsafe
def cl(
  +e: KEnv,
) -> KTerm:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      lhs

# Module: src/check/kernel.bend:489
@unsafe
def cp(
  +e: KEnv,
) -> U32:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      pending

# Module: src/check/kernel.bend:497
@unsafe
def cq(
  +e: KEnv,
) -> List<&2, KTerm>:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      quantities

# Module: src/check/kernel.bend:505
@unsafe
def cu(
  +e: KEnv,
) -> Bool:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      unsafe

# Module: src/check/kernel.bend:513
@unsafe
def ct(
  +r: KChecking,
) -> KTerm:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      term

# Module: src/check/kernel.bend:521
@unsafe
def cy(
  +r: KChecking,
) -> KTerm:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      typ

# Module: src/check/kernel.bend:529
@unsafe
def cs(
  +r: KChecking,
) -> List<&2, KTerm>:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      uses

# Module: src/check/kernel.bend:537
@unsafe
def ce(
  +r: KChecking,
) -> String:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      error

# Module: src/check/kernel.bend:545
@unsafe
def ok(
  +world: KWorld,
  +t: KTerm,
  +ty: KTerm,
  +us: List<&2, KTerm>,
) -> KChecking:
  KChecking{t, ty, us, "", world, 0}

# Module: src/check/kernel.bend:554
@unsafe
def bad(
  +world: KWorld,
  +msg: String,
) -> KChecking:
  KChecking{{KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, msg, world, 0}

# Module: src/check/kernel.bend:561
@unsafe
def good(
  +r: KChecking,
) -> Bool:
  p88_string_eq(ce(r), "")

# Module: src/check/kernel.bend:567
@unsafe
def checked(
  +r: KChecking,
  +t: KTerm,
  +ty: KTerm,
) -> KChecking:
  kc(KChecking, good(r), u => KChecking{t, ty, cs(r), "", rw(r), rx(r)}, u => r)

# Module: src/check/kernel.bend:575
@unsafe
def both(
  +a: KChecking,
  +b: KChecking,
  +t: KTerm,
  +ty: KTerm,
  +join: Bool,
) -> KChecking:
  kc(KChecking, good(a), u => kc(KChecking, good(b), u => KChecking{t, ty, uses_merge(cs(a), cs(b), join), "", rw(b), rx(b)}, u => b), u => a)

# Module: src/check/kernel.bend:585
@unsafe
def ctx_get(
  +ctx: List<&2, KTerm>,
  +id: U32,
) -> KTerm:
  match ctx:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, t}:
      kc(KTerm, U32.is_eq(ix(h), id), u => h, u => ctx_get(t, id))

# Module: src/check/kernel.bend:596
@unsafe
def ctx_bind(
  +ctx: List<&2, KTerm>,
  +id: U32,
  +q: U32,
  +name: String,
  +ty: KTerm,
) -> List<&2, KTerm>:
  Con{kt("Bind", name, id, q, Con{ty, Nil{}}), ctx}

# Module: src/check/kernel.bend:606
@unsafe
def kindq(
  +e: KEnv,
  +q: U32,
) -> U32:
  kc(U32, cu(e) && U32.is_eq(q, 2), u => 1, u => q)

# Module: src/check/kernel.bend:613
@unsafe
def kapply(
  +fn: KTerm,
  +x: KTerm,
) -> KTerm:
  kc(KTerm, p98_tag_eq(strip(fn), "Lam"), u => subst(kid(strip(fn), 0), ix(strip(fn)), x), u => app(fn, x))

# Module: src/check/kernel.bend:620
@unsafe
def lhs_step(
  +e: KEnv,
  +x: KTerm,
) -> KEnv:
  kc(KEnv, U32.is_eq(cp(e), 0), u => e, u => KEnv{cw(e), cn(e), kapply(cl(e), x), U32.sub(cp(e), 1), cq(e), cu(e), cd(e)})

# Module: src/check/kernel.bend:627
@unsafe
def unargs(
  +t: KTerm,
  +acc: List<&2, KTerm>,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, p98_tag_eq(t, "App"), u => unargs(kid(t, 0), Con{kid(t, 1), acc}), u => acc)

# Module: src/check/kernel.bend:634
@unsafe
def infer(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +t: KTerm,
  +dem: U32,
  +sp: List<&2, KTerm>,
) -> KChecking:
  dg_trace(e, ctx, t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, infer_node(e, ctx, core_beta(t), dem, sp))

# Module: src/check/kernel.bend:644
@unsafe
def infer_node(e, ctx, t, dem, sp):
  kc(KChecking, p98_tag_eq(t, "Var"), u => infer_var(e, ctx, t, dem),
   u => kc(KChecking, p98_tag_eq(t, "Ref"), u => infer_ref(e, ctx, t, dem, sp, lookup(cb(e), nm(t))),
   u => kc(KChecking, p98_tag_eq(t, "Typ"), u => ki_one(t, typ(1), check(e, ctx, kid(t, 0), 0, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})),
   u => kc(KChecking, p98_tag_eq(t, "Qnt"), u => ok(cw(e), t, typ(1), Nil{}),
   u => kc(KChecking, p98_tag_eq(t, "Qua"), u => ok(cw(e), t, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}),
   u => kc(KChecking, p98_tag_eq(t, "Min"), u => ki_min(e, ctx, t, dem, check(e, ctx, kid(t, 0), dem, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})),
   u => kc(KChecking, p98_tag_eq(t, "All"), u => ki_all(e, ctx, t, dg_kind_check(e, ctx, kid(t, 0), qt(t), nm(t))),
   u => kc(KChecking, p98_tag_eq(t, "App"), u => infer_app(e, ctx, t, dem, infer(e, ctx, kid(t, 0), dem, Con{kid(t, 1), sp})),
   u => kc(KChecking, p98_tag_eq(t, "ADT"), u => infer_adt(e, ctx, t, dem, lookup(cb(e), nm(t))),
   u => kc(KChecking, p98_tag_eq(t, "Eql"), u => ki_eql_type(e, ctx, t, check(e, ctx, kid(t, 2), 0, typ(1))),
   u => kc(KChecking, p98_tag_eq(t, "Ann"), u => ki_ann(e, ctx, t, dem, check(e, ctx, kid(t, 1), 0, typ(1))),
   u => kc(KChecking, core_literal(t), u => bad(cw(e), "cannot infer: annotation required"), u => bad(cw(e), kc(String, p98_tag_eq(t, "FUnboundVar"), u => "unbound variable", u => "cannot infer: annotation required"))))))))))))))

# Module: src/check/kernel.bend:659
@unsafe
def infer_var(e, ctx, t, dem):
  +bound = ctx_get(ctx, ix(t))
  kc(KChecking, p98_tag_eq(bound, "Absent"), u => bad(cw(e), "unbound variable"), u => ok(cw(e), k_with_children(t, Nil{}), kid(bound, 0), Con{kt("Use", "", ix(t), dem, Nil{}), Nil{}}))

# Module: src/check/kernel.bend:664
@unsafe
def infer_ref(e, ctx, t, dem, sp, d):
  kc(KChecking, p88_string_eq(dk(d), "Absent"), u => bad(cw(e), "undefined name"),
   u => kc(KChecking, p88_string_eq(dk(d), "ADT") && U32.is_gt(da(d), 0), u => bad(cw(e), "a family requires angle-bracket parameters"),
   u => kc(KChecking, U32.is_eq(dem, 0), u => ok(cw(e), t, dt(d), Nil{}),
   u => kc(KChecking, p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(d), "Absent") && Bool.not(p88_string_eq(nm(t), cn(e))) && ((Bool.not(db(d)) && Bool.not(cu(e))) || (U32.is_gt(dx(d), 0) && U32.is_eq(dx(lookup(cb(e), cn(e))), 0))), u => bad(cw(e), "live use of an unfilled law"),
   u => ki_ref_result(e, t, sp, infer_template(e, ctx, t, dem, sp, d))))))

# Module: src/check/kernel.bend:672
@unsafe
def infer_app(e, ctx, t, dem, r):
  kc(KChecking, good(r), u => kc(KChecking, U32.is_gt(rx(r), 0), u => KChecking{ct(r), cy(r), cs(r), "", rw(r), U32.sub(rx(r), 1)}, u => infer_app_type(ke_world(e, rw(r)), ctx, t, dem, r, wnf(kw_book(rw(r)), cy(r)))), u => r)

# Module: src/check/kernel.bend:676
@unsafe
def infer_app_type(e, ctx, t, dem, r, ty):
  kc(KChecking, p98_tag_eq(ty, "All"), u => ki_pair(t, subst(kid(ty, 1), ix(ty), kid(t, 1)), r, check(ke_world(e, rw(r)), ctx, kid(t, 1), qdem(qt(ty), dem), kid(ty, 0)), False{}), u => kr_from(r, dg_bad_detail(rw(r), "application requires a function type", dg_text("a function type"), cy(r))))

# Module: src/check/kernel.bend:680
@unsafe
def infer_adt(e, ctx, t, dem, d):
  kc(KChecking, p88_string_eq(dk(d), "ADT") && U32.is_eq(terms_len(ks(t)), da(d)), u => infer_adt_done(t, tele_check(e, ctx, dt(d), ks(t), dem)), u => dg_adt_error(cw(e), t, d))

# Module: src/check/kernel.bend:684
@unsafe
def infer_adt_done(t, r):
  ki_args(t, cy(r), r)

# Module: src/check/kernel.bend:688
@unsafe
def tele_check(e, ctx, tel, args, dem):
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})
    case Con{h, t}: tele_check_cached_head(e, ctx, wnf(cb(e), tel), h, t, dem)

# Module: src/check/kernel.bend:698
@unsafe
def tele_check_done(a, b):
  both(a, b, k_with_children({KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{ct(a), ks(ct(b))}), cy(b), False{})

# Module: src/check/kernel.bend:702
@unsafe
def tele_fill(
  +book: List<&2, KDef>,
  +tel: KTerm,
  +args: List<&2, KTerm>,
) -> KTerm:
  env_tele_fill(book, tel, args)

# Module: src/check/kernel.bend:714
@unsafe
def check(e, ctx, t, dem, ty):
  dg_trace(e, ctx, t, ty, check_node(e, ctx, core_beta(t), dem, ty))

# Module: src/check/kernel.bend:718
@unsafe
def check_node(e, ctx, t, dem, ty):
  kc(KChecking, core_literal(t), u => kc(KChecking, core_literal_type(cb(e), t, wnf(cb(e), ty)), u => ok(cw(e), t, ty, Nil{}), u => check(e, ctx, core_literal_step(t), dem, ty)), u =>
  kc(KChecking, p98_tag_eq(t, "Lam"), u => check_lam(e, ctx, t, dem, wnf(cb(e), ty)),
   u => kc(KChecking, p98_tag_eq(t, "Ctr"), u => check_ctr(e, ctx, t, dem, wnf(cb(e), ty)),
   u => kc(KChecking, p98_tag_eq(t, "Mat") || p98_tag_eq(t, "Efq"), u => check_mat(e, ctx, t, dem, wnf(cb(e), ty)),
   u => kc(KChecking, p98_tag_eq(t, "Rfl"), u => check_rfl_graph(e, t, ty),
   u => kc(KChecking, p98_tag_eq(t, "Hol"), u => kc(KChecking, p88_string_eq(nm(t), "TODO"), u => ok(cw(e), t, ty, Nil{}), u => bad(cw(e), "unresolved hole")),
   u => kc(KChecking, p98_tag_eq(t, "Let"), u => check_let(e, ctx, ctx, ks(t), dem, ty, Nil{}, Nil{}, t, Nil{}),
   u => kc(KChecking, p98_tag_eq(t, "Rwt"), u => check_rwt(e, ctx, t, dem, ty, infer(e, ctx, kid(t, 0), dem, Nil{})),
   u => check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)))))))))

# Module: src/check/kernel.bend:730
@unsafe
def check_fits(e, r, ty):
  kc(KChecking, good(r), u => kc(KChecking, compare(kw_book(rw(r)), cy(r), ty, True{}), u => checked(r, ct(r), ty), u => kr_from(r, dg_bad_detail(rw(r), "type mismatch", ty, cy(r)))), u => r)

# Module: src/check/kernel.bend:734
@unsafe
def check_lam(e, ctx, t, dem, ty):
  kc(KChecking, p98_tag_eq(ty, "All"), u => check_lam_q(e, ctx, t, dem, ty, kc(U32, k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => 2, u => qt(ty))), u => bad(cw(e), "lambda requires a function type"))

# Module: src/check/kernel.bend:738
@unsafe
def check_lam_q(e, ctx, t, dem, ty, q):
  ki_lam_kind(e, ctx, t, dem, ty, q, kc(KChecking, k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => dg_kind_check(e, ctx, kid(ty, 0), q, nm(t)), u => ok(cw(e), t, ty, Nil{})))

# Module: src/check/kernel.bend:742
@unsafe
def check_lam_done(t, ty, q, r):
  kc(KChecking, good(r), u => kc(KChecking, U32.is_gt(uses_get(cs(r), ix(t)), q), u => kr_from(r, dg_quant_error(rw(r), "affine variable consumed more than allowed", nm(t), q, uses_get(cs(r), ix(t)))), u => KChecking{k_with_children(t, Con{ct(r), Nil{}}), ty, uses_del(cs(r), ix(t)), "", rw(r), rx(r)}), u => r)

# Module: src/check/kernel.bend:746
@unsafe
def check_ctr(e, ctx, t, dem, ty):
  kc(KChecking, p98_tag_eq(ty, "ADT"), u => check_ctr_found(e, ctx, t, dem, ty, lookup(dc(lookup(cb(e), nm(ty))), nm(t))), u => bad(cw(e), "constructor requires a datatype goal"))

# Module: src/check/kernel.bend:750
@unsafe
def check_ctr_found(e, ctx, t, dem, ty, ctr):
  kc(KChecking, Bool.not(p88_string_eq(dk(ctr), "Absent")) && Bool.not(has_name(rm(ty), nm(t))) && U32.is_eq(da(ctr), terms_len(ks(t))), u => ki_args(t, ty, tele_check(e, ctx, tele_fill(cb(e), dt(ctr), ks(ty)), ks(t), dem)), u => dg_ctor_error(e, t, ty, ctr))

# Module: src/check/kernel.bend:754
@unsafe
def check_rfl(e, t, ty):
  kc(KChecking, p98_tag_eq(ty, "Eql"), u => kc(KChecking, compare(cb(e), kid(ty, 0), kid(ty, 1), False{}), u => ok(cw(e), t, ty, Nil{}), u => dg_bad_detail(cw(e), "reflexivity endpoints differ", kid(ty, 0), kid(ty, 1))), u => bad(cw(e), "reflexivity requires equality goal"))

# Expose the goal and compare its endpoints in one private graph. Ordinary wnf
# substitutes raw let values and can expand a shared goal before comparison.
# The result retains the original goal; no heap-local cell enters KChecking.
@unsafe
def check_rfl_graph_head(+e: KEnv, +t: KTerm, +ty: KTerm,
  +fresh: U32, +r: GResult) -> KChecking:
  match r:
    case GResult{st, head}:
      kc(KChecking, p98_tag_eq(head, "Eql"),
        u => kc(KChecking, norm_convert_state(cb(e), st, kid(head, 0), kid(head, 1), False{}, fresh),
          u => ok(cw(e), t, ty, Nil{}),
          u => check_rfl(e, t, wnf(cb(e), ty))),
        u => bad(cw(e), "reflexivity requires equality goal"))

@unsafe
def check_rfl_graph(e, t, ty):
  +fresh = U32.add(1, norm_max(norm_book_bound(cb(e)), norm_max_term(ty)))
  check_rfl_graph_head(e, t, ty, fresh, g_wnf(cb(e), GState{GEmpty{}, 1}, ty))

# Module: src/check/kernel.bend:758
@unsafe
def check_let(e, outer, ctx, xs, dem, ty, bindings, us, site, out):
  match xs:
    case Nil{}: bad(cw(e), "let has no body")
    case Con{h, rest}:
      kc(KChecking, p98_tag_eq(h, "Bind"), u => check_let_value(e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, infer(e, outer, kid(h, 0), qdem(qt(h), dem), Nil{})), u => ki_let_finish(site, out, check_let_done(e, outer, check(e, ctx, let_cells(h, bindings), dem, ty), ki_reverse_terms(bindings, Nil{}), us, kc(KTerm, U32.is_eq(kb(site), 0), u => kid(site, 0), u => site))))

# Module: src/check/kernel.bend:765
# Inference checked the value's type at its source. Only a Data requirement
# can add an obligation here; unsafe reusable binders retain kindq's relaxation.
@unsafe
def check_let_value(e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, r):
  kc(KChecking, good(r), u => check_let_kind(ke_world(e, rw(r)), outer, ctx, h, rest, dem, ty, bindings, us, site, out, r,
    kc(KChecking, U32.is_eq(kindq(e, qt(h)), 2),
      u => dg_kind_at(ke_world(e, rw(r)), outer, cy(r), qt(h), nm(h), h), u => r)), u => r)

# Module: src/check/kernel.bend:769
@unsafe
def check_let_kind(e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, r, k):
  kc(KChecking, good(k), u => check_let(ke_world(e, rw(k)), outer, ctx_bind(ctx, ix(h), qt(h), nm(h), cy(r)), rest, dem, ty, Con{h, bindings}, uses_merge(us, cs(r), False{}), site, Con{k_with_children(h, Con{ct(r), Nil{}}), out}), u => k)

# Module: src/check/kernel.bend:773
@unsafe
def let_cells(body, bs):
  match bs:
    case Nil{}:
      body
    case Con{h, t}:
      let_cells(subst(body, ix(h), kt("Var", nm(h), ix(h), 0, Con{kid(h, 0), Nil{}})), t)

# Module: src/check/kernel.bend:781
@unsafe
def check_let_done(e, ctx, r, bs, us, site):
  match bs:
    case Nil{}:
      kc(KChecking, good(r), u => KChecking{ct(r), cy(r), uses_merge(us, cs(r), False{}), "", rw(r), rx(r)}, u => r)
    case Con{h, t}:
      kc(KChecking, good(r), u => kc(KChecking, U32.is_gt(uses_get(cs(r), ix(h)), qt(h)), u => dg_trace(e, ctx, site, cy(r), kr_from(r, dg_quant_error(rw(r), "let binder consumed more than allowed", nm(h), qt(h), uses_get(cs(r), ix(h))))), u => check_let_done(e, ctx, KChecking{ct(r), cy(r), uses_del(cs(r), ix(h)), "", rw(r), rx(r)}, t, us, site)), u => r)

# Module: src/check/kernel.bend:789
@unsafe
def remaining(
  +cs: List<&2, KDef>,
  +removed: List<&2, String>,
) -> List<&2, KDef>:
  match cs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      kc(List<&2, KDef>, has_name(removed, dn(h)), u => remaining(t, removed), u => Con{h, remaining(t, removed)})

# Module: src/check/kernel.bend:800
@unsafe
def defs_empty(
  +ds: List<&2, KDef>,
) -> Bool:
  match ds:
    case Nil{}:
      True{}
    case Con{h, t}:
      False{}

# Module: src/check/kernel.bend:810
@unsafe
def ctx_dead(
  +book: List<&2, KDef>,
  +ctx: List<&2, KTerm>,
) -> Bool:
  match ctx:
    case Nil{}:
      False{}
    case Con{h, t}:
      kc(Bool, U32.is_eq(qt(h), 0), u => ctx_dead(book, t), u => dead_type(book, wnf(book, kid(h, 0))) || ctx_dead(book, t))

# Module: src/check/kernel.bend:821
@unsafe
def dead_type(book, ty):
  p98_tag_eq(ty, "ADT") && p88_string_eq(dk(lookup(book, nm(ty))), "ADT") && defs_empty(remaining(dc(lookup(book, nm(ty))), rm(ty)))

# Module: src/check/kernel.bend:825
@unsafe
def check_mat(e, ctx, t, dem, ty):
  kc(KChecking, p98_tag_eq(ty, "All"),
   u => kc(KChecking, Bool.not(U32.is_eq(dem, 0)) && U32.is_eq(qt(ty), 0), u => dg_bad_message(cw(e), "erased scrutinee in live match", dg_text("a live scrutinee (a - scrutinee matches only in a dead region)")),
   u => check_mat_type(e, ctx, t, dem, ty, wnf(cb(e), kid(ty, 0)))),
   u => bad(cw(e), "matcher requires a function type"))

# Module: src/check/kernel.bend:832
@unsafe
def check_mat_type(e, ctx, t, dem, ty, a):
  kc(KChecking, p98_tag_eq(a, "ADT") && p88_string_eq(dk(lookup(cb(e), nm(a))), "ADT"),
   u => kc(KChecking, p98_tag_eq(t, "Efq"),
   u => kc(KChecking, dead_type(cb(e), a) || ctx_dead(cb(e), ctx), u => ok(cw(e), t, ty, Nil{}), u => dg_bad_detail(cw(e), "nonexhaustive match", dg_text("cases for " ++ dg_constructor_names(remaining(dc(lookup(cb(e), nm(a))), rm(a)))), t)),
   u => check_mat_ctr(e, ctx, t, dem, ty, a, lookup(remaining(dc(lookup(cb(e), nm(a))), rm(a)), nm(t)))),
   u => dg_bad_detail(cw(e), "match scrutinee requires a datatype", dg_text("a datatype"), kid(ty, 0)))

# Module: src/check/kernel.bend:840
@unsafe
def check_mat_ctr(e, ctx, t, dem, ty, a, ctr):
  kc(KChecking, p88_string_eq(dk(ctr), "Absent"), u => dg_bad_detail(cw(e), "unknown or duplicate match constructor", dg_text("a constructor of " ++ name_key(nm(a)) ++ " (missing, or already matched)"), t),
   u => check_mat_filled(e, ctx, t, dem, ty, a, ctr, tele_fill(cb(e), dt(ctr), ks(a))))

# A non-case fallback past the final constructor is unreachable. The checker
# and annotation pass share this choice so backends receive the same Efq.

# Module: src/check/kernel.bend:847
@unsafe
def mat_rest(
  +book: List<&2, KDef>,
  +t: KTerm,
  +a: KTerm,
) -> KTerm:
  kc(KTerm, Bool.not(p98_tag_eq(kid(t, 1), "Mat")) && defs_empty(remaining(dc(lookup(book, nm(a))), Con{nm(t), rm(a)})), u => {KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u => kid(t, 1))

# Module: src/check/kernel.bend:855
@unsafe
def mat_goal(book, goal, tel, n, name, xs):
  kc(KTerm, U32.is_eq(n, 0), u => subst(kid(goal, 1), ix(goal), kt("Ctr", name, 0, 0, norm_join(xs, Nil{}))), u => mat_goal_head(book, goal, wnf(book, tel), n, name, xs))

# Module: src/check/kernel.bend:859
@unsafe
def mat_goal_head(book, goal, tel, n, name, xs):
  all(kc(U32, U32.is_eq(qt(tel), 0), u => 0, u => kc(U32, U32.is_eq(qt(tel), 1), u => qt(goal), u => qadd(qt(goal), qt(goal)))), nm(tel), ix(tel), kid(tel, 0), mat_goal(book, goal, kid(tel, 1), U32.sub(n, 1), name, norm_join(xs, Con{var(nm(tel), ix(tel)), Nil{}})))

# Module: src/check/kernel.bend:863
@unsafe
def lhs_ext(
  +lhs: KTerm,
  +name: String,
  +tel: KTerm,
  +n: U32,
  +xs: List<&2, KTerm>,
  +fresh: U32,
) -> KTerm:
  kc(KTerm, U32.is_eq(n, 0), u => kapply(lhs, kt("Ctr", name, 0, 0, xs)), u => k_lam(nm(tel), fresh, qt(tel), Con{lhs_ext(lhs, name, kid(tel, 1), U32.sub(n, 1), norm_join(xs, Con{var(nm(tel), fresh), Nil{}}), U32.add(fresh, 1)), Nil{}}, 0, 0, False{}))

# Module: src/check/kernel.bend:878
@unsafe
def check_rwt(e, ctx, t, dem, ty, r):
  kc(KChecking, good(r), u => check_rwt_type(ke_world(e, rw(r)), ctx, t, dem, ty, r, wnf(kw_book(rw(r)), cy(r))), u => r)

# Module: src/check/kernel.bend:882
@unsafe
def check_rwt_type(e, ctx, t, dem, ty, r, eq):
  kc(KChecking, p98_tag_eq(eq, "Eql"), u => ki_rwt_bound(e, ctx, t, dem, ty, r, eq, kw_temp_floor(cw(e), [t, ty, cl(e)])), u => dg_trace(e, ctx, kid(t, 0), ty, kr_from(r, dg_bad_detail(rw(r), "rewrite requires equality evidence", dg_text("an equation {a == b : T}"), cy(r)))))

# Module: src/check/kernel.bend:886
@unsafe
def check_rwt_goal(e, ctx, t, dem, ty, r, eq, fresh):
  +goal = all(1, "_", fresh, kid(eq, 2), all(1, "e", U32.add(fresh, 1), kt("Eql", "", 0, 0, Con{kid(eq, 0), Con{var("_", fresh), Con{kid(eq, 2), Nil{}}}}), typ(1)))
  +next = ke_world(e, kw_temporary(cw(e), goal, U32.add(fresh, 1)))
  ki_rwt_motive(next, ctx, t, dem, ty, r, eq, check(next, ctx, kid(t, 1), 0, goal))

# Module: src/check/kernel.bend:892
@unsafe
def tele_quantities(
  +book: List<&2, KDef>,
  +ty: KTerm,
  +n: U32,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => Nil{}, u => tele_quantities_head(book, wnf(book, ty), n))

# Module: src/check/kernel.bend:900
@unsafe
def tele_quantities_head(book, ty, n):
  Con{qua(kc(U32, p98_tag_eq(ty, "All"), u => qt(ty), u => 1)), tele_quantities(book, kid(ty, 1), U32.sub(n, 1))}

# Module: src/check/kernel.bend:904
@unsafe
def declared(
  +d: KDef,
) -> KDef:
  KDef{dn(d), dk(d), da(d), dx(d), dt(d), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dc(d), db(d), du(d)}

# Module: src/check/kernel.bend:916
@unsafe
def infer_template(e, ctx, t, dem, sp, d):
  kc(KChecking, U32.is_eq(dem, 0) || U32.is_eq(dx(d), 0) || U32.is_gt(dx(lookup(cb(e), cn(e))), 0), u => ok(cw(e), t, dt(d), Nil{}), u => sp_live_checked(e, ctx, t, sp, d, dg_template_result(e, ctx, t, template_args(e, dt(d), sp, dx(d)))))

# Module: src/check/kernel.bend:1081
@unsafe
def template_args(e, ty, sp, n):
  kc(KChecking, U32.is_eq(n, 0), u => ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, ty, Nil{}), u => template_arg_head(e, wnf(cb(e), ty), sp, n))

# Module: src/check/kernel.bend:1085
@unsafe
def template_arg_head(e, ty, sp, n):
  match sp:
    case Nil{}:
      bad(cw(e), "template requires all closed comptime arguments")
    case Con{h, t}:
      kc(KChecking, p98_tag_eq(ty, "All"), u => template_arg_done(e, ty, h, t, n, check(e, Nil{}, h, 0, kid(ty, 0))), u => bad(cw(e), "invalid template telescope"))

# Module: src/check/kernel.bend:1093
@unsafe
def template_arg_done(e, ty, h, rest, n, r):
  kc(KChecking, good(r), u => template_args(ke_world(e, rw(r)), subst(kid(ty, 1), ix(ty), h), rest, U32.sub(n, 1)), u => r)

# Module: src/check/kernel.bend:1097
@unsafe
def self_pending(
  +d: KDef,
  +body: KTerm,
) -> U32:
  kc(U32, du(d), u => 0, u => kc(U32, contains_self(Con{body, Nil{}}, dn(d)), u => U32.sub(da(d), dx(d)), u => 0))

# Module: src/check/kernel.bend:1104
@unsafe
def contains_self(todo, name):
  match todo:
    case Nil{}:
      False{}
    case Con{h, rest}:
      kc(Bool, p98_tag_eq(h, "Ref") && p88_string_eq(nm(h), name), u => True{}, u => contains_self(norm_join(ks(h), rest), name))

# Module: src/check/kernel.bend:1112
@unsafe
def check_template_definition(world, d, ty, body, lhs, n, depth):
  +book = kw_book(world)
  kc(KChecking, U32.is_eq(n, 0), u => check(KEnv{world, dn(d), lhs, kc(U32, U32.is_gt(depth, 0) && Bool.not(du(d)), u => U32.sub(da(d), dx(d)), u => self_pending(d, body)), tele_quantities(book, dt(d), da(d)), du(d), depth}, Nil{}, body, 1, ty), u => check_template_binder(world, d, wnf(book, ty), body, lhs, n, depth))

# Module: src/check/kernel.bend:1117
@unsafe
def check_template_binder(world, d, ty, body, lhs, n, depth):
  +book = kw_book(world)
  kc(KChecking, p98_tag_eq(ty, "All"), u => check_template_open(world, d, ty, body, lhs, n, dn(d) ++ "~" ++ nm(ty), depth), u => bad(world, "template telescope is too short"))

# Module: src/check/kernel.bend:1122
@unsafe
def check_template_open(world, d, ty, body, lhs, n, name, depth):
  +book = kw_book(world)
  kc(KChecking, p88_string_eq(dk(lookup(book, name)), "Absent"), u => check_template_definition(kw_with_book(world, book_put(book, KDef{name, "Def", 0, 0, kid(ty, 0), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, True{}, False{}})), d, subst(kid(ty, 1), ix(ty), ref(name)), kapply(body, ref(name)), app(lhs, ref(name)), U32.sub(n, 1), depth), u => dg_trace(KEnv{world, "", ref(dn(d)), 0, Nil{}, du(d), depth}, Nil{}, ty, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(world, "duplicate comptime binder", dg_text("a fresh ~ binder name"), dg_text(nm(ty)))))

# Module: src/check/kernel.bend:1148
@unsafe
def tele_check_cached_head(e, ctx, tel, h, rest, dem):
  kc(KChecking, p98_tag_eq(tel, "All"),
    u => tele_check_after_head(e, ctx, tel, h, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0))),
    u => bad(cw(e), "too many telescope arguments"))

# Module: src/check/kernel.bend:1154
@unsafe
def tele_check_static(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})
    case Con{h, rest}:
      kc(KChecking, p98_tag_eq(tel, "All"), u => ki_tele_static(e, ctx, tel, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0))), u => tele_check(e, ctx, tel, args, dem))

# Module: src/check/kernel.bend:1161
@unsafe
def tele_check_legacy(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +tel: KTerm,
  +args: List<&2, KTerm>,
  +dem: U32,
) -> KChecking:
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})
    case Con{h, rest}:
      tele_check_legacy_head(e, ctx, wnf(cb(e), tel), h, rest, dem)

# Module: src/check/kernel.bend:1174
@unsafe
def tele_check_legacy_head(e, ctx, tel, h, rest, dem):
  kc(KChecking, p98_tag_eq(tel, "All"), u => ki_tele_legacy(e, ctx, tel, h, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0))), u => bad(cw(e), "too many telescope arguments"))

# Module: src/check/kernel.bend:1188
@unsafe
def tele_check_after_head(e, ctx, tel, h, rest, dem, checked_head):
  kc(KChecking, good(checked_head), u => kc(KChecking, core_subst_stable(kid(tel, 1)),
    u => tele_check_done(checked_head, tele_check_static(ke_world(e, rw(checked_head)), ctx, kid(tel, 1), rest, dem)),
    u => tele_check_done(checked_head, env_tele_check(ke_world(e, rw(checked_head)), ctx, subst(kid(tel, 1), ix(tel), h), rest, dem))), u => checked_head)

# Module: src/check/kernel.bend:1194
@unsafe
def check_mat_filled(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +ctr: KDef, +tel: KTerm) -> KChecking:
  ki_match_bound(e, ctx, t, dem, ty, a, ctr, tel, kc(U32, U32.is_eq(cp(e), 0) || U32.is_eq(da(ctr), 0), u => 0, u => kw_temp_floor(cw(e), Con{cl(e), Con{tel, Con{t, Con{ty, ctx}}}})))

# Module: src/check/kernel.bend:1205
@unsafe
def kw_initial(+book: List<&2,KDef>) -> KWorld:
  KWorld{book, Nil{}, KFreshDeferred{Nil{}}, Nil{}}

# Module: src/check/kernel.bend:1209
@unsafe
def kw_book(+world: KWorld) -> List<&2,KDef>:
  match world:
    case KWorld{book, memo, fresh, checked}: book

# Module: src/check/kernel.bend:1214
@unsafe
def kw_memo(+world: KWorld) -> List<&2,KSpecMemo>:
  match world:
    case KWorld{book, memo, fresh, checked}: memo

# Module: src/check/kernel.bend:1219
@unsafe
def kw_fresh(+world: KWorld) -> KWorldFresh:
  match world:
    case KWorld{book, memo, fresh, checked}: fresh

# Module: src/check/kernel.bend:1224
@unsafe
def kw_with_book(+world: KWorld, +book: List<&2,KDef>) -> KWorld:
  KWorld{book, kw_memo(world), kw_fresh(world), kw_checked(world)}

# Module: src/check/kernel.bend:1228
@unsafe
def cw(+e: KEnv) -> KWorld:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}: world

# Module: src/check/kernel.bend:1233
@unsafe
def cd(+e: KEnv) -> U32:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}: depth

# Module: src/check/kernel.bend:1238
@unsafe
def rw(+r: KChecking) -> KWorld:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}: world

# Module: src/check/kernel.bend:1243
@unsafe
def rx(+r: KChecking) -> U32:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}: consumed

# Module: src/check/kernel.bend:1248
@unsafe
def kw_restore_definition(+world: KWorld, +d: KDef, +r: KChecking) -> KChecking:
  kc(KChecking, good(r) && U32.is_gt(dx(d), 0), u => KChecking{ct(r), cy(r), cs(r), ce(r), kw_with_book(rw(r), kw_book(world)), rx(r)}, u => r)

# Module: src/check/kernel.bend:1252
@unsafe
def kr_from(+origin: KChecking, +derived: KChecking) -> KChecking:
  KChecking{ct(derived), cy(derived), cs(derived), ce(derived), rw(origin), rx(origin)}

# Module: src/check/kernel.bend:1261
@unsafe
def kw_checked(+world: KWorld) -> List<&2,KDef>:
  match world:
    case KWorld{book, memo, fresh, checked}: checked

# Module: src/check/kernel.bend:1266
@unsafe
def ke_world(+e: KEnv, +world: KWorld) -> KEnv:
  KEnv{world, cn(e), cl(e), cp(e), cq(e), cu(e), cd(e)}

# Module: src/check/kernel.bend:1282
@unsafe
def kw_owner(+world: KWorld, +ty: KTerm, +body: KTerm) -> KWorld:
  kw_owner_fresh(world, ty, body, kw_fresh(world))

# Module: src/check/kernel.bend:1286
@unsafe
def kw_owner_fresh(+world: KWorld, +ty: KTerm, +body: KTerm, +fresh: KWorldFresh) -> KWorld:
  match fresh:
    case KFreshKnown{next}: world
    case KFreshDeferred{roots}: KWorld{kw_book(world), kw_memo(world), KFreshDeferred{Con{ty, Con{body, roots}}}, kw_checked(world)}

# Module: src/check/kernel.bend:1292
@unsafe
def check_definition_body(+world: KWorld, +d: KDef, +depth: U32) -> KChecking:
  kw_restore_definition(world, d, check_template_definition(kw_owner(world, dt(d), dv(d)), d, dt(d), dv(d), ref(dn(d)), dx(d), depth))

# Module: src/check/kernel.bend:1295
@unsafe
def ki_one(+t: KTerm, +ty: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => checked(r, k_with_children(t, [ct(r)]), ty), u => r)

# Module: src/check/kernel.bend:1299
@unsafe
def ki_pair(+t: KTerm, +ty: KTerm, +a: KChecking, +b: KChecking, +join: Bool) -> KChecking:
  both(a, b, k_with_children(t, [ct(a), ct(b)]), ty, join)

# Module: src/check/kernel.bend:1303
@unsafe
def ki_args(+t: KTerm, +ty: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => checked(r, k_with_children(t, ks(ct(r))), ty), u => r)

# Module: src/check/kernel.bend:1307
@unsafe
def ki_min(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +a: KChecking) -> KChecking:
  kc(KChecking, good(a), u => ki_pair(t, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, a, check(ke_world(e, rw(a)), ctx, kid(t, 1), dem, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), False{}), u => a)

# Module: src/check/kernel.bend:1311
@unsafe
def ki_all(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking) -> KChecking:
  kc(KChecking, good(a), u => ki_pair(t, typ(1), a, check(ke_world(e, rw(a)), ctx_bind(ctx, ix(t), qt(t), nm(t), kid(t, 0)), kid(t, 1), 0, typ(1)), False{}), u => a)

# Module: src/check/kernel.bend:1315
@unsafe
def ki_eql_type(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking) -> KChecking:
  kc(KChecking, good(a), u => ki_eql_left(ke_world(e, rw(a)), ctx, t, a, check(ke_world(e, rw(a)), ctx, kid(t, 0), 0, kid(t, 2))), u => a)

# Module: src/check/kernel.bend:1319
@unsafe
def ki_eql_left(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking, +b: KChecking) -> KChecking:
  kc(KChecking, good(b), u => ki_eql_done(t, a, b, check(ke_world(e, rw(b)), ctx, kid(t, 1), 0, kid(t, 2))), u => b)

# Module: src/check/kernel.bend:1323
@unsafe
def ki_eql_done(+t: KTerm, +a: KChecking, +b: KChecking, +c: KChecking) -> KChecking:
  both(a, both(b, c, t, typ(2), False{}), k_with_children(t, [ct(b), ct(c), ct(a)]), typ(2), False{})

# Module: src/check/kernel.bend:1327
@unsafe
def ki_ann(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +a: KChecking) -> KChecking:
  kc(KChecking, good(a), u => ki_ann_done(t, a, check(ke_world(e, rw(a)), ctx, kid(t, 0), dem, kid(t, 1))), u => a)

# Module: src/check/kernel.bend:1331
@unsafe
def ki_ann_done(+t: KTerm, +a: KChecking, +b: KChecking) -> KChecking:
  both(a, b, k_with_children(t, [ct(b), kid(t, 1)]), kid(t, 1), False{})

# Module: src/check/kernel.bend:1335
@unsafe
def ki_lam_kind(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +q: U32, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => check_lam_done(t, ty, q, check(lhs_step(ke_world(e, rw(r)), var(nm(t), ix(t))), ctx_bind(ctx, ix(t), q, nm(t), kid(ty, 0)), kid(t, 0), dem, subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))))), u => r)

# Module: src/check/kernel.bend:1339
@unsafe
def ki_reverse_terms(+xs: List<&2,KTerm>, +out: List<&2,KTerm>) -> List<&2,KTerm>:
  match xs:
    case Nil{}: out
    case Con{h, rest}: ki_reverse_terms(rest, Con{h, out})

# Module: src/check/kernel.bend:1345
@unsafe
def ki_let_finish(+site: KTerm, +out: List<&2,KTerm>, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => checked(r, k_with_children(site, ki_reverse_terms(out, [ct(r)])), cy(r)), u => r)

# Module: src/check/kernel.bend:1349
@unsafe
def ki_tele_static(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +rest: List<&2,KTerm>, +dem: U32, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => tele_check_done(r, tele_check_static(ke_world(e, rw(r)), ctx, kid(tel, 1), rest, dem)), u => r)

# Module: src/check/kernel.bend:1353
@unsafe
def ki_tele_legacy(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => tele_check_done(r, tele_check_legacy(ke_world(e, rw(r)), ctx, subst(kid(tel, 1), ix(tel), h), rest, dem)), u => r)

# Module: src/check/kernel.bend:1357
@unsafe
def ki_match_arm(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => ki_pair(t, ty, r, check(ke_world(e, rw(r)), ctx, mat_rest(kw_book(rw(r)), t, a), dem, all(qt(ty), nm(ty), ix(ty), KTerm{tg(a), nm(a), ix(a), qt(a), ks(a), Con{nm(t), rm(a)}, kb(a), ke(a)}, kid(ty, 1))), True{}), u => r)

# Module: src/check/kernel.bend:1361
@unsafe
def ki_rwt_motive(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm, +motive: KChecking) -> KChecking:
  kc(KChecking, good(motive), u => kc(KChecking, compare(kw_book(rw(motive)), kapply(kapply(kid(t, 1), kid(eq, 1)), kid(t, 0)), ty, True{}),
    u => ki_rwt_done(t, ty, r, motive, check(ke_world(e, rw(motive)), ctx, kid(t, 2), dem, kapply(kapply(kid(t, 1), kid(eq, 0)), {KTerm{"Rfl", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))),
    u => kr_from(motive, dg_bad_detail(rw(motive), "rewrite motive does not fit goal", ty, kapply(kapply(kid(t, 1), kid(eq, 1)), kid(t, 0))))), u => motive)

# Module: src/check/kernel.bend:1367
@unsafe
def ki_rwt_done(+t: KTerm, +ty: KTerm, +r: KChecking, +motive: KChecking, +body: KChecking) -> KChecking:
  both(r, body, k_with_children(t, [ct(r), ct(motive), ct(body)]), ty, False{})

# Module: src/check/kernel.bend:1370
@unsafe
def ki_ref_result(+e: KEnv, +t: KTerm, +sp: List<&2,KTerm>, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => kc(KChecking, p88_string_eq(nm(ct(r)), cn(e)) && Bool.not(cu(e)) && Bool.not(descend_spine(cq(e), sp_drop(sp, rx(r)), unargs(cl(e), Nil{}))), u => kr_from(r, bad(rw(r), "nondecreasing self-call")), u => r), u => r)

# Module: src/check/kernel.bend:1374
@unsafe
def kw_floor_fresh(+world: KWorld, +fresh: KWorldFresh, +roots: List<&2,KTerm>) -> U32:
  match fresh:
    case KFreshKnown{next}: norm_max_walk(roots, U32.sub(next, 1))
    case KFreshDeferred{saved}: norm_max_walk(roots, norm_max_walk(saved, norm_book_bound(kw_book(world))))

# Module: src/check/kernel.bend:1380
@unsafe
def kw_mint_floor(+world: KWorld, +roots: List<&2,KTerm>) -> U32:
  kw_floor_fresh(world, kw_fresh(world), roots)

# Module: src/check/kernel.bend:1384
@unsafe
def kw_temp_floor(+world: KWorld, +roots: List<&2,KTerm>) -> U32:
  kw_temp_fresh(world, kw_fresh(world), roots)

# Module: src/check/kernel.bend:1388
@unsafe
def kw_temp_fresh(+world: KWorld, +fresh: KWorldFresh, +roots: List<&2,KTerm>) -> U32:
  match fresh:
    case KFreshKnown{next}: norm_max_walk(roots, U32.sub(next, 1))
    case KFreshDeferred{saved}: norm_max_walk(roots, norm_book_bound(kw_book(world)))

# Module: src/check/kernel.bend:1394
@unsafe
def kw_bound_book(+book: List<&2,KDef>, +bound: U32) -> List<&2,KDef>:
  match book:
    case Nil{}: book_cached(book, bound)
    case Con{h, rest}:
      kc(List<&2,KDef>, p88_string_eq(dk(h), "BookCache"), u => Con{KDef{dn(h), dk(h), norm_max(da(h), bound), dx(h), dt(h), dv(h), dc(h), db(h), du(h)}, rest}, u => book_cached(book, bound))

# Module: src/check/kernel.bend:1401
@unsafe
def kw_temporary(+world: KWorld, +root: KTerm, +bound: U32) -> KWorld:
  kw_temporary_fresh(world, root, bound, kw_fresh(world))

# Module: src/check/kernel.bend:1405
@unsafe
def kw_temporary_fresh(+world: KWorld, +root: KTerm, +bound: U32, +fresh: KWorldFresh) -> KWorld:
  match fresh:
    case KFreshKnown{next}: KWorld{kw_bound_book(kw_book(world), bound), kw_memo(world), KFreshKnown{norm_max(next, U32.add(bound, 1))}, kw_checked(world)}
    case KFreshDeferred{roots}: KWorld{kw_book(world), kw_memo(world), KFreshDeferred{Con{root, roots}}, kw_checked(world)}

# Module: src/check/kernel.bend:1411
@unsafe
def ki_rwt_bound(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm, +bound: U32) -> KChecking:
  kc(KChecking, U32.is_le(bound, 4294967292), u => check_rwt_goal(e, ctx, t, dem, ty, r, eq, U32.add(bound, 1)), u => kr_from(r, bad(rw(r), "fresh binder space exhausted")))

# Module: src/check/kernel.bend:1415
@unsafe
def ki_lhs(+e: KEnv, +name: String, +tel: KTerm, +n: U32, +fresh: U32) -> KEnv:
  +lhs = lhs_ext(cl(e), name, tel, n, Nil{}, fresh)
  KEnv{kc(KWorld, U32.is_eq(n, 0), u => cw(e), u => kw_temporary(cw(e), lhs, U32.sub(U32.add(fresh, n), 1))), cn(e), lhs, U32.add(U32.sub(cp(e), 1), n), cq(e), cu(e), cd(e)}

# Module: src/check/kernel.bend:1420
@unsafe
def ki_match_bound(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +ctr: KDef, +tel: KTerm, +bound: U32) -> KChecking:
  kc(KChecking, U32.is_eq(cp(e), 0) || U32.is_eq(da(ctr), 0) || (U32.is_lt(da(ctr), 4294967295) && U32.is_le(bound, U32.sub(4294967294, da(ctr)))),
    u => ki_match_arm(e, ctx, t, dem, ty, a, check(kc(KEnv, U32.is_eq(cp(e), 0), u => e, u => ki_lhs(e, nm(t), tel, da(ctr), U32.add(bound, 1))), ctx, kid(t, 0), dem, mat_goal(cb(e), ty, tel, da(ctr), nm(t), Nil{}))),
    u => bad(cw(e), "fresh binder space exhausted"))

# Module: src/check/env-telescope.bend:15
@unsafe
def env_tele_safe(+t: KTerm) -> Bool:
  kc(Bool, core_literal(t) || p98_tag_eq(t, "Var"), u => True{},
    u => kc(Bool, env_tele_safe_terms(ks(t)),
      u => kc(Bool, p98_tag_eq(t, "App"),
        u => p88_string_eq(nm(t), "") && U32.is_eq(ix(t), 0) && U32.is_eq(qt(t), 0) && core_subst_stable_app(ks(t), rm(t)) && Bool.not(p98_tag_eq(kid(t, 0), "Var")),
        u => True{}), u => False{}))

# Module: src/check/env-telescope.bend:23
@unsafe
def env_tele_safe_terms(ts):
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: kc(Bool, env_tele_safe(h), u => env_tele_safe_terms(rest), u => False{})

# Module: src/check/env-telescope.bend:29
@unsafe
def env_tele_apply_binding(+t: KTerm, +binding: KTelescopeBinding) -> KTerm:
  match binding:
    case KTelescopeBinding{id, value}: subst(t, id, value)

# Module: src/check/env-telescope.bend:34
@unsafe
def env_tele_apply(+t: KTerm, +bindings: List<&2,KTelescopeBinding>) -> KTerm:
  env_subst_apply(t, bindings)

# Module: src/check/env-telescope.bend:38
@unsafe
def env_tele_many(+args: List<&2,KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{h, rest}: Bool.not(List.is_empty(&2, KTerm, rest))

# Module: src/check/env-telescope.bend:58
@unsafe
def env_tele_fill(+book: List<&2,KDef>, +tel: KTerm, +args: List<&2,KTerm>) -> KTerm:
  kc(KTerm, env_tele_many(args),
    u => kc(KTerm, env_tele_safe(tel), u => env_tele_fill_loop(book, tel, args, Nil{}, 0), u => env_tele_fill_eager(book, tel, args)),
    u => env_tele_fill_eager(book, tel, args))

# Module: src/check/env-telescope.bend:64
@unsafe
def env_tele_fill_eager_head(+book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  kc(KTerm, p98_tag_eq(tel, "All"), u => env_tele_fill_eager(book, subst(kid(tel, 1), ix(tel), h), rest), u => {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/check/env-telescope.bend:68
@unsafe
def env_tele_fill_eager(book, tel, args):
  match args:
    case Nil{}: tel
    case Con{h, rest}: env_tele_fill_eager_head(book, wnf(book, tel), h, rest)

# Module: src/check/env-telescope.bend:74
@unsafe
def env_tele_fill_open(+book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  kc(KTerm, p98_tag_eq(tel, "All"),
    u => kc(KTerm, env_tele_safe(tel),
      u => env_tele_fill_loop(book, kid(tel, 1), rest, [KTelescopeBinding{ix(tel), h}], 1),
      u => env_tele_fill_eager_head(book, tel, h, rest)),
    u => {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/check/env-telescope.bend:82
@unsafe
def env_tele_fill_loop(book, tel, args, bindings, count):
  match args:
    case Nil{}: env_tele_apply(tel, bindings)
    case Con{h, rest}:
      kc(KTerm, env_tele_safe(h),
        u => kc(KTerm, p98_tag_eq(tel, "All") && U32.is_lt(count, 64),
          u => env_tele_fill_loop(book, kid(tel, 1), rest, Con{KTelescopeBinding{ix(tel), h}, bindings}, U32.add(count, 1)),
          u => env_tele_fill_open(book, wnf(book, env_tele_apply(tel, bindings)), h, rest)),
        u => env_tele_fill_eager(book, env_tele_apply(tel, bindings), args))

# Module: src/check/env-telescope.bend:103
@unsafe
def env_tele_check(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:
  kc(KChecking, env_tele_many(args),
    u => kc(KChecking, env_tele_safe(tel), u => env_tele_check_loop(e, ctx, tel, args, dem, Nil{}, 0), u => tele_check_legacy(e, ctx, tel, args, dem)),
    u => tele_check_legacy(e, ctx, tel, args, dem))

# Module: src/check/env-telescope.bend:109
@unsafe
def env_tele_check_after(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +bindings: List<&2,KTelescopeBinding>, +count: U32, +r: KChecking) -> KChecking:
  kc(KChecking, good(r),
    u => tele_check_done(r, env_tele_check_loop(ke_world(e, rw(r)), ctx, kid(tel, 1), rest, dem, Con{KTelescopeBinding{ix(tel), h}, bindings}, U32.add(count, 1))),
    u => r)

# Module: src/check/env-telescope.bend:115
@unsafe
def env_tele_check_head(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +bindings: List<&2,KTelescopeBinding>, +count: U32) -> KChecking:
  env_tele_check_after(e, ctx, tel, h, rest, dem, bindings, count, check(e, ctx, h, qdem(qt(tel), dem), env_tele_apply(kid(tel, 0), bindings)))

# Module: src/check/env-telescope.bend:119
@unsafe
def env_tele_check_open(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32) -> KChecking:
  kc(KChecking, p98_tag_eq(tel, "All"),
    u => kc(KChecking, env_tele_safe(tel),
      u => env_tele_check_head(e, ctx, tel, h, rest, dem, Nil{}, 0),
      u => tele_check_legacy_head(e, ctx, tel, h, rest, dem)),
    u => bad(cw(e), "too many telescope arguments"))

# Module: src/check/env-telescope.bend:127
@unsafe
def env_tele_check_loop(e, ctx, tel, args, dem, bindings, count):
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, env_tele_apply(tel, bindings), Nil{})
    case Con{h, rest}:
      kc(KChecking, env_tele_safe(h),
        u => kc(KChecking, p98_tag_eq(tel, "All") && U32.is_lt(count, 64),
          u => env_tele_check_head(e, ctx, tel, h, rest, dem, bindings, count),
          u => env_tele_check_open(e, ctx, wnf(cb(e), env_tele_apply(tel, bindings)), h, rest, dem)),
        u => tele_check_legacy(e, ctx, env_tele_apply(tel, bindings), args, dem))

# Module: src/check/env-substitution.bend:23
@unsafe
def env_subst_reverse(+bindings: List<&2,KTelescopeBinding>, +out: List<&2,KTelescopeBinding>) -> List<&2,KTelescopeBinding>:
  match bindings:
    case Nil{}: out
    case Con{binding, rest}: env_subst_reverse(rest, Con{binding, out})

# Module: src/check/env-substitution.bend:29
@unsafe
def env_subst_start(+t: KTerm, +bindings: List<&2,KTelescopeBinding>, +first: KTelescopeBinding, +rest: List<&2,KTelescopeBinding>) -> KTerm:
  match rest:
    case Nil{}: env_tele_apply_binding(t, first)
    case Con{h, tail}: env_subst_term(t, env_subst_reverse(bindings, Nil{}))

# Module: src/check/env-substitution.bend:35
@unsafe
def env_subst_apply(+t: KTerm, +bindings: List<&2,KTelescopeBinding>) -> KTerm:
  match bindings:
    case Nil{}: t
    case Con{first, rest}: env_subst_start(t, bindings, first, rest)

# Module: src/check/env-substitution.bend:41
@unsafe
def env_subst_binding(+t: KTerm, +binding: KTelescopeBinding, +rest: List<&2,KTelescopeBinding>) -> KTerm:
  match binding:
    case KTelescopeBinding{id, value}:
      kc(KTerm, U32.is_eq(ix(t), id), u => env_subst_term(value, rest), u => env_subst_find(t, rest))

# Module: src/check/env-substitution.bend:47
@unsafe
def env_subst_find(t, bindings):
  match bindings:
    case Nil{}: t
    case Con{binding, rest}: env_subst_binding(t, binding, rest)

# Module: src/check/env-substitution.bend:53
@unsafe
def env_subst_term(t, bindings):
  match bindings:
    case Nil{}: t
    case Con{binding, rest}:
      kc(KTerm, p98_tag_eq(t, "Var"), u => env_subst_find(t, bindings),
        u => kc(KTerm, core_literal(t), u => t,
          u => k_with_children(t, env_subst_terms(ks(t), bindings))))

# Module: src/check/env-substitution.bend:62
@unsafe
def env_subst_terms(ts, bindings):
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{env_subst_term(h, bindings), env_subst_terms(rest, bindings)}

# Module: src/check/specialize.bend:62
@unsafe
def sp_mtemplate(
  +m: KSpecMemo,
) -> String:
  match m:
    case KSpecMemo{template, key, name, active}:
      template

# Module: src/check/specialize.bend:70
@unsafe
def sp_mkey(
  +m: KSpecMemo,
) -> String:
  match m:
    case KSpecMemo{template, key, name, active}:
      key

# Module: src/check/specialize.bend:78
@unsafe
def sp_mname(
  +m: KSpecMemo,
) -> String:
  match m:
    case KSpecMemo{template, key, name, active}:
      name

# Module: src/check/specialize.bend:86
@unsafe
def sp_active(
  +m: KSpecMemo,
) -> Bool:
  match m:
    case KSpecMemo{template, key, name, active}:
      active

# Module: src/check/specialize.bend:94
@unsafe
def sp_len(+s: String) -> U32:
  sk_width(s, 0)

# Module: src/check/specialize.bend:98
@unsafe
def sk_width(+s: String, +n: U32) -> U32:
  match s:
    case SNil{}: n
    case SCon{c, rest}: sk_width(rest, U32.add(n, dg_units(c)))

# Module: src/check/specialize.bend:104
@unsafe
def sk_quote(+s: String) -> String:
  "\"" ++ String.reverse(sk_escape(s, "")) ++ "\""

# Module: src/check/specialize.bend:108
@unsafe
def sk_escape(+s: String, +acc: String) -> String:
  match s:
    case SNil{}: acc
    case SCon{c, rest}: sk_escape(rest, String.reverse(sk_char(c, Char.to_u32(c))) ++ acc)

# Module: src/check/specialize.bend:114
@unsafe
def sk_char(+c: Char, +n: U32) -> String:
  match n:
    case 34: "\\\""
    case 92: "\\\\"
    case 8: "\\b"
    case 9: "\\t"
    case 10: "\\n"
    case 12: "\\f"
    case 13: "\\r"
    case other:
      kc(String, U32.is_lt(n, 32), u => "\\u00" ++ kc(String, U32.is_lt(n, 16), u => "0", u => "") ++ kp_hex(n),
        u => kc(String, U32.is_ge(n, 55296) && U32.is_le(n, 57343), u => "\\u" ++ kp_hex(n), u => Char.show(c)))

# Module: src/check/specialize.bend:128
@unsafe
def sk_quant(+q: U32) -> String:
  "{\"$\":\"" ++ kc(String, U32.is_eq(q, 0), u => "None", u => kc(String, U32.is_eq(q, 2), u => "Many", u => "Lone")) ++ "\"}"

# Module: src/check/specialize.bend:132
@unsafe
def term_key(+t: KTerm) -> String:
  sk_term(t, Nil{}, 0)

# Module: src/check/specialize.bend:136
@unsafe
def sp_keys(ts):
  match ts:
    case Nil{}: ""
    case Con{head, rest}: term_key(head) ++ kc(String, List.is_empty(&2, KTerm, rest), u => "", u => "\n" ++ sp_keys(rest))

# Module: src/check/specialize.bend:142
@unsafe
def sk_names(+names: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{head, rest}: sk_quote(head) ++ kc(String, List.is_empty(&2, String, rest), u => "", u => "," ++ sk_names(rest))

# Module: src/check/specialize.bend:148
@unsafe
def sk_terms(+ts: List<&2,KTerm>, +env: List<&2,KPName>, +depth: U32) -> String:
  match ts:
    case Nil{}: ""
    case Con{head, rest}: sk_term(head, env, depth) ++ kc(String, List.is_empty(&2, KTerm, rest), u => "", u => "," ++ sk_terms(rest, env, depth))

# Module: src/check/specialize.bend:154
@unsafe
def sk_var(+t: KTerm, +env: List<&2,KPName>) -> String:
  match env:
    case Nil{}: sk_variable(nm(t), ix(t))
    case Con{KPFile{ns, aliases}, rest}: sk_var(t, rest)
    case Con{KPName{name, id, depth}, rest}:
      kc(String, U32.is_eq(ix(t), id), u => sk_variable(name, depth), u => sk_var(t, rest))

# Module: src/check/specialize.bend:162
@unsafe
def sk_variable(+name: String, +id: U32) -> String:
  "{\"$\":\"Var\",\"k\":" ++ sk_quote(name) ++ ",\"i\":" ++ kc(String, U32.is_eq(id, 4294967295), u => "-1", u => U32.show(id)) ++ "}"

# Module: src/check/specialize.bend:166
@unsafe
def sk_term(+t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  kc(String, p98_tag_eq(t, "Var"), u => kc(String, List.is_empty(&2, KTerm, ks(t)), u => sk_var(t, env), u => sk_term(kid(t, 0), env, depth)),
  u => kc(String, p98_tag_eq(t, "Sub"), u => sk_term(subst(kid(t, 1), ix(t), kid(t, 0)), env, depth),
  u => sk_node(t, env, depth)))

# Module: src/check/specialize.bend:172
@unsafe
def sk_node(+t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  kc(String, p98_tag_eq(t, "Ref"), u => "{\"$\":\"Ref\",\"k\":" ++ sk_quote(nm(t)) ++ kc(String, U32.is_eq(qt(t), 3), u => ",\"b\":true", u => "") ++ "}",
  u => kc(String, core_literal(t), u => "{\"$\":\"Lit\",\"k\":" ++ sk_quote(nm(t)) ++ ",\"v\":" ++ kc(String, p88_string_eq(nm(t), "String"), u => sk_quote(kl_text(t)), u => U32.show(kl_number(t))) ++ "}",
  u => kc(String, p98_tag_eq(t, "Lam"), u => "{\"$\":\"Lam\",\"k\":" ++ sk_quote(nm(t)) ++ ",\"i\":" ++ U32.show(depth) ++ ",\"f\":" ++ sk_term(kid(t, 0), Con{KPName{nm(t), ix(t), depth}, env}, U32.inc(depth)) ++ kc(String, k_quantity_present(t), u => ",\"q\":" ++ sk_quant(qt(t)), u => "") ++ "}",
  u => kc(String, p98_tag_eq(t, "All"), u => "{\"$\":\"All\",\"q\":" ++ sk_quant(qt(t)) ++ ",\"k\":" ++ sk_quote(nm(t)) ++ ",\"i\":" ++ U32.show(depth) ++ ",\"A\":" ++ sk_term(kid(t, 0), env, depth) ++ ",\"B\":" ++ sk_term(kid(t, 1), Con{KPName{nm(t), ix(t), depth}, env}, U32.inc(depth)) ++ "}",
  u => kc(String, p98_tag_eq(t, "Let"), u => sk_let(ks(t), env, depth),
  u => kc(String, p98_tag_eq(t, "ADT") || p98_tag_eq(t, "Ctr"), u => "{\"$\":" ++ sk_quote(tg(t)) ++ ",\"k\":" ++ sk_quote(nm(t)) ++ ",\"x\":[" ++ sk_terms(ks(t), env, depth) ++ "]" ++ kc(String, p98_tag_eq(t, "ADT"), u => ",\"r\":[" ++ sk_names(rm(t)) ++ "]", u => "") ++ "}",
  u => sk_other(t, env, depth)))))))

# Module: src/check/specialize.bend:182
@unsafe
def sk_other(+t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  kc(String, p98_tag_eq(t, "App"), u => sk_pair("App", "f", "x", t, env, depth),
  u => kc(String, p98_tag_eq(t, "Min"), u => sk_pair("Min", "a", "b", t, env, depth),
  u => kc(String, p98_tag_eq(t, "Ann"), u => sk_pair("Ann", "x", "T", t, env, depth),
  u => kc(String, p98_tag_eq(t, "Typ"), u => "{\"$\":\"Typ\",\"g\":" ++ sk_term(kid(t, 0), env, depth) ++ "}",
  u => kc(String, p98_tag_eq(t, "Qua"), u => "{\"$\":\"Qua\",\"q\":" ++ sk_quant(qt(t)) ++ "}",
  u => kc(String, p98_tag_eq(t, "Mat"), u => "{\"$\":\"Mat\",\"k\":" ++ sk_quote(nm(t)) ++ ",\"h\":" ++ sk_term(kid(t, 0), env, depth) ++ ",\"m\":" ++ sk_term(kid(t, 1), env, depth) ++ "}",
  u => kc(String, p98_tag_eq(t, "Eql"), u => sk_triple("Eql", "a", "b", "T", t, env, depth),
  u => kc(String, p98_tag_eq(t, "Rwt"), u => sk_triple("Rwt", "e", "p", "f", t, env, depth),
  u => kc(String, p98_tag_eq(t, "Hol"), u => "{\"$\":\"Hol\",\"k\":" ++ sk_quote(nm(t)) ++ "}",
  u => kc(String, p98_tag_eq(t, "Qnt") || p98_tag_eq(t, "Efq") || p98_tag_eq(t, "Rfl"), u => "{\"$\":" ++ sk_quote(tg(t)) ++ "}",
  u => sk_internal(t, env, depth)))))))))))

# Module: src/check/specialize.bend:196
@unsafe
def sk_internal(+t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  "{\"$\":\"Internal\",\"tag\":" ++ sk_quote(tg(t)) ++ ",\"name\":" ++ sk_quote(nm(t)) ++ ",\"id\":" ++ U32.show(ix(t)) ++ ",\"quant\":" ++ U32.show(qt(t)) ++ ",\"kids\":[" ++ sk_terms(ks(t), env, depth) ++ "],\"removed\":[" ++ sk_names(rm(t)) ++ "]}"

# Module: src/check/specialize.bend:200
@unsafe
def sk_pair(+tag: String, +a: String, +b: String, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  "{\"$\":" ++ sk_quote(tag) ++ "," ++ sk_quote(a) ++ ":" ++ sk_term(kid(t, 0), env, depth) ++ "," ++ sk_quote(b) ++ ":" ++ sk_term(kid(t, 1), env, depth) ++ "}"

# Module: src/check/specialize.bend:204
@unsafe
def sk_triple(+tag: String, +a: String, +b: String, +c: String, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  "{\"$\":" ++ sk_quote(tag) ++ "," ++ sk_quote(a) ++ ":" ++ sk_term(kid(t, 0), env, depth) ++ "," ++ sk_quote(b) ++ ":" ++ sk_term(kid(t, 1), env, depth) ++ "," ++ sk_quote(c) ++ ":" ++ sk_term(kid(t, 2), env, depth) ++ "}"

# Module: src/check/specialize.bend:208
@unsafe
def sk_let(+xs: List<&2,KTerm>, +env: List<&2,KPName>, +depth: U32) -> String:
  "{\"$\":\"Let\",\"k\":[" ++ sk_let_field(xs, 0, env, depth, depth) ++ "],\"i\":[" ++ sk_let_field(xs, 1, env, depth, depth) ++ "],\"q\":[" ++ sk_let_field(xs, 2, env, depth, depth) ++ "],\"v\":[" ++ sk_let_field(xs, 3, env, depth, depth) ++ "],\"f\":" ++ sk_let_body(xs, env, depth) ++ "}"

# Module: src/check/specialize.bend:212
@unsafe
def sk_let_field(+xs: List<&2,KTerm>, +field: U32, +env: List<&2,KPName>, +depth: U32, +id: U32) -> String:
  match xs:
    case Nil{}: ""
    case Con{head, rest}:
      kc(String, p98_tag_eq(head, "Bind"),
        u => kc(String, U32.is_eq(field, 0), u => sk_quote(nm(head)),
          u => kc(String, U32.is_eq(field, 1), u => U32.show(id),
          u => kc(String, U32.is_eq(field, 2), u => sk_quant(qt(head)), u => sk_term(kid(head, 0), env, depth))))
          ++ kc(String, p98_tag_eq(terms_at(rest, 0), "Bind"), u => "," ++ sk_let_field(rest, field, env, depth, U32.inc(id)), u => ""),
        u => "")

# Module: src/check/specialize.bend:224
@unsafe
def sk_let_body(+xs: List<&2,KTerm>, +env: List<&2,KPName>, +depth: U32) -> String:
  match xs:
    case Nil{}: "null"
    case Con{head, rest}:
      kc(String, p98_tag_eq(head, "Bind"), u => sk_let_body(rest, Con{KPName{nm(head), ix(head), depth}, env}, U32.inc(depth)), u => sk_term(head, env, depth))

# Module: src/check/specialize.bend:231
@unsafe
def sp_find(
  +ms: List<&2, KSpecMemo>,
  +name: String,
  +key: String,
) -> KSpecMemo:
  match ms:
    case Nil{}:
      KSpecMemo{"", "", "", False{}}
    case Con{h, rest}:
      kc(KSpecMemo, p88_string_eq(sp_mtemplate(h), name) && p88_string_eq(sp_mkey(h), key), u => h, u => sp_find(rest, name, key))

# Module: src/check/specialize.bend:243
@unsafe
def sp_ordinal(
  +ms: List<&2, KSpecMemo>,
  +name: String,
) -> U32:
  match ms:
    case Nil{}: 0
    case Con{h, rest}: U32.add(kc(U32, p88_string_eq(sp_mtemplate(h), name), u => 1, u => 0), sp_ordinal(rest, name))

# Module: src/check/specialize.bend:252
@unsafe
def sp_done_memo(
  +ms: List<&2, KSpecMemo>,
  +name: String,
) -> List<&2, KSpecMemo>:
  match ms:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      Con{kc(KSpecMemo, p88_string_eq(sp_mname(h), name), u => KSpecMemo{sp_mtemplate(h), sp_mkey(h), sp_mname(h), False{}}, u => h), sp_done_memo(rest, name)}

# Module: src/check/specialize.bend:263
@unsafe
def sp_take(
  +ts: List<&2, KTerm>,
  +n: U32,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => Nil{}, u => sp_take_next(ts, n))

# Module: src/check/specialize.bend:270
@unsafe
def sp_take_next(ts, n):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      Con{h, sp_take(rest, U32.sub(n, 1))}

# Module: src/check/specialize.bend:278
@unsafe
def sp_drop(
  +ts: List<&2, KTerm>,
  +n: U32,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => ts, u => sp_drop_next(ts, n))

# Module: src/check/specialize.bend:285
@unsafe
def sp_drop_next(ts, n):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      sp_drop(rest, U32.sub(n, 1))

# Module: src/check/specialize.bend:293
@unsafe
def sp_shift(
  +t: KTerm,
  +offset: U32,
) -> KTerm:
  kc(KTerm, core_literal(t), u => t, u =>
    k_rebuild(t, nm(t), kc(U32, p98_tag_eq(t, "Var") || p98_tag_eq(t, "All") || p98_tag_eq(t, "Lam") || p98_tag_eq(t, "Bind") || p98_tag_eq(t, "Sub"), u => U32.add(ix(t), offset), u => ix(t)), qt(t), sp_shifts(ks(t), offset), rm(t), kb(t), ke(t)))

# Module: src/check/specialize.bend:301
@unsafe
def sp_shifts(ts, offset):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      Con{sp_shift(h, offset), sp_shifts(rest, offset)}

# Module: src/check/specialize.bend:309
@unsafe
def sp_apply_template(body, xs):
  match xs:
    case Nil{}:
      body
    case Con{h, rest}:
      sp_apply_template(kapply(body, h), rest)

# Module: src/check/specialize.bend:327
@unsafe
def sp_live_checked(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => sp_live_args(ke_world(e, rw(r)), ctx, head, sp, d, sp_take(sp, dx(d))), u => r)

# Module: src/check/specialize.bend:349
@unsafe
def sp_live_key(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>, +key: String) -> KChecking:
  kc(KChecking, U32.is_gt(sp_len(key), 32768), u => sp_live_error(e, ctx, head, "a comptime argument must stop growing", "a ~ argument that stops growing"), u => sp_live_memo(e, ctx, head, sp, d, xs, key, sp_find(kw_memo(cw(e)), dn(d), key)))

# Module: src/check/specialize.bend:353
@unsafe
def sp_live_error(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +message: String, +expected: String) -> KChecking:
  dg_trace(e, ctx, head, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(cw(e), message, dg_text(expected), head))

# Module: src/check/specialize.bend:357
@unsafe
def sp_live_memo(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>, +key: String, +memo: KSpecMemo) -> KChecking:
  kc(KChecking, p88_string_eq(sp_mname(memo), ""),
    u => kc(KChecking, U32.is_ge(cd(e), 64), u => sp_live_error(e, ctx, head, "template instantiation exceeds 64 levels", "a template that stops instantiating itself (64 levels at most)"), u => sp_live_fresh(e, ctx, head, d, xs, key, dn(d) ++ "~" ++ U32.show(sp_ordinal(kw_memo(cw(e)), dn(d))), kw_mint_floor(cw(e), Con{cl(e), norm_join(ctx, sp)}), norm_max(norm_max_term(dt(d)), norm_max_term(dv(d))))),
    u => kc(KChecking, sp_active(memo) && Bool.not(p88_string_eq(sp_mname(memo), cn(e))), u => sp_live_error(e, ctx, head, "nondecreasing cross-instance template recursion", "a decreasing self-call (arguments are read left to right: each passed unchanged until one shrinks)"), u => sp_live_ref(cw(e), head, sp_mname(memo), dx(d))))

# Module: src/check/specialize.bend:363
@unsafe
def sp_live_ref(+world: KWorld, +head: KTerm, +name: String, +consumed: U32) -> KChecking:
  KChecking{KTerm{"Ref", name, ix(head), qt(head), ks(head), rm(head), kb(head), ke(head)}, dt(lookup(kw_book(world), name)), Nil{}, "", world, consumed}

# Module: src/check/specialize.bend:367
@unsafe
def sp_live_fresh(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +d: KDef, +xs: List<&2,KTerm>, +key: String, +name: String, +bound: U32, +width: U32) -> KChecking:
  kc(KChecking, U32.is_lt(width, 4294967294) && U32.is_le(bound, U32.sub(4294967293, width)),
    u => sp_live_body(e, head, d, key, name, tele_fill(cb(e), sp_shift(dt(d), U32.add(bound, 1)), xs), sp_apply_template(sp_shift(dv(d), U32.add(bound, 1)), xs), U32.add(U32.add(bound, width), 2)),
    u => sp_live_error(e, ctx, head, "fresh binder space exhausted", "a representable fresh binder identity"))

# Module: src/check/specialize.bend:373
@unsafe
def sp_live_body(+e: KEnv, +head: KTerm, +d: KDef, +key: String, +name: String, +ty: KTerm, +body: KTerm, +next: U32) -> KChecking:
  +inst: KDef = KDef{name, "Def", U32.sub(da(d), dx(d)), 0, ty, body, Nil{}, False{}, du(d)}
  +world: KWorld = KWorld{book_put(kw_bound_book(cb(e), U32.sub(next, 1)), declared(inst)), Con{KSpecMemo{dn(d), key, name, True{}}, kw_memo(cw(e))}, KFreshKnown{next}, kw_checked(cw(e))}
  sp_live_done(head, inst, dx(d), check_definition_body(world, inst, U32.add(cd(e), 1)))

# Module: src/check/specialize.bend:379
@unsafe
def sp_live_done(+head: KTerm, +inst: KDef, +consumed: U32, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => sp_live_ref(KWorld{book_put(kw_book(rw(r)), inst), sp_done_memo(kw_memo(rw(r)), dn(inst)), kw_fresh(rw(r)), Con{KDef{dn(inst), dk(inst), da(inst), dx(inst), dt(inst), ct(r), dc(inst), db(inst), du(inst)}, kw_checked(rw(r))}}, head, dn(inst), consumed), u => r)

# Module: src/check/specialize.bend:382
@unsafe
def sp_live_args(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>) -> KChecking:
  sp_live_key(e, ctx, head, sp, d, xs, sp_keys(xs))

# Module: src/check/prefix-state.bend:5
@unsafe
def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:
  match book:
    case Nil{}: bound
    case Con{d, rest}: kc(U32, p88_string_eq(dk(d), "BookCache"), u => da(d), u => bound)

# Module: src/check/prefix-state.bend:156
@unsafe
def ka_wrap(
  +t: KTerm,
  +ty: KTerm,
) -> KTerm:
  kt("Ann", "", 0, 0, Con{t, Con{ty, Nil{}}})

# Module: src/check/annotate.bend:144
@unsafe
def ka_def(book, d):
  KDef{dn(d), dk(d), da(d), dx(d), dt(d), kc(KTerm, p98_tag_eq(dv(d), "Absent") || p98_tag_eq(dv(d), "Foreign") || U32.is_gt(dx(d), 0), u => dv(d), u => annotate(KEnv{kw_initial(book), dn(d), ref(dn(d)), 0, Nil{}, du(d), 0}, Nil{}, dv(d), dt(d))), dc(d), db(d), du(d)}

# Module: src/check/annotate.bend:168
@unsafe
def annotate(e, ctx, t, ty):
  ka_annotated(e, ctx, core_beta(t), wnf(cb(e), ty))

# Keep the type head already demanded by ka_node. Backend consumers otherwise
# normalize the original annotation again while determining the same layout.

# Module: src/check/annotate.bend:174
@unsafe
def ka_annotated(+e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  ka_wrap(ka_node(e, ctx, t, ty), ty)

# Module: src/check/annotate.bend:178
@unsafe
def ka_node(e, ctx, t, ty):
  kc(KTerm, core_literal(t), u => kc(KTerm, core_literal_type(cb(e), t, ty), u => t, u => ka_node(e, ctx, core_literal_step(t), ty)), u =>
  kc(KTerm, p98_tag_eq(t, "Ann"), u => ka_node(e, ctx, kid(t, 0), wnf(cb(e), kid(t, 1))),
   u => kc(KTerm, p98_tag_eq(t, "Lam"), u => ka_lam(e, ctx, t, ty),
   u => kc(KTerm, p98_tag_eq(t, "App"), u => kc(KTerm, ka_spine_eligible(t), u => ka_app_spine(e, ctx, t), u => ka_app(e, ctx, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0))))),
   u => kc(KTerm, p98_tag_eq(t, "Ctr"), u => kt("Ctr", nm(t), ix(t), qt(t), ka_args_cached(e, ctx, tele_fill(cb(e), dt(lookup(dc(lookup(cb(e), nm(ty))), nm(t))), ks(ty)), ks(t))),
   u => kc(KTerm, p98_tag_eq(t, "Mat"), u => ka_mat(e, ctx, t, ty, wnf(cb(e), kid(ty, 0))),
   u => kc(KTerm, p98_tag_eq(t, "Let"), u => kt("Let", nm(t), ix(t), qt(t), ka_let(e, ctx, ctx, ks(t), ty)),
   u => kc(KTerm, p98_tag_eq(t, "Rwt"), u => ka_rwt(e, ctx, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0)))),
   u => t))))))))

# Module: src/check/annotate.bend:190
@unsafe
def ka_type(e, ctx, t):
  ka_type_node(e, ctx, core_beta(t))

# Module: src/check/annotate.bend:194
@unsafe
def ka_type_node(e, ctx, t):
  kc(KTerm, p98_tag_eq(t, "Var"), u => kid(ctx_get(ctx, ix(t)), 0),
   u => kc(KTerm, p98_tag_eq(t, "Ref"), u => dt(lookup(cb(e), nm(t))),
   u => kc(KTerm, p98_tag_eq(t, "Ann"), u => kid(t, 1),
   u => kc(KTerm, p98_tag_eq(t, "App"), u => ka_type_app(e, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0)))),
   u => kc(KTerm, p98_tag_eq(t, "ADT"), u => tele_fill(cb(e), dt(lookup(cb(e), nm(t))), ks(t)),
   u => kc(KTerm, p98_tag_eq(t, "Eql"), u => typ(2),
   u => kc(KTerm, p98_tag_eq(t, "Qua") || p98_tag_eq(t, "Min"), u => {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
   u => kc(KTerm, p98_tag_eq(t, "Typ") || p98_tag_eq(t, "Qnt") || p98_tag_eq(t, "All"), u => typ(1),
   u => {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))))))))

# Module: src/check/annotate.bend:206
@unsafe
def ka_type_app(e, t, fty):
  subst(kid(fty, 1), ix(fty), kid(t, 1))

# Module: src/check/annotate.bend:210
@unsafe
def ka_lam(e, ctx, t, ty):
  k_lam(nm(t), ix(t), kc(U32, k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => 2, u => qt(ty)), Con{annotate(e, ctx_bind(ctx, ix(t), qt(ty), nm(t), kid(ty, 0)), kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t)))), Nil{}}, 0, 0, False{})

# Module: src/check/annotate.bend:214
@unsafe
def ka_app(e, ctx, t, fty):
  app(annotate(e, ctx, kid(t, 0), fty), annotate(e, ctx, kid(t, 1), kid(fty, 0)))

# Module: src/check/annotate.bend:218
@unsafe
def ka_args(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +tel: KTerm,
  +xs: List<&2, KTerm>,
) -> List<&2, KTerm>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      ka_args_head(e, ctx, wnf(cb(e), tel), h, rest)

# Module: src/check/annotate.bend:231
@unsafe
def ka_args_head(e, ctx, tel, h, rest):
  Con{ka_field(annotate(e, ctx, h, kid(tel, 0)), qt(tel)), ka_args(e, ctx, subst(kid(tel, 1), ix(tel), h), rest)}

# Module: src/check/annotate.bend:235
@unsafe
def ka_mat(e, ctx, t, ty, a):
  ka_mat_ctr(e, ctx, t, ty, a, lookup(dc(lookup(cb(e), nm(a))), nm(t)))

# Module: src/check/annotate.bend:239
@unsafe
def ka_mat_ctr(e, ctx, t, ty, a, c):
  kt("Mat", nm(t), ix(t), qt(t), Con{annotate(e, ctx, kid(t, 0), mat_goal(cb(e), ty, tele_fill(cb(e), dt(c), ks(a)), da(c), nm(t), Nil{})), Con{annotate(e, ctx, mat_rest(cb(e), t, a), all(qt(ty), nm(ty), ix(ty), KTerm{tg(a), nm(a), ix(a), qt(a), ks(a), Con{nm(t), rm(a)}, kb(a), ke(a)}, kid(ty, 1))), Nil{}}})

# Module: src/check/annotate.bend:243
@unsafe
def ka_let(e, outer, ctx, xs, ty):
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      kc(List<&2, KTerm>, p98_tag_eq(h, "Bind"), u => ka_let_head(e, outer, ctx, h, rest, ty, ka_type(e, outer, kid(h, 0))), u => Con{annotate(e, ctx, h, ty), Nil{}})

# Module: src/check/annotate.bend:251
@unsafe
def ka_let_head(e, outer, ctx, h, rest, ty, vty):
  Con{kt("Bind", nm(h), ix(h), qt(h), Con{annotate(e, outer, kid(h, 0), vty), Nil{}}), ka_let(e, outer, ctx_bind(ctx, ix(h), qt(h), nm(h), vty), subst_terms(rest, ix(h), kt("Var", nm(h), ix(h), 0, Con{kid(h, 0), Nil{}})), ty)}

# Module: src/check/annotate.bend:255
@unsafe
def ka_rwt(e, ctx, t, eq):
  kt("Rwt", nm(t), ix(t), qt(t), Con{annotate(e, ctx, kid(t, 0), eq), Con{kid(t, 1), Con{annotate(e, ctx, kid(t, 2), kapply(kapply(kid(t, 1), kid(eq, 0)), {KTerm{"Rfl", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})), Nil{}}}})


# A Ref/Var-headed application spine has no beta-redex in its function prefix.
# Infer each intermediate function type once, preserving the old Ann structure.

# Module: src/check/annotate.bend:298
@unsafe
def ka_spine_eligible(t):
  kc(Bool, p98_tag_eq(t, "App"), u => ka_spine_eligible(kid(t, 0)), u => p98_tag_eq(t, "Ref") || p98_tag_eq(t, "Var"))

# Module: src/check/annotate.bend:302
@unsafe
def ka_spine(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +t: KTerm,
) -> KAnnotatedSpine:
  kc(KAnnotatedSpine, p98_tag_eq(t, "App"), u => ka_spine_finish(e, ctx, kid(t, 1), ka_spine(e, ctx, kid(t, 0))), u => KAnnotatedSpine{t, ka_type(e, ctx, t)})

# Module: src/check/annotate.bend:310
@unsafe
def ka_spine_finish(e, ctx, arg, r):
  match r:
    case KAnnotatedSpine{node, ty}: ka_spine_step(e, ctx, arg, node, wnf(cb(e), ty))

# Module: src/check/annotate.bend:315
@unsafe
def ka_spine_step(e, ctx, arg, node, fty):
  KAnnotatedSpine{ka_app_spine_root(e, ctx, arg, node, fty), subst(kid(fty, 1), ix(fty), arg)}

# Module: src/check/annotate.bend:319
@unsafe
def ka_app_spine(e, ctx, t):
  ka_app_spine_finish(e, ctx, kid(t, 1), ka_spine(e, ctx, kid(t, 0)))

# Module: src/check/annotate.bend:330
@unsafe
def ka_app_spine_finish(e, ctx, arg, r):
  match r:
    case KAnnotatedSpine{node, ty}: ka_app_spine_root(e, ctx, arg, node, wnf(cb(e), ty))

# Module: src/check/annotate.bend:335
@unsafe
def ka_app_spine_root(e, ctx, arg, node, fty):
  app(ka_wrap(node, fty), annotate(e, ctx, arg, kid(fty, 0)))

# Reuse a closed tail with only inert canonical Apps along its literal All spine.
# Ref/Ann/other heads restart analysis after ordinary weak-head normalization.

# Module: src/check/annotate.bend:356
@unsafe
def ka_args_cached(e, ctx, tel, xs):
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      ka_args_cached_head(e, ctx, wnf(cb(e), tel), h, rest)

# Module: src/check/annotate.bend:363
@unsafe
def ka_args_cached_head(e, ctx, tel, h, rest):
  kc(List<&2, KTerm>, p98_tag_eq(tel, "All"),
    u => ka_args_after_head(e, ctx, tel, h, rest, annotate(e, ctx, h, kid(tel, 0))),
    u => ka_args_head(e, ctx, tel, h, rest))

# Module: src/check/annotate.bend:369
@unsafe
def ka_args_static(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +tel: KTerm,
  +xs: List<&2, KTerm>,
) -> List<&2, KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      kc(List<&2, KTerm>, p98_tag_eq(tel, "All"),
        u => Con{ka_field(annotate(e, ctx, h, kid(tel, 0)), qt(tel)), ka_args_static(e, ctx, kid(tel, 1), rest)},
        u => ka_args_cached(e, ctx, tel, xs))

# Module: src/check/annotate.bend:392
@unsafe
def ka_args_after_head(e, ctx, tel, h, rest, annotated):
  kc(List<&2, KTerm>, core_subst_stable(kid(tel, 1)),
    u => Con{ka_field(annotated, qt(tel)), ka_args_static(e, ctx, kid(tel, 1), rest)},
    u => Con{ka_field(annotated, qt(tel)), ka_args(e, ctx, subst(kid(tel, 1), ix(tel), h), rest)})

# Checked layout validation consumes the field quantity already reconstructed
# here. Ann's first two children keep the existing backend representation.

# Module: src/check/annotate.bend:400
@unsafe
def ka_field(+annotated: KTerm, +quantity: U32) -> KTerm:
  kt("Ann", "", 1, quantity, ks(annotated))

# Module: src/front/lexer.bend:48
@unsafe
def f_choose(
  -A: Type,
  +b: Bool,
  yes: Unit -> A,
  no: Unit -> A,
) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# Module: src/front/lexer.bend:61
@unsafe
def f_raw_line(
  +ts: List<&2, FToken>,
) -> U32:
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k, begin, end, previousEnd}, rest}:
      l

# Module: src/front/lexer.bend:98
@unsafe
def f_raw_col(
  +ts: List<&2, FToken>,
) -> U32:
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k, begin, end, previousEnd}, rest}:
      c

# Module: src/front/lexer.bend:108
@unsafe
def f_raw_kind(
  +ts: List<&2, FToken>,
) -> U32:
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k, begin, end, previousEnd}, rest}:
      k

# Module: src/front/lexer.bend:118
@unsafe
def f_ident(
  +c: Char,
) -> Bool:
  f_ascii_ident_code(Char.to_u32(c))

# Zero disables cursor metadata and preserves the legacy token list.

# Module: src/front/lexer.bend:189
@unsafe
def f_cursor_add(+offset: U32, +size: U32) -> U32:
  f_choose(U32, U32.is_eq(offset, 0), u => 0, u => U32.add(offset, size))

# Module: src/front/lexer.bend:193
type P150LQuoted is Data:
  P150LQuoted{+word: String, +rest: String, size: U32, width: U32, line: U32, column: U32}

type P150LEdge is Data:
  P150LEdge{column: U32, natural: Bool}

@unsafe
def p150l_cursor(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match s:
    case SNil{}:
      List.reverse(&2,FToken,f_choose(List<&2,FToken>,U32.is_eq(offset,0),
        u => acc,u => Con{FToken{"<eof>",0,0,0,offset,offset,previous},acc}))
    case SCon{+head,+rest}:
      +code = Char.to_u32(head)
      f_choose(List<&2,FToken>,U32.is_eq(code,10),u => p150l_newline(rest,l,c,d,acc,offset,previous),
      u => f_choose(List<&2,FToken>,f_ascii_space_code(code),
        u => p150l_cursor(rest,l,U32.add(c,1),d,acc,f_cursor_add(offset,dg_units(head)),previous),
      u => f_choose(List<&2,FToken>,U32.is_eq(code,35),u => p150l_comment(rest,l,c,d,acc,f_cursor_add(offset,1),previous),
      u => f_choose(List<&2,FToken>,U32.is_eq(code,34) || U32.is_eq(code,39),
        u => p150l_quoted(p150l_quote(rest,head,SCon{head,""},1,1,l,U32.add(c,1)),l,c,d,acc,offset,previous),
        u => f_choose(List<&2,FToken>,f_ident(head) && Bool.not(Char.is_eq(head,'.')),
          u => p150l_word_done(p150l_word(rest,SCon{head,""},1,head),l,c,d,acc,offset,previous),
          u => p150l_other(head,rest,l,c,d,acc,offset,previous))))))

@unsafe
def p150l_newline(rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p150l_cursor(rest,U32.add(l,1),0,d,
    f_choose(List<&2,FToken>,U32.is_eq(d,0),u => Con{FToken{"\n",l,c,0,offset,f_cursor_add(offset,1),previous},acc},u => acc),
    f_cursor_add(offset,1),previous)

# Comment bytes advance the indexed cursor, deliberately not the physical column.
@unsafe
def p150l_comment(s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match s:
    case SNil{}: p150l_cursor("",l,c,d,acc,offset,previous)
    case SCon{+head,+rest}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'\n'),
        u => p150l_newline(rest,l,c,d,acc,offset,previous),
        u => p150l_comment(rest,l,c,d,acc,f_cursor_add(offset,dg_units(head)),previous))

@unsafe
def p150l_digit(s: String) -> Bool:
  match s:
    case SNil{}: False{}
    case SCon{head,rest}: f_ascii_digit(head)

# The exponent sign rule also applies to identifiers such as name+2.
@unsafe
def p150l_word(+s: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  p170ls_word(s,s,acc,n,last)


@unsafe
def p150l_word_done(sc: FScanned, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match sc:
    case FScanned{word,rest,+size}:
      f_choose(List<&2,FToken>,U32.is_eq(size,0),
        u => p150l_unterminated(l,c,acc,offset,previous),
        u => p150l_word_end(word,rest,l,c,d,acc,offset,previous,size,f_cursor_add(offset,size)))

@unsafe
def p150l_word_end(+word: String, rest: String, +l: U32, +c: U32, d: U32, acc: List<&2,FToken>, +offset: U32, previous: U32, size: U32, +end: U32) -> List<&2,FToken>:
  p150l_cursor(rest,l,U32.add(c,size),d,Con{FToken{word,l,c,1,offset,end,previous},acc},end,end)

# Metadata is accumulated with raw U32 addition, then added to the opening
# cursor once. Applying f_cursor_add per quote character changes wrap-to-zero.
# Only the entry's single/double quote calls reach these private scanners.
@unsafe
def p150l_quote(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match s:
    case SNil{}: P150LQuoted{"","",0,0,0,0}
    case SCon{+head,+rest}:
      f_choose(P150LQuoted,f_ascii_char_eq(head,'\\'),u => p150l_escape(rest,quote,acc,n,width,l,c),
      u => f_choose(P150LQuoted,f_ascii_char_eq(head,'\n'),
        u => p150l_quote(rest,quote,SCon{head,acc},U32.add(n,1),U32.add(width,1),U32.add(l,1),0),
      u => f_choose(P150LQuoted,Char.is_eq(head,quote),
        u => P150LQuoted{String.reverse(SCon{head,acc}),rest,U32.add(n,1),U32.add(width,1),l,U32.add(c,1)},
        u => p150l_quote(rest,quote,SCon{head,acc},U32.add(n,1),U32.add(width,dg_units(head)),l,U32.add(c,1)))))

@unsafe
def p150l_escape(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match s:
    case SNil{}: P150LQuoted{"","",0,0,0,0}
    case SCon{+head,+rest}:
      f_choose(P150LQuoted,f_ascii_char_eq(head,'\n'),
        u => p150l_quote(rest,quote,SCon{head,SCon{'\\',acc}},U32.add(n,2),U32.add(width,2),U32.add(l,1),0),
        u => p150l_quote(rest,quote,SCon{head,SCon{'\\',acc}},U32.add(n,2),U32.add(width,U32.add(1,dg_units(head))),l,U32.add(c,2)))

@unsafe
def p150l_quoted(sc: P150LQuoted, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match sc:
    case P150LQuoted{word,rest,size,width,line,column}:
      f_choose(List<&2,FToken>,U32.is_eq(size,0),
        u => p150l_unterminated(l,c,acc,offset,previous),
        u => p150l_quote_end(word,rest,l,c,d,acc,offset,previous,line,column,f_cursor_add(offset,width)))

@unsafe
def p150l_quote_end(word: String, rest: String, l: U32, c: U32, d: U32, acc: List<&2,FToken>, offset: U32, previous: U32, line: U32, column: U32, +end: U32) -> List<&2,FToken>:
  p150l_cursor(rest,line,column,d,Con{FToken{word,l,c,2,offset,end,previous},acc},end,end)

@unsafe
def p150l_unterminated(l: U32, c: U32, acc: List<&2,FToken>, +offset: U32, previous: U32) -> List<&2,FToken>:
  List.reverse(&2,FToken,Con{FToken{"unterminated string",l,c,3,offset,offset,previous},acc})

# Exact three-character dispatch precedes dot-word scanning. Only accepted
# operators construct token text; lookahead compares scalar character values.
@unsafe
def p150l_other(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p170ls_other(head,rest,rest,l,c,d,acc,offset,previous)


@unsafe
def p150l_triple(+a: Char, +b: Char, +c: Char) -> Bool:
  f_choose(Bool,f_ascii_char_eq(a,'.'),
    u => f_ascii_char_eq(c,'.') && (f_ascii_char_eq(b,'&') || f_ascii_char_eq(b,'|') || f_ascii_char_eq(b,'^')),
    u => f_ascii_char_eq(a,'<') && f_ascii_char_eq(b,'&') && f_ascii_char_eq(c,'>'))

@unsafe
def p150l_other_plain(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  f_choose(List<&2,FToken>,f_ascii_char_eq(head,'.'),u => p150l_word_done(p150l_word(rest,".",1,'.'),l,c,d,acc,offset,previous),
  u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'+'),u => p150l_plus(rest,l,c,d,acc,offset,previous,p150l_edge(acc)),
  u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'>'),u => p150l_greater(rest,l,c,d,acc,offset,previous,p150l_edge(acc)),
    u => p150l_symbol(head,rest,l,c,d,acc,offset,previous))))

# The old adjacency rule uses the stored token text, including >op/+bind,
# and no line check. One scan obtains length and the final character together.
@unsafe
def p150l_edge(tokens: List<&2,FToken>) -> P150LEdge:
  match tokens:
    case Nil{}: P150LEdge{5,False{}}
    case Con{FToken{text,line,column,kind,begin,end,previous},rest}: p150l_edge_text(text,column,'\0')

@unsafe
def p150l_edge_text(text: String, +column: U32, last: Char) -> P150LEdge:
  match text:
    case SNil{}: P150LEdge{column,Char.is_eq(last,'n')}
    case SCon{head,rest}: p150l_edge_text(rest,U32.add(column,1),head)

@unsafe
def p150l_plus(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, edge: P150LEdge) -> List<&2,FToken>:
  match edge:
    case P150LEdge{column,natural}: p150l_plus_at(rest,l,c,d,acc,offset,previous,natural && U32.is_eq(c,column))

@unsafe
def p150l_plus_at(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +contiguous: Bool) -> List<&2,FToken>:
  p170ls_plus(rest,rest,l,c,d,acc,offset,previous,contiguous)


@unsafe
def p150l_greater(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, edge: P150LEdge) -> List<&2,FToken>:
  match edge:
    case P150LEdge{column,natural}: p150l_greater_at(rest,l,c,d,acc,offset,previous,U32.is_gt(c,column))

@unsafe
def p150l_greater_at(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +gap: Bool) -> List<&2,FToken>:
  p170ls_greater(rest,rest,l,c,d,acc,offset,previous,gap)


@unsafe
def p150l_symbol(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p170ls_symbol(head,rest,rest,l,c,d,acc,offset,previous)


# Scalar predicates avoid expanding Char literal patterns into bit patterns.
@unsafe
def p150l_pair(a: Char, b: Char) -> Bool:
  +x = Char.to_u32(a)
  +y = Char.to_u32(b)
  f_choose(Bool,U32.is_eq(y,62),u => U32.is_eq(x,45) || U32.is_eq(x,61) || U32.is_eq(x,60),
  u => f_choose(Bool,U32.is_eq(y,61),u => U32.is_eq(x,61) || U32.is_eq(x,33) || U32.is_eq(x,60),
  u => f_choose(Bool,U32.is_eq(x,60),u => U32.is_eq(y,45) || U32.is_eq(y,60),
    u => U32.is_eq(x,y) && (U32.is_eq(x,38) || U32.is_eq(x,124)))))

@unsafe
def p150l_single(+head: Char, rest: String, l: U32, c: U32, d: U32, acc: List<&2,FToken>, offset: U32, previous: U32) -> List<&2,FToken>:
  p150l_emit(SCon{head,""},rest,l,c,p150l_depth(head,d),acc,offset,previous,1,dg_units(head))

@unsafe
def p150l_depth(head: Char, +depth: U32) -> U32:
  +code = Char.to_u32(head)
  f_choose(U32,U32.is_eq(code,40) || U32.is_eq(code,91) || U32.is_eq(code,123),u => U32.add(depth,1),
  u => f_choose(U32,U32.is_eq(code,41) || U32.is_eq(code,93) || U32.is_eq(code,125),u => U32.sub(depth,1),u => depth))

@unsafe
def p150l_emit(text: String, rest: String, +l: U32, +c: U32, d: U32, acc: List<&2,FToken>, +offset: U32, previous: U32, columns: U32, width: U32) -> List<&2,FToken>:
  p150l_emitted(text,rest,l,c,d,acc,offset,previous,columns,f_cursor_add(offset,width))

@unsafe
def p150l_emitted(text: String, rest: String, +l: U32, +c: U32, d: U32, acc: List<&2,FToken>, offset: U32, previous: U32, columns: U32, +end: U32) -> List<&2,FToken>:
  p150l_cursor(rest,l,U32.add(c,columns),d,Con{FToken{text,l,c,0,offset,end,previous},acc},end,end)


# Composite Phase152: preserve the public lexer contract and all old helper laws.
@unsafe
def f_lex_cursor(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p150l_cursor(s,l,c,d,acc,offset,previous)


# Compiler-local ASCII classification. Unsigned subtraction tests a bounded
# ASCII range; setting bit 5 folds uppercase ASCII into lowercase. Other Unicode
# codepoints cannot enter either ASCII range, including isolated surrogates.
# Base Char workers and exported runtime primitive semantics remain unchanged.

# Module: src/front/lexer.bend:292
@unsafe
def f_ascii_char_eq(a, b):
  U32.is_eq(Char.to_u32(a), Char.to_u32(b))

# Module: src/front/lexer.bend:296
@unsafe
def f_ascii_alpha(c):
  U32.is_le(U32.sub(U32.or(Char.to_u32(c), 32), 97), 25)

# Module: src/front/lexer.bend:300
@unsafe
def f_ascii_digit(c):
  U32.is_le(U32.sub(Char.to_u32(c), 48), 9)

# Module: src/front/lexer.bend:304
@unsafe
def f_ascii_ident_code(code):
  U32.is_le(U32.sub(U32.or(code, 32), 97), 25) || U32.is_le(U32.sub(code, 48), 9) || U32.is_eq(code, 95) || U32.is_eq(code, 46)

# Module: src/front/lexer.bend:312
@unsafe
def f_ascii_space_code(code):
  U32.is_eq(code, 32) || U32.is_le(U32.sub(code, 9), 4)

# Header and argument whitespace preserves statement semicolons.

# Module: src/front/lexer.bend:317
@unsafe
def f_line(+input: FInput) -> U32:
  match input:
    case FInput{tokens, context}: f_raw_line(tokens)

# Module: src/front/lexer.bend:353
@unsafe
def f_col(+input: FInput) -> U32:
  match input:
    case FInput{tokens, context}: f_raw_col(tokens)

# Module: src/front/lexer.bend:358
@unsafe
def f_kind(+input: FInput) -> U32:
  match input:
    case FInput{tokens, context}: f_raw_kind(tokens)

# Module: src/front/lexer.bend:363
@unsafe
def dg_units(
  +c: Char,
) -> U32:
  kc(U32, U32.is_gt(Char.to_u32(c), 65535), u => 2, u => 1)

# Module: src/diagnostic/render.bend:49
@unsafe
def dg_scope(
  +ctx: List<&2, KTerm>,
  +env: List<&2, KPName>,
) -> List<&2, KPName>:
  match ctx:
    case Nil{}: env
    case Con{h, rest}: dg_scope(rest, kp_bind(env, h))


# book_load blanks leading imports while retaining their newlines. Coordinates
# still use the immutable raw source; only the displayed lines differ.

# Module: src/diagnostic/render.bend:227
@unsafe
def dg_text(s):
  kt("DText", s, 0, 0, Nil{})

# Module: src/diagnostic/trace.bend:50
@unsafe
def dg_bad_detail(world, message, expected, observed):
  KChecking{kt("DDetail", "", 0, 1, [expected, observed]), {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, message, world, 0}

# Module: src/diagnostic/trace.bend:54
@unsafe
def dg_bad_message(world, message, expected):
  KChecking{kt("DDetail", "", 0, 0, [expected, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]), {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, message, world, 0}

# Module: src/diagnostic/trace.bend:58
@unsafe
def dg_pair(
  +expected: KTerm,
  +observed: KTerm,
) -> KTerm:
  kt("DDetail", "", 0, 1, [expected, observed])

# Module: src/diagnostic/trace.bend:65
@unsafe
def dg_family(
  +book: List<&2, KDef>,
  +name: String,
) -> String:
  match book:
    case Nil{}: ""
    case Con{d, rest}: kc(String, p88_string_eq(dk(d), "ADT") && Bool.not(p88_string_eq(dk(lookup(dc(d), name)), "Absent")), u => dn(d), u => dg_family(rest, name))

# Module: src/diagnostic/trace.bend:74
@unsafe
def dg_trace(e, ctx, t, ty, r):
  kc(KChecking, good(r), u => r, u => kc(KChecking, p98_tag_eq(ct(r), "DTrace"), u => KChecking{kt("DTrace", nm(ct(r)), ix(ct(r)), qt(ct(r)), [kid(ct(r), 0), kid(ct(r), 1), kid(ct(r), 2), kid(ct(r), 3), kt("DTrail", "", 0, 0, norm_join(ks(kid(ct(r), 4)), [t])), kid(ct(r), 5)]), cy(r), cs(r), ce(r), rw(r), rx(r)}, u => dg_trace_detail(ke_world(e, rw(r)), ctx, t, r, kc(KTerm, p98_tag_eq(ct(r), "DDetail"), u => ct(r), u => dg_reason(ke_world(e, rw(r)), ctx, t, ty, ce(r))))))

# Module: src/diagnostic/trace.bend:78
@unsafe
def dg_unqualified_name(+rest: String, +name: String) -> String:
  match rest:
    case SNil{}: name
    case SCon{head,tail}: dg_unqualified_name(tail,kc(String,Char.is_eq(head,':'),u => tail,u => name))

@unsafe
def dg_datatype_braces(+book: List<&2,KDef>, +name: String) -> String:
  +bare = dg_unqualified_name(name,name)
  +found = kc(String,p88_string_eq(dk(lookup(book,name)),"ADT"),u => name,
    u => kc(String,p88_string_eq(dk(lookup(book,bare)),"ADT"),v => bare,v => ""))
  kc(String,Bool.not(String.is_empty(found)) && String.is_empty(dg_family(book,name)),
    u => "Note: " ++ found ++ " is a datatype: write its arguments as <>",u => "")

@unsafe
def dg_trace_detail(e, ctx, t, r, detail):
  KChecking{kt("DTrace", cn(e), 0, qt(detail), [kid(detail, 0), kid(detail, 1), kt("DCtx", "", 0, 0, ctx), t, kt("DTrail", "", 0, 0, [t]), dg_text(kc(String, p88_string_eq(ce(r), "constructor requires a datatype goal"), u => dg_datatype_braces(cb(e),nm(t)), u => ""))]), cy(r), cs(r), ce(r), rw(r), rx(r)}

# Module: src/diagnostic/trace.bend:82
@unsafe
def dg_reason(e, ctx, t, ty, code):
  kc(KTerm, p88_string_eq(code, "undefined name"), u => dg_pair(dg_text("a defined name"), t),
   u => kc(KTerm, p88_string_eq(code, "unbound variable"), u => dg_pair(dg_text("a bound variable"), kc(KTerm, p98_tag_eq(t, "FUnboundVar"), u => dg_text(nm(t) ++ kc(String, kp_bound(dg_scope(ctx, Nil{}), nm(t)), u => "^-1", u => "")), u => t)),
   u => kc(KTerm, p88_string_eq(code, "nondecreasing self-call"), u => dg_pair(dg_text("a decreasing self-call (arguments are read left to right: each passed unchanged until one shrinks)"), t),
   u => kc(KTerm, p88_string_eq(code, "live use of an unfilled law"), u => dg_pair(dg_text("a filled definition (an unfilled law is a dead claim: live code cannot use it)"), t),
   u => kc(KTerm, p88_string_eq(code, "a family requires angle-bracket parameters"), u => dg_pair(dg_text("a family instance (write " ++ name_key(nm(t)) ++ "<..>)"), t),
   u => kc(KTerm, p88_string_eq(code, "unresolved hole"), u => dg_pair(ty, t),
   u => kc(KTerm, p88_string_eq(code, "cannot infer: annotation required"), u => dg_pair(dg_text(kc(String, (p98_tag_eq(t, "Ctr") || core_literal(t)) && p88_string_eq(dg_family(cb(e), nm(kc(KTerm, core_literal(t), u => core_literal_step(t), u => t))), ""), u => "a declared constructor", u => "an annotated term (cannot infer)")), t),
   u => kc(KTerm, p88_string_eq(code, "lambda requires a function type") || p88_string_eq(code, "matcher requires a function type") || p88_string_eq(code, "reflexivity requires equality goal"), u => dg_pair(ty, dg_text("non-inferrable term")),
   u => kc(KTerm, p88_string_eq(code, "constructor requires a datatype goal"), u => dg_pair(ty, kc(KTerm, p88_string_eq(dg_family(cb(e), nm(t)), ""), u => dg_text("non-inferrable term"), u => ref(dg_family(cb(e), nm(t))))),
   u => kt("DDetail", "", 0, 0, [dg_text(code), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]))))))))))

# Module: src/diagnostic/trace.bend:95
@unsafe
def dg_template_result(+e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, p88_string_eq(ce(r), "unbound variable") && p98_tag_eq(ct(r), "DTrace") && p98_tag_eq(kid(ct(r), 1), "Var") && Bool.not(p98_tag_eq(ctx_get(ctx, ix(kid(ct(r), 1))), "Absent")), u => dg_trace(e, ctx, t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, kr_from(r, dg_bad_detail(rw(r), ce(r), dg_text("a template applied to closed ~ arguments (" ++ nm(kid(ct(r), 1)) ++ " is a variable here, not comptime: pass it at run time)"), t))), u => r)

# Module: src/diagnostic/trace.bend:121
@unsafe
def dg_kind_check(+e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +q: U32, +name: String) -> KChecking:
  dg_kind_at(e, ctx, t, q, name, t)

# Module: src/diagnostic/trace.bend:125
@unsafe
def dg_kind_at(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +q: U32, +name: String, +site: KTerm) -> KChecking:
  +kind = typ(kindq(e, q))
  dg_kind_result(t, q, name, site, kind, check(e, ctx, t, 0, kind))

# Module: src/diagnostic/trace.bend:130
@unsafe
def dg_kind_result(+t: KTerm, +q: U32, +name: String, +site: KTerm, +kind: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, p88_string_eq(ce(r), "type mismatch") && p98_tag_eq(ct(r), "DTrace") && norm_exact(kid(ct(r), 0), kind) && norm_exact(kid(ct(r), 3), t) && (U32.is_eq(kb(t), 0) || U32.is_eq(kb(kid(ct(r), 3)), 0) || (U32.is_eq(kb(t), kb(kid(ct(r), 3))) && U32.is_eq(ke(t), ke(kid(ct(r), 3))))), u => KChecking{kt("DTrace", nm(ct(r)), ix(ct(r)), qt(ct(r)), [kid(ct(r), 0), kid(ct(r), 1), kid(ct(r), 2), site, kt("DTrail", "", 0, 0, Con{site, ks(kid(ct(r), 4))}), kc(KTerm, U32.is_eq(q, 2), u => dg_text("Note: +" ++ name ++ " can be used many times, so its type must be Data."), u => kid(ct(r), 5))]), cy(r), cs(r), ce(r), rw(r), rx(r)}, u => r)

# Module: src/diagnostic/trace.bend:134
@unsafe
def dg_quant_error(world, message, name, allowed, used):
  dg_bad_detail(world, message, dg_text(kp_quant(allowed) ++ name), dg_text(kc(String, U32.is_eq(used, 2), u => name ++ " (consumed more than once)", u => kp_quant(used) ++ name)))

# Module: src/diagnostic/produce.bend:179
@unsafe
def dg_constructor_names(ds):
  match ds:
    case Nil{}: ""
    case Con{d, rest}: name_key(dn(d)) ++ kc(String, defs_empty(rest), u => "", u => ", " ++ dg_constructor_names(rest))

# Module: src/diagnostic/produce.bend:185
@unsafe
def dg_ctor_error(e, t, ty, ctr):
  kc(KChecking, Bool.not(p88_string_eq(dk(ctr), "Absent")) && Bool.not(has_name(rm(ty), nm(t))), u => dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", dg_text(name_key(nm(t)) ++ " with " ++ U32.show(da(ctr)) ++ kc(String, U32.is_eq(da(ctr), 1), u => " field", u => " fields")), t), u => kc(KChecking, p88_string_eq(dg_family(cb(e), nm(t)), ""), u => dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", dg_text("a declared constructor (" ++ name_key(nm(ty)) ++ " declares " ++ dg_constructor_names(dc(lookup(cb(e), nm(ty)))) ++ ")"), t), u => dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", ty, ref(dg_family(cb(e), nm(t))))))

# The checker verdict stays unchanged; only rejection metadata differs.

# Module: src/diagnostic/produce.bend:197
@unsafe
def dg_adt_error(world, t, d):
  kc(KChecking, p88_string_eq(dk(d), "ADT"), u => dg_bad_detail(world, "unknown family or wrong parameter count", dg_text(name_key(nm(t)) ++ " with " ++ U32.show(da(d)) ++ kc(String, U32.is_eq(da(d), 1), u => " parameter", u => " parameters")), t), u => dg_bad_message(world, "unknown family or wrong parameter count", dg_text("a declared datatype (unknown: " ++ name_key(nm(t)) ++ ")")))

# Compatibility projections and explicit capability for hosts using one verdict.

# Module: src/diagnostic/produce.bend:205
type P205Pattern is Data:
  L205{+inner: P205Pattern}
  B205{+value: P205Pattern, +inner: P205Pattern}
  V205{+depth: U32}
  R205{+role: String}
  N205{+tag: String, +name: String, +kids: List<&2,P205Pattern>}

type P205Equation is Data:
  P205Equation{+signature: List<&2,String>, +pattern: P205Pattern}

type P205UResult is Data:
  P205UResult{+term: KTerm, +next: U32, +steps: U32, +ok: Bool}
type P205UFields is Data:
  P205UFields{+terms: List<&2,KTerm>, +next: U32, +steps: U32, +ok: Bool}

type P205UPick is Data:
  P205UPick{+change: KDef, +used: Bool}
type CtfeVal is Data:
  CVU32{+n: U32}
  CVNat{+n: U32}
  CVF32{+x: F32}
  CVStr{+s: String}
  CVCtr{+name: String, +fields: List<&2, CtfeVal>}
  CVClo{+env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +term: KTerm}
  CVPrim{+name: String, +arity: U32, +args: List<&2, CtfeVal>}
  CVEra{}
  CVFail{}

type CtfeRes is Data:
  CtfeRes{+val: CtfeVal, +fuel: U32}

type CtfeListRes is Data:
  CtfeListRes{+vals: List<&2, CtfeVal>, +fuel: U32, +ok: Bool}

type AgyAbsPeel is Data:
  AgyAbsPeel{+lams: List<&2,KTerm>, +body: KTerm, +ok: Bool}

type AgyAbsWalk is Data:
  AgyAbsWalk{+term: KTerm, +hit: Bool, +ok: Bool}

type AgyAbsResult is Data:
  AgyAbsResult{+context: List<&2,KDef>, +defs: List<&2,KDef>, +changed: Bool}

type AgyPeel is Data:
  AgyPeel{+lams: List<&2,KTerm>, +body: KTerm, +ok: Bool}

type AgyStep is Data:
  AgyStep{+step: U32, +ok: Bool}

type AgyBFResult is Data:
  AgyBFResult{+context: List<&2,KDef>, +defs: List<&2,KDef>, +changed: Bool}

type W2Range is Data:
  W2Range{+lo: U32, +hi: U32, +ok: Bool}

type W2Fold is Data:
  W2Fold{+fname: String, +st_ty: KTerm, +nil_fn: KTerm, +step_fn: KTerm, +ok: Bool}

type W2StepExtract is Data:
  W2StepExtract{+term: KTerm, +found: Bool}

type W2Builder is Data:
  W2Builder{+pname: String, +arity: U32, +rec: Bool, +lams0: List<&2,KTerm>, +lams1: List<&2,KTerm>, +lets: List<&2,KTerm>, +ch_expr: KTerm, +rec_args: List<&2,KTerm>, +ok: Bool}

type W2State is Data:
  W2State{+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +term: KTerm, +changed: Bool}

type W2Lets is Data:
  W2Lets{+binds: List<&2,KTerm>, +body: KTerm}

type W2UnboxArm is Data:
  W2UnboxArm{+cname: String, +hid: U32, +h_next: KTerm, +rec_args: List<&2,KTerm>, +ok: Bool}

type W2Hoist is Data:
  W2Hoist{+cname: String, +term: KTerm, +ok: Bool}

type W2Bind is Data:
  W2Bind{+bid: U32, +rhs: KTerm}

def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  match term:
    case KTerm{tag, _, _, _, _, _, _, _}: String.eq(tag, key)
    case KLambda{_, _, _, _, _, _, _, _}: String.eq("Lam", key)
    case KLiteral{_, _, _, _, _}: String.eq("Lit", key)

# Bounded saturated selector expansion. The syntax gate admits no references,
# primitive calls, data fields, or free variables from the callee body.
type N111Type is Data:
  N111U32{}
  N111U64{}
  N111Ptr{}

type N111Value is Data:
  N111Local{+name: String}
  N111Const{+lo: U32, +hi: U32}
  N111Symbol{+name: String}
  N111FuncId{+name: String}
  N111CtorId{+name: String}

type N111Arg is Data:
  N111Arg{+typ: N111Type, +value: N111Value}

type N111Stmt is Data:
  N111Set{+name: String, +typ: N111Type, +value: N111Value}
  N111Bin{+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value}
  N111Call{+name: String, +typ: N111Type, +symbol: String, +args: List<&2, N111Arg>}
  N111If{+condition: N111Value, +yes: List<&2, N111Stmt>, +no: List<&2, N111Stmt>}
  N111Return{+value: N111Value}
  N111Load{+name: String, +typ: N111Type, +base: N111Value, +offset: U32}
  N111Store{+typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value}
  N111Offset{+name: String, +base: N111Value, +bytes: N111Value}
  N111Alloca{+name: String, +bytes: U32, +align: U32}

# Every body already includes its parameter/frame prelude. The sole machine
# argument is the borrowed state pointer, available as N111Local{"state"}.
type N111Segment is Data:
  N111Segment{+name: String, +arity: U32, +result: U32, +incoming: U32, +flags: U32, +body: List<&2, N111Stmt>}

type N111Ids is Data:
  N111Ids{+functions: KDef, +constructors: KDef}

type P111Program is Data:
  P111Program{+segments: List<&2, N111Segment>, +constructors: List<&2, N_Constructor>, +show: List<&2, U32>, +show_names: List<&2, String>, +effects: List<&2, String>, +pure: Bool}

type P111Result is Data:
  P111Result{+program: P111Program, +error: String}

type P111Code is Data:
  P111Code{+body: List<&2, N111Stmt>, +segments: List<&2, N111Segment>, +fresh: U32, +error: String}

type P111Book is Data:
  P111Book{+segments: List<&2, N111Segment>, +fresh: U32, +error: String}

type P111Partition is Data:
  P111Partition{+live: List<&2, NC_Binding>, +drop: List<&2, N111Stmt>}

type P111ValueCode is Data:
  P111ValueCode{+body: List<&2, N111Stmt>, +value: N111Value, +error: String}


# Phase111 module: selfhost/tools/performance/phase111/segment/show.bend
# Structured counterpart of the mature native/show.bend descriptor builder.
# References remain typed until the breadth-first offsets and constructor IDs
# are known. No NC_Desc string cells, C declarations or macros are parsed.
type P111Show is Data:
  P111Show{+words: List<&2, U32>, +names: List<&2, String>, +error: String}

type P111ShowCell is Data:
  P111ShowWord{+value: U32}
  P111ShowRef{+index: U32}
  P111ShowCtor{+name: String}

type P111ShowDesc is Data:
  P111ShowDesc{+cells: List<&2, P111ShowCell>, +types: List<&2, KTerm>, +error: String}

type P111ShowGraph is Data:
  P111ShowGraph{+cells: List<&2, P111ShowCell>, +offsets: List<&2, U32>, +error: String}

type P111ShowWords is Data:
  P111ShowWords{+words: List<&2, U32>, +error: String}

type P111VScan is Data:
  P111VScan{+index: KDef, +error: String, +count: U32}

type P111VFlow is Data:
  P111VFlow{+live: KDef, +terminal: Bool, +error: String}

type P111QDecimal is Data:
  P111QDecimal{+lo: U32, +hi: U32, +digit: U32}

type P111QDatum is Data:
  P111QByte{+value: U32}
  P111QWord{+value: U32}
  P111QLong{+lo: U32, +hi: U32}
  P111QReloc{+symbol: String, +offset: U32}
  P111QZeros{+bytes: U32}

type P111QData is Data:
  P111QData{+name: String, +alignment: U32, +exported: Bool, +items: List<&2,P111QDatum>}

type P112Liveness is Data:
  P112LivenessEmpty{}
  P112LivenessLeaf{+term: KTerm, +uses: NU_Set}
  P112LivenessLet{+value: KTerm, +id: U32, +uses: NU_Set, +rest: P112Liveness}


type P112TailStmt is Data:
  P112TailScalar{+stmt: N111Stmt}
  P112TailIf{+condition: N111Value, +yes: List<&2,P112TailStmt>, +no: List<&2,P112TailStmt>}
  P112TailAgain{}


type P112TailPrelude is Data:
  P112TailPrelude{+valid: Bool, +params: List<&2,String>, +prefix: List<&2,N111Stmt>, +body: List<&2,N111Stmt>}


type P112TailBody is Data:
  P112TailBody{+valid: Bool, +loops: U32, +body: List<&2,P112TailStmt>}


type P112TailPlan is Data:
  P112TailPlan{+valid: Bool, +loops: U32, +params: List<&2,String>, +prefix: List<&2,N111Stmt>, +body: List<&2,P112TailStmt>}


type P112WorkerStmt is Data:
  P112WorkerScalar{+stmt: N111Stmt}
  P112WorkerIf{+condition: N111Value, +yes: List<&2,P112WorkerStmt>, +no: List<&2,P112WorkerStmt>}
  P112WorkerAgain{}
  P112WorkerResult{}
  P112WorkerCall{+target: String, +arity: U32}


type P112WorkerBody is Data:
  P112WorkerBody{+valid: Bool, +calls: U32, +body: List<&2,P112WorkerStmt>}


type P112WorkerPlan is Data:
  P112WorkerPlan{+valid: Bool, +calls: U32, +params: List<&2,String>, +body: List<&2,P112WorkerStmt>}


type P112SWord is Data:
  P112SRaw{+value: U32}
  P112SPacked{+name: String, +payload: U32}
  P112SBox{+name: String, +offset: U32}


type P112SNode is Data:
  P112SNode{+offset: U32, +name: String, +fields: List<&2,P112SWord>}


type P112StaticProgram is Data:
  P112StaticProgram{+program: P111Program, +nodes: List<&2,P112SNode>}


type P112SImage is Data:
  P112SImage{+size: U32, +nodes: List<&2,P112SNode>, +index: KDef, +error: String}


type P112STerm is Data:
  P112STerm{+term: KTerm, +image: P112SImage}


type P112STerms is Data:
  P112STerms{+terms: List<&2,KTerm>, +image: P112SImage}


type P112SDefs is Data:
  P112SDefs{+facts: List<&2,KDef>, +image: P112SImage}


type P112SPrepared is Data:
  P112SPrepared{+book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +error: String}

# Same ordered identities as p111_finish / p111q_constructor_ids. Store both
# numeric ID and exact live arity so lowering and validation share one lookup.


type P112FusionFrame is Data:
  P112FusionFrame{+captures: List<&2,N111Value>, +name: String, +dest: String, +tail: List<&2,N111Stmt>}


type P112FusionCont is Data:
  P112FusionCont{+captures: List<&2,String>, +result: String, +pop: String, +body: List<&2,N111Stmt>}


type P112FusionBody is Data:
  P112FusionBody{+body: List<&2,N111Stmt>, +count: U32, +next: U32}

# Typed exact-name index. Hash collisions retain their original N111 segments.


type P112FusionIndex is Data:
  P112FusionEmpty{}
  P112FusionLeaf{+hash: U32, +bucket: List<&2,N111Segment>}
  P112FusionNode{+mask: U32, +left: P112FusionIndex, +right: P112FusionIndex}


type P112RegionEntry is Data:
  P112RegionEntry{+segment: N111Segment, +plan: P112WorkerPlan, +rank: U32, +sites: U32}


type P112RegionRegistry is Data:
  P112RegionRegistry{+ready: KDef, +symbols: KDef, +entries: List<&2,P112RegionEntry>, +workers: U32, +fusions: U32}


type P112MultiCandidate is Data:
  P112MultiCandidate{+segment: N111Segment}


type P112PureGap is Data:
  P112PureGap{+gap: List<&2,N111Stmt>, +tail: List<&2,N111Stmt>}


type P113DStmt is Data:
  P113DScalar{+stmt: N111Stmt}
  P113DIf{+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>}
  P113DCall{+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>}
  P113DResult{+values: List<&2,N111Value>}
  P113DAgain{+values: List<&2,N111Value>}


type P113DTarget is Data:
  P113DReturn{}
  P113DLocal{+name: String}


type P113DCode is Data:
  P113DCode{+body: List<&2,P113DStmt>, +fresh: U32, +error: String, +calls: List<&2,String>}


type P113DFunction is Data:
  P113DFunction{+name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, +body: List<&2,P113DStmt>}


type P113DCandidate is Data:
  P113DCandidate{+function: P113DFunction, +error: String, +calls: List<&2,String>}

# The original verified/static program is always retained as fallback.
# Only original public segments whose name occurs in functions are wrapped.


type P113DProgram is Data:
  P113DProgram{+original: P112StaticProgram, +functions: List<&2,P113DFunction>}


type P113DPass is Data:
  P113DPass{+index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32}


type P113PValueCode is Data:
  P113PValueCode{+body: List<&2,N111Stmt>, +values: List<&2,N111Value>, +error: String}


type P113PTarget is Data:
  P113PTarget{+destinations: List<&2,String>, +shape: KTerm, +tail: Bool, +owner: String, +signatures: List<&2,KDef>}


type P113ITable is Data:
  P113IEmpty{}
  P113IBucket{+values: List<&2,P113DFunction>}
  P113INode{+zero: P113ITable, +one: P113ITable}


type P113IScan is Data:
  P113IScan{+body: List<&2,P113DStmt>, +next: U32, +budget: U32}


type P113ACertificate is Data:
  P113ACertificate{+scalar: Bool, +unshared: Bool}


type P113AProgram is Data:
  P113AProgram{+original: P113DProgram, +certificate: P113ACertificate}


type P113ABody is Data:
  P113ABody{+body: List<&2,P113DStmt>, +next: U32}


type P113ASunk is Data:
  P113ASunkNo{}
  P113ASunkYes{+stmt: N111Stmt, +id: U32, +pre: List<&2,P113DStmt>,
    +v0: N111Value, +v1: N111Value, +v2: N111Value, +rest: List<&2,P113DStmt>}


type P113KFact is Data:
  P113KFact{+bits: U32, +exact: Bool, +lo: U32, +hi: U32}


type P113KScalar is Data:
  P113KScalar{+body: List<&2,N111Stmt>, +facts: KDef}


type P113KBody is Data:
  P113KBody{+body: List<&2,P113DStmt>, +facts: KDef, +terminal: Bool}


type W4GCopyEnv is Data:
  W4GCopyEnv{+vers: KDef, +aliases: KDef}

type W4GCopySc is Data:
  W4GCopySc{+stmts: List<&2,N111Stmt>, +env: W4GCopyEnv}

type W4GCopyBd is Data:
  W4GCopyBd{+stmts: List<&2,P113DStmt>, +env: W4GCopyEnv}


type W4GBwd is Data:
  W4GBwd{+body: List<&2,P113DStmt>, +live: KDef}


type P113BQDiamond is Data:
  P113BQNo{}
  P113BQYes{+name: String, +invert: Bool}


type P114RStmt is Data:
  P114RScalar{+stmt: N111Stmt}
  P114RIf{+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>}
  P114RDescend{+frame: List<&2,N111Stmt>, +arguments: List<&2,N111Stmt>}
  P114RAgain{+arguments: List<&2,N111Stmt>}
  P114RResult{+value: N111Value}
  P114RFailure{+body: List<&2,N111Stmt>}
  P114RResumeReady{+frame: List<&2,N111Stmt>, +call: List<&2,N111Stmt>, +result: N111Value}
  P114RPushFrame{+frame: List<&2,N111Stmt>}


type P114GFrame is Data:
  P114GFrame{+name: String, +count: U32}


type P114GBody is Data:
  P114GBody{+valid: Bool, +frames: List<&2,P114GFrame>, +body: List<&2,P114RStmt>}


type P114HCase is Data:
  P114HCase{+name: String, +captures: List<&2,String>, +result: String,
    +pop: String, +body: List<&2,P114RStmt>}


type P114HPlan is Data:
  P114HPlan{+valid: Bool, +params: List<&2,String>, +body: List<&2,P114RStmt>, +cases: List<&2,P114HCase>}


type P114HClosed is Data:
  P114HClosed{+valid: Bool, +cases: List<&2,P114HCase>}


type P114TExpansion is Data:
  P114TExpansion{+body: List<&2,N111Stmt>, +changed: Bool}


type P117HScan is Data:
  P117HScan{+facts: KDef, +slots: KDef, +mask: U32, +used: U32,
    +again: Bool, +left: U32, +next: U32, +sites: KDef}


type W5SetLoc is Data:
  W5SetLocNone{}
  W5SetLoc{+dst: String, +src: String}

type W4CBCEPlan is Data:
  W4CBCEPlan{+nomask: KDef, +guards: List<&2,N111Stmt>, +next: U32}

type P118BValues is Data:
  P118BValues{+body: List<&2,P113DStmt>, +values: List<&2,N111Value>, +next: U32, +error: String}


type P118BWorkers is Data:
  P118BWorkers{+functions: List<&2,P113DFunction>, +error: String}


type P118CPlan is Data:
  P118CPlan{+request: NR_Request, +hot: List<&2,String>, +cold: List<&2,String>, +valid: Bool, +error: String}


type P121FPlan is Data:
  P121FNone{}
  P121FPlan{+params: List<&2,NC_Binding>, +producer: KDef, +filter: KDef,
    +mapping: KDef, +fold: KDef, +count: KTerm, +seed: KTerm, +initial: KTerm}


type P198EArm is Data:
  P198ENoArm{}
  P198EArm{+op: String, +left: Bool, +value: KTerm, +seed: KTerm}

type P198EPlan is Data:
  P198ERefused{}
  P198EReady{+params: List<&2,NC_Binding>, +entryCount: KTerm, +entrySeed: KTerm, +stepSeed: KTerm,
    +baseValue: KTerm, +baseBinder: KTerm, +nextSeed: KTerm, +key: KTerm, +branchSeed: KTerm,
    +a: P198EArm, +b: P198EArm, +c: P198EArm}

type P124Callable is Data:
  P124Callable{+valid: Bool, +arity: U32, +symbol: String}


type P126ITable is Data:
  P126ITable{+name: String, +last: U32}


type P128BRHelper is Data:
  P128BRHelper{+owner: String, +params: List<&2,KTerm>, +roots: List<&2,U32>, +result: String, +reader: String, +wrapper: KTerm, +resultId: U32}

type P128BRPatch is Data:
  P128BRPatch{+target: String, +functions: List<&2,P113DFunction>}


type P128BRPatches is Data:
  P128BRPatches{+patches: List<&2,P128BRPatch>, +error: String}


type P128BLGraph is Data:
  P128BLGraph{+types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +error: String}


type P128BLNode is Data:
  P128BLNode{+specs: List<&2,NO_Spec>, +children: List<&2,KTerm>, +error: String}


type P128BROpen is Data:
  P128BROpen{+functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +error: String}


type P128BFRead is Data:
  P128BFSkip{}
  P128BFRead{+dest: String, +term: N111Value, +buffer: String, +ctor: String, +count: U32}

# Keep the existing numeric IDs; retain constructor arity in unused emitter
# metadata so this late template checks the same descriptor/count again.

type P131UEntry is Data:
  P131UEntry{+id: U32, +low: U32, +high: U32}



@unsafe
def w5c2_orig_set_if(is_abs: Bool, +tree: KDef, +d: KDef, +hash: U32) -> KDef:
  match is_abs:
    case True{}: index_leaf(d, hash, Nil{})
    case False{}: index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash)))))

@unsafe
def p131i_original_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  w5c2_orig_set_if(String.eq(dk(tree), "Absent"), tree, d, hash)


law p131i_insert:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  KDef

@unsafe
def w5c_p131i_join(bit: U32, +stored: U32, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match bit:
    case 0: KIndexNode{stored, mask, KIndexLeaf{hash, [d]}, tree}
    case _: KIndexNode{stored, mask, tree, KIndexLeaf{hash, [d]}}

@unsafe
def w5c_p131i_leaf(+mask: U32, +tree: KDef, +d: KDef, +hash: U32, +stored: U32, bucket: List<&2, KDef>) -> KDef:
  match mask:
    case 0: KIndexLeaf{hash, Con{d, index_remove(bucket, dn(d))}}
    case _: w5c_p131i_join(U32.and(hash, mask), stored, tree, d, hash, mask)

@unsafe
def w5c_p131i_br(bit: U32, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32) -> KDef:
  match bit:
    case 0: KIndexNode{stored, split, p131i_insert(left, d, hash), right}
    case _: KIndexNode{stored, split, left, p131i_insert(right, d, hash)}

@unsafe
def w5c_p131i_in(outside: U32, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +diff: U32) -> KDef:
  match outside:
    case 0: w5c_p131i_br(U32.and(hash, split), stored, split, left, right, d, hash)
    case _:
      +m = index_split_bit(diff)
      w5c_p131i_join(U32.and(hash, m), stored, tree, d, hash, m)

@unsafe
def p131i_insert(tree, d, hash):
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131i_original_set(tree, d, hash, 32)
    case KIndexLeaf{stored, bucket}:
      w5c_p131i_leaf(index_split_bit(U32.xor(hash, stored)), tree, d, hash, stored, bucket)
    case KIndexNode{stored, split, left, right}:
      +diff = U32.xor(hash, stored)
      w5c_p131i_in(U32.and(diff, U32.sub(split, 1)), tree, stored, split, left, right, d, hash, diff)

type P134Context is Data:
  P134Context{+ids: N111Ids, +index: P112FusionIndex, +direct: KDef,
    +ready: KDef, +view: KDef, +lookups: List<&2,P126ITable>, +heap: U32, +mode: U32}


type P134Cursor is Data:
  P134Private{+functions: List<&2,P113DFunction>, +context: P134Context, +next: P134Cursor}
  P134Legacy{+entries: List<&2,P112RegionEntry>, +context: P134Context, +next: P134Cursor}
  P134Public{+segments: List<&2,N111Segment>, +context: P134Context, +next: P134Cursor}
  P134Tables{+tables: List<&2,P111QData>}
  P134Data{+items: List<&2,P111QDatum>, +first: Bool, +rest: List<&2,P111QData>}
  P134Main{}
  P134End{}


type P140PStop is Data:
  P140PDone{+raw: FRawResult}
  P140PCut{+input: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +scope: FParseScope}


type P143CEvent is Data:
  P143CEvent{+definition: KDef, +next: KDef}


type P143CSchedule is Data:
  P143CSchedule{+index: KDef, +events: List<&2,P143CEvent>}


type P144OFacts is Data:
  P144OFacts{+names: List<&2,String>, +valid: Bool}

# Independent original semantics. Keep this unchanged when wiring the entry.

type P144CEFacts is Data:
  P144CEFacts{+members: KDef, +valid: Bool}


type P167Lowered is Data:
  P167Lowered{+program: P113DProgram, +adapters: KDef, +error: String, +stats: List<&2,U32>}



type P167Catalogue is Data:
  P167Catalogue{+index: KDef, +error: String}



type P167Context is Data:
  P167Context{+book: List<&2,KDef>, +catalogue: KDef, +bangs: List<&2,String>}



type P167Demand is Data:
  P167Demand{+todo: List<&2,String>, +asked: KDef, +count: U32}



type P167Built is Data:
  P167Built{+segments: List<&2,N111Segment>, +present: KDef, +adapters: KDef,
    +fresh: U32, +families: U32, +factories: U32, +wrappers: U32,
    +demands: U32, +error: String}


# Candidate-first, scheduler-on-demand prototype. No generic region registry,
# borrowed retry pipeline, or fictitious original body. Final checks/emission
# belong to demand-verify/emit.bend. The input must be a checked NR_Request.

type W6Local is Data:
  W6Local{+orig: String, +cid: U32}

type W6CState is Data:
  W6CState{+locals: List<&2,W6Local>, +next: U32, +chunks: List<&2,String>, +fuel: U32}

type W6DedupAcc is Data:
  W6DedupAcc{+seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32}

type W4PUnpack is Data:
  W4PUnpack{+stmts: List<&2,N111Stmt>, +args: List<&2,N111Value>, +ok: Bool}

type P168TSelection is Data:
  P168TSelection{+blocked: KDef, +targets: KDef}



type P169Prepared is Data:
  P169Prepared{+forwarders: List<&2,String>, +cursor: P134Cursor, +error: String}



type P169ScalarPlan is Data:
  P169ScalarPlan{+plan: NO_Plan, +eligible: Bool}



@unsafe
def p170ls_word(inspected: String, +original: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  match inspected:
    case SNil{}: FScanned{String.reverse(acc),"",n}
    case SCon{+head,+rest}:
      f_choose(FScanned,f_choose(Bool,f_ident(head),u => True{},u =>
        (Char.is_eq(head,'+') || Char.is_eq(head,'-')) &&
          (Char.is_eq(last,'e') || Char.is_eq(last,'E')) && p150l_digit(rest)),
        u => p150l_word(rest,SCon{head,acc},U32.add(n,1),head),
        u => FScanned{String.reverse(acc),original,n})

@unsafe
def p170ls_other(+head: Char, inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match inspected:
    case SCon{+second,SCon{+third,tail}}:
      f_choose(List<&2,FToken>,p150l_triple(head,second,third),
        u => p150l_emit(SCon{head,SCon{second,SCon{third,""}}},tail,l,c,d,acc,offset,previous,3,3),
        u => p150l_other_plain(head,original,l,c,d,acc,offset,previous))
    case _: p150l_other_plain(head,original,l,c,d,acc,offset,previous)

@unsafe
def p170ls_symbol(+head: Char, inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match inspected:
    case SNil{}: p150l_single(head,"",l,c,d,acc,offset,previous)
    case SCon{+second,tail}:
      f_choose(List<&2,FToken>,p150l_pair(head,second),
        u => p150l_emit(SCon{head,SCon{second,""}},tail,l,c,d,acc,offset,previous,2,2),
        u => p150l_single(head,original,l,c,d,acc,offset,previous))

@unsafe
def p170ls_plus(inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +contiguous: Bool) -> List<&2,FToken>:
  match inspected:
    case SNil{}: p150l_emit("+","",l,c,d,acc,offset,previous,1,1)
    case SCon{+head,tail}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'+'),
        u => f_choose(List<&2,FToken>,contiguous,
          v => p150l_emit("+",original,l,c,d,acc,offset,previous,1,1),
          v => p150l_emit("++",tail,l,c,d,acc,offset,previous,2,2)),
        u => p150l_emit(f_choose(String,f_ascii_alpha(head) && Bool.not(contiguous),v => "+bind",v => "+"),original,l,c,d,acc,offset,previous,1,1))

@unsafe
def p170ls_greater(inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +gap: Bool) -> List<&2,FToken>:
  match inspected:
    case SNil{}: p150l_emit(f_choose(String,gap,u => ">op",u => ">"),"",l,c,d,acc,offset,previous,1,1)
    case SCon{+head,+tail}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'>'),
        u => p150l_emit(f_choose(String,gap,v => ">>op",v => ">>"),tail,l,c,d,acc,offset,previous,2,2),
      u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'='),u => p150l_emit(">=",tail,l,c,d,acc,offset,previous,2,2),
        u => p150l_emit(f_choose(String,gap,v => ">op",v => ">"),original,l,c,d,acc,offset,previous,1,1)))

type P171SCPlan is Data:
  P171SCPlan{+plan: NO_Plan, +catalogue: Maybe<&2,List<&2,NO_Spec>>}

type P177SFrame is Data:
  P177SNode{shell: KTerm, rest: List<&2,KTerm>, done: List<&2,KTerm>}
  P177SBeta{oldId: U32, oldValue: KTerm}

@unsafe
def p177s_reverse(terms: List<&2,KTerm>, done: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: done
    case Con{head,rest}: p177s_reverse(rest,Con{head,done})

def p177s_visit_state(variable: Bool, hit: Bool) -> U32:
  match variable:
    case False{}: 2
    case True{}:
      match hit:
        case False{}: 4
        case True{}: 1

def p177s_rebuild_state(application: Bool) -> U32:
  match application:
    case False{}: 7
    case True{}: 6

def p177s_leaf_state(application: Bool) -> U32:
  match application:
    case False{}: 4
    case True{}: 6

def p177s_apply_state(lambda: Bool) -> U32:
  match lambda:
    case False{}: 9
    case True{}: 8

@unsafe
def p177s_loop(state: U32, +term: KTerm, +terms: List<&2,KTerm>,
  +id: U32, +value: KTerm, stack: List<&1,P177SFrame>) -> KTerm:
  match state:
    case 0:
      p177s_loop(p177s_visit_state(p98_tag_eq(term,"Var"),U32.is_eq(ix(term),id)),
        term,Nil{},id,value,stack)
    case 1:
      p177s_loop(4,value,Nil{},id,value,stack)
    case 2:
      match term:
        case KTerm{tag,name,n,quant,kids,removed,begin,end}:
          match kids:
            case Nil{}:
              p177s_loop(p177s_leaf_state(p88_string_eq(tag,"App")),
                term,Nil{},id,value,stack)
            case Con{head,rest}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{KTerm{tag,name,n,quant,Nil{},removed,begin,end},rest,Nil{}},stack})
        case KLambda{name,n,quant,kids,removed,begin,end,present}:
          match kids:
            case Nil{}: p177s_loop(4,term,Nil{},id,value,stack)
            case Con{head,rest}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{KLambda{name,n,quant,Nil{},removed,begin,end,present},rest,Nil{}},stack})
        case KLiteral{kind,number,text,begin,end}:
          p177s_loop(4,term,Nil{},id,value,stack)
    case 4:
      match stack:
        case Nil{}: term
        case Con{P177SBeta{oldId,oldValue},tail}:
          p177s_loop(4,term,Nil{},oldId,oldValue,tail)
        case Con{P177SNode{shell,rest,done},tail}:
          match rest:
            case Nil{}:
              p177s_loop(5,shell,p177s_reverse(Con{term,done},Nil{}),id,value,tail)
            case Con{head,pending}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{shell,pending,Con{term,done}},tail})
    case 5:
      p177s_loop(p177s_rebuild_state(p98_tag_eq(term,"App")),
        term,terms,id,value,stack)
    case 6:
      p177s_loop(p177s_apply_state(p98_tag_eq(terms_at(terms,0),"Lam")),
        term,terms,id,value,stack)
    case 7:
      p177s_loop(4,k_with_children(term,terms),Nil{},id,value,stack)
    case 8:
      +function = terms_at(terms,0)
      p177s_loop(0,kid(function,0),Nil{},ix(function),terms_at(terms,1),
        Con{P177SBeta{id,value},stack})
    case _:
      p177s_loop(4,kt_span("App","",0,0,[terms_at(terms,0),terms_at(terms,1)],kb(term),ke(term)),
        Nil{},id,value,stack)

@unsafe
def p177s_entry(t,id,value):
  p177s_loop(0,t,Nil{},id,value,Nil{})

type X187Operand is Data:
  X187Reg{+index: U32, +width: U32, +vector: Bool}
  X187Imm{+lo: U32, +hi: U32}
  X187Mem{+base: U32, +disp: U32}
  X187Rip{+symbol: String, +addendLo: U32, +addendHi: U32}
  X187Target{+symbol: String}
  # Address size is64, scale is1/2/4/8, and disp is signed32 bits.
  # Both registers are mandatory GPRs0..15. RSP(index4) is forbidden;
  # R12(index12) is valid and requires REX.X, even though its low bits are4.
  X187Indexed{+base: U32, +index: U32, +scale: U32, +disp: U32}

type X187Instruction is Data:
  X187Instruction{+op: String, +operands: List<&2,X187Operand>}

type X187Symbol is Data:
  X187Symbol{+name: String, +section: U32, +value: U32, +size: U32, +global: Bool, +kind: U32}

type X187Relocation is Data:
  X187Relocation{+section: U32, +offset: U32, +kind: U32, +symbol: String, +addendLo: U32, +addendHi: U32}

type X187Encoded is Data:
  X187Encoded{+bytes: List<&2,U32>, +relocations: List<&2,X187Relocation>, +error: String}

type X187Object is Data:
  X187Object{+text: List<&2,U32>, +rodata: List<&2,U32>, +data: List<&2,U32>,
    +symbols: List<&2,X187Symbol>, +relocations: List<&2,X187Relocation>}

type X187ObjectResult is Data:
  X187ObjectResult{+bytes: List<&2,U32>, +error: String}
# Shared machine boundary. Instruction selection never renders assembly.
# Opcodes are selected finite mnemonics; operands retain widths, register
# identities, exact bit patterns and symbolic references. Directives preserve
# data widths. The sequence is released one function/data slice at a time.
type X187Parsed is Data:
  PInst{+inst: X187Instruction}
  PLabel{+name: String}
  PSection{+section: U32}
  PGlobal{+name: String}
  PType{+name: String, +kind: U32}
  PSize{+name: String}
  PAlign{+alignment: U32}
  PBytes{+bytes: List<&2,U32>}
  PDataReloc{+symbol: String, +addendLo: U32, +addendHi: U32}
  PDatum{+datum: P111QDatum}
  PEmpty{}
  PError{+error: String}

type X188Seq is Data:
  X188Empty{}
  X188One{+item: X187Parsed}
  X188Join{+left: X188Seq, +right: X188Seq}

# Machine sequences concatenate in constant time. Consumers use an explicit
# work list, so neither output needs a recursive walk on the host stack.
type X185Physical is Data:
  X185Physical{+wide: X187Operand, +narrow: X187Operand, +byte: X187Operand}
  X185PhysicalNone{}

# Experimental AMD64 SysV machine selection. The checked native operations
# remain the semantic input; this per-function frame is machine placement only.
# slots: X181Stack da=positive rbp displacement, X181Buffer da=end displacement,
# or X181Register da=register number (0=state/r12,1=rbx,2=r13,3=r14,4=r15).
# X185Transient da=0..4 is confined to one call-free region and maps to the
# separate rdi/rsi/rdx/r8/r9 pool; parameters and call arguments never use it.
# bytes is the last reserved rbp displacement; calls is maximum outgoing bytes.
type X181Frame is Data:
  X181Frame{+slots: KDef, +bytes: U32, +calls: U32, +params: List<&2,String>, +symbol: String}

type X181Code is Data:
  X181Code{+chunks: List<&2,X188Seq>, +next: U32, +terminal: Bool, +error: String}

type X181Output is Data:
  X181Output{+chunks: List<&2,X188Seq>, +error: String}

# Shared emission interfaces. Forward declarations are contracts, not proofs.
type X191Address is Data:
  X191Address{+base: N111Value, +index: N111Value, +scale: U32, +disp: U32}
type X191Operation is Data:
  X191Load{+name: String, +typ: N111Type, +address: X191Address}
  X191Store{+typ: N111Type, +address: X191Address, +value: N111Value}
  X191MemoryAlu{+name: String, +typ: N111Type, +op: String, +left: N111Value, +address: X191Address}
type X191Pick is Data:
  X191Pick{+rest: List<&2,P113DStmt>, +operation: X191Operation}
type X191AddressCode is Data:
  X191AddressCode{+prefix: X188Seq, +operand: X187Operand}

type X186InlineOp is Data:
  X186InlineNone{}
  X186InlineF32{+destination: String, +id: U32, +buffer: String}

# General known-effect sqrt: all allocated GPR/XMM homes survive the helper.
# Negative inputs retain sqrtf errno/FP behavior; no reassociation or fast-math.
type X198WOp is Data:
  X198WNone{}
  X198WOp{+name: String,+buffer: String,+id: U32}

type X195Sqrt is Data:
  X195Sqrt{+name: String, +buffer: String}

type AgyReuseMatch is Data:
  AgyReuseMatch{+ok: Bool, +ctor: String, +stmts: List<&2,P113DStmt>}

type X186CallPlan is Data:
  X186CallPlan{+kind: U32, +count: U32}

type AgyCallMove is Data:
  AgyCallMove{+dstIdx: U32, +dstReg: U32, +srcReg: U32, +typ: N111Type, +value: N111Value}

type AgyCallPick is Data:
  AgyCallPick{+move: AgyCallMove, +rest: List<&2,AgyCallMove>}
  AgyCallPickNone{}

type X181ReadCounts is Data:
  X181ReadCounts{+counts: KDef, +reversedNames: List<&2,String>}

type X181RegisterChoice is Data:
  X181RegisterChoice{+name: String, +reads: U32}

type X185TScan is Data:
  X185TScan{+ranges: KDef, +reversedNames: List<&2,String>, +position: U32, +region: U32}

type W4CSelArm is Data:
  W4CSelArmNone{}
  W4CSelArm{+name: String, +typ: N111Type, +val: N111Value}

type X185Dead is Data:
  X185Dead{+body: List<&2,P113DStmt>, +live: KDef}

type X185ScratchCell is Data:
  X185ScratchCell{+buffer: String, +offset: U32, +typ: N111Type, +value: N111Value}

type X185ScratchStep is Data:
  X185ScratchStep{+stmt: P113DStmt, +facts: List<&2,X185ScratchCell>}

type X186Memory is Data:
  X186Memory{+buffers: KDef, +reads: KDef, +used: KDef}

type X186Move is Data:
  X186Move{+destination: String, +source: N111Value, +home: KDef, +read: KDef}

type X186Pick is Data:
  X186Pick{+move: X186Move, +rest: List<&2,X186Move>}
  X186PickNone{}

type X186Expr is Data:
  X186Expr{+name: String, +kind: U32, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value}
type X186Alias is Data:
  X186Alias{+name: String, +value: N111Value}
# AGY-W5-STRUCT: O(log N) Patricia-trie CSE & Alias Engine (100% bit-exact)
type X186FactTrie is Data:
  X186FTNil{}
  X186FTLeaf{+hash: U32, +items: List<&2,X186Expr>}
  X186FTNode{+hash: U32, +mask: U32, +left: X186FactTrie, +right: X186FactTrie}

type X186AliasTrie is Data:
  X186ATNil{}
  X186ATLeaf{+hash: U32, +items: List<&2,X186Alias>}
  X186ATNode{+hash: U32, +mask: U32, +left: X186AliasTrie, +right: X186AliasTrie}

type X186ExprState is Data:
  X186ExprState{+facts: List<&2,X186Expr>, +aliases: List<&2,X186Alias>,
    +factCount: U32, +aliasCount: U32,
    +mentioned: KDef, +factTrie: X186FactTrie, +aliasTrie: X186AliasTrie}

type X186ExprStep is Data:
  X186ExprStep{+stmt: P113DStmt, +state: X186ExprState}

type W4CLastDst is Data:
  W4CLastNone{}
  W4CLast{+name: String, +typ: N111Type}

type W4CDiaRes is Data:
  W4CDiaRes{+body: List<&2,P113DStmt>, +live: KDef, +seq: U32}

type W5Sel is Data:
  W5SelNone{}
  W5Sel{+c: N111Value, +dst: String, +typ: N111Type, +va: N111Value, +vb: N111Value}

type W5SnapSet is Data:
  W5SnapNone{}
  W5Snap{+dst: String, +typ: N111Type, +val: N111Value}

type W5NatArm is Data:
  W5NatArm{+k: U32, +val: N111Value}

type W5NatChain is Data:
  W5NatChainNone{}
  W5NatChain{+arms: List<&2,W5NatArm>, +defVal: N111Value}

type X190Values is Data:
  X190Values{+aliases: List<&2,X186Alias>, +widths: KDef}
type X190ValueStep is Data:
  X190ValueStep{+stmt: P113DStmt, +state: X190Values}

type W5BSplitSets is Data:
  W5BSplitSets{+prefix: List<&2,P113DStmt>, +sets: List<&2,P113DStmt>}

type X186FloatNode is Data:
  X186FloatPlain{+stmt: P113DStmt}
  X186FloatBranch{+condition: N111Value, +yes: List<&2,X186FloatNode>, +no: List<&2,X186FloatNode>}
  X186FloatValues{+destination: String, +id: U32, +left: N111Value, +right: N111Value}

type X186FloatStep is Data:
  X186FloatStep{+node: X186FloatNode, +facts: List<&2,X185ScratchCell>}

type X186XScan is Data:
  X186XScan{+ranges: X185TScan, +canonical: KDef}

type W2TblMatch is Data:
  W2TblHit{+dest: String, +sym: String, +val: N111Value, +last: U32, +rest: List<&2,X186FloatNode>}
  W2TblMiss{}

type W2BoolMatch is Data:
  W2BoolHit{+word: N111Value, +yes: List<&2,X186FloatNode>, +no: List<&2,X186FloatNode>, +rest: List<&2,X186FloatNode>}
  W2BoolMiss{}

type W4Carried is Data:
  W4Carried{+name: String, +idx: U32, +xmm: U32}

type W2XLoopPlan is Data:
  W2XLoopPlan{+homes: KDef, +pre: X188Seq, +carried: List<&2,W4Carried>, +active: Bool}

type W2XLAlloc is Data:
  W2XLAlloc{+homes: KDef, +pre: X188Seq, +nextReg: U32}

type X190LCandidates is Data:
  X190LCandidates{+names: List<&2,String>, +ids: KDef}

type X190LFlow is Data:
  X190LFlow{+live: U32, +graph: List<&2,U32>}

type X190LEnv is Data:
  X190LEnv{+ids: KDef, +parameters: U32, +header: U32, +collect: Bool}

type X190LFixed is Data:
  X190LFixed{+header: U32, +ready: Bool}

type W5CIntv is Data:
  W5CIntv{+first: U32, +last: U32}

type W5CPJState is Data:
  W5CPJState{+ends: List<&2,U32>, +occ: List<&2,List<&2,W5CIntv>>}

type X191LoopReads is Data:
  X191LoopReads{+reads: X181ReadCounts, +reaches: Bool, +falls: Bool}

type X190BranchFacts is Data:
  X190BranchFacts{+reads: KDef, +writes: KDef, +pairs: KDef, +protected: KDef}

type X192AddressAlias is Data:
  X192AddressAlias{+name: String, +address: X191Address, +reads: U32}

type X192AddressRow is Data:
  X192AddressPlain{+stmt: P113DStmt}
  X192AddressMemory{+operation: X191Operation}

type X192AddressPick is Data:
  X192AddressPick{+rest: List<&2,P113DStmt>, +rows: List<&2,X192AddressRow>}

type X191FrameStore is Data:
  X191FrameStore{+source: U32, +displacement: U32}
  X191FrameStoreNone{}

type P198Quot is Data:
  P198NoQuot{}
  P198Shift{+shift: U32}
  P198Magic{+multiplier: U32, +shift: U32}

# q,r represent floor and residue of 2^(32+s) divided by d.
type W4QMDividend is Data:
  W4QMDividend{+src: X187Operand, +rest: List<&2,X188Seq>}

type X197DHead is Data:
  X197DHead{+item: X187Parsed, +rest: List<&2,X188Seq>}

type W4LeafPrologue is Data:
  W4LeafNone{}
  W4LeafPrologue{+prefix: List<&2,X187Parsed>, +saved: List<&2,U32>, +body: List<&2,X187Parsed>}

type W5BLblEntry is Data:
  W5BLblEntry{+lbl: String, +tail: List<&2,X187Parsed>}

type W5BLblTrie is Data:
  W5BLNil{}
  W5BLLeaf{+h: U32, +items: List<&2,W5BLblEntry>}
  W5BLNode{+h: U32, +mask: U32, +l: W5BLblTrie, +r: W5BLblTrie}

type W4BRR is Data:
  W4BRRNone{}
  W4BRR{+op: String, +s: U32, +ws: U32, +d: U32, +wd: U32}

type W4BImmReg is Data:
  W4BImmRegNone{}
  W4BImmReg{+op: String, +lo: U32, +hi: U32, +r: U32, +w: U32}

type W4BBranch is Data:
  W4BBranchNone{}
  W4BBranch{+op: String, +tgt: String}

type W5BPeepOut is Data:
  W5BPeepOut{+changed: Bool, +seq: List<&2,X188Seq>}

type W4BLoopSplit is Data:
  W4BLoopNone{}
  W4BLoopSplit{+before: List<&2,X187Parsed>, +lbl: String, +body: List<&2,X187Parsed>}

type W4BMagicMap is Data:
  W4BMagicEntry{+imm: U32, +reg: U32}

type W4BExitSplit is Data:
  W4BExitNone{}
  W4BExitSplit{+exit: List<&2,X187Parsed>, +rest: List<&2,X187Parsed>}

# ---- W5-R1 Pass 4b: General Exit-Block Rotation (allows cold calls/internal branches) ----
type W4CMemAdd is Data:
  W4CMemAddNone{}
  W4CMemAdd{+b: U32, +idx: U32, +sc: U32, +disp: U32, +r: U32}

type W4CMap is Data:
  W4CMEmpty{}
  W4CMLeaf{+key: U32, +val: U32}
  W4CMNode{+zero: W4CMap, +one: W4CMap}

type W4CMovqXmmMem is Data:
  W4CMXMNo{}
  W4CMXMYes{+xreg: U32, +disp: U32}

type W4CLoadXmm is Data:
  W4CLXNo{}
  W4CLXYes{+op: String, +src: X187Operand, +dst: U32}

type W4CFopMem is Data:
  W4CFMNo{}
  W4CFMYes{+op: String, +disp: U32, +dst: U32}

type W4CFopAny is Data:
  W4CFANo{}
  W4CFAYes{+op: String, +src: X187Operand, +dst: U32}

type W4CStoreR10 is Data:
  W4CSRNo{}
  W4CSRMem{+disp: U32}
  W4CSRGpr{+reg: U32}

type W4CDefSplit is Data:
  W4CDSNo{}
  W4CDSYes{+betweenRev: List<&2,X187Parsed>, +defInst: X187Parsed, +beforeRev: List<&2,X187Parsed>}

type W5Movaps is Data:
  W5MANo{}
  W5MAYes{+src: U32, +dst: U32}

type W5MovdSlot is Data:
  W5MSNo{}
  W5MSYes{+disp: U32, +dst: U32}

type W5XmmProd is Data:
  W5XPNo{}
  W5XPYes{+op: String, +src: X187Operand, +dst: U32}

type W5LoadRbp is Data:
  W5LRNo{}
  W5LRYes{+disp: U32, +dst: U32}

type W5StoreRbp is Data:
  W5SRNo{}
  W5SRYes{+src: U32, +disp: U32}

type W5MovqToReg is Data:
  W5MTRNo{}
  W5MTRYes{+src: X187Operand, +dst: U32}

type W5MovqFromReg is Data:
  W5MFRNo{}
  W5MFRYes{+src: U32, +dst: X187Operand}

type W5Setcc is Data:
  W5SetNo{}
  W5SetYes{+op: String, +reg: U32}

type W5Movzbl is Data:
  W5MZNo{}
  W5MZYes{+sr: U32, +dr: U32}

type W5BSlotScan is Data:
  W5BSlotScan{+counts: W4CMap, +bad: W4CMap}

type W5BBestSlot is Data:
  W5BBestSlot{+key: U32, +cnt: U32}

type W5BGprOut is Data:
  W5BGprUnchanged{}
  W5BGprChanged{+out: List<&2,X187Parsed>}

type X191SelectPlan is Data:
  X191SelectPlan{+typ: N111Type, +yes: N111Value, +no: N111Value, +names: List<&2,String>}

type X194Select is Data:
  X194Select{+rest: List<&2,P113DStmt>, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +invert: Bool,
    +select: X191SelectPlan, +names: List<&2,String>}

type X198ACountdown is Data:
  X198ACountdown{+params: List<&2,String>, +fuel: String, +pred: String, +buffer: String, +ids: N111Ids}

type X198Perm is Data:
  X198NoPerm{}
  X198Perm{+ctor: String, +slot_a: U32, +slot_b: U32}

type X198Sym is Data:
  X198Refuse{}
  X198Sym{+env: KDef, +ctor: String, +taken: U32, +made: U32, +slot0: U32, +slot1: U32}

type X198NFact is Data:
  X198NUnknown{}
  X198NConst{+lo: U32, +hi: U32}
  X198NAlias{+name: String, +narrow: Bool}
  X198NNonzero{+narrow: Bool}
  X198NPredecessor{}

type X198NBinding is Data:
  X198NBinding{+name: String, +fact: X198NFact}

type X198NState is Data:
  X198NState{+valid: Bool, +env: List<&2,X198NBinding>}

type X198NLoop is Data:
  X198NLoop{+prefix: List<&2,P113DStmt>, +values: List<&2,N111Value>}

type X198ABinding is Data:
  X198ABinding{+name: String, +fact: U32}

type X198AState is Data:
  X198AState{+valid: Bool, +env: List<&2,X198ABinding>}

type X198OProgress is Data:
  X198OProgress{+fact: X198NFact, +different: String, +sameParity: String}

type X198OProgressBinding is Data:
  X198OProgressBinding{+name: String, +value: X198OProgress}

type X198OProgressState is Data:
  X198OProgressState{+valid: Bool, +env: List<&2,X198OProgressBinding>}

type X198PWPattern is Data:
  X198PWCase{+role: String,+body: X198PWPattern}
  X198PWLam{+slot: String,+body: X198PWPattern}
  X198PWVar{+slot: String}
  X198PWCall{+role: String,+args: List<&2,X198PWPattern>}
  X198PWCtr{+role: String,+fields: List<&2,X198PWPattern>}
  X198PWLet2{+a: X198PWPattern,+b: X198PWPattern,+body: X198PWPattern}

type X198PWState is Data:
  X198PWBad{}
  X198PWState{+roles: KDef,+vars: KDef}

type X198PWPlan is Data:
  X198PWNone{}
  X198PWPlan{+owner: String,+leaf: String,+node: String}

type AgyZipPlan is Data:
  AgyZipNone{}
  AgyZipPlan{+owner: String, +leaf: String, +node: String}

type AgyZipPat is Data:
  AgyZCase{+role: String, +body: AgyZipPat}
  AgyZLam{+slot: String, +body: AgyZipPat}
  AgyZVar{+slot: String}
  AgyZCall{+role: String, +args: List<&2,AgyZipPat>}
  AgyZCtr{+role: String, +fields: List<&2,AgyZipPat>}
  AgyZLet1{+slot: String, +val: AgyZipPat, +body: AgyZipPat}

type AgyFlowPlan is Data:
  AgyFlowNone{}
  AgyFlowPlan{+owner: String, +leaf: String, +node: String, +warp: String, +wn: String}

type X193FBody is Data:
  X193FBody{body: List<&2,N111Stmt>, calls: U32, error: String}

type X199ScanState is Data:
  X199ScanState{+env: KDef, +loads: U32, +stores: U32}

type AgyDpState is Data:
  AgyDpState{+env: KDef, +stores: U32}

type W5LcuCtor is Data:
  W5LcuNo{}
  W5LcuYes{+ctor: String, +arity: U32, +buf: String, +vals: List<&2,N111Value>, +aName: String}

type W5LcuScan is Data:
  W5LcuScan{+ok: Bool, +seen: Bool, +ctor: String, +arity: U32}

type W5LcuUse is Data:
  W5LcuUse{+ok: Bool, +seenTake: Bool}

type W5LcuCand is Data:
  W5LcuCandNo{}
  W5LcuCandYes{+idx: U32, +pName: String, +ctor: String, +arity: U32}

type AgyF32State is Data:
  AgyF32State{+env: KDef, +s0: Maybe<&2,N111Value>, +s8: Maybe<&2,N111Value>, +obs: Maybe<&2,KTerm>, +has_obs: Bool}

type AgyF32Plan is Data:
  AgyF32No{}
  AgyF32Yes{+y_expr: KTerm, +obs_expr: Maybe<&2,KTerm>, +h_expr: KTerm}

type X181StreamSlice is Data:
  X181StreamSlice{+text: X188Seq, +rest: List<&2,P111QDatum>, +error: String}

type X187RM is Data:
  X187RM{+bytes: List<&2,U32>, +relocations: List<&2,X187Relocation>, +error: String}
type X187Op is Data:
  X187Op{+family: U32, +width: U32, +code: U32, +extra: U32, +prefix: U32}
  X187OpNone{}

type X187ElfSizes is Data:
  X187ElfSizes{+text: U32, +rodata: U32, +data: U32}

type X187ElfSymbols is Data:
  X187ElfSymbols{+index: KDef, +count: U32, +firstGlobal: U32,
    +table: List<&2,U32>, +strings: List<&2,U32>, +stringSize: U32, +error: String}

type X187ElfSection is Data:
  X187ElfSection{+name: U32, +kind: U32, +flags: U32, +alignment: U32,
    +entry: U32, +link: U32, +info: U32, +bytes: List<&2,U32>}

type X187ElfLayout is Data:
  X187ElfLayout{+offset: U32, +body: List<&2,U32>, +headers: List<&2,U32>}

type X187Build is Data:
  X187Build{+section: U32, +text: List<&2,U32>, +rodata: List<&2,U32>, +data: List<&2,U32>,
    +textSize: U32, +rodataSize: U32, +dataSize: U32, +symbols: KDef,
    +names: List<&2,String>, +relocations: List<&2,X187Relocation>, +error: String}

type X188Fixups is Data:
  X188Fixups{+patches: List<&2,X187Relocation>, +relocations: List<&2,X187Relocation>,
    +escaped: KDef, +error: String}

type AgyHPass is Data:
  AgyHPass{+hready: KDef, +rem: List<&2,N111Segment>, +added: Bool}

type AgyParCgReady is Data:
  AgyParCgReady{+cursor: P134Cursor, +available: KDef, +error: String}

type AgyLptPriv is Data:
  AgyLptPriv{+weight: U32, +item: P113DFunction}

type AgyLptPub is Data:
  AgyLptPub{+weight: U32, +item: N111Segment}

type AgyLptPrivSplit is Data:
  AgyLptPrivSplit{+left: List<&2,AgyLptPriv>, +right: List<&2,AgyLptPriv>}

type AgyLptPubSplit is Data:
  AgyLptPubSplit{+left: List<&2,AgyLptPub>, +right: List<&2,AgyLptPub>}

type AgyLptPrivOut is Data:
  AgyLptPrivOut{+build: X187Build, +loads: List<&2,U32>}


def w7_slice_len(xs: List<&2, FToken>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: w7_slice_len(t, U32.add(acc, 1))

def main() -> U32:
  +toks = f_lex_cursor("def foo(x: U32) -> U32:\n  U32.add(x, 1)\n", 1, 1, 0, [], 0, 0)
  +st = base_prefix_stamp([], 16)
  U32.add(w7_slice_len(toks, 0), st)
