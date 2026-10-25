# Exact caller rewrites and one static comparator family.
# See contract-v01.json; unchanged protected final verifiers remain external.

@unsafe
def p134v_list(~A: Data, ~eq: A -> A -> Bool, a: List<&2,A>, b: List<&2,A>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: eq(x,y) && p134v_list(~A,~eq,xs,ys)
    case _ _: False{}

@unsafe
def p134v_scalar(a: N111Stmt, b: N111Stmt) -> Bool:
  match a b:
    case N111Set{an,at,av} N111Set{bn,bt,bv}: String.eq(an,bn) && p134v_type(at,bt) && p134v_value(av,bv)
    case N111Bin{an,at,ao,al,ar} N111Bin{bn,bt,bo,bl,br}:
      String.eq(an,bn) && p134v_type(at,bt) && String.eq(ao,bo) && p134v_value(al,bl) && p134v_value(ar,br)
    case N111Call{an,at,as,aa} N111Call{bn,bt,bs,ba}:
      String.eq(an,bn) && p134v_type(at,bt) && String.eq(as,bs) && p134v_list(~N111Arg,~p134v_arg,aa,ba)
    case N111If{ac,ay,an} N111If{bc,by,bn}:
      p134v_value(ac,bc) && p134v_list(~N111Stmt,~p134v_scalar,ay,by) && p134v_list(~N111Stmt,~p134v_scalar,an,bn)
    case N111Return{av} N111Return{bv}: p134v_value(av,bv)
    case N111Load{an,at,ab,ao} N111Load{bn,bt,bb,bo}:
      String.eq(an,bn) && p134v_type(at,bt) && p134v_value(ab,bb) && U32.is_eq(ao,bo)
    case N111Store{at,ab,ao,av} N111Store{bt,bb,bo,bv}:
      p134v_type(at,bt) && p134v_value(ab,bb) && U32.is_eq(ao,bo) && p134v_value(av,bv)
    case N111Offset{an,ab,ax} N111Offset{bn,bb,bx}:
      String.eq(an,bn) && p134v_value(ab,bb) && p134v_value(ax,bx)
    case N111Alloca{an,ab,aa} N111Alloca{bn,bb,ba}: String.eq(an,bn) && U32.is_eq(ab,bb) && U32.is_eq(aa,ba)
    case _ _: False{}

@unsafe
def p134v_stmt(a: P113DStmt, b: P113DStmt) -> Bool:
  match a b:
    case P113DScalar{as} P113DScalar{bs}: p134v_scalar(as,bs)
    case P113DIf{ac,ay,an} P113DIf{bc,by,bn}:
      p134v_value(ac,bc) && p134v_list(~P113DStmt,~p134v_stmt,ay,by) && p134v_list(~P113DStmt,~p134v_stmt,an,bn)
    case P113DCall{ad,at,aa} P113DCall{bd,bt,ba}:
      p134v_list(~String,~String.eq,ad,bd) && String.eq(at,bt) && p134v_list(~N111Value,~p134v_value,aa,ba)
    case P113DResult{av} P113DResult{bv}: p134v_list(~N111Value,~p134v_value,av,bv)
    case P113DAgain{av} P113DAgain{bv}: p134v_list(~N111Value,~p134v_value,av,bv)
    case _ _: False{}

@unsafe
def p134v_header(a: P113DFunction, b: P113DFunction) -> Bool:
  match a b:
    case P113DFunction{an,ap,ar,au,ab} P113DFunction{bn,bp,br,bu,bb}:
      String.eq(an,bn) && p134v_list(~NC_Binding,~p134v_binding,ap,bp) && U32.is_eq(ar,br) && p134v_bool(au,bu)

@unsafe
def p134v_function(a: P113DFunction, b: P113DFunction) -> Bool:
  match a b:
    case P113DFunction{an,ap,ar,au,ab} P113DFunction{bn,bp,br,bu,bb}:
      String.eq(an,bn) && p134v_list(~NC_Binding,~p134v_binding,ap,bp) && U32.is_eq(ar,br) && p134v_bool(au,bu) && p134v_list(~P113DStmt,~p134v_stmt,ab,bb)

@unsafe
def p134v_commit(+boundary: P114SBoundary, +candidate: List<&2,P113DFunction>) -> P114SBoundary:
  match boundary:
    case P114SBoundary{+original,+ids,+functions,+valid}:
      nt_choose(P114SBoundary,valid,
        u => nt_choose(P114SBoundary,p134v_list(~P113DFunction,~p134v_header,functions,candidate),
          v => nt_choose(P114SBoundary,String.is_empty(p134v_check(functions,candidate,ids,missing())),
            w => P114SBoundary{original,ids,candidate,True{}},w => boundary),
          v => p114s_commit(boundary,candidate)),u => boundary)

@unsafe
def p134v_boundary_same(a: P114SBoundary, b: P114SBoundary) -> Bool:
  match a b:
    case P114SBoundary{ao,ai,af,av} P114SBoundary{bo,bi,bf,bv}:
      p134v_bool(av,bv) && p134v_list(~P113DFunction,~p134v_function,af,bf)

@unsafe
def p140sp_context(+book: List<&2,KDef>, names: List<&2,String>, +constructors: List<&2,N_Constructor>, +previous: P140SPCache, +blocked: KDef) -> P140SPResult:
  match previous:
    case P140SPCache{old,old_blocked,entries}:
      p140sp_finish(book,constructors,blocked,previous,
        p140sp_walk(book,blocked,names,entries,p140sp_policy(p134v_list(~N_Constructor,~p140v_ctor,old,constructors) && p140eq_def(old_blocked,blocked)),
          P112SDefs{[],P112SImage{0,[],missing(),""}},[],0,0,0,0))

@unsafe
def p140v_segment(a: N111Segment, b: N111Segment) -> Bool:
  match a b:
    case N111Segment{an,aa,ar,ai,af,ab} N111Segment{bn,ba,br,bi,bf,bb}:
      String.eq(an,bn) && U32.is_eq(aa,ba) && U32.is_eq(ar,br) && U32.is_eq(ai,bi) && U32.is_eq(af,bf) && p134v_list(~N111Stmt,~p134v_scalar,ab,bb)

@unsafe
def p140v_context(old: P112StaticProgram, current: P112StaticProgram) -> Bool:
  match old current:
    case P112StaticProgram{P111Program{os,oc,osh,osn,oe,op},on} P112StaticProgram{P111Program{ns,nc,nsh,nsn,ne,np},nn}:
      p134v_list(~N111Segment,~p140v_header,os,ns) && p134v_list(~N_Constructor,~p140v_ctor,oc,nc)

@unsafe
def p140v_reuse_context(old: P112StaticProgram, +of: List<&2,P113DFunction>, nf: List<&2,P113DFunction>, metadata: P140VMetadata, +same: Bool) -> P140VReuse:
  match old:
    case P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes}:
      P140VReuse{segments,of,same,same && p134v_list(~P113DFunction,~p134v_header,of,nf),nt_choose(Maybe<&2,P140VMetadata>,same,u => Some{metadata},u => None{})}

