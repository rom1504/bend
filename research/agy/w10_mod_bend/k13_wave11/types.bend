# Frozen shared type header for K=13 modular split of wave11_unified/compiler.bend
# Canonical cid order preserved verbatim (404 type declarations).
import Base

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
type P150LQuoted is Data:
  P150LQuoted{+word: String, +rest: String, size: U32, width: U32, line: U32, column: U32}

type P150LEdge is Data:
  P150LEdge{column: U32, natural: Bool}

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

type W7PreNode is Data:
  W7PreNode{+name: String, +deps: List<&2,String>}

type W7PrePass is Data:
  W7PrePass{+ready: KDef, +admitted: List<&2,String>, +waiting: List<&2,W7PreNode>, +count: U32}

type P168TSelection is Data:
  P168TSelection{+blocked: KDef, +targets: KDef}



type W7C112CPass is Data:
  W7C112CPass{+registry: P112RegionRegistry, +waiting: List<&2,P112MultiCandidate>, +added: U32}

type P169Prepared is Data:
  P169Prepared{+forwarders: List<&2,String>, +cursor: P134Cursor, +error: String}



type P169ScalarPlan is Data:
  P169ScalarPlan{+plan: NO_Plan, +eligible: Bool}



type P171SCPlan is Data:
  P171SCPlan{+plan: NO_Plan, +catalogue: Maybe<&2,List<&2,NO_Spec>>}

type P177SFrame is Data:
  P177SNode{shell: KTerm, rest: List<&2,KTerm>, done: List<&2,KTerm>}
  P177SBeta{oldId: U32, oldValue: KTerm}

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

type W11PairU32 is Data:
  W11PairU32{+a: U32, +b: U32}

type W11SetCC is Data:
  W11SetCC{+op: String, +reg: U32}

type W11Jcc is Data:
  W11Jcc{+isN: Bool, +lbl: String}

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

type W7cAscii is Data:
  W7cAscii{+ok: Bool, +bytes: List<&2,U32>, +len: U32}

type W7RelocParts is Data:
  W7RelocParts{+r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32}

type W7cRelocResult is Data:
  W7cRelocOk{+parts: W7RelocParts}
  W7cRelocBad{}

type X187Build is Data:
  X187Build{+section: U32, +text: List<&2,U32>, +rodata: List<&2,U32>, +data: List<&2,U32>,
    +textSize: U32, +rodataSize: U32, +dataSize: U32, +symbols: KDef,
    +names: List<&2,String>, +relocations: List<&2,X187Relocation>, +error: String}

type X188Fixups is Data:
  X188Fixups{+patches: List<&2,X187Relocation>, +relocations: List<&2,X187Relocation>,
    +escaped: KDef, +error: String}

type W7RevCount is Data:
  W7RevCount{+list: List<&2,U32>, +len: U32}

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

type W10fFnBuild is Data:
  W10fFnBuild{+build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>}

# Returns 233 for `jmp`, 130..143 for 2-byte `0F 8x` Jcc, or 0 if not a branch.
type W10IfHash is Data:
  W10IfHash{+h1: U32, +h2: U32}

type W10IfBind is Data:
  W10IfBind{+name: String, +id: U32, +quant: U32}

type W10IfAbi is Data:
  W10IfAbi{+direct: KDef, +public: KDef}

type W10IfEnc is Data:
  W10IfEnc{+str_map: KDef, +str_rev: List<&2, String>, +str_n: U32, +rec_map: KDef, +rec_rev: List<&2, String>, +rec_n: U32}

type W10IfRes is Data:
  W10IfRes{+enc: W10IfEnc, +id: U32}

type W10IfLoad is Data:
  W10IfLoad{+ok: Bool, +error: String, +suffix: List<&2, KDef>}

# === AGY-W10-P5D-FAST-IFACE: Pure-Bend Fast x86-iface (.p130 interface carrier emitter) ===
# Eliminates 4 major bottlenecks while preserving 100% bit-for-bit identical .p130 output:
#   1. Single-parse: parse source ONCE via f_prefix_graph_trace, feeding FPrefixLoad directly
#      to p86_plan_loaded and reusing load.suffix (eliminates duplicate w10_if_load_suffix parse).
#   2. Direct-ABI-only lowering: extract W10IfAbi directly from p112s_prepare + p128br_scan +
#      p113pl_candidates + p113d_passes + req.names (skips w4p, p168_closed/inlining/retry,
#      p111_program CPS lowering, p169s_lowered IR verification/tables/registry, x198pw_after).
#   3. World-resumed stub check: use base_prefix_resume_world(base_world, fresh_suffix, bound)
#      instead of re-replaying base_state from scratch via base_prefix_resume_saved.
#   4. Zero-redundancy .p130 encoding:
#      (a) right-consing w10_if_w(n, tail) eliminates O(k^2) ++ chains in record encoding;
#      (b) reuse e1 (s_state) and e0 (s_book) IDs for world.state and world.prefix;
#      (c) cache unique, non-patched s_book KDef node IDs in def_cache for O(1) encoding
#          across world.{final,book,checked,seen} and s_ready.names.

# --- Dual 32-bit FNV-1a interface hasher (alpha-invariant, ignores spans & bodies) ---

type W10TrCompiled is Data:
  W10TrCompiled{+prepared: P169Prepared, +weak_set: KDef}

