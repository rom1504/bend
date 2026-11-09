

# Phase111 module: selfhost/tools/performance/phase111/segment/model.bend
# Structured CPU segment IR. Values are machine words, never C expressions.
# Binary typ is operand width; comparisons produce U32. Offsets are bytes.
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


# Phase111 module: selfhost/tools/performance/phase111/segment/verify.bend
# Structural/type boundary for the sequential runtime ABI. Persistent exact-name
# tries avoid scanning all functions/constructors for every reference. This is
# not an ownership proof or a proof that foreign/runtime implementations are safe.
type P111VScan is Data:
  P111VScan{+index: KDef, +error: String, +count: U32}

type P111VFlow is Data:
  P111VFlow{+live: KDef, +terminal: Bool, +error: String}


# Phase111 module: selfhost/tools/performance/phase111/qbe/numbers.bend
# QBE 1.3 accepts decimal integer tokens; preserve all 64 bits without host
# floating-point conversion, hexadecimal assumptions or an auxiliary C parser.
type P111QDecimal is Data:
  P111QDecimal{+lo: U32, +hi: U32, +digit: U32}


# Phase111 module: selfhost/tools/performance/phase111/qbe/data.bend
# Linkable QBE data: exact words, byte arrays and explicit symbol relocations.
# This model describes output layout; it never embeds C source or C expressions.
type P111QDatum is Data:
  P111QByte{+value: U32}
  P111QWord{+value: U32}
  P111QLong{+lo: U32, +hi: U32}
  P111QReloc{+symbol: String, +offset: U32}
  P111QZeros{+bytes: U32}

type P111QData is Data:
  P111QData{+name: String, +alignment: U32, +exported: Bool, +items: List<&2,P111QDatum>}

type P111QCode is Data:
  P111QCode{+chunks: List<&2,String>, +next: U32, +terminal: Bool, +error: String}


# Phase111 module: selfhost/tools/performance/phase111/entry.bend
# Native checked source -> structured segments -> direct QBE.
# The host transports source bytes only. No unchecked semantic certificate is
# accepted by this public entry, and failures never select the C backend.
type P111Emission is Data:
  P111Emission{+chunks: List<&2,String>, +error: String}
  P134Planned{+plan: P134EmissionPlan}


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


type P112SResult is Data:
  P112SResult{+bundle: P112StaticProgram, +error: String}


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


type P112FPEmission is Data:
  P112FPEmission{+expanded: Bool, +code: P111QCode}


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


type P113DLowering is Data:
  P113DLowered{+program: P113DProgram, +error: String}


type P113DPass is Data:
  P113DPass{+index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32}


type P113PValueCode is Data:
  P113PValueCode{+body: List<&2,N111Stmt>, +values: List<&2,N111Value>, +error: String}


type P113PArguments is Data:
  P113PArguments{+valid: Bool, +values: List<&2,N111Value>}


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


type P113ALowering is Data:
  P113ALowered{+program: P113AProgram, +error: String}


type P113ABody is Data:
  P113ABody{+body: List<&2,P113DStmt>, +next: U32}


type P113AInspection is Data:
  P113AInspection{+scalar: Bool, +unshared: Bool, +enabled: Bool, +functions: U32, +sites: U32, +error: String}


type P113KFact is Data:
  P113KFact{+bits: U32, +exact: Bool, +lo: U32, +hi: U32}


type P113KScalar is Data:
  P113KScalar{+body: List<&2,N111Stmt>, +facts: KDef}


type P113KBody is Data:
  P113KBody{+body: List<&2,P113DStmt>, +facts: KDef, +terminal: Bool}


type P113BQDiamond is Data:
  P113BQNo{}
  P113BQYes{+name: String, +invert: Bool}


type P114SBoundary is Data:
  P114SBoundary{+original: P112StaticProgram, +ids: N111Ids, +functions: List<&2,P113DFunction>, +valid: Bool}


type P114SLowered is Data:
  P114SLowered{+boundary: P114SBoundary, +error: String}


type P114RStmt is Data:
  P114RScalar{+stmt: N111Stmt}
  P114RIf{+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>}
  P114RDescend{+frame: List<&2,N111Stmt>, +arguments: List<&2,N111Stmt>}
  P114RAgain{+arguments: List<&2,N111Stmt>}
  P114RResult{+value: N111Value}
  P114RFailure{+body: List<&2,N111Stmt>}
  P114RResumeReady{+frame: List<&2,N111Stmt>, +call: List<&2,N111Stmt>, +result: N111Value}
  P114RPushFrame{+frame: List<&2,N111Stmt>}