@unsafe
def p140v_direct_walk(old: List<&2,P113DFunction>, current: List<&2,P113DFunction>, +ids: N111Ids, +ready: KDef, +reuse: Bool, hits: U32, misses: U32) -> P140VWalk:
  match old current:
    case _ Nil{}: P140VWalk{"",hits,misses}
    case Nil{} Con{+head,rest}: p140v_direct_step([],head,rest,ids,ready,False{},hits,misses,False{})
    case Con{prior,tail} Con{+head,rest}: p140v_direct_step(tail,head,rest,ids,ready,reuse,hits,misses,reuse && p134v_function(prior,head))

@unsafe
def p140r_segment(a: N111Segment, b: N111Segment) -> Bool:
  match a b:
    case N111Segment{an,aa,ar,ai,af,ab} N111Segment{bn,ba,br,bi,bf,bb}:
      String.eq(an,bn) && U32.is_eq(aa,ba) && U32.is_eq(ar,br) &&
        U32.is_eq(ai,bi) && U32.is_eq(af,bf) && p134v_list(~N111Stmt,~p134v_scalar,ab,bb)

@unsafe
def p140r_worker(a: P112WorkerStmt, b: P112WorkerStmt) -> Bool:
  match a b:
    case P112WorkerScalar{x} P112WorkerScalar{y}: p134v_scalar(x,y)
    case P112WorkerIf{ac,ay,an} P112WorkerIf{bc,by,bn}:
      p134v_value(ac,bc) && p140er_workers(ay,by) && p140er_workers(an,bn)
    case P112WorkerAgain{} P112WorkerAgain{}: True{}
    case P112WorkerResult{} P112WorkerResult{}: True{}
    case P112WorkerCall{an,aa} P112WorkerCall{bn,ba}: String.eq(an,bn) && U32.is_eq(aa,ba)
    case _ _: False{}

