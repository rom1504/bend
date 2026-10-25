# Only returned internal caches are used by these controls. Invalid source IR
# is passed to the verifier, never executed by a generated native program.
def p140vt_cache(value: P140VChecked) -> P140VCache:
  match value:
    case P140VChecked{cache,ids,static_ok,error,counts}: cache

def p140vt_error(value: P140VChecked) -> String:
  match value:
    case P140VChecked{cache,ids,static_ok,error,counts}: error

def p140vt_counts(value: P140VChecked) -> List<&2,U32>:
  match value:
    case P140VChecked{cache,ids,static_ok,error,counts}: counts

def p140vt_empty(value: P140VCache) -> Bool:
  match value:
    case P140VEmpty{}: True{}
    case P140VCache{program}: False{}

def p140vt_opened(value: P140VOpened) -> P114SBoundary:
  match value:
    case P140VOpened{boundary,cache,counts}: boundary

def p140vt_array_error(value: P140VArrayChecked) -> String:
  match value:
    case P140VArrayChecked{cache,error,counts}: error

@unsafe
def p140vt_equal(+old: P113DProgram, +now: P113DProgram) -> Bool:
  String.eq(p113e_verify(now),p140vt_error(p140v_check(now,p140vt_cache(p140v_check(old,P140VEmpty{})))))

@unsafe
def p140vt_open_equal(+old: P113DProgram, +now: P113DProgram) -> Bool:
  p134v_boundary_same(p114s_open(now),p140vt_opened(p140v_open(now,p140vt_cache(p140v_check(old,P140VEmpty{})))))

@unsafe
def p140vt_count_equal(+old: P113DProgram, +now: P113DProgram, counts: List<&2,U32>) -> Bool:
  p134v_list(U32,U32.is_eq,counts,p140vt_counts(p140v_check(now,p140vt_cache(p140v_check(old,P140VEmpty{})))))

def p140vt_program(body: List<&2,N111Stmt>, functions: List<&2,P113DFunction>) -> P113DProgram:
  P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,body}],[],[0],[],[],True{}},[]},functions}

def p140vt_bad_direct() -> P113DFunction:
  P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Local{"undefined"}]}]}

def p140vt_changed_direct() -> P113DFunction:
  P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{9,0}]}]}

@unsafe
def p140vt_controls() -> List<&2,String>:
  +plain = p114st_program(1)
  +changed = p140vt_program([N111Return{N111Const{9,0}}],[p114st_identity()])
  +badraw = p140vt_program([N111Return{N111Local{"undefined"}}],[p114st_identity()])
  +badfn = p140vt_program([N111Return{N111Const{0,0}}],[p140vt_bad_direct()])
  +newfn = p140vt_program([N111Return{N111Const{0,0}}],[p140vt_changed_direct()])
  +badboth = p140vt_program([N111Return{N111Local{"raw_missing"}}],[p140vt_bad_direct()])
  +badmain : P113DProgram = P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",1,1,0,0,[N111Return{N111Const{0,0}}]}],[],[],[],[],True{}},[]},[p114st_identity()]}
  +dupraw : P113DProgram = P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]},N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],[],[],[],[],True{}},[]},[]}
  +dupctor : P113DProgram = P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],[N_Constructor{"Dup",0,True{}},N_Constructor{"Dup",0,True{}}],[],[],[],True{}},[]},[]}
  +badimage : P113DProgram = P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],[],[],[],[],True{}},[P112SNode{0,"missing",[]}]},[p114st_identity()]}
  +arity : P113DFunction = P113DFunction{"p114_scalar",[],1,False{},[P113DResult{[N111Const{7,0}]}]}
  +callee : P113DFunction = P113DFunction{"p114_scalar",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{7,0}]}]}
  +forward : P113DProgram = P113DProgram{p114st_original(),[p114st_caller(),p114st_pair(),p114st_scalar()]}
  +public : P113DProgram = P113DProgram{p114st_original(),[P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,True{},[P113DResult{[N111Local{"a"}]}]}]}
  +array : P113AProgram = P113AProgram{changed,P113ACertificate{False{},False{}}}
  [p114st_row("v-cold-original",p140vt_equal(p114st_program(0),plain)),
   p114st_row("v-identical",p140vt_equal(plain,plain)),
   p114st_row("v-count-identical",p140vt_count_equal(plain,plain,[1,0,1,0])),
   p114st_row("v-valid-raw-edit",p140vt_equal(plain,changed)),
   p114st_row("v-count-raw-edit",p140vt_count_equal(plain,changed,[0,1,1,0])),
   p114st_row("v-invalid-raw-edit",p140vt_equal(plain,badraw)),
   p114st_row("v-valid-direct-edit",p140vt_equal(plain,newfn)),
   p114st_row("v-count-direct-edit",p140vt_count_equal(plain,newfn,[1,0,0,1])),
   p114st_row("v-invalid-direct-edit",p140vt_equal(plain,badfn)),
   p114st_row("v-first-error",p140vt_equal(plain,badboth)),
   p114st_row("v-main-header",p140vt_equal(plain,badmain)),
   p114st_row("v-duplicate-raw",p140vt_equal(plain,dupraw)),
   p114st_row("v-duplicate-constructor",p140vt_equal(plain,dupctor)),
   p114st_row("v-static-image-rechecked",p140vt_equal(plain,badimage)),
   p114st_row("v-callee-body-edit",p140vt_equal(p114st_program(2),P113DProgram{p114st_original(),[callee,p114st_pair(),p114st_caller()]})),
   p114st_row("v-callee-header-edit",p140vt_equal(p114st_program(2),P113DProgram{p114st_original(),[arity,p114st_pair(),p114st_caller()]})),
   p114st_row("v-forward-order",p140vt_equal(p114st_program(2),forward)),
   p114st_row("v-public-flag",p140vt_equal(plain,public)),
   p114st_row("v-invalid-cache-not-published",p140vt_empty(p140vt_cache(p140v_check(badfn,P140VEmpty{})))),
   p114st_row("v-invalid-prior-recomputed",p140vt_equal(badfn,plain)),
   p114st_row("v-open-valid",p140vt_open_equal(plain,changed)),
   p114st_row("v-open-invalid-raw",p140vt_open_equal(plain,badraw)),
   p114st_row("v-open-invalid-direct",p140vt_open_equal(plain,badfn)),
   p114st_row("v-array-wrapper",String.eq(p113a_verify(array),p140vt_array_error(p140v_array(array,p140vt_cache(p140v_check(plain,P140VEmpty{})))))),
   p114st_row("v-constant-highword",Bool.not(p140v_segment(N111Segment{"main",0,1,0,0,[N111Return{N111Const{1,0}}]},N111Segment{"main",0,1,0,0,[N111Return{N111Const{1,1}}]})))]