type P114RBody is Data:
  P114RBody{+valid: Bool, +frames: List<&2,String>, +body: List<&2,P114RStmt>}


type P114RPlan is Data:
  P114RPlan{+valid: Bool, +params: List<&2,String>, +body: List<&2,P114RStmt>,
    +continuation: String, +head: String, +result: String, +unwind: List<&2,N111Stmt>}


type P114RInspection is Data:
  P114RInspection{+entries: List<&2,String>, +error: String}


type P114GFrame is Data:
  P114GFrame{+name: String, +count: U32}


type P114GBody is Data:
  P114GBody{+valid: Bool, +frames: List<&2,P114GFrame>, +body: List<&2,P114RStmt>}


type P114GPlan is Data:
  P114GPlan{+valid: Bool, +params: List<&2,String>, +body: List<&2,P114RStmt>,
    +continuation: String, +captures: List<&2,String>, +result: String,
    +pop: String, +resume: List<&2,P112WorkerStmt>}


type P114HCase is Data:
  P114HCase{+name: String, +captures: List<&2,String>, +result: String,
    +pop: String, +body: List<&2,P114RStmt>}


type P114HPlan is Data:
  P114HPlan{+valid: Bool, +params: List<&2,String>, +body: List<&2,P114RStmt>, +cases: List<&2,P114HCase>}


type P114HClosed is Data:
  P114HClosed{+valid: Bool, +cases: List<&2,P114HCase>}


type P114HEntry is Data:
  P114HEntry{+name: String, +continuations: List<&2,String>}


type P114HInspection is Data:
  P114HInspection{+entries: List<&2,P114HEntry>, +error: String}


type P114TExpansion is Data:
  P114TExpansion{+body: List<&2,N111Stmt>, +changed: Bool}


type P117HScan is Data:
  P117HScan{+facts: KDef, +slots: KDef, +mask: U32, +used: U32,
    +again: Bool, +left: U32, +next: U32, +sites: KDef}

type P118BPlan is Data:
  P118BPlan{+request: NR_Request, +names: List<&2,String>, +error: String}


type P118BValues is Data:
  P118BValues{+body: List<&2,P113DStmt>, +values: List<&2,N111Value>, +next: U32, +error: String}


type P118BWorkers is Data:
  P118BWorkers{+functions: List<&2,P113DFunction>, +error: String}

type P118CPlan is Data:
  P118CPlan{+request: NR_Request, +hot: List<&2,String>, +cold: List<&2,String>, +valid: Bool, +error: String}

# Total private list pipeline -> scalar native loop. Semantic admission reuses
# the JS backend predicates; scalar evaluation reuses the native IR lowerer.
# Original generic segments and every ordinary verifier remain unchanged.

type P121FPlan is Data:
  P121FNone{}
  P121FPlan{+params: List<&2,NC_Binding>, +producer: KDef, +filter: KDef,
    +mapping: KDef, +fold: KDef, +count: KTerm, +seed: KTerm, +initial: KTerm}


type P124Callable is Data:
  P124Callable{+valid: Bool, +arity: U32, +symbol: String}

type P114SOGroup is Data:
  P114SONo{}
  P114SOYes{+buffer: String, +name: String, +id: U32,
    +left: N111Value, +right: N111Value, +rest: List<&2,P113DStmt>}

type P114FLFact is Data:
  P114FLFact{+word: String, +lane: String}



type P114FLOperand is Data:
  P114FLOperand{+prefix: String, +lane: String}

type P126LCtx is Data:
  P126LCtx{+params: List<&2,NC_Binding>, +buffers: List<&2,String>, +ids: N111Ids}

type P126ITable is Data:
  P126ITable{+name: String, +last: U32}


type P126ICtx is Data:
  P126ICtx{+params: List<&2,NC_Binding>, +buffers: List<&2,String>, +ids: N111Ids, +tables: List<&2,P126ITable>}

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

type P128RawLowering is Data:
  P128RawLowering{+lowered: P113DLowering, +raw: List<&2,P113DCandidate>}

type P128BFRead is Data:
  P128BFSkip{}
  P128BFRead{+dest: String, +term: N111Value, +buffer: String, +ctor: String, +count: U32}

type P134EmissionPlan is Data:
  P134Raw{+program: P111Program}
  P134Static{+program: P112StaticProgram}
  P134Direct{+program: P113DProgram}
  P134Admitted{+program: P113AProgram}


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


type P134Step is Data:
  P134Done{}
  P134Piece{+text: String, +legacy_end: Bool, +next: P134Cursor}


type P134DataSlice is Data:
  P134DataSlice{+text: String, +rest: List<&2,P111QDatum>, +first: Bool}