@unsafe
def p140r_legacy(a: P112RegionEntry, b: P112RegionEntry) -> Bool:
  match a b:
    case P112RegionEntry{as,P112WorkerPlan{av,ac,ap,ab},ar,an} P112RegionEntry{bs,P112WorkerPlan{bv,bc,bp,bb},br,bn}:
      p140r_segment(as,bs) && p134v_bool(av,bv) && U32.is_eq(ac,bc) &&
        p134v_list(~String,~String.eq,ap,bp) && p140er_workers(ab,bb) &&
        U32.is_eq(ar,br) && U32.is_eq(an,bn)

@unsafe
def p140r_hit(cursor: P134Cursor, key: P140RKey) -> Bool:
  match cursor key:
    case P134Private{Con{head,rest},context,next} P140RPrivate{old}: p134v_function(head,old)
    case P134Public{Con{head,rest},P134Context{ids,index,direct,ready,view,lookups,heap,mode},next} P140RPublic{old,facts}:
      nt_choose(Bool,p140r_segment(head,old),u => p140r_facts_valid(facts,index),u => False{})
    case P134Legacy{Con{head,rest},context,next} P140RLegacy{old}: p140r_legacy(head,old)
    case P134Tables{Con{P111QData{name,alignment,exported,items},rest}} P140RHeader{on,oa,oe}:
      String.eq(name,on) && U32.is_eq(alignment,oa) && p134v_bool(exported,oe)
    case P134Data{Nil{},first,rest} P140RClose{}: True{}
    case P134Data{items,first,rest} P140RData{old,of}:
      p134v_bool(first,of) && p140er_data(p140r_take(items,128),old)
    case P134Main{} P140RMain{}: True{}
    case _ _: False{}

@unsafe
def p140gm_headers(a: P111Program, b: P111Program) -> Bool:
  match a b:
    case P111Program{aseg,ac,aw,an,ae,ap} P111Program{bs,bc,bw,bn,be,bp}:
      p134v_list(~N111Segment,~p140v_header,aseg,bs) && p134v_list(~N_Constructor,~p140v_ctor,ac,bc) &&
        p134v_list(~U32,~U32.is_eq,aw,bw) && p140o_strings(an,bn) && p140o_strings(ae,be) && p134v_bool(ap,bp)

@unsafe
def p140l_scan(+book: List<&2,KDef>, +names: List<&2,String>, original: List<&2,P113DFunction>, +previous: P140LCache) -> P140LResult:
  match previous:
    case P140LCache{+old,+edges,+reverse,old_names,old_specs,items}:
      +specs = nol_scalar_specs(book,book)
      +analysis = p140l_analyze(old,book,edges,reverse)
      p140l_context(book,names,specs,original,previous,analysis,p140oq_refresh(edges,reverse,analysis),
        p140o_strings(old_names,names) && p134v_list(~NO_Spec,~p140l_spec,old_specs,specs),items)

@unsafe
def p140l_hit(+book: List<&2,KDef>, +name: String, original: List<&2,P113DFunction>, allowed: Bool, dirty: KDef, item: P140LItem) -> Bool:
  match item:
    case P140LItem{old,plan,+mode,workers,fallback}:
      allowed && String.eq(name,old) && Bool.not(p140o_has(dirty,name)) &&
        nt_choose(Bool,U32.is_eq(mode,2),
          u => p134v_list(~P113DFunction,~p134v_function,fallback,p140l_fallback(original,p113d_public(book,name))),u => True{})

@unsafe
def p140lc_counts(result: P140LResult, hits: U32, misses: U32) -> Bool:
  match result:
    case P140LResult{scan,cache,stats}: p134v_list(~U32,~U32.is_eq,p140lc_pair(stats),[hits,misses])

