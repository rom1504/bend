# Candidate-first, scheduler-on-demand prototype. No generic region registry,
# borrowed retry pipeline, or fictitious original body. Final checks/emission
# belong to demand-verify/emit.bend. The input must be a checked NR_Request.

@unsafe
def p167l_fail(error: String) -> P167Lowered:
  P167Lowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},missing(),error,[]}

@unsafe
def p167l_mark(+index: KDef, name: String) -> KDef:
  p113e_insert(index,KDef{name,"P167Seen",0,0,atom("Absent"),atom("Absent"),[],False{},False{}})

@unsafe
def p167l_demand(+name: String, demand: P167Demand) -> P167Demand:
  match demand:
    case P167Demand{+todo,+asked,+count}:
      nt_choose(P167Demand,String.eq(dk(p111v_get(asked,name)),"Absent"),
        u => P167Demand{Con{name,todo},p167l_mark(asked,name),U32.inc(count)},
        u => P167Demand{todo,asked,count})

@unsafe
def p167l_value(value: N111Value, demand: P167Demand) -> P167Demand:
  match value:
    case N111FuncId{name}: p167l_demand(name,demand)
    case _: demand

@unsafe
def p167l_values(values: List<&2,N111Value>, demand: P167Demand) -> P167Demand:
  match values:
    case Nil{}: demand
    case Con{head,rest}: p167l_values(rest,p167l_value(head,demand))

@unsafe
def p167l_args(args: List<&2,N111Arg>, demand: P167Demand) -> P167Demand:
  match args:
    case Nil{}: demand
    case Con{N111Arg{typ,value},rest}: p167l_args(rest,p167l_value(value,demand))

@unsafe
def p167l_stmts(body: List<&2,N111Stmt>, demand: P167Demand) -> P167Demand:
  match body:
    case Nil{}: demand
    case Con{head,rest}: p167l_stmts(rest,p167l_stmt(head,demand))

@unsafe
def p167l_stmt(stmt: N111Stmt, demand: P167Demand) -> P167Demand:
  match stmt:
    case N111Set{name,typ,value}: p167l_value(value,demand)
    case N111Bin{name,typ,op,left,right}: p167l_value(right,p167l_value(left,demand))
    case N111Call{name,typ,symbol,args}: p167l_args(args,demand)
    case N111If{condition,yes,no}: p167l_stmts(no,p167l_stmts(yes,p167l_value(condition,demand)))
    case N111Return{value}: p167l_value(value,demand)
    case N111Load{name,typ,base,offset}: p167l_value(base,demand)
    case N111Store{typ,base,offset,value}: p167l_value(value,p167l_value(base,demand))
    case N111Offset{name,base,bytes}: p167l_value(bytes,p167l_value(base,demand))
    case N111Alloca{name,bytes,align}: demand

@unsafe
def p167l_direct(body: List<&2,P113DStmt>, demand: P167Demand) -> P167Demand:
  match body:
    case Nil{}: demand
    case Con{head,rest}: p167l_direct(rest,p167l_direct_stmt(head,demand))

@unsafe
def p167l_direct_stmt(stmt: P113DStmt, demand: P167Demand) -> P167Demand:
  match stmt:
    case P113DScalar{scalar}: p167l_stmt(scalar,demand)
    case P113DIf{condition,yes,no}: p167l_direct(no,p167l_direct(yes,p167l_value(condition,demand)))
    case P113DCall{destinations,target,args}: p167l_values(args,demand)
    case P113DResult{values}: p167l_values(values,demand)
    case P113DAgain{values}: p167l_values(values,demand)

@unsafe
def p167l_function_demands(functions: List<&2,P113DFunction>, demand: P167Demand) -> P167Demand:
  match functions:
    case Nil{}: demand
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p167l_function_demands(rest,p167l_direct(body,demand))