type P140PStop is Data:
  P140PDone{+raw: FRawResult}
  P140PCut{+input: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +scope: FParseScope}


type P140PCache is Data:
  P140PCache{+source: String, +initial: FParseScope, +start: U32, +token: FToken, +previous: FToken, +context: FParseContext, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +scope: FParseScope}


type P140PParsed is Data:
  P140PParsed{+result: FResult, +cache: Maybe<&2,P140PCache>, +hit: Bool}


type P140PMatch is Data:
  P140PMatch{+tail: String, +same: Bool}

type P140PLoadResult is Data:
  P140PLoadReady {+load: FPrefixLoad, +cache: Maybe<&2,P140PCache>, +hit: Bool}
  P140PLoadError {+error: String, +cache: Maybe<&2,P140PCache>}

type P140CPCheckpoint is Data:
  P140CPEmpty{}
  P140CPSaved{+epoch: String, +prefix: List<&2,KDef>, +headers: List<&2,KDef>,
    +bound: U32, +world: KWorld, +seen: List<&2,KDef>, +cut: U32, +steps: U32}


type P140CPCapture is Data:
  P140CPCaptured{+checkpoint: P140CPCheckpoint, +suffix: List<&2,KDef>}
  P140CPCaptureFailed{+checked: DChecking}


type P140CPSeed is Data:
  P140CPSeed{+checkpoint: P140CPCheckpoint, +checked: DChecking}


type P140CPSplit is Data:
  P140CPSplit{+prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +complete: Bool}


type P140CPAdmission is Data:
  P140CPAccepted{+suffix: List<&2,KDef>, +world: KWorld, +seen: List<&2,KDef>, +steps: U32}
  P140CPRefused{+reason: String}


type P140CPReplay is Data:
  P140CPReplay{+checked: DChecking, +reused: Bool, +skipped: U32, +reason: String}

type P140CBResult is Data:
  P140CBResult{+result: DResult, +checkpoint: P140CPCheckpoint, +reused: Bool, +skipped: U32, +reason: String}

type P140OEdge is Data:
  P140OEdge{+name: String, +refs: List<&2,String>}


type P140ODirty is Data:
  P140ODirty{+names: KDef, +count: U32}


type P140OAnalysis is Data:
  P140OAnalysis{+ready: Bool, +dirty: KDef, +edges: List<&2,P140OEdge>, +count: U32}

# One exact ordered owner comparison determines both the initial dirty set and
# the next graph. Propagation still uses the OLD graph exactly as in v03.

type P140ODelta is Data:
  P140ODelta{+edges: List<&2,P140OEdge>, +dirty: P140ODirty}

type P140OAEntry is Data:
  P140OAEntry{+name: String, +stopped: Bool, +product: KDef}


type P140OAResult is Data:
  P140OAResult{+definitions: List<&2,KDef>, +entries: List<&2,P140OAEntry>, +hits: U32, +misses: U32}


type P140OEEntry is Data:
  P140OEEntry{+name: String, +body: KTerm, +arity: U32, +refs: List<&2,String>}


type P140OEResult is Data:
  P140OEResult{+closure: NR_Closure, +entries: List<&2,P140OEEntry>, +hits: U32, +misses: U32}

type P140OGEntry is Data:
  P140OGEntry{+name: String, +input: U32, +code: P111Code}


type P140OGResult is Data:
  P140OGResult{+compiled: P111Book, +entries: List<&2,P140OGEntry>, +hits: U32, +misses: U32}


type P140OPEntry is Data:
  P140OPEntry{+name: String, +candidates: List<&2,P113DCandidate>}


type P140OPResult is Data:
  P140OPResult{+candidates: List<&2,P113DCandidate>, +entries: List<&2,P140OPEntry>, +hits: U32, +misses: U32}

type P140QPending is Data:
  P140QPending{+dirty: P140ODirty, +queue: List<&2,String>}

type P140SPPolicy is Data:
  P140SPPolicy{+global: Bool, +aligned: Bool}


type P140SPEntry is Data:
  P140SPEntry{+name: String, +active: Bool, +fact: KDef, +state: P112SDefs}


type P140SPCache is Data:
  P140SPCache{+constructors: List<&2,N_Constructor>, +blocked: KDef, +entries: List<&2,P140SPEntry>}


type P140SPWalk is Data:
  P140SPWalk{+state: P112SDefs, +entries: List<&2,P140SPEntry>, +stats: List<&2,U32>}


type P140SPResult is Data:
  P140SPResult{+prepared: P112SPrepared, +cache: P140SPCache, +stats: List<&2,U32>}