@unsafe
def p140lc_controls() -> List<&2,String>:
  +hidden_a = p140lc_hidden_book(1,"H")
  +hidden_b = p140lc_hidden_book(1,"G")
  +hidden_cache = p140lc_cache(p140l_scan(hidden_a,["main"],[],p140l_empty()))
  +hidden_next = p140lc_cache(p140l_scan(hidden_b,["main"],[],hidden_cache))
  +global_a = p140lc_global_book("Hidden")
  +global_b = p140lc_global_book("Other")
  +global_cache = p140lc_cache(p140l_scan(global_a,["main"],[],p140l_empty()))
  +spec : NO_Spec = NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["A","B"]}
  +empty = missing()
  +name = p113d_public([],"f")
  +a = p140lc_function(name,1)
  +b = p140lc_function(name,2)
  +other = p140lc_function("unrelated",9)
  +none = p140lc_item("f",0,[])
  +scalar = p140lc_item("f",2,[a])
  +absent = p140lc_item("f",2,[])
  +book = p140lc_book(1)
  +names : List<&2,String> = ["main","leaf","other"]
  +cold = p140l_scan(book,names,[],p140l_empty())
  +prior = p140lc_cache(cold)
  [p114st_row("late-hidden-fact-reference-invalidates",p140lc_counts(p140l_scan(p140lc_hidden_book(2,"H"),["main"],[],hidden_cache),0,1)),
   p114st_row("late-hidden-fact-edit-invalidates",p140lc_counts(p140l_scan(hidden_b,["main"],[],hidden_cache),0,1)),
   p114st_row("late-hidden-fact-edge-removal-retained",p140lc_counts(p140l_scan(p140lc_hidden_book(2,"G"),["main"],[],hidden_next),1,0)),
   p114st_row("late-global-alias-changes-catalogue",Bool.not(p134v_list(~NO_Spec,~p140l_spec,nol_scalar_specs(global_a,global_a),nol_scalar_specs(global_b,global_b)))),
   p114st_row("late-global-alias-invalidates-unrelated-owner",p140lc_counts(p140l_scan(global_b,["main"],[],global_cache),0,1)),
   p114st_row("late-spec-identical",p140l_spec(spec,spec)),
   p114st_row("late-spec-key",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"other","ctor","Boxed",2},"Owner",["A","B"]}))),
   p114st_row("late-spec-ctor",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","other","Boxed",2},"Owner",["A","B"]}))),
   p114st_row("late-spec-storage",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Nullary",2},"Owner",["A","B"]}))),
   p114st_row("late-spec-width",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",1},"Owner",["A","B"]}))),
   p114st_row("late-spec-owner",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Other",["A","B"]}))),
   p114st_row("late-spec-type-order",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["B","A"]}))),
   p114st_row("late-spec-type-length",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["A"]}))),
   p114st_row("late-spec-type-name",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["A","C"]}))),
   p114st_row("late-refusal-reuses",p140l_hit([],"f",[],True{},empty,none)),
   p114st_row("late-unready-refuses",Bool.not(p140l_hit([],"f",[],False{},empty,none))),
   p114st_row("late-owner-name-refuses",Bool.not(p140l_hit([],"g",[],True{},empty,none))),
   p114st_row("late-dirty-refuses",Bool.not(p140l_hit([],"f",[],True{},p140lc_dirty("f"),none))),
   p114st_row("late-unrelated-dirty-reuses",p140l_hit([],"f",[],True{},p140lc_dirty("g"),none)),
   p114st_row("late-scalar-exact-fallback",p140l_hit([],"f",[a],True{},empty,scalar)),
   p114st_row("late-scalar-body-change",Bool.not(p140l_hit([],"f",[b],True{},empty,scalar))),
   p114st_row("late-scalar-missing-fallback",Bool.not(p140l_hit([],"f",[],True{},empty,scalar))),
   p114st_row("late-scalar-new-fallback",Bool.not(p140l_hit([],"f",[a],True{},empty,absent))),
   p114st_row("late-scalar-unchanged-absence",p140l_hit([],"f",[other],True{},empty,absent)),
   p114st_row("late-scalar-unrelated-body",p140l_hit([],"f",[other,a],True{},empty,scalar)),
   p114st_row("late-scalar-first-duplicate",p140l_hit([],"f",[a,b],True{},empty,scalar)),
   p114st_row("late-scalar-changed-first-duplicate",Bool.not(p140l_hit([],"f",[b,a],True{},empty,scalar))),
   p114st_row("late-cold-misses",p140lc_counts(cold,0,3)),
   p114st_row("late-same-book-hits",p140lc_counts(p140l_scan(book,names,[],prior),3,0)),
   p114st_row("late-transitive-body-edit",p140lc_counts(p140l_scan(p140lc_book(2),names,[],prior),1,2)),
   p114st_row("late-owner-order-refuses",p140lc_counts(p140l_scan(book,["leaf","main","other"],[],prior),0,3)),
   p114st_row("late-bound-change-refuses",p140lc_counts(p140l_scan(book_cached(p140o_plain(book),41),names,[],prior),0,3))]

