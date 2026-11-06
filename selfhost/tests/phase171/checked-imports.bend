# Experimental late promotion only. All retained generic bodies stay present.
# Import authority is rederived from the checked original and frozen old workers.
# This file never overrides a maintained declaration or fabricates a function.

type P171Import is Data:
  P171Import{+source: String, +segment: N111Segment, +family: List<&2,N111Segment>, +plan: P114HPlan, +dependencies: List<&2,P113DFunction>, +rank: U32}

type P171Program is Data:
  P171Program{+base: P113DProgram, +adapters: KDef, +imports: List<&2,P171Import>, +added: List<&2,P113DFunction>, +error: String}

type P171Ready is Data:
  P171Ready{+index: KDef, +error: String}

law p171r_body:
  for a: List<&2,P114RStmt>
  for b: List<&2,P114RStmt>
  Bool

@unsafe
def p171r_stmt(a: P114RStmt, b: P114RStmt) -> Bool:
  match a b:
    case P114RScalar{x} P114RScalar{y}: p134v_scalar(x,y)
    case P114RIf{ac,ay,an} P114RIf{bc,by,bn}: p134v_value(ac,bc) && p171r_body(ay,by) && p171r_body(an,bn)
    case P114RDescend{af,aa} P114RDescend{bf,ba}: p134v_list(~N111Stmt,~p134v_scalar,af,bf) && p134v_list(~N111Stmt,~p134v_scalar,aa,ba)
    case P114RAgain{a} P114RAgain{b}: p134v_list(~N111Stmt,~p134v_scalar,a,b)
    case P114RResult{a} P114RResult{b}: p134v_value(a,b)
    case P114RFailure{a} P114RFailure{b}: p134v_list(~N111Stmt,~p134v_scalar,a,b)
    case P114RResumeReady{af,ac,ar} P114RResumeReady{bf,bc,br}:
      p134v_list(~N111Stmt,~p134v_scalar,af,bf) && p134v_list(~N111Stmt,~p134v_scalar,ac,bc) && p134v_value(ar,br)
    case _ _: False{}

@unsafe
def p171r_body(a,b):
  p134v_list(~P114RStmt,~p171r_stmt,a,b)

@unsafe
def p171r_case(a: P114HCase, b: P114HCase) -> Bool:
  match a b:
    case P114HCase{an,ac,ar,ap,ab} P114HCase{bn,bc,br,bp,bb}:
      String.eq(an,bn) && p140o_strings(ac,bc) && String.eq(ar,br) && String.eq(ap,bp) && p171r_body(ab,bb)

@unsafe
def p171r_plan(+a: P114HPlan, +b: P114HPlan) -> Bool:
  match a b:
    case P114HPlan{av,ap,ab,ac} P114HPlan{bv,bp,bb,bc}:
      p134v_bool(av,bv) && p140o_strings(ap,bp) && p171r_body(ab,bb) && p134v_list(~P114HCase,~p171r_case,ac,bc)

@unsafe
def p171i_case_found(+tail: List<&2,N111Segment>, +found: Maybe<&2,N111Segment>) -> List<&2,N111Segment>:
  match found:
    case Some{segment}: Con{segment,tail}
    case None{}: tail

@unsafe
def p171i_cases(+cases: List<&2,P114HCase>, +index: P112FusionIndex) -> List<&2,N111Segment>:
  match cases:
    case Nil{}: []
    case Con{P114HCase{name,captures,result,pop,body},rest}:
      p171i_case_found(p171i_cases(rest,index),p112f_index_get(index,name))

@unsafe
def p171i_family(+segment: N111Segment, +index: P112FusionIndex, +plan: P114HPlan) -> List<&2,N111Segment>:
  match plan:
    case P114HPlan{valid,params,body,cases}: Con{segment,p171i_cases(cases,index)}

@unsafe
def p171i_source(+book: List<&2,KDef>, +name: String, +bangs: List<&2,String>) -> Bool:
  +d = lookup(book,name)
  +arity = nd_arity(book,name)
  String.eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs,name)) &&
    U32.is_gt(arity,0) && U32.is_le(arity,8)

@unsafe
def p171i_planned(+source: String, +segment: N111Segment, +index: P112FusionIndex,
    +dependencies: List<&2,P113DFunction>, +plan: P114HPlan, +tail: List<&2,P171Import>) -> List<&2,P171Import>:
  nt_choose(List<&2,P171Import>,p114h_valid(plan),
    u => Con{P171Import{source,segment,p171i_family(segment,index,plan),plan,dependencies,1},tail},u => tail)

@unsafe
def p171i_found(+source: String, +index: P112FusionIndex, +dependencies: List<&2,P113DFunction>,
    +view: KDef, +tail: List<&2,P171Import>, +found: Maybe<&2,N111Segment>) -> List<&2,P171Import>:
  match found:
    case None{}: tail
    case Some{+segment}: p171i_planned(source,segment,index,dependencies,p114h_plan(segment,index,view),tail)