type P140OFCache is Data:
  P140OFCache{+book: List<&2,KDef>, +edges: List<&2,P140OEdge>, +reverse: KDef, +annotations: List<&2,P140OAEntry>, +erasures: List<&2,P140OEEntry>}


type P140OFResult is Data:
  P140OFResult{+plan: P86Plan, +cache: P140OFCache, +stats: List<&2,U32>}


type P140ORCache is Data:
  P140ORCache{+book: List<&2,KDef>, +edges: List<&2,P140OEdge>, +reverse: KDef, +nodes: List<&2,P112SNode>,
    +names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>,
    +generic: List<&2,P140OGEntry>, +private: List<&2,P140OPEntry>, +static: P140SPCache}


type P140ORResult is Data:
  P140ORResult{+lowering: P128RawLowering, +cache: P140ORCache, +stats: List<&2,U32>}

type P134RKMemo is Data:
  P134RKEmpty{}
  P134RKMemo{+input: P113DFunction, +output: P113DFunction}


type P134RKUnit is Data:
  P134RKUnit{+function: P113DFunction, +memo: P134RKMemo}


type P134RKBatch is Data:
  P134RKBatch{+functions: List<&2,P113DFunction>, +memos: List<&2,P134RKMemo>}


type P134RKPrepared is Data:
  P134RKPrepared{+boundary: P114SBoundary, +memos: List<&2,P134RKMemo>}

type P134UFact is Data:
  P134UFact{+target: String, +found: Maybe<&2,P113DFunction>}


type P134USlot is Data:
  P134UEmpty{}
  P134USlot{+input: P113DFunction, +facts: List<&2,P134UFact>, +unit: P134RKUnit}


type P134UOne is Data:
  P134UOne{+unit: P134RKUnit, +slot: P134USlot, +hit: Bool}


type P134UInline is Data:
  P134UInline{+functions: List<&2,P113DFunction>, +memos: List<&2,P134RKMemo>, +slots: List<&2,P134USlot>, +hits: U32, +misses: U32}


type P134URangeOne is Data:
  P134URangeOne{+function: P113DFunction, +memo: P134RKMemo, +prior: Bool, +inner: Bool}


type P134URanges is Data:
  P134URanges{+functions: List<&2,P113DFunction>, +slots: List<&2,P134RKMemo>, +hits: U32, +inner: U32, +misses: U32}


type P134UCache is Data:
  P134UCache{+inline: List<&2,P134USlot>, +ranges: List<&2,P134RKMemo>}


type P134UOptimized is Data:
  P134UOptimized{+boundary: P114SBoundary, +cache: P134UCache, +stats: List<&2,U32>}


type P134UEmission is Data:
  P134UEmission{+emission: P111Emission, +cache: P134UCache, +stats: List<&2,U32>}

type P140VCache is Data:
  P140VEmpty{}
  P140VCache{+program: P113DProgram, +metadata: P140VMetadata}


type P140VMetadata is Data:
  P140VMetadata{+functions: P111VScan, +constructors: P111VScan, +ids: N111Ids}


type P140VReuse is Data:
  P140VReuse{+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +raw: Bool, +direct: Bool, +metadata: Maybe<&2,P140VMetadata>}


type P140VWalk is Data:
  P140VWalk{+error: String, +hits: U32, +misses: U32}


type P140VChecked is Data:
  P140VChecked{+cache: P140VCache, +ids: N111Ids, +static_ok: Bool, +error: String, +counts: List<&2,U32>}


type P140VOpened is Data:
  P140VOpened{+boundary: P114SBoundary, +cache: P140VCache, +counts: List<&2,U32>}


type P140VArrayChecked is Data:
  P140VArrayChecked{+cache: P140VCache, +error: String, +counts: List<&2,U32>}

type P140RFact is Data:
  P140RFact{+name: String, +value: Maybe<&2,N111Segment>}


type P140RFacts is Data:
  P140RFacts{+valid: Bool, +facts: List<&2,P140RFact>}


type P140RKey is Data:
  P140RNone{}
  P140RPublic{+segment: N111Segment, +facts: List<&2,P140RFact>}
  P140RPrivate{+function: P113DFunction}
  P140RLegacy{+entry: P112RegionEntry}
  P140RHeader{+name: String, +alignment: U32, +exported: Bool}
  P140RData{+items: List<&2,P111QDatum>, +first: Bool}
  P140RClose{}
  P140RMain{}


type P140RSlot is Data:
  P140RSlot{+key: P140RKey, +ordinal: U32}


type P140RCache is Data:
  P140REmpty{}
  P140RCache{+context: P134Context, +slots: List<&2,P140RSlot>}