@unsafe
def p140gmc_index(a: P112FusionIndex, b: P112FusionIndex) -> Bool:
  match a b:
    case P112FusionEmpty{} P112FusionEmpty{}: True{}
    case P112FusionLeaf{ah,ab} P112FusionLeaf{bh,bb}: U32.is_eq(ah,bh) && p134v_list(~N111Segment,~p140r_segment,ab,bb)
    case P112FusionNode{am,al,ar} P112FusionNode{bm,bl,br}: U32.is_eq(am,bm) && p140gmc_index(al,bl) && p140gmc_index(ar,br)
    case _ _: False{}

@unsafe
def p140cat_programs(+a: P111Program, +b: P111Program) -> Bool:
  match a b:
    case P111Program{aseg,c,s,n,e,p} P111Program{bseg,bc,bw,bn,be,bpure}:
      p140gm_headers(a,b) && p134v_list(~N111Segment,~p140r_segment,aseg,bseg)

@unsafe
def p140spc_checked(fresh: P112SPrepared, candidate: P140SPResult, counts: List<&2,U32>) -> Bool:
  match candidate:
    case P140SPResult{prepared,cache,stats}: p140spc_equal(fresh,prepared) && p134v_list(~U32,~U32.is_eq,stats,counts)

@unsafe
def p140vt_count_equal(+old: P113DProgram, +now: P113DProgram, counts: List<&2,U32>) -> Bool:
  p134v_list(~U32,~U32.is_eq,counts,p140vt_counts(p140v_check(now,p140vt_cache(p140v_check(old,P140VEmpty{})))))

def p141sf_expected(+row: U32, +column: U32, +alias: U32) -> Bool:
  U32.is_eq(row,column) || (U32.is_gt(alias,0) &&
    ((U32.is_eq(row,0) && U32.is_eq(column,alias)) ||
     (U32.is_eq(column,0) && U32.is_eq(row,alias))))

@unsafe
def p141sf_row(~A: Data, ~same: A -> A -> Bool, +a: A, bs: List<&2,A>, +row: U32, +column: U32, +alias: U32) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{b,rest}: p134v_bool(same(a,b),p141sf_expected(row,column,alias)) && p141sf_row(~A,~same,a,rest,row,U32.inc(column),alias)

@unsafe
def p141sf_matrix(~A: Data, ~same: A -> A -> Bool, as: List<&2,A>, +bs: List<&2,A>, +row: U32, +alias: U32) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p141sf_row(~A,~same,a,bs,row,0,alias) && p141sf_matrix(~A,~same,rest,bs,U32.inc(row),alias)