@unsafe
def p171i_collect(+book: List<&2,KDef>, +names: List<&2,String>, +bangs: List<&2,String>,
    +index: P112FusionIndex, +dependencies: List<&2,P113DFunction>, +view: KDef, +acc: List<&2,P171Import>) -> List<&2,P171Import>:
  match names:
    case Nil{}: nt_reverse(P171Import,acc,[])
    case Con{+name,rest}:
      p171i_collect(book,rest,bangs,index,dependencies,view,
        nt_choose(List<&2,P171Import>,p171i_source(book,name,bangs),
          u => p171i_found(name,index,dependencies,view,acc,p112f_index_get(index,p113d_public(book,name))),u => acc))

@unsafe
def p171i_signature(+segment: N111Segment) -> KDef:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      KDef{name,"P113Direct",arity,1,atom("Absent"),kt("P113Public","",0,0,[]),[],False{},False{}}

# This map is a producer proposal only. p171v_imports reconstructs authority.
@unsafe
def p171i_signatures(+imports: List<&2,P171Import>, +index: KDef) -> KDef:
  match imports:
    case Nil{}: index
    case Con{P171Import{source,segment,family,plan,dependencies,rank},rest}:
      p171i_signatures(rest,p113e_insert(index,p171i_signature(segment)))

@unsafe
def p171i_matches(+item: P171Import, +book: List<&2,KDef>, +bangs: List<&2,String>,
    +index: P112FusionIndex, +dependencies: List<&2,P113DFunction>, +view: KDef, +found: Maybe<&2,N111Segment>) -> Bool:
  match item found:
    case P171Import{+source,+segment,+family,+plan,old,rank} Some{+actual}:
      U32.is_eq(rank,1) && p171i_source(book,source,bangs) && p140v_segment(segment,actual) &&
      p134v_list(~P113DFunction,~p134v_function,dependencies,old) &&
      p114h_valid(plan) && p171r_plan(plan,p114h_plan(actual,index,view)) &&
      p134v_list(~N111Segment,~p140v_segment,family,p171i_family(actual,index,plan))
    case _ _: False{}

@unsafe
def p171i_valid(+item: P171Import, +book: List<&2,KDef>, +bangs: List<&2,String>,
    +index: P112FusionIndex, +dependencies: List<&2,P113DFunction>, +view: KDef) -> Bool:
  match item:
    case P171Import{+source,segment,family,plan,old,rank}:
      p171i_matches(item,book,bangs,index,dependencies,view,p112f_index_get(index,p113d_public(book,source)))

law p171v_imports:
  for imports: List<&2,P171Import>
  for +book: List<&2,KDef>
  for +bangs: List<&2,String>
  for +index: P112FusionIndex
  for +dependencies: List<&2,P113DFunction>
  for +view: KDef
  for ready: KDef
  P171Ready

@unsafe
def p171v_import_one(+item: P171Import, +rest: List<&2,P171Import>, +book: List<&2,KDef>,
    +bangs: List<&2,String>, +index: P112FusionIndex, +dependencies: List<&2,P113DFunction>, +view: KDef, +ready: KDef) -> P171Ready:
  match item:
    case P171Import{source,+segment,family,plan,old,rank}:
      +signature = p171i_signature(segment)
      nt_choose(P171Ready,String.eq(dk(p111v_get(ready,dn(signature))),"Absent") &&
        p171i_valid(item,book,bangs,index,dependencies,view),
        u => p171v_imports(rest,book,bangs,index,dependencies,view,p113e_insert(ready,signature)),
        u => P171Ready{ready,"frame import identity/family/plan/dependency/rank mismatch"})

@unsafe
def p171v_imports(imports,book,bangs,index,dependencies,view,ready):
  match imports:
    case Nil{}: P171Ready{ready,""}
    case Con{item,rest}: p171v_import_one(item,rest,book,bangs,index,dependencies,view,ready)

@unsafe
def p171v_projected(+ids: N111Ids, +ready: KDef, +workers: P118BWorkers) -> String:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(String,String.is_empty(error),u => p113e_functions(functions,ids,ready),u => error)

@unsafe
def p171v_ready(+added: List<&2,P113DFunction>, +ids: N111Ids, +checked: P171Ready) -> String:
  match checked:
    case P171Ready{ready,+error}:
      nt_choose(String,String.is_empty(error),
        u => p171v_projected(ids,ready,p118b_project_functions(added,ids)),u => error)

@unsafe
def p171v_view(+request: NR_Request, +base: P113DProgram, +imports: List<&2,P171Import>,
    +added: List<&2,P113DFunction>, +dependencies: List<&2,P113DFunction>, +error: String) -> String:
  match request base:
    case NR_Request{source,+book,+names,paths,scope,bound} P113DProgram{P112StaticProgram{+original,nodes},functions}:
      match original:
        case P111Program{+segments,constructors,show,show_names,effects,pure}:
          +ready = p113e_signatures(dependencies,missing())
          nt_choose(String,String.is_empty(error),u => p171v_ready(added,p114s_ids(P112StaticProgram{original,nodes}),
            p171v_imports(imports,book,nc_bangs_names(book,names),p112f_index(segments),dependencies,p124r_view(missing(),ready),ready)),u => error)