type P140RState is Data:
  P140RState{+cursor: P134Cursor, +context: P134Context, +valid: Bool,
    +prior: List<&2,P140RSlot>, +slots: List<&2,P140RSlot>,
    +ordinal: U32, +hits: U32, +misses: U32}


type P140RStep is Data:
  P140REnd{+cache: P140RCache, +hits: U32, +misses: U32}
  P140RText{+text: String, +ending: Bool, +next: P140RState}
  P140RReuse{+ordinal: U32, +next: P140RState}

type P140GSlot is Data:
  P140GSkip{}
  P140GRow{+key: P140RKey, +segment: N111Segment, +plan: P112WorkerPlan, +sites: U32}


type P140GPass is Data:
  P140GPass{+ready: KDef, +symbols: KDef, +rank: U32, +slots: List<&2,P140GSlot>}


type P140GCache is Data:
  P140GCache{+passes: List<&2,P140GPass>}
  P140GMetadata{+passes: List<&2,P140GPass>, +program: P111Program, +nodes: List<&2,P112SNode>,
    +arrays: Bool, +live: Bool, +ids: N111Ids, +index: P112FusionIndex, +tables: List<&2,P111QData>}


type P140GWalk is Data:
  P140GWalk{+registry: P112RegionRegistry, +slots: List<&2,P140GSlot>, +hits: U32, +misses: U32}


type P140GResult is Data:
  P140GResult{+registry: P112RegionRegistry, +passes: List<&2,P140GPass>, +hits: U32, +misses: U32}


type P140GPrepared is Data:
  P140GPrepared{+cursor: P134Cursor, +cache: P140GCache, +hits: U32, +misses: U32}

type P140RWritten is Data:
  P140RWritten{+cache: P140RCache, +hits: U32, +misses: U32, +pieces: U32}

type P140LItem is Data:
  P140LItem{+name: String, +plan: NO_Plan, +mode: U32, +workers: P118BWorkers, +fallback: List<&2,P113DFunction>}


type P140LCache is Data:
  P140LCache{+book: List<&2,KDef>, +edges: List<&2,P140OEdge>, +reverse: KDef, +names: List<&2,String>, +scalar_specs: List<&2,NO_Spec>, +items: List<&2,P140LItem>}


type P140LScan is Data:
  P140LScan{+scan: P128BROpen, +items: List<&2,P140LItem>, +hits: U32, +misses: U32}


type P140LResult is Data:
  P140LResult{+scan: P128BROpen, +cache: P140LCache, +stats: List<&2,U32>}

type P140LEmission is Data:
  P140LEmission{+emission: P111Emission, +cache: P140LCache, +stats: List<&2,U32>}

type P140FCache is Data:
  P140FCache{+parser: Maybe<&2,P140PCache>, +checker: P140CPCheckpoint, +owners: P140OFCache}


type P140FResult is Data:
  P140FResult{+plan: P86Plan, +cache: P140FCache, +stats: List<&2,U32>}

type P140BCache is Data:
  P140BCache{+opened: P140VCache, +optimized: P134UCache, +array: P140VCache, +late: P140LCache}


type P140BResult is Data:
  P140BResult{+emission: P111Emission, +cache: P140BCache, +stats: List<&2,U32>}


type P140SCache is Data:
  P140SCache{+front: P140FCache, +raw: P140ORCache, +back: P140BCache}


type P140SResult is Data:
  P140SResult{+emission: P111Emission, +cache: P140SCache, +stats: List<&2,U32>}

type P140NCache is Data:
  P140NCache{+session: P140SCache, +registry: P140GCache, +render: P140RCache}


type P140NMarks is Data:
  P140NMarks{+started: Nat, +frontend: Nat, +raw: Nat, +backend: Nat, +registry: Nat, +written: Nat}


type P140NResult is Data:
  P140NResult{+cache: P140NCache, +marks: P140NMarks, +stats: List<&2,U32>}

type P140NBJob is Data:
  P140NBJob{+source: String, +output: String, +hint: U32, +owner: String, +warm: Bool}

type P140NBJobs is Data:
  P140NBError{+error: String}
  P140NBReady{+jobs: List<&2,P140NBJob>}

type P143CEvent is Data:
  P143CEvent{+definition: KDef, +next: KDef}


type P143CSchedule is Data:
  P143CSchedule{+index: KDef, +events: List<&2,P143CEvent>}

type P144OFacts is Data:
  P144OFacts{+names: List<&2,String>, +valid: Bool}

type P144CEFacts is Data:
  P144CEFacts{+members: KDef, +valid: Bool}