@unsafe
def p140tc_controls() -> List<&2,String>:
  [p128bs_control_row("typed-values-all-pairs",p141sf_matrix(~N111Value,~p134v_value,p140tc_values(),p140tc_values(),0,0)),
   p128bs_control_row("typed-args-all-pairs",p141sf_matrix(~N111Arg,~p134v_arg,p140tc_args(),p140tc_args(),0,0)),
   p128bs_control_row("typed-bindings-all-pairs",p141sf_matrix(~NC_Binding,~p134v_binding,p140tc_bindings(),p140tc_bindings(),0,0)),
   p128bs_control_row("typed-scalars-all-pairs",p141sf_matrix(~N111Stmt,~p134v_scalar,p140tc_scalars(),p140tc_scalars(),0,0)),
   p128bs_control_row("typed-stmts-all-pairs",p141sf_matrix(~P113DStmt,~p134v_stmt,p140tc_stmts(),p140tc_stmts(),0,0)),
   p128bs_control_row("typed-functions-all-pairs",p141sf_matrix(~P113DFunction,~p134v_function,p140tc_functions(),p140tc_functions(),0,0)),
   p128bs_control_row("typed-headers-all-pairs",p141sf_matrix(~P113DFunction,~p134v_header,p140tc_functions(),p140tc_functions(),0,4)),
   p128bs_control_row("typed-raw_headers-all-pairs",p141sf_matrix(~N111Segment,~p140v_header,p140tc_raw_headers(),p140tc_raw_headers(),0,6)),
   p128bs_control_row("typed-ctors-all-pairs",p141sf_matrix(~N_Constructor,~p140v_ctor,p140tc_ctors(),p140tc_ctors(),0,0)),
   p128bs_control_row("typed-values-list",p134v_list(~N111Value,~p134v_value,p140tc_values(),p140tc_values()) && Bool.not(p134v_list(~N111Value,~p134v_value,[],p140tc_values())) && Bool.not(p134v_list(~N111Value,~p134v_value,p140tc_values(),[])) && p134v_list(~N111Value,~p134v_value,[],[])),
   p128bs_control_row("typed-args-list",p134v_list(~N111Arg,~p134v_arg,p140tc_args(),p140tc_args()) && Bool.not(p134v_list(~N111Arg,~p134v_arg,[],p140tc_args())) && Bool.not(p134v_list(~N111Arg,~p134v_arg,p140tc_args(),[])) && p134v_list(~N111Arg,~p134v_arg,[],[])),
   p128bs_control_row("typed-bindings-list",p134v_list(~NC_Binding,~p134v_binding,p140tc_bindings(),p140tc_bindings()) && Bool.not(p134v_list(~NC_Binding,~p134v_binding,[],p140tc_bindings())) && Bool.not(p134v_list(~NC_Binding,~p134v_binding,p140tc_bindings(),[])) && p134v_list(~NC_Binding,~p134v_binding,[],[])),
   p128bs_control_row("typed-scalars-list",p134v_list(~N111Stmt,~p134v_scalar,p140tc_scalars(),p140tc_scalars()) && Bool.not(p134v_list(~N111Stmt,~p134v_scalar,[],p140tc_scalars())) && Bool.not(p134v_list(~N111Stmt,~p134v_scalar,p140tc_scalars(),[])) && p134v_list(~N111Stmt,~p134v_scalar,[],[])),
   p128bs_control_row("typed-stmts-list",p134v_list(~P113DStmt,~p134v_stmt,p140tc_stmts(),p140tc_stmts()) && Bool.not(p134v_list(~P113DStmt,~p134v_stmt,[],p140tc_stmts())) && Bool.not(p134v_list(~P113DStmt,~p134v_stmt,p140tc_stmts(),[])) && p134v_list(~P113DStmt,~p134v_stmt,[],[])),
   p128bs_control_row("typed-headers-list",p134v_list(~P113DFunction,~p134v_header,p140tc_functions(),p140tc_functions()) && Bool.not(p134v_list(~P113DFunction,~p134v_header,[],p140tc_functions())) && Bool.not(p134v_list(~P113DFunction,~p134v_header,p140tc_functions(),[])) && p134v_list(~P113DFunction,~p134v_header,[],[])),
   p128bs_control_row("typed-raw_headers-list",p134v_list(~N111Segment,~p140v_header,p140tc_raw_headers(),p140tc_raw_headers()) && Bool.not(p134v_list(~N111Segment,~p140v_header,[],p140tc_raw_headers())) && Bool.not(p134v_list(~N111Segment,~p140v_header,p140tc_raw_headers(),[])) && p134v_list(~N111Segment,~p140v_header,[],[])),
   p128bs_control_row("typed-ctors-list",p134v_list(~N_Constructor,~p140v_ctor,p140tc_ctors(),p140tc_ctors()) && Bool.not(p134v_list(~N_Constructor,~p140v_ctor,[],p140tc_ctors())) && Bool.not(p134v_list(~N_Constructor,~p140v_ctor,p140tc_ctors(),[])) && p134v_list(~N_Constructor,~p140v_ctor,[],[])),
   p128bs_control_row("typed-strings-list",p134v_list(~String,~String.eq,["a","b"],["a","b"]) && Bool.not(p134v_list(~String,~String.eq,["a","b"],["a","c"])) && Bool.not(p134v_list(~String,~String.eq,["a"],[])) && p134v_list(~String,~String.eq,[],[])),
   p128bs_control_row("typed-u32-list",p134v_list(~U32,~U32.is_eq,[0,1,4294967295],[0,1,4294967295]) && Bool.not(p134v_list(~U32,~U32.is_eq,[0,1],[0,2])) && Bool.not(p134v_list(~U32,~U32.is_eq,[],[0])) && p134v_list(~U32,~U32.is_eq,[],[]))]