@unsafe
def p171v_base(+request: NR_Request, +program: P171Program, +error: String) -> String:
  match program:
    case P171Program{+base,+adapters,imports,added,old_error}:
      match base:
        case P113DProgram{P112StaticProgram{+original,nodes},functions}:
          +dependencies = p168v_functions(functions,adapters)
          nt_choose(String,String.is_empty(error),u =>
            p171v_view(request,base,imports,added,dependencies,p118b_verify_functions(dependencies,original)),u => error)

@unsafe
def p171_verify(+request: NR_Request, +program: P171Program) -> String:
  match request program:
    case NR_Request{source,+book,+names,paths,scope,bound} P171Program{+base,+adapters,imports,added,+error}:
      nt_choose(String,String.is_empty(error),u => p171v_base(request,program,
        p167ob_final(book,nc_bangs_names(book,names),adapters,base)),u => error)

@unsafe
def p171s_word(a: P112SWord, b: P112SWord) -> Bool:
  match a b:
    case P112SRaw{x} P112SRaw{y}: U32.is_eq(x,y)
    case P112SPacked{an,ap} P112SPacked{bn,bp}: String.eq(an,bn) && U32.is_eq(ap,bp)
    case P112SBox{an,ap} P112SBox{bn,bp}: String.eq(an,bn) && U32.is_eq(ap,bp)
    case _ _: False{}

@unsafe
def p171s_node(a: P112SNode, b: P112SNode) -> Bool:
  match a b:
    case P112SNode{ao,an,af} P112SNode{bo,bn,bf}:
      U32.is_eq(ao,bo) && String.eq(an,bn) && p134v_list(~P112SWord,~p171s_word,af,bf)

@unsafe
def p171b_candidates(+request: NR_Request, +base: P113DProgram, +adapters: KDef,
    +dependencies: List<&2,P113DFunction>, +imports: List<&2,P171Import>, +prepared: P112SPrepared) -> P171Program:
  match request base prepared:
    case NR_Request{source,old,+names,paths,scope,bound} P113DProgram{P112StaticProgram{original,old_nodes},functions} P112SPrepared{+book,nodes,+error}:
      +same = p134v_list(~P112SNode,~p171s_node,old_nodes,nodes)
      nt_choose(P171Program,String.is_empty(error) && same,u => P171Program{base,adapters,imports,
        p113d_passes(p126sc_candidates(p113pl_candidates(book,names,nc_bangs_names(book,names),book_cached(nq_signatures(book,names),0))),
          p171i_signatures(imports,p113e_signatures(dependencies,missing())),[],32),""},
        u => P171Program{base,adapters,[],[],nt_choose(String,String.is_empty(error),
          v => "frame late preparation: static image mismatch",v => error)})

@unsafe
def p171b_imported(+request: NR_Request, +base: P113DProgram, +adapters: KDef,
    +dependencies: List<&2,P113DFunction>, +imports: List<&2,P171Import>) -> P171Program:
  match request base:
    case NR_Request{source,+book,+names,paths,scope,bound} P113DProgram{P112StaticProgram{P111Program{segments,+constructors,show,show_names,effects,pure},nodes},functions}:
      p171b_candidates(request,base,adapters,dependencies,imports,p112s_prepare(book,names,constructors))

@unsafe
def p171b_view(+request: NR_Request, +base: P113DProgram, +adapters: KDef,
    +dependencies: List<&2,P113DFunction>, +error: String) -> P171Program:
  match request base:
    case NR_Request{source,+book,+names,paths,scope,bound} P113DProgram{P112StaticProgram{P111Program{+segments,constructors,show,show_names,effects,pure},nodes},functions}:
      nt_choose(P171Program,String.is_empty(error),u => p171b_imported(request,base,adapters,dependencies,
        p171i_collect(book,names,nc_bangs_names(book,names),p112f_index(segments),dependencies,
          p124r_view(missing(),p113e_signatures(dependencies,missing())),[])),
        u => P171Program{base,adapters,[],[],error})

@unsafe
def p171b_base(+request: NR_Request, +base: P113DProgram, +adapters: KDef, +error: String) -> P171Program:
  match base:
    case P113DProgram{P112StaticProgram{+original,nodes},functions}:
      +dependencies = p168v_functions(functions,adapters)
      nt_choose(P171Program,String.is_empty(error),u => p171b_view(request,base,adapters,dependencies,
        p118b_verify_functions(dependencies,original)),u => P171Program{base,adapters,[],[],error})

@unsafe
def p171b_lowered(+request: NR_Request, +lowered: P167Lowered) -> P171Program:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+base,+adapters,+error,stats}:
      nt_choose(P171Program,String.is_empty(error),u =>
        p171b_base(request,base,adapters,p167ob_final(book,nc_bangs_names(book,names),adapters,base)),
        u => P171Program{base,adapters,[],[],error})

@unsafe
def p171_request(+request: NR_Request) -> P171Program:
  p171b_lowered(request,p168_request_mode(1,request))