# Static P112SWord is Raw/Packed/Box, and contains no function-ID variant.
# Every node is retained and independently checked against the actual schema.
@unsafe
def p167l_segment_demands(segments: List<&2,N111Segment>, demand: P167Demand) -> P167Demand:
  match segments:
    case Nil{}: demand
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p167l_segment_demands(rest,p167l_stmts(body,demand))

@unsafe
def p167l_present(segments: List<&2,N111Segment>, present: KDef) -> KDef:
  match segments:
    case Nil{}: present
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p167l_present(rest,p167l_mark(present,name))

@unsafe
def p167l_private(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Con{P113DFunction{name,params,result,False{},body},p167l_private(rest)}

# Catalogue records bind exact identities to source declarations. dx is proposed
# adapter eligibility, never a verifier certificate. No symbol is decoded.
@unsafe
def p167l_catalogue_put(+name: String, +source: String, +kind: String, +arity: U32,
    +allowed: Bool, catalogue: P167Catalogue) -> P167Catalogue:
  match catalogue:
    case P167Catalogue{+index,+error}:
      +old = p111v_get(index,name)
      nt_choose(P167Catalogue,Bool.not(String.is_empty(error)),u => P167Catalogue{index,error},u =>
        nt_choose(P167Catalogue,String.eq(dk(old),"Absent"),
          v => P167Catalogue{p113e_insert(index,KDef{name,kind,arity,Bool.to_u32(allowed),ref(source),atom("Absent"),[],False{},False{}}),""},
          v => nt_choose(P167Catalogue,String.eq(dk(old),kind) && String.eq(nm(dt(old)),source) && U32.is_eq(da(old),arity),
            w => P167Catalogue{index,""},w => P167Catalogue{index,"demand: conflicting scheduled identity " ++ name})))

@unsafe
def p167l_catalogue(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>,
    +ready: KDef, catalogue: P167Catalogue) -> P167Catalogue:
  match names:
    case Nil{}: catalogue
    case Con{+name,rest}:
      p167l_catalogue(book,rest,bangs,ready,
        p167l_catalogue_name(book,name,bangs,ready,catalogue))

@unsafe
def p167l_catalogue_name(+book: List<&2,KDef>, +name: String, +bangs: List<&2,String>,
    +ready: KDef, +catalogue: P167Catalogue) -> P167Catalogue:
  +arity = nd_arity(book,name)
  +allowed = p164a_allowed(book,name,bangs,ready)
  +worker = p167l_catalogue_put(p113d_public(book,name),name,"P167Worker",arity,allowed,catalogue)
  nt_choose(P167Catalogue,U32.is_eq(arity,0),u => worker,
    u => p167l_catalogue_put(nc_ref_name(book,name),name,"P167Factory",arity,allowed,worker))

# Exactly the original source factory branch, without p111_extend. Its real
# continuations are retained. No dummy base is passed to any checker or emitter.
@unsafe
def p167l_factory(+book: List<&2,KDef>, +source: String, +n: U32, +arity: U32) -> P111Code:
  +definition = lookup(book,source)
  +typed = jd_live_arity(book,dt(definition),jd_arity(book,definition))
  +params = nd_entry_params(arity,U32.add(n,1024))
  nt_choose(P111Code,U32.is_gt(typed,0) && U32.is_eq(typed,arity),
    u => p111_lower(book,nd_eta_body(params,kt("NCall",nd_name(nc_ref_name(book,source)),0,0,nd_entry_args(params))),[],U32.add(U32.add(n,1024),arity)),
    u => p111_lower(book,nc_compact_definition(book,definition,n),[],U32.add(n,1024)))

@unsafe
def p167l_family(+book: List<&2,KDef>, +source: String, +n: U32, +bangs: List<&2,String>) -> P111Code:
  p111_entry(book,nc_compact_definition(book,lookup(book,source),n),source,U32.add(n,1024),nb_contains(bangs,source))

@unsafe
def p167l_accept(+context: P167Context, +segments: List<&2,N111Segment>, +fresh: U32,
    +pending: P167Demand, built: P167Built, +kind: U32, +source: String, +owner: String,
    +arity: U32, +error: String) -> P167Built:
  match built:
    case P167Built{+acc,+present,+adapters,oldfresh,+families,+factories,+wrappers,demands,old_error}:
      nt_choose(P167Built,String.is_empty(error),
        u => p167l_loop(context,p167l_segment_demands(segments,pending),
          P167Built{nt_reverse(N111Segment,segments,acc),p167l_present(segments,present),
            nt_choose(KDef,U32.is_eq(kind,2),v => p164a_put(adapters,source,owner,arity),v => adapters),
            fresh,U32.add(families,Bool.to_u32(U32.is_eq(kind,0))),
            U32.add(factories,Bool.to_u32(U32.is_eq(kind,1))),
            U32.add(wrappers,Bool.to_u32(U32.is_eq(kind,2))),0,""}),
        u => P167Built{acc,present,adapters,fresh,families,factories,wrappers,0,error})

@unsafe
def p167l_code(+context: P167Context, +source: String, +owner: String, +arity: U32,
    +kind: U32, pending: P167Demand, built: P167Built, code: P111Code) -> P167Built:
  match context code:
    case P167Context{+book,catalogue,+bangs} P111Code{body,segments,fresh,error}:
      p167l_accept(context,p111_mark_segments(
        Con{p111_segment(nc_ref_name(book,source),[],0,0,body),segments},
        nb_contains(bangs,source)),fresh,pending,built,kind,source,owner,arity,error)

@unsafe
def p167l_dispatch(+context: P167Context, +entry: KDef, +pending: P167Demand,
    +built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{+book,catalogue,+bangs}:
      +source = nm(dt(entry))
      +owner = p113d_public(book,source)
      nt_choose(P167Built,U32.is_eq(dx(entry),0),
        u => p167l_code(context,source,owner,da(entry),0,pending,built,p167l_family(book,source,fresh,bangs)),
        u => nt_choose(P167Built,String.eq(dk(entry),"P167Factory"),
          v => p167l_code(context,source,owner,da(entry),1,pending,built,p167l_factory(book,source,fresh,da(entry))),
          v => p167l_accept(context,[p164a_segment(owner,da(entry))],fresh,pending,built,2,source,owner,da(entry),"")))

@unsafe
def p167l_take(+context: P167Context, +name: String, +pending: P167Demand, +built: P167Built) -> P167Built:
  match context built:
    case P167Context{book,+catalogue,bangs}
         P167Built{+segments,+present,+adapters,+fresh,+families,+factories,+wrappers,+demands,+error}:
      +entry = p111v_get(catalogue,name)
      nt_choose(P167Built,Bool.not(String.is_empty(error)),u => built,u =>
        nt_choose(P167Built,Bool.not(String.eq(dk(p111v_get(present,name)),"Absent")),
          v => p167l_loop(context,pending,built),v =>
          nt_choose(P167Built,String.eq(dk(entry),"Absent"),
            w => P167Built{segments,present,adapters,fresh,families,factories,wrappers,demands,"demand: unknown scheduled identity " ++ name},
            w => p167l_dispatch(context,entry,pending,built,fresh))))

@unsafe
def p167l_loop(+context: P167Context, pending: P167Demand, built: P167Built) -> P167Built:
  match pending:
    case P167Demand{Nil{},asked,count}: p167l_complete(built,count)
    case P167Demand{Con{name,rest},asked,count}:
      p167l_take(context,name,P167Demand{rest,asked,count},built)

def p167l_complete(built: P167Built, demands: U32) -> P167Built:
  match built:
    case P167Built{segments,present,adapters,fresh,families,factories,wrappers,old_demands,error}:
      P167Built{segments,present,adapters,fresh,families,factories,wrappers,demands,error}

@unsafe
def p167l_finish(+source: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, built: P167Built) -> P167Lowered:
  match built:
    case P167Built{+segments,present,adapters,fresh,families,factories,wrappers,demands,+error}:
      p167l_finished(nodes,functions,adapters,
        [nt_count(String,names),nt_count(P113DFunction,functions),families,factories,wrappers,nt_count(N111Segment,segments),demands],
        p140or_finish(source,names,constructors,P111Book{nt_reverse(N111Segment,segments,[]),fresh,error}))

def p167l_finished(nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>, adapters: KDef,
    stats: List<&2,U32>, result: P111Result) -> P167Lowered:
  match result:
    case P111Result{program,error}: P167Lowered{P113DProgram{P112StaticProgram{program,nodes},functions},adapters,error,stats}

@unsafe
def p167l_catalogued(+source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +functions: List<&2,P113DFunction>, catalogue: P167Catalogue) -> P167Lowered:
  match catalogue:
    case P167Catalogue{index,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p167l_finish(source,names,constructors,nodes,functions,
          p167l_loop(P167Context{book,index,bangs},
            p167l_demand(nc_ref_name(book,"main"),p167l_function_demands(functions,P167Demand{[],missing(),0})),
            P167Built{[],missing(),missing(),0,0,0,0,0,""})),
        u => p167l_fail(error))

@unsafe
def p167l_functions(+source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +functions: List<&2,P113DFunction>) -> P167Lowered:
  p167l_catalogued(source,book,names,constructors,nodes,bangs,p167l_private(functions),
    p167l_catalogue(book,names,bangs,p113e_signatures(functions,missing()),P167Catalogue{missing(),""}))

@unsafe
def p167l_candidates(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +mode: U32, raw: List<&2,P113DCandidate>) -> P167Lowered:
  p167l_optimized(source,book,names,constructors,nodes,bangs,mode,
    p113d_passes(p126sc_candidates(raw),missing(),[],32))

@unsafe
def p167l_optimized(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +mode: U32, +functions: List<&2,P113DFunction>) -> P167Lowered:
  p167l_functions(source,book,names,constructors,nodes,bangs,
    nt_choose(List<&2,P113DFunction>,U32.is_eq(mode,1),
      u => p113i_functions(functions,P113IEmpty{},[]),u => functions))

@unsafe
def p167l_prepared(source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>,
    mode: U32, prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P167Lowered,String.is_empty(error),
        u => p167l_candidates(source,book,names,constructors,nodes,bangs,mode,
          p113pl_candidates(book,names,bangs,book_cached(nq_signatures(book,names),0))),
        u => p167l_fail("demand static preparation: " ++ error))

@unsafe
def p167l_cold(+constructors: List<&2,N_Constructor>, plan: P118CPlan) -> List<&2,N_Constructor>:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}:
      nt_choose(List<&2,N_Constructor>,valid && String.is_empty(error),
        u => p118c_ctors(constructors,cold),u => constructors)

@unsafe
def p167l_start(+request: NR_Request, +mode: U32, +constructors: List<&2,N_Constructor>) -> P167Lowered:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      +selected = nt_choose(List<&2,N_Constructor>,U32.is_eq(mode,1),
        u => p167l_cold(constructors,p118c_plan(request)),u => constructors)
      p167l_prepared(source,names,selected,mode,p112s_prepare(book,names,selected))

@unsafe
def p167l_request(+request: NR_Request, +mode: U32) -> P167Lowered:
  match request:
    case NR_Request{+source,+book,names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P167Lowered,U32.is_gt(mode,1),u => p167l_fail("demand mode must be 0 or 1"),u =>
        nt_choose(P167Lowered,String.is_empty(error),
          v => p167l_start(request,mode,nc_add_ctors(nc_default_ctors(),
            p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
          v => p167l_fail("demand request: " ++ error)))
